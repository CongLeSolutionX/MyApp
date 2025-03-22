//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI
import Combine

// MARK: - Data Models

struct LoanPerformanceData: Identifiable, Codable {
    let id = UUID()
    let s3Uri: String
    let year: Int?
    let quarter: String?
    let effectiveDate: String? // For LphDetailResponse

    // Custom initializer to handle both LphDetails and LphResponse
    init(from details: LphDetails) {
        self.s3Uri = details.s3Uri
        self.year = details.year
        self.quarter = details.quarter
        self.effectiveDate = nil // Not applicable for individual details
    }
    
    init(from response: LphResponse) {
        self.s3Uri = response.s3Uri
        self.effectiveDate = response.effectiveDate
        self.year = nil
        self.quarter = nil
    }
}

// Structs for API response decoding.  Mirrors the OpenAPI spec.
struct LphDetailResponse: Decodable {
    let effectiveDate: String
    let lphResponse: [LphDetails]
}

struct LphDetails: Decodable {
    let s3Uri: String
    let year: Int?
    let quarter: String?
}

struct LphResponse: Decodable {
    let s3Uri: String
    let effectiveDate: String
}

// MARK: - Enums for API Endpoints

enum APIEndpoint {
    case yearlyQuarterly(year: Int, quarter: String)
    case harp
    case primary
    
    var path: String {
        switch self {
        case .yearlyQuarterly(let year, let quarter):
            return "/v1/sf-loan-performance-data/years/\(year)/quarters/\(quarter)"
        case .harp:
            return "/v1/sf-loan-performance-data/harp-dataset"
        case .primary:
            return "/v1/sf-loan-performance-data/primary-dataset"
        }
    }
}


// MARK: - Error Handling

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String) // Include error message from API
    case decodingFailed
    case noData
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
            return "No data found for the given parameters."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Service (Placeholder for API calls, using local storage)

class LoanPerformanceDataService: ObservableObject {
    @Published var loanData: [LoanPerformanceData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.fanniemae.com" // As per your provided OpenAPI spec
    private let localDataKey = "loanPerformanceData" // Key for UserDefaults.
    private var cancellables = Set<AnyCancellable>() // For Combine

    init() {
        loadLocalData()
    }

    // MARK: - Public API Interaction Methods (with local storage)
     func fetchData(for endpoint: APIEndpoint) {
         isLoading = true
         errorMessage = nil
         
         // Construct the full URL.
         guard let url = URL(string: baseURLString + endpoint.path) else {
             self.isLoading = false
             self.errorMessage = APIError.invalidURL.localizedDescription
             return
         }
         
         
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.addValue("application/json", forHTTPHeaderField: "accept")

           // In a real app, you MUST use a secure method to store and provide the API key!
           //  Keychain Services is the recommended approach.  Do *NOT* hardcode it.
           // request.addValue("YOUR_API_KEY", forHTTPHeaderField: "Authorization")  // Replace with your API Key
          #warning("Replace with Your API Key and do not store it here")

         let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                  DispatchQueue.main.async {
                      guard let self = self else { return }
                      self.isLoading = false
                      
                      if let error = error {
                   self.handleError(.unknown(error))
                        return
                      }
                      
                      guard let httpResponse = response as? HTTPURLResponse else {
                         self.handleError(.requestFailed("Invalid response"))
                         return
                      }
                      
                      guard (200...299).contains(httpResponse.statusCode) else {
                        self.handleError(.requestFailed("HTTP Status Code: \(httpResponse.statusCode)"))
                          // In a real app, parse the error response from the API for a more detailed message.
                          return
                      }
                      
                      guard let data = data else {
                         self.handleError(.noData)
                          return
                      }
                    
                      // Handle response based on endpoint.
                      do {
                      switch endpoint {
                          case .yearlyQuarterly:
                              let decodedResponse = try JSONDecoder().decode(LphDetailResponse.self, from: data)
                            self.loanData = decodedResponse.lphResponse.map { LoanPerformanceData(from: $0) }

                          case .harp, .primary:
                              let decodedResponse = try JSONDecoder().decode(LphResponse.self, from: data)
                             self.loanData = [LoanPerformanceData(from: decodedResponse)]  // Single object usually
                      }
                         // Store after update.
                            self.saveLocalData()
                    } catch{
                         self.handleError(.decodingFailed)
                   }
                  }
              }
              task.resume()
     }

       private func handleError(_ error: APIError) {
         errorMessage = error.localizedDescription
         print("handleError \(error)") // Log for debugging.
        }


    // MARK: - Local Storage Methods (UserDefaults)

    private func saveLocalData() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(loanData)
            UserDefaults.standard.set(encodedData, forKey: localDataKey)
        } catch {
            print("Error encoding loan data: \(error)") // Log for debugging.
            errorMessage = "Failed to save data locally."
        }
    }

    private func loadLocalData() {
        guard let data = UserDefaults.standard.data(forKey: localDataKey) else {
            return // No data saved yet.
        }
        do {
            let decoder = JSONDecoder()
            loanData = try decoder.decode([LoanPerformanceData].self, from: data)
        } catch {
            print("Error decoding loan data: \(error)") // Log for debugging.
            errorMessage = "Failed to load data locally."
        }
    }

    func clearLocalData() {
        loanData = []
        UserDefaults.standard.removeObject(forKey: localDataKey)
        errorMessage = "Local data cleared."
    }
}


// MARK: - SwiftUI Views

struct ContentView: View {
    @StateObject private var dataService = LoanPerformanceDataService()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedQuarter: String = "Q1"
    private let quarters = ["Q1", "Q2", "Q3", "Q4", "All"]
       private var availableYears: [Int] {
           // Generate a range of years, e.g., from 2000 to the current year.
           let startYear = 2000
           let currentYear = Calendar.current.component(.year, from: Date())
           return Array(startYear...currentYear)
       }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Selection")) {
                   Picker("Year", selection: $selectedYear) {
                       ForEach(availableYears, id: \.self) { year in
                           Text("\(year)").tag(year)
                       }
                   }
                   Picker("Quarter", selection: $selectedQuarter) {
                       ForEach(quarters, id: \.self) { quarter in
                           Text(quarter).tag(quarter)
                       }
                   }
                    
                    Button("Fetch Yearly/Quarterly Data") {
                        dataService.fetchData(for: .yearlyQuarterly(year: selectedYear, quarter: selectedQuarter))
                    }
                    
                    Button("Fetch HARP Data") {
                        dataService.fetchData(for: .harp)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Fetch Primary Data") {
                        dataService.fetchData(for: .primary)
                    }
                   .buttonStyle(.borderedProminent)

                   Button("Clear Local Data", role: .destructive) {
                        dataService.clearLocalData()
                    }
                }

                Section(header: Text("Loan Performance Data")) {
                    if dataService.isLoading {
                        ProgressView()
                    } else if let errorMessage = dataService.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        List(dataService.loanData) { data in
                            VStack(alignment: .leading) {
                                Text("S3 URI: \(data.s3Uri)")
                                    .font(.caption)
                                if let year = data.year {
                                      Text("Year:  \(String(describing: year))")
                                }
                                if let quarter = data.quarter {
                                    Text("Quarter: \(quarter)")
                                }
                                if let effectDate = data.effectiveDate {
                                  Text("Effective Date: \(effectDate)")

                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fannie Mae Data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
