////
////  ConstructionSpendingView_v2.swift
////  MyApp
////
////  Created by Cong Le on 4/28/25.
////
//
//import SwiftUI
//import Combine // For ObservableObject
//
//// MARK: - 1. Model Layer (Codable Structs for API Responses)
//
//// Matches the structure for GET requests like /section, /sectionandsector, etc.
//struct ConstructionSpendingDto: Codable, Identifiable {
//    // Add an id for Identifiable conformance in SwiftUI Lists
//    let id = UUID()
//    let constructionSpending: [ConstructionSpendingDatumDto]
//
//    // Implement CodingKeys if JSON keys differ from struct properties (e.g., kebab-case)
//    enum CodingKeys: String, CodingKey {
//        case constructionSpending = "constructionSpending" // Example if key matched
//    }
//}
//
//struct ConstructionSpendingDatumDto: Codable, Identifiable {
//    let id = UUID() // For Identifiable
//    let constructionSpendingValue: Double? // Make optional to handle potential nulls
//    let monthAndValueType: String?
//    let monthLabelType: String?
//    let dataSectionName: String?
//
//    enum CodingKeys: String, CodingKey {
//        case constructionSpendingValue = "construction-spending-value"
//        case monthAndValueType = "month-and-value-type"
//        case monthLabelType = "month-label-type"
//        case dataSectionName = "data-section-name"
//    }
//}
//
//// Note: Models for the POST /multiple endpoint (MultiplePostResponse, etc.)
//// are not included here as we are focusing on the more straightforward GET requests
//// for this initial implementation based on the UI design chosen.
//
//// Error Handling Enum
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case requestFailed(Error)
//    case invalidResponseStatus(Int)
//    case dataDecodingError(Error)
//    case noData // For 204 No Content or empty arrays
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "The API endpoint URL is invalid."
//        case .requestFailed(let error):
//            return "Network request failed: \(error.localizedDescription)"
//        case .invalidResponseStatus(let status):
//            return "Received invalid response status: \(status)"
//        case .dataDecodingError(let error):
//            if let decodingError = error as? DecodingError {
//                 // Provide more specific decoding error info if possible
//                return "Failed to decode data: \(decodingError.localizedDescription). Context: \(decodingError.failureReason ?? "N/A")"
//            }
//            return "Failed to decode data: \(error.localizedDescription)"
//        case .noData:
//            return "No data found for the selected criteria."
//        }
//    }
//}
//
//// MARK: - 2. Service Layer (Handles Network Requests)
//
//class APIService {
//    private let baseURL = URL(string: "https://api.fanniemae.com")!
//    // IMPORTANT: In a real app, add API Key handling if required by Fannie Mae
//    // private let apiKey = "YOUR_API_KEY"
//
//    func fetchData(section: String, sector: String?, subsector: String?) async throws -> [ConstructionSpendingDto] {
//        var components: URLComponents
//
//        // Determine endpoint and build URL based on provided parameters
//        if let sector = sector, let subsector = subsector, !sector.isEmpty, !subsector.isEmpty {
//            // Section, Sector & Subsector
//            components = URLComponents(url: baseURL.appendingPathComponent("/v1/construction-spending/sectionsectorandsubsector"), resolvingAgainstBaseURL: false)!
//            components.queryItems = [
//                URLQueryItem(name: "section", value: section),
//                URLQueryItem(name: "sector", value: sector),
//                URLQueryItem(name: "subsector", value: subsector)
//            ]
//        } else if let sector = sector, !sector.isEmpty {
//            // Section & Sector
//            components = URLComponents(url: baseURL.appendingPathComponent("/v1/construction-spending/sectionandsector"), resolvingAgainstBaseURL: false)!
//            components.queryItems = [
//                URLQueryItem(name: "section", value: section),
//                URLQueryItem(name: "sector", value: sector)
//            ]
//        } else {
//            // Section Only
//            components = URLComponents(url: baseURL.appendingPathComponent("/v1/construction-spending/section"), resolvingAgainstBaseURL: false)!
//            components.queryItems = [
//                URLQueryItem(name: "section", value: section)
//            ]
//        }
//
//        guard let url = components.url else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//        // Add API Key Header if needed:
//        // request.setValue(apiKey, forHTTPHeaderField: "Your-API-Key-Header-Name")
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw APIError.requestFailed(URLError(.badServerResponse)) // Or a custom error
//            }
//
//            switch httpResponse.statusCode {
//            case 200:
//                // Decode the JSON data
//                do {
//                    let decoder = JSONDecoder()
//                    let spendingData = try decoder.decode([ConstructionSpendingDto].self, from: data)
//                     // Check if the result is logically empty (e.g., DTO exists but inner array is empty)
//                    if spendingData.allSatisfy({ $0.constructionSpending.isEmpty }) {
//                       throw APIError.noData
//                    }
//                    return spendingData
//                } catch {
//                     print("Decoding Error Details: \(error)") // Log detailed error
//                    throw APIError.dataDecodingError(error)
//                }
//            case 204:
//                // No content, return empty or throw specific error
//                throw APIError.noData
//            case 401, 403: // Unauthorized or Forbidden
//                 // Handle authentication/authorization errors specifically if needed
//                throw APIError.invalidResponseStatus(httpResponse.statusCode) // Simple handling for now
//            case 404: // Not Found
//                 throw APIError.noData // Treat 404 as no data found per spec description
//            default:
//                // Handle other error status codes
//                throw APIError.invalidResponseStatus(httpResponse.statusCode)
//            }
//        } catch let error as APIError {
//            throw error // Re-throw known API errors
//        } catch {
//             // Catch URLSession or other underlying errors
//            throw APIError.requestFailed(error)
//        }
//    }
//}
//
//// MARK: - 3. ViewModel Layer (Manages State and Logic)
//
//@MainActor // Ensure UI updates happen on the main thread
//class SpendingViewModel: ObservableObject {
//    @Published var spendingData: [ConstructionSpendingDto] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    // --- Selection State ---
//    @Published var selectedSection: String = "Total" // Default selection
//    @Published var selectedSector: String = "" // Default to none
//    @Published var selectedSubsector: String = "" // Default to none
//
//    // --- Picker Options ---
//    let sections = ["Total", "Private", "Public"]
//    let sectors = ["", "Residential", "Nonresidential"] // Include "" for "None" option
//    let subsectors = ["", "Lodging", "Office", "Commercial", "Health care", "Educational", "Religious", "Public safety", "Amusement and recreation", "Transportation", "Communication", "Power", "Highway and street", "Sewage and waste disposal", "Water supply", "Conservation and development", "Manufacturing"] // Include ""
//
//    private let apiService = APIService()
//
//    func fetchData() {
//        // Don't fetch if section is somehow empty (shouldn't happen with picker)
//        guard !selectedSection.isEmpty else {
//            errorMessage = "Please select a valid Section."
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//        spendingData = [] // Clear previous results
//
//        Task {
//            do {
//                // Pass optional values correctly (nil if empty string)
//                let sector = selectedSector.isEmpty ? nil : selectedSector
//                let subsector = selectedSubsector.isEmpty ? nil : selectedSubsector
//
//                let results = try await apiService.fetchData(
//                    section: selectedSection,
//                    sector: sector,
//                    subsector: subsector
//                )
//                self.spendingData = results
//                self.isLoading = false
//            } catch let error as APIError {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            } catch {
//                // Catch any other unexpected errors
//                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//
//    // Helper to determine if "None" should be disabled for Subsector
//    var isSubsectorSelectionEnabled: Bool {
//        // Subsector only makes sense if a Sector is selected (and is Nonresidential)
//        return !selectedSector.isEmpty && selectedSector == "Nonresidential"
//    }
//
//    // Reset Subsector if Sector changes to something incompatible
//    func sectorDidChange() {
//        if !isSubsectorSelectionEnabled && !selectedSubsector.isEmpty {
//            selectedSubsector = ""
//        }
//    }
//}
//
//// MARK: - 4. View Layer (SwiftUI Interface)
//
//struct ContentView: View {
//    @StateObject private var viewModel = SpendingViewModel()
//
//    var body: some View {
//        NavigationView {
//            Form {
//                // --- Input Section ---
//                Section("Query Parameters") {
//                    Picker("Section", selection: $viewModel.selectedSection) {
//                        ForEach(viewModel.sections, id: \.self) { section in
//                            Text(section).tag(section)
//                        }
//                    }
//
//                    Picker("Sector", selection: $viewModel.selectedSector) {
//                        ForEach(viewModel.sectors, id: \.self) { sector in
//                             Text(sector.isEmpty ? "None" : sector).tag(sector)
//                        }
//                    }
//                    .onChange(of: viewModel.selectedSector) {
//                        viewModel.sectorDidChange() // Reset subsector if needed
//                    }
//
//                    Picker("Subsector", selection: $viewModel.selectedSubsector) {
//                         ForEach(viewModel.subsectors, id: \.self) { subsector in
//                             Text(subsector.isEmpty ? "None" : subsector).tag(subsector)
//                         }
//                     }
//                     // Disable subsector unless a valid sector (Nonresidential) is selected
//                     .disabled(!viewModel.isSubsectorSelectionEnabled)
//                     .opacity(viewModel.isSubsectorSelectionEnabled ? 1.0 : 0.5) // Visual cue
//                }
//
//                // --- Action Button ---
//                Section {
//                    Button("Fetch Construction Spending Data") {
//                        viewModel.fetchData()
//                    }
//                    .disabled(viewModel.isLoading) // Disable button while loading
//                }
//
//                // --- Results Section ---
//                Section("Results") {
//                    if viewModel.isLoading {
//                        HStack {
//                            Spacer()
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                            Text("Loading...")
//                            Spacer()
//                        }
//                    } else if let errorMessage = viewModel.errorMessage {
//                        Text("Error: \(errorMessage)")
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.center)
//                    } else if viewModel.spendingData.isEmpty {
//                         Text("No data available for the selected criteria. Try adjusting the parameters.")
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                    } else {
//                        // Display the fetched data
//                        List {
//                            ForEach(viewModel.spendingData) { dto in
//                                // You might want a more specific section header if multiple DTOs are returned
//                                ForEach(dto.constructionSpending) { datum in
//                                    DataRow(datum: datum)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Construction Spending")
//        }
//    }
//}
//
//// Helper View for displaying a single data row
//struct DataRow: View {
//    let datum: ConstructionSpendingDatumDto
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Section: \(datum.dataSectionName ?? "N/A")")
//                 .font(.headline)
//            HStack {
//                Text("Period:")
//                Text(datum.monthAndValueType ?? "N/A")
//            }
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//            HStack {
//                 Text("Value:")
//                 Text(datum.constructionSpendingValue ?? 0.0, format: .currency(code:"USD").precision(.fractionLength(0))) // Format as currency (adjust precision/currency code as needed)
//                    .fontWeight(.bold)
//            }
//             .font(.subheadline)
//
//        }
//        .padding(.vertical, 4)
//    }
//}
//#Preview("ContentView") {
//    ContentView()
//}
//
//// MARK: - 5. App Entry Point
////
////@main
////struct ConstructionSpendingApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
