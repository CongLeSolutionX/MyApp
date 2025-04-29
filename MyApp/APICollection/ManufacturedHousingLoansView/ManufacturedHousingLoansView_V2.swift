//
//  ManufacturedHousingLoansView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import Combine

// MARK: - Data Models (Matching OpenAPI Specification)

// --- Top-Level Payloads ---

// For /v1/manufactured-housing-loans/{id}
struct Loan: Decodable, Identifiable {
    let id = UUID() // SwiftUI Identifiable
    let acquisition: LoanAcquisition?
    let monthlyPerformances: [LoanPerformance]?
    
    // Add coding keys if needed, seems direct mapping works based on spec
    private enum CodingKeys: String, CodingKey {
        case acquisition, monthlyPerformances
    }
    // We need a stable identifier from the data if possible, using acquisition's ID
    //var loanIdentifier: String? { acquisition?.loanIdentifier }
}

// --- Embedded & Pagination Structures ---

// Base Hypermedia Page Structure
struct HypermediaPage<T: Decodable>: Decodable {
    let _links: Links?
    let total: Int? // Total number of items across all pages
    let _embedded: Embedded<T>?
    
    // Custom CodingKeys if needed, appears direct mapping is okay
    private enum CodingKeys: String, CodingKey {
        case _links, total, _embedded
    }
}

// Structure for the _embedded part
struct Embedded<T: Decodable>: Decodable {
    // Use dynamic keys if the embedded array name changes, but spec shows fixed names
    let acquisitions: [T]? // For LoanAcquisitionHypermediaPage
    let performances: [T]? // Assuming this key for LoanPerformanceHypermediaPage
    
    // Handle potential variations in embedded key names if necessary
    private enum CodingKeys: String, CodingKey {
        case acquisitions, performances // List expected embedded keys
    }
    
    // Get the actual items regardless of the key name ("acquisitions" or "performances")
    var items: [T]? {
        acquisitions ?? performances
    }
}

// --- Core Data Structures ---

struct LoanAcquisition: Decodable, Identifiable, Hashable {
    let id: String // Use loanIdentifier as the primary ID
    let channel: String?
    let sellerName: String?
    let originalInterestRate: Double?
    let originalUnpaidPrincipalBalance: Double?
    let originalLoanTerm: Int?
    let originationDate: String? // Keep as String for simplicity unless date math needed
    let firstPaymentDate: String? // Keep as String
    let originalLoanToValue: Double?
    let originalCombinedLoanToValue: Double?
    let numberOfBorrowers: Int?
    let debtToIncomeRatio: Double?
    let borrowerCreditScore: Int?
    let firstTimeHomeBuyerIndicator: String? // Represents Y/N/U typically
    let loanPurpose: String?
    let propertyType: String?
    let numberOfUnits: Int?
    let occupancyStatus: String? // Represents P/I/S typically
    let propertyGeographicalState: String?
    let zip3: String?
    let mortgageInsurancePercentage: Double?
    let productType: String?
    let coborrowerCreditScore: Int?
    // mortgageInsuranceType seems to be Int in spec, map carefully if needed
    let mortgageInsuranceType: Int?
    // relocationMortgageIndicator likely Y/N
    let relocationMortgageIndicator: String?
    
    // Explicit CodingKeys mapping JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id = "loanIdentifier" // Map JSON 'loanIdentifier' to Swift 'id'
        case channel, sellerName, originalInterestRate, originalUnpaidPrincipalBalance
        case originalLoanTerm, originationDate, firstPaymentDate, originalLoanToValue
        case originalCombinedLoanToValue, numberOfBorrowers, debtToIncomeRatio
        case borrowerCreditScore, firstTimeHomeBuyerIndicator, loanPurpose, propertyType
        case numberOfUnits, occupancyStatus, propertyGeographicalState, zip3
        case mortgageInsurancePercentage, productType, coborrowerCreditScore
        case mortgageInsuranceType, relocationMortgageIndicator
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: LoanAcquisition, rhs: LoanAcquisition) -> Bool {
        lhs.id == rhs.id
    }
}

struct LoanPerformance: Decodable, Identifiable, Hashable {
    let id = UUID() // Need a unique ID for SwiftUI List items within a loan's history
    let loanIdentifier: String?
    let monthlyReportingPeriod: String? // Keep as String (e.g., "YYYYMM") or Date
    let servicerName: String?
    let currentInterestRate: Double?
    let currentActualUpb: Double? // Unpaid Principal Balance
    let loanAge: Int?
    let remainingMonthsToMaturity: Int?
    let adjustedRemainingMonthsToMaturity: Int?
    let maturityDate: String? // Keep as String
    let msa: Int? // Metropolitan Statistical Area
    let loanDelinquencyStatus: String? // Could be 'X', '0', '1', etc.
    let modificationFlag: String? // Likely Y/N
    let zeroBalanceCode: String? // Represents reason for payoff/removal
    let zeroBalanceEffectiveDate: String? // Keep as String
    let lastPaidInstallmentDate: String? // Keep as String or Date
    let foreclosureDate: String? // Keep as String or Date
    let dispositionDate: String? // Keep as String or Date
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
    let repurchaseMakeWholeProceedsFlag: String? // Likely Y/N
    let foreclosurePrincipalWriteOffAmount: Double?
    let servicingActivityIndicator: String? // Likely Y/N
    
