//
//  NationalHousingSurveyView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Unified data model for National Housing Survey results.
struct SurveyData: Identifiable {
    let id = UUID()
    let date: String
    let questions: [Question]

    struct Question: Identifiable {
        let id: String
        let description: String
        let responses: [Response]

        struct Response: Identifiable {
            let id = UUID()
            let description: String
            let percent: Double
        }
    }

    // Initializer for NhsResults (from API response)
    init(from nhsResult: NhsResults) {
        self.date = nhsResult.date
        self.questions = nhsResult.questions.map { question in
            Question(id: question.id,
                     description: question.description,
                     responses: question.responses.map { response in
                         Question.Response(description: response.description, percent: response.percent)
                     })
        }
    }
}

/// Unified data model for HPSI data.
struct HpsiDataModel: Identifiable {
    let id = UUID()
    let hpsiValue: Double
    let date: String
    
    // Initializer for HpsiData
    init(from hpsiData: HpsiData) {
        self.hpsiValue = hpsiData.hpsiValue
        self.date = hpsiData.date
    }
}

// API Response Models (Matching JSON structure)
struct NhsResults: Decodable {
    let date: String
    let questions: [NhsQuestion]
}

struct NhsQuestion: Decodable {
    let id: String
    let description: String
    let responses: [NhsResponse]
}

struct NhsResponse: Decodable {
    let description: String
    let percent: Double
}

struct HpsiData: Decodable {
    let hpsiValue: Double
    let date: String
}

// MARK: - API Endpoints

/// Enumeration for API endpoints.
enum NationalHousingSurveyViewAPIEndpoint {
    case nhsResults
    case hpsiData
    case hpsiDataByAreaType(areaType: String)
    case hpsiDataByOwnershipStatus(ownershipStatus: String)
    case hpsiDataByHousingCostRatio(housingCostRatio: String)
    case hpsiDataByAgeGroup(ageGroup: String)
    case hpsiDataByCensusRegion(censusRegion: String)
    case hpsiDataByIncomeGroup(incomeGroup: String)
    case hpsiDataByEducation(educationLevel: String)

    var path: String {
        switch self {
        case .nhsResults:
            return "/v1/nhs/results"
        case .hpsiData:
            return "/v1/nhs/hpsi"
        case .hpsiDataByAreaType(let areaType):
            return "/v1/nhs/hpsi/area-type/\(areaType)"
        case .hpsiDataByOwnershipStatus(let ownershipStatus):
            return "/v1/nhs/hpsi/ownership-status/\(ownershipStatus)"
        case .hpsiDataByHousingCostRatio(let housingCostRatio):
            return "/v1/nhs/hpsi/housing-cost-ratio/\(housingCostRatio)"
        case .hpsiDataByAgeGroup(let ageGroup):
            return "/v1/nhs/hpsi/age-groups/\(ageGroup)"
        case .hpsiDataByCensusRegion(let censusRegion):
            return "/v1/nhs/hpsi/census-region/\(censusRegion)"
        case .hpsiDataByIncomeGroup(let incomeGroup):
            return "/v1/nhs/hpsi/income-groups/\(incomeGroup)"
        case .hpsiDataByEducation(let educationLevel):
            return "/v1/nhs/hpsi/education/\(educationLevel)"
        }
    }
}

// MARK: - API Errors

/// API error definition.
enum NationalHousingSurveyViewAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case invalidParameter(String)
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
        case .invalidParameter(let parameter):
            return "Invalid parameter: \(parameter)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication

///  Securely store client credentials.
struct NationalHousingSurvey_AuthCredentials {
    // Replace with secure storage like Keychain
   static let clientID = "clientIDKeyHere"
   static let clientSecret = "clientSecretKeyHere"
}


