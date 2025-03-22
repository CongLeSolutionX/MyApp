//
//  View.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents the request parameters for the HomeReady Evaluation API.
struct HomeReadyRequest: Encodable {
    let censusTract: String?
    let city: String?
    let includesNonOccupantIncome: Bool?
    let loanPurpose: String?
    let numberOfUnits: Int?
    let productType: String?
    let propertyType: String?
    let propertyValue: Double?
    let state: String?
    let street: String?
    let subordinateCommunitySecond: Bool?
    let subordinateFinancingAmount: Double?
    let totalGrossMonthlyIncome: Double?
    let totalLoanAmount: Double?
    let zipCode: String?
}

/// Represents the API response for HomeReady evaluation.
struct HomeReadyResponse: Decodable {
    let areaMedianIncome: Int?
    let code: String?
    let hcaType: String?
    let homeReadyIncomeLimit: Int?
    let messages: [Message]?
    let ruralType: String?
    let homeReadyFirstEligible: String?
    
    enum Code: String, Decodable {
        case errorCensusTractInvalid = "error.census_tract.invalid"
        case errorCensusTractNotFound = "error.census_tract.not_found"
        case errorCensusTractNotFoundForAddress = "error.census_tract.not_found_for_address"
        case errorMediaTypeInvalid = "error.mediatype.invalid"
        case errorRequestInvalid = "error.request.invalid"
        case errorServiceFailure = "error.service.failure"
        case errorZipCodeInvalid = "error.zip_code.invalid"
        case success
    }
    
    // Add the CodingKeys so these keys are in scope.
     enum CodingKeys: String, CodingKey {
         case areaMedianIncome, code, hcaType, homeReadyIncomeLimit, messages, ruralType, homeReadyFirstEligible
     }
    
    enum HcaType: String, Decodable {
        case highCostArea = "HIGH_COST_AREA"
        case standardArea = "STANDARD_AREA"
    }
    
    enum RuralType: String, Decodable {
        case highNeedsRural = "HIGH_NEEDS_RURAL"
        case notRural = "NOT_RURAL"
        case rural = "RURAL"
    }
    
    enum HomeReadyFirstEligibleType: String, Decodable {
        case no = "NO", unknown = "UNKNOWN", yes = "YES"
    }
    
    /// Custom decoding initializer to decode raw-value enums.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        areaMedianIncome = try container.decodeIfPresent(Int.self, forKey: .areaMedianIncome)
        homeReadyIncomeLimit = try container.decodeIfPresent(Int.self, forKey: .homeReadyIncomeLimit)
        messages = try container.decodeIfPresent([Message].self, forKey: .messages)
        
        if let codeString = try container.decodeIfPresent(String.self, forKey: .code) {
            code = Code(rawValue: codeString)?.rawValue
        } else {
            code = nil
        }
        if let hcaTypeString = try container.decodeIfPresent(String.self, forKey: .hcaType) {
            hcaType = HcaType(rawValue: hcaTypeString)?.rawValue
        } else {
            hcaType = nil
        }
        
        if let ruralTypeString = try container.decodeIfPresent(String.self, forKey: .ruralType){
            ruralType = RuralType(rawValue: ruralTypeString)?.rawValue
        } else {
            ruralType = nil
        }
        
        if let homeReadyFirstEligibleString = try container.decodeIfPresent(String.self, forKey: .homeReadyFirstEligible) {
            homeReadyFirstEligible = HomeReadyFirstEligibleType(rawValue: homeReadyFirstEligibleString)?.rawValue
        } else {
            homeReadyFirstEligible = nil
        }
    }
}

/// Represents a message within the API response.
struct Message: Decodable {
    let code: String?
    let description: String?
}

// MARK: - API Endpoint

/// Enum for the API endpoint.
enum APIEndpoint {
    case evaluation
    
    var path: String {
        switch self {
        case .evaluation:
            return "/singlefamily/originating/loans/homeready/evaluation"
        }
    }
}

// MARK: - API Errors

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

// MARK: - Authentication