    // Custom Hashable implementation using key fields
    func hash(into hasher: inout Hasher) {
        hasher.combine(loanIdentifier)
        hasher.combine(monthlyReportingPeriod)
    }
    
    // Custom Equatable implementation
    static func == (lhs: LoanPerformance, rhs: LoanPerformance) -> Bool {
        return lhs.loanIdentifier == rhs.loanIdentifier &&
        lhs.monthlyReportingPeriod == rhs.monthlyReportingPeriod
    }
    
    // Explicit CodingKeys mapping
    enum CodingKeys: String, CodingKey {
        case loanIdentifier, monthlyReportingPeriod, servicerName, currentInterestRate, currentActualUpb, loanAge
        case remainingMonthsToMaturity, adjustedRemainingMonthsToMaturity, maturityDate, msa, loanDelinquencyStatus
        case modificationFlag, zeroBalanceCode, zeroBalanceEffectiveDate, lastPaidInstallmentDate, foreclosureDate
        case dispositionDate, foreclosureCosts, propertyPreservationAndRepairCosts, assetRecoveryCosts
        case miscHoldingExpensesAndCredits, associatedTaxesForHoldingProperty, netSaleProceeds, creditEnhancementProceeds
        case repurchaseMakeWholeProceeds, otherForeclosureProceeds, nonInterestBearingUpb, principalForgivenessUpb
        case repurchaseMakeWholeProceedsFlag, foreclosurePrincipalWriteOffAmount, servicingActivityIndicator
    }
}

// --- Links and Href Structures (for HATEOAS pagination) ---

struct Links: Decodable {
    let `self`: Href? // Use backticks for reserved keyword
    let results: Href?
    let next: Href?
    let previous: Href?
}

struct Href: Decodable {
    let href: String?
}

// --- Pagination Info Structure ---
struct PaginationInfo {
    var totalItems: Int = 0
    var currentPage: Int = 1 // Track current page number locally
    var itemsPerPage: Int = 20 // Assuming a default, API might dictate this
    var nextURL: URL?
    var previousURL: URL?
    var selfURL: URL?
    var resultsURL: URL?
    
    var totalPages: Int {
        guard itemsPerPage > 0 else { return 0 }
        return (totalItems + itemsPerPage - 1) / itemsPerPage // Ceiling division
    }
}

// MARK: - API Endpoints Enum

enum ManufacturedHousingAPIEndpoint {
    case loanById(id: String)
    case allAcquisitions(page: Int = 1) // Default to page 1
    case acquisitionById(id: String)
    case allPerformance(page: Int = 1) // Default to page 1
    case performanceById(id: String)
    case pagedURL(url: URL) // For handling next/previous links
    
    func url(baseURL: String) -> URL? {
        switch self {
        case .loanById(let id):
            return URL(string: "\(baseURL)/v1/manufactured-housing-loans/\(id)")
        case .allAcquisitions(let page):
            // Ensure page >= 1
            let validPage = max(1, page)
            return URL(string: "\(baseURL)/v1/manufactured-housing-loans/acquisitions?page=\(validPage)")
        case .acquisitionById(let id):
            return URL(string: "\(baseURL)/v1/manufactured-housing-loans/\(id)/acquisition")
        case .allPerformance(let page):
            // Ensure page >= 1
            let validPage = max(1, page)
            return URL(string: "\(baseURL)/v1/manufactured-housing-loans/performance?page=\(validPage)")
        case .performanceById(let id):
            return URL(string: "\(baseURL)/v1/manufactured-housing-loans/\(id)/performance")
        case .pagedURL(let url):
            return url // Use the exact URL from the API response
        }
    }
}

// MARK: - API Errors Enum (Adopted from previous example, can customize)

enum ManufacturedHousingAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String)
    case authenticationFailed(String)
    case tokenDecodingFailed
    case dataDecodingFailed(Error)
    case noData // Specific case for 404 or empty results where expected
    case invalidPageNumber
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API URL provided was invalid."
        case .requestFailed(let code, let msg): return "Request failed (\(code)): \(msg)"
        case .authenticationFailed(let reason): return "Authentication failed: \(reason)"
        case .tokenDecodingFailed: return "Failed to decode authentication token."
        case .dataDecodingFailed(let err): return "Failed to decode data: \(err.localizedDescription)"
        case .noData: return "No data found for the specified criteria."
        case .invalidPageNumber: return "The requested page number is invalid."
        case .unknown(let error): return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication Data (Reused)
