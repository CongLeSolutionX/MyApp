//
//  ManufacturedHousingLoansView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a unified loan, combining acquisition and performance data.
struct ManufacturedLoan: Identifiable, Decodable {
    var id = UUID()
    let loanIdentifier: String
    let acquisition: LoanAcquisition?
    let monthlyPerformances: [LoanPerformance]?
    
    // Initializer for fetching a specific loan by ID (combines acquisition and performance)
    init(from loan: Loan) {
        self.loanIdentifier = loan.acquisition?.loanIdentifier ?? "Unknown"
        self.acquisition = loan.acquisition
        self.monthlyPerformances = loan.monthlyPerformances
    }
    
    // Initializer for acquisition data
    init(from acquisition: LoanAcquisition) {
        self.loanIdentifier = acquisition.loanIdentifier
        self.acquisition = acquisition
        self.monthlyPerformances = nil
    }
    
    // Initializer for performance data
    init(from performance: LoanPerformance) {
        self.loanIdentifier = performance.loanIdentifier
        self.acquisition = nil
        self.monthlyPerformances = [performance]
    }
}


/// Represents the loan data as returned by the /v1/manufactured-housing-loans/{id} endpoint.
struct Loan: Decodable {
    let acquisition: LoanAcquisition?
    let monthlyPerformances: [LoanPerformance]?
}

/// Represents loan acquisition data.
struct LoanAcquisition: Decodable, Identifiable {
    var id = UUID()
    let loanIdentifier: String
    let channel: String?
    let sellerName: String?
    let originalInterestRate: Double?
    let originalUnpaidPrincipalBalance: Double?
    let originalLoanTerm: Int?
    let originationDate: String?
    let firstPaymentDate: String?
    let originalLoanToValue: Double?
    let originalCombinedLoanToValue: Double?
    let numberOfBorrowers: Int?
    let debtToIncomeRatio: Double?
    let borrowerCreditScore: Int?
    let firstTimeHomeBuyerIndicator: String?
    let loanPurpose: String?
    let propertyType: String?
    let numberOfUnits: Int?
    let occupancyStatus: String?
    let propertyGeographicalState: String?
    let zip3: String?
    let mortgageInsurancePercentage: Double?
    let productType: String?
    let coborrowerCreditScore: Int?
    let mortgageInsuranceType: Int?
    let relocationMortgageIndicator: String?
}

/// Represents loan performance data.
struct LoanPerformance: Decodable, Identifiable {
    var id = UUID()
    let loanIdentifier: String
    let monthlyReportingPeriod: String?
    let servicerName: String?
    let currentInterestRate: Double?
    let currentActualUpb: Double? // Renamed for clarity
    let loanAge: Int?
    let remainingMonthsToMaturity: Int?
    let adjustedRemainingMonthsToMaturity: Int?
    let maturityDate: String?
    let msa: Int? // Metropolitan Statistical Area
    let loanDelinquencyStatus: String?
    let modificationFlag: String?
    let zeroBalanceCode: String?
    let zeroBalanceEffectiveDate: String?
    let lastPaidInstallmentDate: String? // Consider Date type for stricter handling
    let foreclosureDate: String? // Consider Date type
    let dispositionDate: String? // Consider Date type
    let foreclosureCosts: Double?
    let propertyPreservationAndRepairCosts: Double?
    let assetRecoveryCosts: Double?
    let miscHoldingExpensesAndCredits: Double?
    let associatedTaxesForHoldingProperty: Double?
    let netSaleProceeds: Double?
    let creditEnhancementProceeds: Double?
    let repurchaseMakeWholeProceeds: Double?
    let otherForeclosureProceeds: Double?
    let nonInterestBearingUpb: Double?
    let principalForgivenessUpb: Double?
    let repurchaseMakeWholeProceedsFlag: String?
    let foreclosurePrincipalWriteOffAmount: Double?
    let servicingActivityIndicator: String?
}

// Hypermedia Models (for /acquisitions and /performance endpoints)
struct LoanAcquisitionHypermediaPage: Decodable {
    let _links: Links?
    let total: Int?
    let _embedded: LoanAcquisitionEmbedded?
}

struct LoanAcquisitionEmbedded: Decodable {
    let acquisitions: [LoanAcquisition]?
}