/// Model for the token response.
struct NationalHousingSurveyTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - Data Service
final class NationalHousingSurveyService: ObservableObject {
    @Published var surveyData: [SurveyData] = []
    @Published var hpsiData: [HpsiDataModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com"
    private let tokenURL = "https://auth.pingone.com/4c2b23f9-52b1-4f8f-aa1f-1d477590770c/as/token"  // Same as before
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management (Same as previous code)

    private func getAccessToken(completion: @escaping (Result<String, NationalHousingSurveyViewAPIError>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(NationalHousingSurvey_AuthCredentials.clientID):\(NationalHousingSurvey_AuthCredentials.clientSecret)"
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
                     throw NationalHousingSurveyViewAPIError.requestFailed("Invalid response. Response:\(responseString)")
                }
                return data
            }
            .decode(type: NationalHousingSurveyTokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? NationalHousingSurveyViewAPIError) ?? NationalHousingSurveyViewAPIError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError)) // Propagate the error
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }



    // MARK: - Public API Data Fetching
       func fetchData(for endpoint: NationalHousingSurveyViewAPIEndpoint) {
           isLoading = true
           errorMessage = nil
           surveyData = []  // Clear previous data
           hpsiData = []

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
    
       private func makeDataRequest(endpoint: NationalHousingSurveyViewAPIEndpoint, accessToken: String) {
           guard let url = URL(string: baseURLString + endpoint.path) else {
               handleError(.invalidURL)
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue(accessToken, forHTTPHeaderField: "x-public-access-token") // Use the token

           URLSession.shared.dataTaskPublisher(for: request)
               .tryMap { data, response -> Data in
                   guard let httpResponse = response as? HTTPURLResponse else {
                       throw NationalHousingSurveyViewAPIError.requestFailed("No HTTP response received.")
                   }
                   switch httpResponse.statusCode {
                   case 200...299:
                       return data // Successful
                   case 400:
                       let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                       // Extract parameter name if possible. This is a simplistic approach.
                       let invalidParam = responseString.lowercased().contains("invalid") ?
                           endpoint.path.components(separatedBy: "/").last ?? "Unknown" : "Unknown"
                       throw NationalHousingSurveyViewAPIError.invalidParameter(invalidParam)
                    case 401:
                        throw NationalHousingSurveyViewAPIError.authenticationFailed
                    case 403:
                        throw NationalHousingSurveyViewAPIError.requestFailed("Forbidden")
                    case 404:
                         throw NationalHousingSurveyViewAPIError.noData
                    case 500:
                        let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                        throw NationalHousingSurveyViewAPIError.requestFailed("Server Error: \(responseString)")

                   default:
                       let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                       throw NationalHousingSurveyViewAPIError.requestFailed("HTTP Status Code error: \(httpResponse.statusCode), Response: \(responseString)")
                   }
               }
               .receive(on: DispatchQueue.main)
               .sink { [weak self] completionResult in
                   guard let self = self else { return }
                   self.isLoading = false
                   switch completionResult {
                   case .finished:
                       break
                   case .failure(let error):
                       let apiError = (error as? NationalHousingSurveyViewAPIError) ?? NationalHousingSurveyViewAPIError.unknown(error)
                       self.handleError(apiError)

                   }
               } receiveValue: { [weak self] data in
                   guard let self = self else { return }
                   self.isLoading = false

                   // Determine the response type *before* decoding
                   let responseType = self.determineResponseType(for: endpoint)

                   do {
                       if responseType == [NhsResults].self {
                           let decodedResponse = try JSONDecoder().decode([NhsResults].self, from: data)
                           self.surveyData = decodedResponse.map { SurveyData(from: $0) }
                           
                       } else if responseType == [HpsiData].self {
                           let decodedResponse = try JSONDecoder().decode([HpsiData].self, from: data)
                           self.hpsiData = decodedResponse.map { HpsiDataModel(from: $0)}
                       } else {
                           self.handleError(.decodingFailed) // Should not normally happen
                       }
                   } catch {
                       self.handleError(NationalHousingSurveyViewAPIError.decodingFailed)
                   }
               }
               .store(in: &cancellables)
       }

       /// Determines the expected type for decoding.
       private func determineResponseType(for endpoint: NationalHousingSurveyViewAPIEndpoint) -> Decodable.Type {
           switch endpoint {
           case .nhsResults:
               return [NhsResults].self // Returns an array of NhsResults
           case .hpsiData, .hpsiDataByAreaType, .hpsiDataByOwnershipStatus, .hpsiDataByHousingCostRatio,
                .hpsiDataByAgeGroup, .hpsiDataByCensusRegion, .hpsiDataByIncomeGroup, .hpsiDataByEducation:
               return [HpsiData].self // Returns an array of HpsiData
           }
       }

    
    //Clear Local Data
    func clearLocalData() {
        surveyData.removeAll()
        hpsiData.removeAll()
     }

    // MARK: - Error Handling
    private func handleError(_ error: NationalHousingSurveyViewAPIError) {
        errorMessage = error.localizedDescription
        print("API Error: \(error.localizedDescription)")  // Log the error
    }
}

// MARK: - SwiftUI Views

struct NationalHousingSurveyView: View {
    @StateObject private var dataService = NationalHousingSurveyService()
    @State private var selectedAreaType: String = "1"  // Default: Urban
    @State private var selectedOwnershipStatus: String = "1" // Default: Owner
    @State private var selectedHousingCostRatio: String = "1" //Default: Low
    @State private var selectedAgeGroup: String = "1"
    @State private var selectedCensusRegion: String = "1"
    @State private var selectedIncomeGroup: String = "1"
    @State private var selectedEducation: String = "1"

    let areaTypes = ["1", "2", "3"]
    let ownershipStatuses = ["1", "2"]
    let housingCostRatios = ["1", "2", "3"]
    let ageGroups = ["1", "2", "3", "4"]
    let censusRegions = ["1", "2", "3", "4"]
    let incomeGroups = ["1", "2", "3"]
    let educationLevels = ["1", "2", "3", "4"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                    // Buttons to fetch general data
                    Button("Fetch All NHS Results") {
                        dataService.fetchData(for: .nhsResults)
                    }.buttonStyle(.bordered)
                    
                    Button("Fetch All HPSI Data") {
                        dataService.fetchData(for: .hpsiData)
                    }.buttonStyle(.bordered)
                    
                    // Pickers and buttons for filtered HPSI data
                    Picker("Area Type", selection: $selectedAreaType) {
                        ForEach(areaTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    Button("Fetch HPSI by Area Type") {
                        dataService.fetchData(for: .hpsiDataByAreaType(areaType: selectedAreaType))
                    }.buttonStyle(.bordered)

                    Picker("Ownership Status", selection: $selectedOwnershipStatus) {
                        ForEach(ownershipStatuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    
                    Button("Fetch by Ownership Status") {
                           dataService.fetchData(for: .hpsiDataByOwnershipStatus(ownershipStatus: selectedOwnershipStatus))
                       }
                       .buttonStyle(.bordered)

                    Picker("Housing Cost Ratio", selection: $selectedHousingCostRatio) {
                        ForEach(housingCostRatios, id: \.self) { ratio in
                            Text(ratio).tag(ratio)
                        }
                    }
                    Button("Fetch by Housing Cost Ratio") {
                          dataService.fetchData(for: .hpsiDataByHousingCostRatio(housingCostRatio: selectedHousingCostRatio))
                      }
                      .buttonStyle(.bordered)
                    
                    Picker("Age Group", selection: $selectedAgeGroup) {
                            ForEach(ageGroups, id: \.self) { group in
                                Text(group).tag(group)
                            }
                        }
                    
                    Button("Fetch by Age Group") {
                           dataService.fetchData(for: .hpsiDataByAgeGroup(ageGroup: selectedAgeGroup))
                       }
                       .buttonStyle(.bordered)
                    
                    Picker("Census Region", selection: $selectedCensusRegion) {
                        ForEach(censusRegions, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    
                    Button("Fetch by Census Region") {
                           dataService.fetchData(for: .hpsiDataByCensusRegion(censusRegion: selectedCensusRegion))
                       }
                       .buttonStyle(.bordered)
                    
                    Picker("Income Group", selection: $selectedIncomeGroup) {
                        ForEach(incomeGroups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    
                    Button("Fetch by Income Group") {
                           dataService.fetchData(for: .hpsiDataByIncomeGroup(incomeGroup: selectedIncomeGroup))
                       }
                       .buttonStyle(.bordered)
                    
                    Picker("Education", selection: $selectedEducation) {
                           ForEach(educationLevels, id: \.self) { level in
                               Text(level).tag(level)
                           }
                       }
                    
                    Button("Fetch by Education") {
                           dataService.fetchData(for: .hpsiDataByEducation(educationLevel: selectedEducation))
                       }
                       .buttonStyle(.bordered)

                    Button("Clear Data", role: .destructive) {
                        dataService.clearLocalData()

                }
                }

                
                Section(header: Text("Results")) {
                    if dataService.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if !dataService.surveyData.isEmpty {
                         List(dataService.surveyData) { survey in
                             VStack(alignment: .leading) {
                                 Text("Date: \(survey.date)").font(.headline)
                                 ForEach(survey.questions) { question in
                                     VStack(alignment: .leading) {
                                         Text("Q: \(question.description)").font(.subheadline)
                                        ForEach(question.responses) { response in
                                            HStack {
                                                Text("A: \(response.description)")
                                                Spacer()
                                                Text("\(String(format: "%.1f", response.percent))%")
                                          }
                                        }
                                     }.padding(.leading)
                                 }
                             }
                         }
                    } else if !dataService.hpsiData.isEmpty {
                        List(dataService.hpsiData) { data in
                            VStack(alignment: .leading) {
                                Text("Date: \(data.date)")
                                Text("HPSI Value: \(String(format: "%.2f", data.hpsiValue))")
                            }
                        }

                    } else {
                        Text("No data available.")
                    }
                }
            }
            .navigationTitle("National Housing Survey")
        }
    }
}

// MARK: - Preview

struct NationalHousingSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        NationalHousingSurveyView()
    }
}