// Assume same structure and placeholders as before
// struct TokenResponse: Decodable { ... }

// Structure to decode the token response from the authentication server
struct ManufacturedHousingLoans_TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int // Duration in seconds
    // let scope: String // Include if needed
}


// struct LoanLimitsAuthCredentials { ... } // RENAME if desired, ensure credentials are correct
struct LoanLimitsAuthCredentials {
    // --- ⚠️ IMPORTANT SECURITY WARNING ⚠️ ---
    // NEVER hardcode credentials directly in production code.
    // Use Keychain for secure storage or a configuration management system.
    // These are placeholders only.
    static let clientID = "YOUR_CLIENT_ID_HERE"        // Replace with your actual Client ID
    static let clientSecret = "YOUR_CLIENT_SECRET_HERE" // Replace with your actual Client Secret
    // -----------------------------------------
}

// MARK: - Data Service (ObservableObject)

final class ManufacturedHousingService: ObservableObject {
    
    // Published properties for different data types
    @Published var fullLoanDetail: Loan? // For single loan lookup
    @Published var acquisitionsList: [LoanAcquisition] = [] // For paginated acquisitions
    @Published var performanceList: [LoanPerformance] = [] // For paginated performance or single loan performance history
    
    @Published var paginationInfo = PaginationInfo() // Holds pagination state
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Result Type Enum to manage what's displayed
    enum DisplayMode {
        case none
        case fullLoan
        case acquisitions
        case performance
    }
    @Published var currentDisplayMode: DisplayMode = .none
    
    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURLString = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token" // Make sure this is correct
    private var accessToken: String?
    private var tokenExpiration: Date?
    
    private var cancellables = Set<AnyCancellable>()
    private var tokenFetchCancellable: AnyCancellable?
    