struct AuthCredentials {
    static let clientID = "clientIDKeyHere"        // Replace with your actual clientID
    static let clientSecret = "clientSecretKeyHere"  // Replace with your actual clientSecret
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service

final class HomeReadyEvaluationService: ObservableObject {
    @Published var homeReadyResponse: HomeReadyResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Token Management
    
    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
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
                    throw APIError.requestFailed("Invalid Response: \(responseString)")
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
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
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
    
    // MARK: - Public API - Evaluation
    
    func evaluateHomeReady(requestData: HomeReadyRequest) {
        isLoading = true
        errorMessage = nil
        homeReadyResponse = nil
        
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                self.makeEvaluationRequest(requestData: requestData, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }
    
    // MARK: - Private API Request
    
    private func makeEvaluationRequest(requestData: HomeReadyRequest, accessToken: String) {
        guard let url = URL(string: baseURLString + APIEndpoint.evaluation.path) else {
            handleError(.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Build query items from the request object.
        let mirror = Mirror(reflecting: requestData)
        var queryItems: [URLQueryItem] = []
        for child in mirror.children {
            guard let label = child.label else { continue }
            let valueString: String
            
            if let boolValue = child.value as? Bool {
                valueString = boolValue ? "true" : "false"
            } else if let intValue = child.value as? Int {
                valueString = String(intValue)
            } else if let doubleValue = child.value as? Double {
                valueString = String(doubleValue)
            } else if let stringValue = child.value as? String {
                valueString = stringValue
            } else {
                continue
            }
            queryItems.append(URLQueryItem(name: label, value: valueString))
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        guard let finalURL = components?.url else {
            handleError(.invalidURL)
            return
        }
        request.url = finalURL
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw APIError.requestFailed("Invalid Response: \(responseString)")
                }
                return data
            }
            .decode(type: HomeReadyResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                self.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error as? APIError ?? APIError.unknown(error))
                }
            } receiveValue: { [weak self] response in
                self?.homeReadyResponse = response
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")
    }
}

// MARK: - SwiftUI Views

struct HomeReadyEvaluationView: View {
    // Instead of a single mutable request, keep separate state properties.
    @State private var censusTract: String = ""
    @State private var city: String = ""
    @State private var includesNonOccupantIncome: Bool = false
    @State private var loanPurpose: String = ""
    @State private var numberOfUnits: Int?
    @State private var productType: String = ""
    @State private var propertyType: String = ""
    @State private var propertyValue: Double?
    @State private var stateText: String = ""
    @State private var street: String = ""
    @State private var subordinateCommunitySecond: Bool = false
    @State private var subordinateFinancingAmount: Double?
    @State private var totalGrossMonthlyIncome: Double?
    @State private var totalLoanAmount: Double?
    @State private var zipCode: String = ""
    
    @StateObject private var service = HomeReadyEvaluationService()
    @State private var showResult = false