struct LoanPerformanceHypermediaPage: Decodable {
    let _links: Links?
    let total: Int?
    let _embedded: LoanPerformanceEmbedded?
}

struct LoanPerformanceEmbedded: Decodable {
    let performances: [LoanPerformance]? // Assuming 'performances' is the correct key.  Verify with API documentation.
}

struct Links: Decodable {
    let selfLink: Href?
    let results: Href?
    let next: Href?
    let previous: Href?
    
    private enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case results
        case next
        case previous
    }
}

struct Href: Decodable {
    let href: String?
}

// Optional Loan Specification Model
struct LoanSpecification : Encodable {
    let state: String?
    let zip3: String?
    let acquisitionYear: Int?
}

// MARK: - API Endpoints

/// Enumeration for API endpoints.
enum ManufacturedHousingLoansAPIEndpoint {
    case loanById(id: String)
    case acquisitions(page: String?)
    case acquisitionById(id: String)
    case performances(page: String?)
    case performanceById(id: String)
    
    
    var path: String {
        switch self {
        case .loanById(let id):
            return "/v1/manufactured-housing-loans/\(id)"
        case .acquisitions(let page):
            if let page = page {
                return "/v1/manufactured-housing-loans/acquisitions?page=\(page)"
            }
            return "/v1/manufactured-housing-loans/acquisitions"
        case .acquisitionById(let id):
            return "/v1/manufactured-housing-loans/\(id)/acquisition"
        case .performances(let page):
            if let page = page {
                return "/v1/manufactured-housing-loans/performance?page=\(page)"
            }
            return "/v1/manufactured-housing-loans/performance"
        case .performanceById(let id):
            return "/v1/manufactured-housing-loans/\(id)/performance"
        }
    }
}

// MARK: - API Errors

/// API error definition for common network / decoding failures.
enum ManufacturedHousingLoansAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case forbidden
    case notFound(String)
    case unknown(Error)
    case invalidPage
    
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
        case .forbidden:
            return "Forbidden. You do not have access to this data."
        case .notFound(let message):
            return "Not Found: \(message)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        case .invalidPage:
            return "The specified page number is invalid."
        }
    }
}

// MARK: - Authentication (Re-use from previous example, but shown for completeness)

struct ManufacturedHousingLoans_AuthCredentials {
    static let clientID = "clientIDKeyHere" // Replace with your actual Client ID
    static let clientSecret = "clientSecretKeyHere" // Replace with your actual Client Secret
}

struct ManufacturedHousingLoansAPI_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