    // --- Token Management (Reuse from previous example) ---
    private func getAccessToken() -> Future<String, ManufacturedHousingAPIError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknown(NSError(domain: "LoanLimitsService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Service deallocated"]))))
                return
            }
            
            // Check if existing token is valid (adding a small buffer for safety)
            if let token = self.accessToken, let expiration = self.tokenExpiration, Date().addingTimeInterval(60) < expiration {
                // print("Using cached access token.")
                promise(.success(token))
                return
            }
            
            // print("Fetching new access token...")
            guard let url = URL(string: self.tokenURLString) else {
                promise(.failure(.invalidURL))
                return
            }
            
            // --- Basic Authentication Header ---
            let credentials = "\(LoanLimitsAuthCredentials.clientID):\(LoanLimitsAuthCredentials.clientSecret)"
            guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
                promise(.failure(.authenticationFailed("Could not encode credentials.")))
                return
            }
            
            // --- Request Setup ---
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = "grant_type=client_credentials".data(using: .utf8)
            
            // --- Make the Request ---
            self.tokenFetchCancellable = URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw ManufacturedHousingAPIError.requestFailed(statusCode: -1, message: "Invalid response object.")
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                        throw ManufacturedHousingAPIError.authenticationFailed("Token request failed with status \(httpResponse.statusCode). Response: \(responseString)")
                    }
                    return data
                }
                .decode(type: ManufacturedHousingLoans_TokenResponse.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished: break
                    case .failure(let error):
                        // print("Token fetching failed: \(error)")
                        if error is DecodingError {
                            promise(.failure(.tokenDecodingFailed))
                        } else if let apiError = error as? ManufacturedHousingAPIError {
                            promise(.failure(apiError))
                        } else {
                            promise(.failure(.unknown(error)))
                        }
                    }
                }, receiveValue: { tokenResponse in
                    // print("Successfully fetched new token.")
                    self.accessToken = tokenResponse.access_token
                    self.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                    promise(.success(tokenResponse.access_token))
                })
            // Keep the subscription store mechanism if preferred, or just assign to the single cancellable
        }
    }
    
    // --- Reset/Clear Function ---
    func clearAllData() {
        fullLoanDetail = nil
        acquisitionsList = []
        performanceList = []
        paginationInfo = PaginationInfo() // Reset pagination
        errorMessage = nil
        currentDisplayMode = .none
        print("All local data cleared.")
    }
    
    // MARK: - Specific Data Fetchers
    
    func fetchLoanDetails(id: String) {
        fetchData(for: .loanById(id: id), expectedType: Loan.self, displayMode: .fullLoan) { [weak self] result in
            self?.fullLoanDetail = result // Store single loan detail
            self?.acquisitionsList = [] // Clear other lists
            self?.performanceList = []
        }
    }
    
    func fetchAcquisition(id: String) {
        fetchData(for: .acquisitionById(id: id), expectedType: LoanAcquisition.self, displayMode: .acquisitions) { [weak self] result in
            self?.acquisitionsList = [result] // Display as a list of one
            self?.fullLoanDetail = nil
            self?.performanceList = []
        }
    }
    
    // Remember: Fetching performance by ID returns an ARRAY
    func fetchPerformanceHistory(id: String) {
        fetchData(for: .performanceById(id: id), expectedType: [LoanPerformance].self, displayMode: .performance) { [weak self] result in
            self?.performanceList = result // Store the array of performance records
            self?.fullLoanDetail = nil
            self?.acquisitionsList = []
        }
    }
    
    func fetchAllAcquisitions(page: Int = 1) {
        fetchPaginatedData(for: .allAcquisitions(page: page), expectedItemType: LoanAcquisition.self, displayMode: .acquisitions) { [weak self] results in
            self?.acquisitionsList = results
            self?.fullLoanDetail = nil
            self?.performanceList = []
        }
    }
    
    func fetchAllPerformance(page: Int = 1) {
        fetchPaginatedData(for: .allPerformance(page: page), expectedItemType: LoanPerformance.self, displayMode: .performance) { [weak self] results in
            self?.performanceList = results
            self?.fullLoanDetail = nil
            self?.acquisitionsList = []
        }
    }
    
    // --- Pagination Fetchers ---
    func fetchNextPage() {
        guard let nextURL = paginationInfo.nextURL else { return }
        print("Fetching next page: \(nextURL)")
        // Determine the correct item type based on the *current* display mode
        switch currentDisplayMode {
        case .acquisitions:
            fetchPaginatedData(for: .pagedURL(url: nextURL), expectedItemType: LoanAcquisition.self, displayMode: .acquisitions) { [weak self] results in
                self?.acquisitionsList = results
            }
        case .performance:
            fetchPaginatedData(for: .pagedURL(url: nextURL), expectedItemType: LoanPerformance.self, displayMode: .performance) { [weak self] results in
                self?.performanceList = results
            }
        default:
            print("Warning: Cannot fetch next page for display mode \(currentDisplayMode)")
            errorMessage = "Cannot fetch next page for the current view."
            break // Or handle appropriately
        }
    }
    
    func fetchPreviousPage() {
        guard let prevURL = paginationInfo.previousURL else { return }
        print("Fetching previous page: \(prevURL)")
        switch currentDisplayMode {
        case .acquisitions:
            fetchPaginatedData(for: .pagedURL(url: prevURL), expectedItemType: LoanAcquisition.self, displayMode: .acquisitions) { [weak self] results in
                self?.acquisitionsList = results
            }
        case .performance:
            fetchPaginatedData(for: .pagedURL(url: prevURL), expectedItemType: LoanPerformance.self, displayMode: .performance) { [weak self] results in
                self?.performanceList = results
            }
        default:
            print("Warning: Cannot fetch previous page for display mode \(currentDisplayMode)")
            errorMessage = "Cannot fetch previous page for the current view."
            break // Or handle appropriately
        }
    }
    
    // MARK: - Generic Fetch Logic
    
    /// Generic function to fetch non-paginated data (single objects or arrays).
    private func fetchData<T: Decodable>(
        for endpoint: ManufacturedHousingAPIEndpoint,
        expectedType: T.Type,
        displayMode: DisplayMode,
        completionHandler: @escaping (T) -> Void
    ) {
        isLoading = true
        errorMessage = nil
        currentDisplayMode = .none // Reset display mode until success
        
        getAccessToken()
            .flatMap { [weak self] token -> AnyPublisher<T, ManufacturedHousingAPIError> in
                guard let self = self else {
                    return Fail(error: .unknown(NSError(domain: "Service Deallocated", code: -1))).eraseToAnyPublisher()
                }
                return self.makeDataRequest(endpoint: endpoint, accessToken: token, responseType: expectedType)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                switch completionResult {
                case .finished:
                    self?.currentDisplayMode = displayMode // Set display mode on success
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { result in
                completionHandler(result) // Pass the decoded result back
            })
            .store(in: &cancellables)
    }
    
    /// Generic function to fetch paginated data.
    private func fetchPaginatedData<T: Decodable>(
        for endpoint: ManufacturedHousingAPIEndpoint,
        expectedItemType: T.Type, // The type of item *within* the embedded array
        displayMode: DisplayMode,
        completionHandler: @escaping ([T]) -> Void
    ) {
        isLoading = true
        errorMessage = nil
        currentDisplayMode = .none // Reset until success
        
        guard case .allAcquisitions(let acqPage) = endpoint
                // Add page tracking for .allPerformance
                ?? (endpoint == .allPerformance(page: 1) ? .allPerformance(page: 1) : nil) // Placeholder check for performance
                ?? (currentPageInfo.nextURL != nil || currentPageInfo.previousURL != nil ? endpoint : nil) // Allow paginatedURL endpoint
        else {
            // If it's not a paginated endpoint type we handle currently
            if case .pagedURL(_) = endpoint {} else {
                print("Error: fetchPaginatedData called with non-paginated endpoint type \(endpoint)")
                self.errorMessage = "Internal error: Invalid endpoint for pagination."
                self.isLoading = false
                return
            }
            
            // Extract the desired page number from the endpoint or use current page if it's a pagedURL fetch
            let pageNum: Int
            switch endpoint {
            case .allAcquisitions(let p): pageNum = p
            case .allPerformance(let p): pageNum = p
            case .pagedURL(let url):
                // Attempt to parse page number from URL (example, might need adjustment based on actual API URL format)
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let pageItem = components.queryItems?.first(where: { $0.name == "page" }),
                   let page = Int(pageItem.value ?? "") {
                    pageNum = page
                } else {
                    // Fallback or error if page can't be parsed from URL
                    pageNum = paginationInfo.currentPage // Best guess
                    print("Warning: Could not parse page number from URL: \(url). Using stored current page.")
                }
            default: pageNum = 1 // Should not happen due to guard above
            }
            
            paginationInfo.currentPage = pageNum
            
        }
        
        
        
        getAccessToken()
            .flatMap { [weak self] token -> AnyPublisher<HypermediaPage<T>, ManufacturedHousingAPIError> in
                guard let self = self, let url = endpoint.url(baseURL: self.baseURLString) else {
                    return Fail(error: .invalidURL).eraseToAnyPublisher()
                }
                return self.makePaginatedRequest(url: url, accessToken: token, pageType: HypermediaPage<T>.self)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completionResult in
                self?.isLoading = false
                switch completionResult {
                case .finished:
                    self?.currentDisplayMode = displayMode
                case .failure(let error):
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] pageData in
                guard let self = self else { return }
                
                // Update pagination info
                self.paginationInfo.totalItems = pageData.total ?? 0
                self.paginationInfo.nextURL = URL(string: pageData._links?.next?.href ?? "")
                self.paginationInfo.previousURL = URL(string: pageData._links?.previous?.href ?? "")
                self.paginationInfo.selfURL = URL(string: pageData._links?.self.href ?? "")
                self.paginationInfo.resultsURL = URL(string: pageData._links?.results?.href ?? "")
                
                // Extract page number from self link if possible
                if let selfUrl = self.paginationInfo.selfURL,
                   let components = URLComponents(url: selfUrl, resolvingAgainstBaseURL: false),
                   let pageItem = components.queryItems?.first(where: { $0.name == "page" }),
                   let page = Int(pageItem.value ?? "") {
                    self.paginationInfo.currentPage = page
                }
                // else { Keep previous page number if it couldn't be parsed }
                
                completionHandler(pageData._embedded?.items ?? []) // Pass back the array of items
            })
            .store(in: &cancellables)
    }
    
    // --- Private Network Request Helpers ---
    
    /// Makes a request expecting a specific Decodable type T (single object or array).
    private func makeDataRequest<T: Decodable>(
        endpoint: ManufacturedHousingAPIEndpoint,
        accessToken: String,
        responseType: T.Type
    ) -> AnyPublisher<T, ManufacturedHousingAPIError> {
        guard let url = endpoint.url(baseURL: baseURLString) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        // print("Making data request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
        request.addValue("application/json", forHTTPHeaderField: "Accept") // Prefer JSON
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ManufacturedHousingAPIError.requestFailed(statusCode: -1, message: "Invalid response.")
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let msg = String(data: data, encoding: .utf8) ?? "No details"
                    if httpResponse.statusCode == 404 { throw ManufacturedHousingAPIError.noData }
                    if httpResponse.statusCode == 401 { throw ManufacturedHousingAPIError.authenticationFailed("Token rejected or expired.") }
                    if httpResponse.statusCode == 403 { throw ManufacturedHousingAPIError.authenticationFailed("Forbidden - Check Permissions.") }
                    throw ManufacturedHousingAPIError.requestFailed(statusCode: httpResponse.statusCode, message: msg)
                }
                return data
            }
            .decode(type: responseType, decoder: JSONDecoder())
            .mapError { error -> ManufacturedHousingAPIError in // Ensure mapping to our error type
                if let decodingError = error as? DecodingError {
                    return .dataDecodingFailed(decodingError)
                } else if let apiError = error as? ManufacturedHousingAPIError {
                    return apiError
                } else {
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Makes a request specifically expecting a paginated HypermediaPage response.
    private func makePaginatedRequest<T: Decodable>(
        url: URL,
        accessToken: String,
        pageType: HypermediaPage<T>.Type
    ) -> AnyPublisher<HypermediaPage<T>, ManufacturedHousingAPIError> {
        
        // print("Making paginated request to: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ManufacturedHousingAPIError.requestFailed(statusCode: -1, message: "Invalid response.")
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    let msg = String(data: data, encoding: .utf8) ?? "No details"
                    if httpResponse.statusCode == 400 { throw ManufacturedHousingAPIError.invalidPageNumber }
                    if httpResponse.statusCode == 404 { throw ManufacturedHousingAPIError.noData }
                    if httpResponse.statusCode == 401 { throw ManufacturedHousingAPIError.authenticationFailed("Token rejected or expired.") }
                    if httpResponse.statusCode == 403 { throw ManufacturedHousingAPIError.authenticationFailed("Forbidden - Check Permissions.") }
                    throw ManufacturedHousingAPIError.requestFailed(statusCode: httpResponse.statusCode, message: msg)
                }
                return data
            }
            .decode(type: pageType, decoder: JSONDecoder())
            .mapError { error -> ManufacturedHousingAPIError in
                if let decodingError = error as? DecodingError {
                    return .dataDecodingFailed(decodingError)
                } else if let apiError = error as? ManufacturedHousingAPIError {
                    return apiError
                } else {
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // --- Error Handling ---
    private func handleError(_ error: ManufacturedHousingAPIError) {
        self.errorMessage = error.localizedDescription
    }
}

// MARK: - SwiftUI Views

struct ManufacturedHousingView: View {
    @StateObject private var service = ManufacturedHousingService()
    @State private var loanIdInput: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // --- Fetch by ID Section ---
                    Section("Fetch by Loan ID") {
                        TextField("Enter Loan Identifier", text: $loanIdInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .disabled(service.isLoading)
                        
                        HStack {
                            Spacer()
                            Button("Loan Details") { service.fetchLoanDetails(id: loanIdInput) }
                                .buttonStyle(.bordered)
                                .disabled(loanIdInput.isEmpty || service.isLoading)
                            Button("Acquisition") { service.fetchAcquisition(id: loanIdInput) }
                                .buttonStyle(.bordered)
                                .disabled(loanIdInput.isEmpty || service.isLoading)
                            Button("Performance") { service.fetchPerformanceHistory(id: loanIdInput) }
                                .buttonStyle(.bordered)
                                .disabled(loanIdInput.isEmpty || service.isLoading)
                            Spacer()
                        }
                    }
                    
                    // --- Fetch All (Paginated) Section ---
                    Section("Fetch All Data (Paginated)") {
                        HStack {
                            Spacer()
                            Button("All Acquisitions (Page \(service.paginationInfo.currentPage))") {
                                service.fetchAllAcquisitions() // Start from page 1
                            }
                            .buttonStyle(.bordered)
                            .disabled(service.isLoading)
                            Spacer()
                            Button("All Performance (Page \(service.paginationInfo.currentPage))") {
                                service.fetchAllPerformance() // Start from page 1
                            }
                            .buttonStyle(.bordered)
                            .disabled(service.isLoading)
                            Spacer()
                        }
                        
                        // Pagination Controls
                        if service.currentDisplayMode == .acquisitions || service.currentDisplayMode == .performance {
                            HStack {
                                Button("Previous") { service.fetchPreviousPage() }
                                    .disabled(service.paginationInfo.previousURL == nil || service.isLoading)
                                Spacer()
                                Text("Page \(service.paginationInfo.currentPage) / \(service.paginationInfo.totalPages)")
                                    .font(.caption)
                                Spacer()
                                Button("Next") { service.fetchNextPage() }
                                    .disabled(service.paginationInfo.nextURL == nil || service.isLoading)
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 5)
                        }
                    }
                    
                    // --- Clear Data ---
                    Section {
                        Button("Clear All Displayed Data", role: .destructive) {
                            service.clearAllData()
                            loanIdInput = "" // Also clear input field
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(service.isLoading)
                    }
                    
                    // --- Results Display Area ---
                    Section("Results (\(resultTypeDescription))") {
                        if service.isLoading {
                            ProgressView("Loading...")
                                .frame(maxWidth:.infinity)
                        } else if let errorMsg = service.errorMessage {
                            Text("Error: \(errorMsg)")
                                .foregroundColor(.red)
                        } else {
                            // Switch display based on currentDisplayMode
                            switch service.currentDisplayMode {
                            case .none:
                                Text("No data requested or available.")
                                    .foregroundColor(.secondary)
                            case .fullLoan:
                                if let loan = service.fullLoanDetail {
                                    FullLoanDetailView(loan: loan)
                                } else {
                                    Text("Loan details not found.")
                                        .foregroundColor(.secondary)
                                }
                            case .acquisitions:
                                if service.acquisitionsList.isEmpty {
                                    Text("No acquisition data found.")
                                        .foregroundColor(.secondary)
                                } else {
                                    List(service.acquisitionsList) { acq in
                                        LoanAcquisitionRow(acquisition: acq)
                                    }
                                }
                            case .performance:
                                if service.performanceList.isEmpty {
                                    Text("No performance data found.")
                                        .foregroundColor(.secondary)
                                } else {
                                    List(service.performanceList) { perf in
                                        LoanPerformanceRow(performance: perf)
                                    }
                                }
                            }
                        }
                    }
                } // End Form
            } // End VStack
            .navigationTitle("Manufactured Housing")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Check if placeholder credentials are still there
                if LoanLimitsAuthCredentials.clientID == "YOUR_CLIENT_ID_HERE" || LoanLimitsAuthCredentials.clientSecret == "YOUR_CLIENT_SECRET_HERE" {
                    service.errorMessage = "Error: Please replace placeholder API credentials in LoanLimitsAuthCredentials."
                }
            }
        } // End NavigationView
        .navigationViewStyle(.stack)
    }
    
    // Helper to describe results type
    private var resultTypeDescription: String {
        switch service.currentDisplayMode {
        case .none: return "None"
        case .fullLoan: return "Full Loan Detail"
        case .acquisitions: return "Acquisitions"
        case .performance: return "Performance History"
        }
    }
}