    // Sample enum choices
    let loanPurposes = ["LIMITED_CASH_OUT_REFILL", "OTHER", "PURCHASE"]
    let productTypes = ["ARM", "FRM", "OTHER"]
    let propertyTypes = ["ATTACHED", "CONDO", "COOP", "DETACHED", "DETACHED_CONDO", "HIGH_RISE_CONDO", "MANUFACTURED_HOME_CONDO_PUD_COOP", "MANUFACTURED_HOUSING", "MH_SELECT", "PUD"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Request Parameters")) {
                    TextField("Census Tract", text: $censusTract)
                    
                    TextField("City", text: $city)
                    
                    Toggle("Includes Non-Occupant Income", isOn: $includesNonOccupantIncome)
                    
                    Picker("Loan Purpose", selection: $loanPurpose) {
                        ForEach(loanPurposes, id: \.self) { purpose in
                            Text(purpose)
                        }
                    }
                    
                    TextField("Number of Units", value: Binding(get: { numberOfUnits ?? 0 },
                                                                 set: { numberOfUnits = $0 }),
                              format: .number)
                    
                    Picker("Product Type", selection: $productType) {
                        ForEach(productTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    Picker("Property Type", selection: $propertyType) {
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    TextField("Property Value", value: Binding(get: { propertyValue ?? 0.0 },
                                                                set: { propertyValue = $0 }),
                              format: .currency(code: "USD"))
                    
                    TextField("State", text: $stateText)
                    TextField("Street", text: $street)
                    
                    Toggle("Subordinate Community Second", isOn: $subordinateCommunitySecond)
                    
                    TextField("Subordinate Financing Amount", value: Binding(get: { subordinateFinancingAmount ?? 0.0 },
                                                                              set: { subordinateFinancingAmount = $0 }),
                              format: .currency(code: "USD"))
                    
                    TextField("Total Gross Monthly Income", value: Binding(get: { totalGrossMonthlyIncome ?? 0.0 },
                                                                            set: { totalGrossMonthlyIncome = $0 }),
                              format: .currency(code: "USD"))
                    
                    TextField("Total Loan Amount", value: Binding(get: { totalLoanAmount ?? 0.0 },
                                                                   set: { totalLoanAmount = $0 }),
                              format: .currency(code: "USD"))
                    
                    TextField("Zip Code", text: $zipCode)
                }
                
                Button("Evaluate Eligibility") {
                    let requestData = HomeReadyRequest(censusTract: censusTract.isEmpty ? nil : censusTract,
                                                       city: city.isEmpty ? nil : city,
                                                       includesNonOccupantIncome: includesNonOccupantIncome,
                                                       loanPurpose: loanPurpose.isEmpty ? nil : loanPurpose,
                                                       numberOfUnits: numberOfUnits,
                                                       productType: productType.isEmpty ? nil : productType,
                                                       propertyType: propertyType.isEmpty ? nil : propertyType,
                                                       propertyValue: propertyValue,
                                                       state: stateText.isEmpty ? nil : stateText,
                                                       street: street.isEmpty ? nil : street,
                                                       subordinateCommunitySecond: subordinateCommunitySecond,
                                                       subordinateFinancingAmount: subordinateFinancingAmount,
                                                       totalGrossMonthlyIncome: totalGrossMonthlyIncome,
                                                       totalLoanAmount: totalLoanAmount,
                                                       zipCode: zipCode.isEmpty ? nil : zipCode)
                    
                    service.evaluateHomeReady(requestData: requestData)
                    showResult = true
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("HomeReady Eligibility")
            .sheet(isPresented: $showResult) {
                ResultView(response: service.homeReadyResponse, errorMessage: service.errorMessage)
            }
        }
    }
}

struct ResultView: View {
    let response: HomeReadyResponse?
    let errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if let response = response {
                        Group {
                            if let ami = response.areaMedianIncome {
                                Text("Area Median Income: \(ami)")
                            }
                            if let code = response.code {
                                Text("Code: \(code)")
                            }
                            if let hcaType = response.hcaType {
                                Text("HCA Type: \(hcaType)")
                            }
                            if let incomeLimit = response.homeReadyIncomeLimit {
                                Text("HomeReady Income Limit: \(incomeLimit)")
                            }
                            if let ruralType = response.ruralType {
                                Text("Rural Type: \(ruralType)")
                            }
                            if let eligible = response.homeReadyFirstEligible {
                                Text("HomeReady First Eligible: \(eligible)")
                            }
                        }
                        if let messages = response.messages, !messages.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Messages:")
                                    .font(.headline)
                                ForEach(messages, id: \.code) { message in
                                    VStack(alignment: .leading) {
                                        if let code = message.code {
                                            Text("Code: \(code)")
                                                .font(.subheadline)
                                        }
                                        if let description = message.description {
                                            Text(description)
                                        }
                                    }
                                    .padding(4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                                }
                            }
                        }
                    } else {
                        Text("No data available.")
                    }
                }
                .padding()
            }
            .navigationTitle("Results")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct HomeReadyEvaluationView_Previews: PreviewProvider {
    static var previews: some View {
        HomeReadyEvaluationView()
    }
}