/// Service responsible for fetching and decoding manufactured housing loan data.
final class ManufacturedHousingDataService: ObservableObject {
    @Published var loans: [ManufacturedLoan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.fanniemae.com" // From the OpenAPI spec.
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // Use the same token URL as before
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management (Re-used and improved from the previous example)
    
    private func getAccessToken(completion: @escaping (Result<String, ManufacturedHousingLoansAPIError>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }
        
        
        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let credentials = "\(ManufacturedHousingLoans_AuthCredentials.clientID):\(ManufacturedHousingLoans_AuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }
        
        
        print("Credentials (REMOVE THIS PRINT STATEMENT LATER): \(credentials)") // Temporary debugging
        
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }
        print("base64Credentials (REMOVE THIS LATER) : \(base64Credentials)")
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ManufacturedHousingLoansAPIError.requestFailed("Invalid HTTP Response received.")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw ManufacturedHousingLoansAPIError.authenticationFailed
                case 403:
                    throw ManufacturedHousingLoansAPIError.forbidden
                default:
                    let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                    throw ManufacturedHousingLoansAPIError.requestFailed("HTTP Status Code: \(httpResponse.statusCode), Response: \(responseString)")
                }
            }
            .decode(type: ManufacturedHousingLoansAPI_TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    let apiError: ManufacturedHousingLoansAPIError
                    if let err = error as? ManufacturedHousingLoansAPIError {
                        apiError = err
                    } else {
                        apiError = .unknown(error)
                    }
                    self?.handleError(apiError)
                    completion(.failure(apiError)) // Propagate the error
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                // Subtract a small buffer (e.g., 60 seconds) to account for potential network delays.
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in - 60))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    func fetchData(for endpoint: ManufacturedHousingLoansAPIEndpoint) {
        isLoading = true
        errorMessage = nil
        // Cancel any existing requests to avoid race conditions or unnecessary work.
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
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
    
    private func makeDataRequest(endpoint: ManufacturedHousingLoansAPIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Use standard Bearer token
        
        let publisher: AnyPublisher<any Decodable, Error>
        
        switch endpoint {
        case .loanById(let id):
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { try self.validateResponse(data: $0, response: $1) }
                .decode(type: Loan.self, decoder: JSONDecoder())
                .map { $0 as any Decodable }
                .eraseToAnyPublisher()
            
        case .acquisitions:
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { try self.validateResponse(data: $0, response: $1) }
                .decode(type: LoanAcquisitionHypermediaPage.self, decoder: JSONDecoder())
                .map { $0 as any Decodable }
                .eraseToAnyPublisher()
            
        case .acquisitionById(let id):
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { try self.validateResponse(data: $0, response: $1) }
                .decode(type: LoanAcquisition.self, decoder: JSONDecoder())
                .map { $0 as any Decodable }
                .eraseToAnyPublisher()
            
        case .performances:
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { try self.validateResponse(data: $0, response: $1) }
                .decode(type: LoanPerformanceHypermediaPage.self, decoder: JSONDecoder())
                .map { $0 as any Decodable }
                .eraseToAnyPublisher()
            
        case .performanceById(let id):
            publisher = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { try self.validateResponse(data: $0, response: $1) }
                .decode(type: [LoanPerformance].self, decoder: JSONDecoder())
                .map { $0 as any Decodable }
                .eraseToAnyPublisher()
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    let apiError: ManufacturedHousingLoansAPIError
                    if let err = error as? ManufacturedHousingLoansAPIError {
                        apiError = err
                    }else {
                        apiError = .unknown(error)
                    }
                    self.handleError(apiError) // Centralized error handling.
                }
            }, receiveValue: { [weak self] decodedData in
                guard let self = self else { return }
                self.processDecodedData(decodedData, for: endpoint)
            })
            .store(in: &cancellables)
    }
    
    /// Centralized response validation to reduce code duplication.
    private func validateResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ManufacturedHousingLoansAPIError.requestFailed("Invalid HTTP response")
        }
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 400:
            throw ManufacturedHousingLoansAPIError.invalidPage
        case 401:
            throw ManufacturedHousingLoansAPIError.authenticationFailed
        case 403:
            throw ManufacturedHousingLoansAPIError.forbidden
        case 404:
            let responseString = String(data: data, encoding: .utf8) ?? "Resource not found"
            throw ManufacturedHousingLoansAPIError.notFound(responseString)
        case 500:
            let responseString = String(data: data, encoding: .utf8) ?? "Internal Server Error"
            throw ManufacturedHousingLoansAPIError.requestFailed("Server Error: \(responseString)")
        default:
            let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ManufacturedHousingLoansAPIError.requestFailed("HTTP Status Code: \(httpResponse.statusCode), Response: \(responseString)")
        }
    }
    
    private func processDecodedData(_ data: Any, for endpoint: ManufacturedHousingLoansAPIEndpoint) {
        var newLoans: [ManufacturedLoan] = []
        
        // Remove duplicates by adding results into Set
        var uniqueLoanIdentifiers = Set<String>()
        
        switch endpoint {
        case .loanById(let id):
            if let loan = data as? Loan {
                let manufacturedLoan = ManufacturedLoan(from: loan)
                newLoans.append(manufacturedLoan)
            }
            
        case .acquisitions:
            if let acquisitionsPage = data as? LoanAcquisitionHypermediaPage,
               let acquisitions = acquisitionsPage._embedded?.acquisitions {
                for acquisition in acquisitions {
                    // Use Set to check the loanIdentifier to skip duplicates
                    if !uniqueLoanIdentifiers.contains(acquisition.loanIdentifier) {
                        let manufacturedLoan = ManufacturedLoan(from: acquisition)
                        newLoans.append(manufacturedLoan)
                        uniqueLoanIdentifiers.insert(acquisition.loanIdentifier)
                    }
                }
            }
            
        case .acquisitionById(let id):
            if let acquisition = data as? LoanAcquisition {
                if !uniqueLoanIdentifiers.contains(acquisition.loanIdentifier) {
                    let manufacturedLoan = ManufacturedLoan(from: acquisition)
                    newLoans.append(manufacturedLoan)
                    uniqueLoanIdentifiers.insert(acquisition.loanIdentifier)
                }
            }
            
        case .performances:
            if let performancesPage = data as? LoanPerformanceHypermediaPage,
               let performances = performancesPage._embedded?.performances {
                for performance in performances {
                    if !uniqueLoanIdentifiers.contains(performance.loanIdentifier) {
                        let manufacturedLoan = ManufacturedLoan(from: performance)
                        newLoans.append(manufacturedLoan)
                        uniqueLoanIdentifiers.insert(performance.loanIdentifier)
                    }
                }
            }
            
        case .performanceById(let id):
            if let performances = data as? [LoanPerformance] {
                for performance in performances {
                    if !uniqueLoanIdentifiers.contains(performance.loanIdentifier) {
                        let manufacturedLoan = ManufacturedLoan(from: performance)
                        newLoans.append(manufacturedLoan)
                        uniqueLoanIdentifiers.insert(performance.loanIdentifier)
                    }
                }
            }
        }
        // Replace to avoid the cases that there are some new updates to the existing values
        self.loans = newLoans
    }
    
    // MARK: - Error Handling (Centralized)
    
    private func handleError(_ error: ManufacturedHousingLoansAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log for debugging
    }
    
    func clearLocalData() {
        loans.removeAll()
    }
}