// MARK: - Detail Row Views

struct FullLoanDetailView: View {
    let loan: Loan
    
    var body: some View {
        ScrollView { // Use ScrollView for potentially long content
            VStack(alignment: .leading, spacing: 15) {
                if let acq = loan.acquisition {
                    Text("Acquisition Details").font(.title2).padding(.bottom, 5)
                    LoanAcquisitionRow(acquisition: acq) // Reuse the acquisition row
                } else {
                    Text("No Acquisition Data").foregroundColor(.secondary)
                }
                
                Divider().padding(.vertical, 10)
                
                if let perf = loan.monthlyPerformances, !perf.isEmpty {
                    Text("Performance History (\(perf.count) records)").font(.title2).padding(.bottom, 5)
                    ForEach(perf) { p in
                        LoanPerformanceRow(performance: p)
                        Divider()
                    }
                } else {
                    Text("No Performance Data").foregroundColor(.secondary)
                }
            }
            .padding() // Add padding around the ScrollView content
        }
    }
}

struct LoanAcquisitionRow: View {
    let acquisition: LoanAcquisition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Loan ID: \(acquisition.id)")
                .font(.headline)
            HStack {
                Text("Seller: \(acquisition.sellerName ?? "N/A")")
                Spacer()
                Text("Channel: \(acquisition.channel ?? "N/A")")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Text("Orig. Rate: \(formatPercent(acquisition.originalInterestRate))")
                Spacer()
                Text("Orig. UPB: \(formatCurrency(acquisition.originalUnpaidPrincipalBalance))")
            }
            .font(.footnote)
            
            HStack {
                Text("Orig. LTV: \(formatPercent(acquisition.originalLoanToValue))")
                Spacer()
                Text("Orig. Term: \(acquisition.originalLoanTerm ?? 0) months")
            }
            .font(.footnote)
            
            HStack {
                Text("Credit Score: \(acquisition.borrowerCreditScore ?? 0)")
                Spacer()
                if let coScore = acquisition.coborrowerCreditScore {
                    Text("Co-Score: \(coScore)")
                }
                Spacer()
                Text("DTI: \(formatPercent(acquisition.debtToIncomeRatio))")
            }
            .font(.footnote)
            
            // Add more fields as needed
        }
    }
}

struct LoanPerformanceRow: View {
    let performance: LoanPerformance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Period: \(performance.monthlyReportingPeriod ?? "N/A")")
                    .font(.headline)
                Spacer()
                Text("Loan Age: \(performance.loanAge ?? 0) mo")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            HStack {
                Text("Current Rate: \(formatPercent(performance.currentInterestRate))")
                Spacer()
                Text("Current UPB: \(formatCurrency(performance.currentActualUpb))")
            }
            .font(.footnote)
            
            HStack {
                Text("Status: \(performance.loanDelinquencyStatus ?? "N/A")")
                    .foregroundColor(delinquencyColor(performance.loanDelinquencyStatus))
                Spacer()
                if performance.modificationFlag == "Y" {
                    Text("Modified").font(.caption).bold().foregroundColor(.orange)
                }
                if let zbCode = performance.zeroBalanceCode, !zbCode.isEmpty, zbCode != "00" {
                    Text("ZB: \(zbCode)").font(.caption).bold().foregroundColor(.blue)
                }
            }
            .font(.footnote)
            