// MARK: - SwiftUI Views (Example)

struct ManufacturedHousingLoansView: View {
    @StateObject private var dataService = ManufacturedHousingDataService()
    @State private var loanIdInput: String = ""
    @State private var selectedEndpoint: Int = 0
    @State private var currentPage: String = "1"
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    Picker("Endpoint", selection: $selectedEndpoint) {
                        Text("Loan by ID").tag(0)
                        Text("Acquisitions").tag(1)
                        Text("Acquisition by ID").tag(2)
                        Text("Performances").tag(3)
                        Text("Performance by ID").tag(4)
                    }
                    
                    if selectedEndpoint == 0 || selectedEndpoint == 2 || selectedEndpoint == 4 {
                        TextField("Loan ID", text: $loanIdInput)
                            .keyboardType(.default)
                    }
                    
                    if selectedEndpoint == 1 || selectedEndpoint == 3 {
                        TextField("Page", text: $currentPage)
                            .keyboardType(.numberPad)
                    }
                    
                    
                    Button("Fetch Data") {
                        fetchSelectedData()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear Data", role: .destructive){
                        dataService.clearLocalData()
                    }
                }
                
                Section(header: Text("Loans")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.loans) { loan in
                            VStack(alignment: .leading) {
                                Text("Loan ID: \(loan.loanIdentifier)")
                                    .font(.headline)
                                if let acquisition = loan.acquisition {
                                    Text("Seller: \(acquisition.sellerName ?? "N/A")")
                                    Text("Original Rate: \(acquisition.originalInterestRate?.description ?? "N/A")")
                                }
                                if let performances = loan.monthlyPerformances, !performances.isEmpty {
                                    Text("Performance Records: \(performances.count)")
                                    // You can add more UI components for the performances here.
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manufactured Housing Loans")
        }
    }
    
    private func fetchSelectedData() {
        let endpoint: ManufacturedHousingLoansAPIEndpoint
        switch selectedEndpoint {
        case 0:
            endpoint = .loanById(id: loanIdInput)
        case 1:
            endpoint = .acquisitions(page: currentPage)
        case 2:
            endpoint = .acquisitionById(id: loanIdInput)
        case 3:
            endpoint = .performances(page: currentPage)
        case 4:
            endpoint = .performanceById(id: loanIdInput)
        default:
            return // Should not happen
        }
        dataService.fetchData(for: endpoint)
    }
}

// MARK: - Preview
struct ManufacturedHousingLoansView_Previews: PreviewProvider {
    static var previews: some View {
        ManufacturedHousingLoansView()
    }
}