            // Add more relevant performance details if needed
        }
    }
    
    // Helper for delinquency color coding (Example)
    private func delinquencyColor(_ status: String?) -> Color {
        guard let status = status else { return .gray }
        if status == "X" { // Assuming 'X' means foreclosure or serious delinquency
            return .red
        } else if let days = Int(status), days > 0 {
            return .orange // Delinquent
        } else {
            return .green // Current or '0'
        }
    }
}

// MARK: - Formatting Helpers

func formatCurrency(_ value: Double?) -> String {
    guard let value = value else { return "N/A" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

func formatPercent(_ value: Double?) -> String {
    guard let value = value else { return "N/A" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 0
    // Note: API values might be direct percentages (e.g., 5.5) or decimals (e.g., 0.055).
    // If they are direct percentages, don't multiply by 100. If decimals, do multiply.
    // Assuming the API provides direct percentages as shown in some examples:
    // return formatter.string(from: NSNumber(value: value / 100.0)) ?? "\(value)%"
    // If API provides decimals (e.g., 0.055 for 5.5%):
    return formatter.string(from: NSNumber(value: value)) ?? "\(value * 100)%"
    // Adjust based on actual API data format observed. Let's assume direct % for now.
    // return "\(String(format: "%.2f", value))%" // Simpler direct formatting
}

// MARK: - Preview Provider

struct ManufacturedHousingView_Previews: PreviewProvider {
    static var previews: some View {
        // Create dummy data
        let acq1 = LoanAcquisition(id: "MH12345", channel: "R", sellerName: "Seller A", originalInterestRate: 3.5, originalUnpaidPrincipalBalance: 150000, originalLoanTerm: 360, originationDate: "202201", firstPaymentDate: "202203", originalLoanToValue: 80, originalCombinedLoanToValue: 80, numberOfBorrowers: 1, debtToIncomeRatio: 35, borrowerCreditScore: 750, firstTimeHomeBuyerIndicator: "N", loanPurpose: "P", propertyType: "MH", numberOfUnits: 1, occupancyStatus: "P", propertyGeographicalState: "CA", zip3: "902", mortgageInsurancePercentage: 0, productType: "FRM", coborrowerCreditScore: nil, mortgageInsuranceType: 0, relocationMortgageIndicator: "N")
        
        let perf1 = LoanPerformance(loanIdentifier: "MH12345", monthlyReportingPeriod: "202401", servicerName: "Servicer X", currentInterestRate: 3.5, currentActualUpb: 148000.0, loanAge: 24, remainingMonthsToMaturity: 336, adjustedRemainingMonthsToMaturity: 336, maturityDate: "205202", msa: 12345, loanDelinquencyStatus: "0", modificationFlag: "N", zeroBalanceCode: nil, zeroBalanceEffectiveDate: nil, lastPaidInstallmentDate: "20240101", foreclosureDate: nil, dispositionDate: nil, foreclosureCosts: nil, propertyPreservationAndRepairCosts: nil, assetRecoveryCosts: nil, miscHoldingExpensesAndCredits: nil, associatedTaxesForHoldingProperty: nil, netSaleProceeds: nil, creditEnhancementProceeds: nil, repurchaseMakeWholeProceeds: nil, otherForeclosureProceeds: nil, nonInterestBearingUpb: nil, principalForgivenessUpb: nil, repurchaseMakeWholeProceedsFlag: nil, foreclosurePrincipalWriteOffAmount: nil, servicingActivityIndicator: "N")
        
        let perf2 = LoanPerformance(loanIdentifier: "MH12345", monthlyReportingPeriod: "202402", servicerName: "Servicer X", currentInterestRate: 3.5, currentActualUpb: 147800.0, loanAge: 25, remainingMonthsToMaturity: 335, adjustedRemainingMonthsToMaturity: 335, maturityDate: "205202", msa: 12345, loanDelinquencyStatus: "0", modificationFlag: "N", zeroBalanceCode: nil, zeroBalanceEffectiveDate: nil, lastPaidInstallmentDate: "20240201", foreclosureDate: nil, dispositionDate: nil, foreclosureCosts: nil, propertyPreservationAndRepairCosts: nil, assetRecoveryCosts: nil, miscHoldingExpensesAndCredits: nil, associatedTaxesForHoldingProperty: nil, netSaleProceeds: nil, creditEnhancementProceeds: nil, repurchaseMakeWholeProceeds: nil, otherForeclosureProceeds: nil, nonInterestBearingUpb: nil, principalForgivenessUpb: nil, repurchaseMakeWholeProceedsFlag: nil, foreclosurePrincipalWriteOffAmount: nil, servicingActivityIndicator: "N")
        
        let fullLoan = Loan(acquisition: acq1, monthlyPerformances: [perf1, perf2])
        
        let previewService = ManufacturedHousingService()
        //        previewService.fullLoanDetail = fullLoan // Uncomment to preview full loan
        //        previewService.acquisitionsList = [acq1] // Uncomment to preview acquisition list
        previewService.performanceList = [perf1, perf2] // Uncomment to preview performance list
        previewService.currentDisplayMode = .performance // Set the mode for preview
        previewService.paginationInfo.totalItems = 2 // Example pagination info
        previewService.paginationInfo.totalPages = 1
        previewService.paginationInfo.currentPage = 1
        //        previewService.errorMessage = "Preview Error Message Goes Here" // Uncomment to test error state
        //        previewService.isLoading = true // Uncomment to test loading state
        
        //return ManufacturedHousingView(service: previewService)
        return ManufacturedHousingView()
    }
}
