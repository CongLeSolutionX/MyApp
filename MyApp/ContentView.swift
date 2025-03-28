////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//
//// MARK: - Data Models (Mimicking API Schemas)
//
//// Represents the outcome of an address check
//struct OpportunityZoneResult: Codable, Hashable {
//    var resultStatus: String // e.g., "Success", "Address Not Found"
//    var belongsToOpportunityZones: String // "Yes", "No", "Unknown"
//    var censusTractNumber: String? // Optional tract number
//    var category: String? // Optional category info
//}
//
//// Represents a full address along with its Opportunity Zone check result
//struct AddressInfo: Codable, Identifiable, Hashable {
//    var id = UUID() // For SwiftUI list identification
//    var number: String
//    var streetAddress: String
//    var city: String
//    var state: String
//    var zip: String
//    var result: OpportunityZoneResult? // Result is optional until checked
//
//    // Computed property for display
//    var fullAddress: String {
//        "\(number) \(streetAddress), \(city), \(state) \(zip)"
//    }
//}
//
//// Represents a single Opportunity Zone census tract
//struct OpportunityZone: Codable, Identifiable, Hashable {
//    var id = UUID() // For SwiftUI list identification
//    var state: String
//    var county: String? // County might be optional in some contexts or derived
//    var censusTractNumber: String
//    var tractType: String? // e.g., "Qualified", "Eligible"
//    var acsDataSource: String? // Data source info
//}
//
//// MARK: - Mock Data Service (Local Storage Simulation)
//
//class MockDataService {
//
//    // Sample data - replace with more extensive list or loading from local JSON if needed
//    private let sampleAddresses: [AddressInfo] = [
//        AddressInfo(number: "13150", streetAddress: "Worldgate Drive", city: "Herndon", state: "VA", zip: "20171",
//                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "Yes", censusTractNumber: "610100", category: "Low-Income Community")),
//        AddressInfo(number: "1600", streetAddress: "Amphitheatre Pkwy", city: "Mountain View", state: "CA", zip: "94043",
//                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "No", censusTractNumber: nil, category: nil)),
//        AddressInfo(number: "1", streetAddress: "Infinite Loop", city: "Cupertino", state: "CA", zip: "95014",
//                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "No", censusTractNumber: "506503", category: nil)), // Example tract
//         AddressInfo(number: "123", streetAddress: "Main St", city: "Anytown", state: "VA", zip: "12345",
//                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "Yes", censusTractNumber: "610200", category: "Low-Income Community")),
//    ]
//
//    private let sampleZones: [OpportunityZone] = [
//        OpportunityZone(state: "VA", county: "Fairfax", censusTractNumber: "610100", tractType: "Qualified", acsDataSource: "ACS 2015"),
//        OpportunityZone(state: "VA", county: "Fairfax", censusTractNumber: "610200", tractType: "Qualified", acsDataSource: "ACS 2015"),
//        OpportunityZone(state: "VA", county: "Arlington", censusTractNumber: "101100", tractType: "Qualified", acsDataSource: "ACS 2015"),
//        OpportunityZone(state: "CA", county: "Santa Clara", censusTractNumber: "506503", tractType: "Contiguous", acsDataSource: "ACS 2015"), // Note: Not necessarily a real OZ, just for matching
//        OpportunityZone(state: "CA", county: "Alameda", censusTractNumber: "400100", tractType: "Qualified", acsDataSource: "ACS 2015"),
//    ]
//
//    // Simulates the GET /v1/opportunity-zones/addresscheck endpoint
//    func checkSingleAddress(number: String, street: String, city: String, state: String, zip: String) async throws -> AddressInfo {
//        // Simulate network delay
//        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
//
//        // Basic validation simulation
//        if number.isEmpty || street.isEmpty || city.isEmpty || state.isEmpty || zip.isEmpty {
//             throw NSError(domain: "MockDataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing required address fields."])
//        }
//
//        // Find matching address in mock data (case-insensitive comparison)
//        if let foundAddress = sampleAddresses.first(where: {
//            $0.number.lowercased() == number.lowercased() &&
//            $0.streetAddress.lowercased() == street.lowercased() &&
//            $0.city.lowercased() == city.lowercased() &&
//            $0.state.uppercased() == state.uppercased() && // States often uppercase
//            $0.zip == zip
//        }) {
//            return foundAddress
//        } else {
//            // Simulate address not found or not in OZ database explicitly
//            // Return a basic structure indicating not found/checked
//             return AddressInfo(
//                number: number, streetAddress: street, city: city, state: state, zip: zip,
//                result: OpportunityZoneResult(resultStatus: "Address Match Not Found", belongsToOpportunityZones: "Unknown", censusTractNumber: nil, category: nil)
//             )
//            // Alternatively, throw an error:
//            // throw NSError(domain: "MockDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Address not found in mock data."])
//        }
//    }
//
//    // Simulates the POST /v1/opportunity-zones/addressvalidation endpoint (Simplified)
//    // A real implementation would parse the input string, call checkSingleAddress repeatedly.
//    // For this example, we'll just return a fixed collection matching the first sample address.
//    func checkMultipleAddresses(input: String) async throws -> [AddressInfo] {
//         try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay
//         // Simulate finding only the first sample address if mentioned
//        if input.contains("13150") && input.contains("Worldgate Drive") {
//             return [sampleAddresses[0]]
//         }
//         return [] // Return empty if no match logic implemented here
//    }
//
//
//    // Simulates the GET /v1/opportunity-zones/censustracts endpoint
//    func findZonesByRegion(state: String, county: String?) async throws -> [OpportunityZone] {
//        // Simulate network delay
//        try await Task.sleep(nanoseconds: 1_200_000_000) // 1.2 second delay
//
//        if state.isEmpty {
//             throw NSError(domain: "MockDataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "State cannot be empty."])
//        }
//
//
//        let stateFiltered = sampleZones.filter { $0.state.uppercased() == state.uppercased() }
//
//        if let county = county, !county.isEmpty {
//            // Filter by county as well (case-insensitive)
//            let countyFiltered = stateFiltered.filter { $0.county?.lowercased() == county.lowercased() }
//            // Simulate 404 if state is valid but county yields no results
//            // In a real API, the API might return 200 with empty list or 404. Here we return empty list for simplicity.
//            return countyFiltered
//
//        } else {
//            // Return all zones for the state if no county is specified
//             // If stateFiltered is empty after filtering by a valid state, it effectively simulates a 404 for the state
//             return stateFiltered
//        }
//    }
//}
//
//// MARK: - View Models (State Management)
//
//@MainActor // Ensure UI updates happen on the main thread
//class SingleAddressViewModel: ObservableObject {
//    @Published var number: String = ""
//    @Published var street: String = ""
//    @Published var city: String = ""
//    @Published var state: String = ""
//    @Published var zip: String = ""
//
//    @Published private(set) var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var resultAddress: AddressInfo? = nil
//
//    private let dataService: MockDataService
//
//    init(dataService: MockDataService = MockDataService()) {
//        self.dataService = dataService
//    }
//
//    var canSubmit: Bool {
//        !number.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty && !isLoading
//    }
//
//    func checkAddress() {
//        guard canSubmit else {
//            errorMessage = "Please fill in all address fields."
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//        resultAddress = nil
//
//        Task {
//            do {
//                let addressResult = try await dataService.checkSingleAddress(
//                    number: number,
//                    street: street,
//                    city: city,
//                    state: state,
//                    zip: zip
//                )
//                self.resultAddress = addressResult
//                self.isLoading = false
//            } catch {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//@MainActor
//class StateCountyViewModel: ObservableObject {
//    @Published var selectedState: String = ""
//    @Published var county: String = "" // Optional county
//
//    @Published private(set) var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var opportunityZones: [OpportunityZone] = []
//    @Published private(set) var searched: Bool = false // To know if a search was attempted
//
//    private let dataService: MockDataService
//
//    // Example states - Use a more robust source in a real app
//    let states = ["", "VA", "CA", "MD", "DC", "NY", "TX"] // Add more as needed
//
//    init(dataService: MockDataService = MockDataService()) {
//        self.dataService = dataService
//    }
//
//     var canSubmit: Bool {
//        !selectedState.isEmpty && !isLoading
//    }
//
//    func findZones() {
//         guard canSubmit else {
//             errorMessage = "Please select a state."
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//        opportunityZones = [] // Clear previous results
//        searched = true // Mark that a search was done
//
//        Task {
//            do {
//                let zonesResult = try await dataService.findZonesByRegion(
//                    state: selectedState,
//                    county: county.isEmpty ? nil : county // Pass nil if county field is empty
//                )
//                self.opportunityZones = zonesResult
//                self.isLoading = false
//            } catch {
//                self.errorMessage = error.localizedDescription
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//
//// MARK: - SwiftUI Views
//
//struct ContentView: View {
//    // Create a single instance of the service if needed globally, or instantiate per ViewModel
//     // For this simple case, ViewModels will create their own.
//
//    var body: some View {
//        TabView {
//            SingleAddressCheckView()
//                .tabItem {
//                    Label("Single Address", systemImage: "location.magnifyingglass")
//                }
//
//            StateCountyCheckView()
//                .tabItem {
//                    Label("State/County", systemImage: "map")
//                }
//             // Placeholder for Bulk Upload if added later
//             Text("Bulk Address Check (Not Implemented)")
//                 .tabItem {
//                     Label("Bulk Check", systemImage: "doc.text.magnifyingglass")
//                 }
//        }
//    }
//}
//
//struct SingleAddressCheckView: View {
//    @StateObject private var viewModel = SingleAddressViewModel()
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text("Enter Address Details").font(.headline)
//
//                TextField("Building Number", text: $viewModel.number)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .keyboardType(.numbersAndPunctuation) // Adjust as needed
//                TextField("Street Name", text: $viewModel.street)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                TextField("City", text: $viewModel.city)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                 HStack {
//                     TextField("State (e.g., VA)", text: $viewModel.state)
//                         .textFieldStyle(RoundedBorderTextFieldStyle())
//                         .autocapitalization(.allCharacters)
//                     TextField("Zip Code", text: $viewModel.zip)
//                         .textFieldStyle(RoundedBorderTextFieldStyle())
//                         .keyboardType(.numberPad)
//                 }
//
//
//                Button {
//                    viewModel.checkAddress()
//                } label: {
//                    HStack {
//                        Spacer()
//                        if viewModel.isLoading {
//                            ProgressView().tint(.white)
//                        } else {
//                            Text("Check Opportunity Zone")
//                        }
//                        Spacer()
//                    }
//                    .padding()
//                    .background(viewModel.canSubmit ? Color.blue : Color.gray)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//                .disabled(!viewModel.canSubmit)
//
//                // --- Result Display Area ---
//                if let errorMessage = viewModel.errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding(.top)
//                } else if let result = viewModel.resultAddress {
//                     AddressResultView(addressInfo: result)
//                         .padding(.top)
//                 }
//
//
//                Spacer() // Pushes content to the top
//            }
//            .padding()
//            .navigationTitle("Single Address Check")
//        }
//         // Hide keyboard when tapping outside TextFields
//         .onTapGesture {
//             hideKeyboard()
//         }
//    }
//}
//
//// View to display the result of a single address check
//struct AddressResultView: View {
//    let addressInfo: AddressInfo
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Result for: \(addressInfo.fullAddress)")
//                .font(.headline)
//
//            Divider()
//
//            if let result = addressInfo.result {
//                 HStack {
//                     Text("In Opportunity Zone:")
//                         .fontWeight(.medium)
//                     Text(result.belongsToOpportunityZones)
//                         .foregroundColor(result.belongsToOpportunityZones == "Yes" ? .green : (result.belongsToOpportunityZones == "No" ? .orange : .gray))
//                         .fontWeight(.bold)
//                 }
//
//                 HStack {
//                     Text("Status:")
//                         .fontWeight(.medium)
//                     Text(result.resultStatus)
//                 }
//
//                if let tract = result.censusTractNumber, !tract.isEmpty {
//                     HStack {
//                         Text("Census Tract:")
//                             .fontWeight(.medium)
//                         Text(tract)
//                     }
//                 }
//                if let category = result.category, !category.isEmpty {
//                      HStack {
//                          Text("Category:")
//                              .fontWeight(.medium)
//                          Text(category)
//                      }
//                 }
//
//            } else {
//                 Text("Result pending or not available.")
//                     .foregroundColor(.gray)
//            }
//        }
//        .padding()
//        .background(Color(UIColor.secondarySystemBackground)) // Subtle background
//        .cornerRadius(10)
//    }
//}
//
//struct StateCountyCheckView: View {
//    @StateObject private var viewModel = StateCountyViewModel()
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text("Select Region").font(.headline)
//
//                HStack {
//                     Text("State:")
//                     Picker("Select State", selection: $viewModel.selectedState) {
//                         ForEach(viewModel.states, id: \.self) { state in
//                             Text(state.isEmpty ? "Select State" : state).tag(state)
//                         }
//                     }
//                    .pickerStyle(.menu) // Or .wheel, .segmented
//                    .tint(.blue) // Make picker more visible
//                }
//
//                TextField("County (Optional)", text: $viewModel.county)
//                     .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                 Button {
//                     viewModel.findZones()
//                 } label: {
//                     HStack {
//                         Spacer()
//                         if viewModel.isLoading {
//                             ProgressView().tint(.white)
//                         } else {
//                             Text("Find Opportunity Zones")
//                         }
//                         Spacer()
//                     }
//                     .padding()
//                     .background(viewModel.canSubmit ? Color.blue : Color.gray)
//                     .foregroundColor(.white)
//                     .cornerRadius(8)
//                 }
//                 .disabled(!viewModel.canSubmit)
//
//                 // --- Result Display Area ---
//                 if let errorMessage = viewModel.errorMessage {
//                     Text("Error: \(errorMessage)")
//                         .foregroundColor(.red)
//                         .padding(.top)
//                 } else if viewModel.isLoading {
//                     ProgressView("Searching...")
//                         .padding(.top)
//                 } else if viewModel.searched && viewModel.opportunityZones.isEmpty {
//                      Text("No Opportunity Zones found for this selection.")
//                          .foregroundColor(.gray)
//                          .padding(.top)
//                 } else if !viewModel.opportunityZones.isEmpty {
//                     List {
//                         ForEach(viewModel.opportunityZones) { zone in
//                             OpportunityZoneRow(zone: zone)
//                         }
//                     }
//                     .listStyle(.plain) // Use plain style for less visual clutter
//                     .padding(.top)
//                 }
//
//
//                Spacer() // Pushes content to the top
//            }
//            .padding()
//            .navigationTitle("State/County Search")
//        }
//         // Hide keyboard when tapping outside TextFields
//         .onTapGesture {
//             hideKeyboard()
//         }
//    }
//}
//
//// View for a single row in the opportunity zone list
//struct OpportunityZoneRow: View {
//    let zone: OpportunityZone
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Tract: \(zone.censusTractNumber)")
//                 .font(.headline)
//             HStack {
//                 Text("County:")
//                 Text(zone.county ?? "N/A") // Handle optional county
//             }
//             .font(.subheadline)
//             .foregroundColor(.gray)
//            if let type = zone.tractType {
//                 Text("Type: \(type)")
//                     .font(.caption)
//            }
//
//        }
//    }
//}
//
//// MARK: - Keyboard Helper Extension
//
//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//#endif
//
//// MARK: - App Entry Point (if needed for preview or testing)
//
//struct OpportunityZoneApp_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//        OpportunityZoneRow(zone: OpportunityZone(state: "CA", county: "Test County", censusTractNumber: "12345"))
//    }
//}
import SwiftUI

// MARK: - Data Models (Mimicking API Schemas) - NO CHANGES HERE
// ... (Keep the AddressInfo, OpportunityZoneResult, OpportunityZone structs as they were) ...
struct OpportunityZoneResult: Codable, Hashable {
    var resultStatus: String
    var belongsToOpportunityZones: String
    var censusTractNumber: String?
    var category: String?
}

struct AddressInfo: Codable, Identifiable, Hashable {
    var id = UUID()
    var number: String
    var streetAddress: String
    var city: String
    var state: String
    var zip: String
    var result: OpportunityZoneResult?
    
    var fullAddress: String {
        "\(number) \(streetAddress), \(city), \(state) \(zip)"
    }
}

struct OpportunityZone: Codable, Identifiable, Hashable {
    var id = UUID()
    var state: String
    var county: String?
    var censusTractNumber: String
    var tractType: String?
    var acsDataSource: String?
}


// MARK: - Enhanced Mock Data Service - NO CHANGES HERE
// ... (Keep the MockDataService class with its sample data and methods as it was) ...
class MockDataService {
    
    // Private sample data from previous response
    private let sampleAddresses: [AddressInfo] = [
        AddressInfo(number: "13150", streetAddress: "Worldgate Drive", city: "Herndon", state: "VA", zip: "20171",
                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "Yes", censusTractNumber: "610100", category: "Low-Income Community")),
        AddressInfo(number: "1600", streetAddress: "Amphitheatre Pkwy", city: "Mountain View", state: "CA", zip: "94043",
                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "No", censusTractNumber: nil, category: nil)),
        AddressInfo(number: "1", streetAddress: "Infinite Loop", city: "Cupertino", state: "CA", zip: "95014",
                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "No", censusTractNumber: "506503", category: "Contiguous Tract")),
        AddressInfo(number: "456", streetAddress: "Elm St", city: "Baltimore", state: "MD", zip: "21201",
                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "Yes", censusTractNumber: "040100", category: "Low-Income Community")),
        AddressInfo(number: "789", streetAddress: "Oak Ave", city: "Arlington", state: "VA", zip: "22201",
                    result: OpportunityZoneResult(resultStatus: "Success", belongsToOpportunityZones: "Yes", censusTractNumber: "101100", category: "Low-Income Community")),
    ]
    
    private let sampleZones: [OpportunityZone] = [
        OpportunityZone(state: "VA", county: "Fairfax", censusTractNumber: "610100", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "VA", county: "Fairfax", censusTractNumber: "610200", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "VA", county: "Arlington", censusTractNumber: "101100", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "VA", county: "Loudoun", censusTractNumber: "611501", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "CA", county: "Santa Clara", censusTractNumber: "506503", tractType: "Contiguous", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "CA", county: "Alameda", censusTractNumber: "400100", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "CA", county: "Los Angeles", censusTractNumber: "980010", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "MD", county: "Baltimore City", censusTractNumber: "040100", tractType: "Qualified", acsDataSource: "ACS 2015"),
        OpportunityZone(state: "MD", county: "Montgomery", censusTractNumber: "701101", tractType: "Qualified", acsDataSource: "ACS 2015"),
    ]
    
    // Methods (checkSingleAddress, checkMultipleAddresses, findZonesByRegion)
    func checkSingleAddress(number: String, street: String, city: String, state: String, zip: String) async throws -> AddressInfo {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        guard !number.isEmpty, !street.isEmpty, !city.isEmpty, !state.isEmpty, !zip.isEmpty else {
            throw NSError(domain: "MockDataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing required address fields."])
        }
        if number == "999" {
            throw NSError(domain: "MockDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated Server Error - Cannot process."])
        }
        if let foundAddress = sampleAddresses.first(where: {
            $0.number.lowercased() == number.lowercased() &&
            $0.streetAddress.lowercased() == street.lowercased() &&
            $0.city.lowercased() == city.lowercased() &&
            $0.state.uppercased() == state.uppercased() &&
            $0.zip == zip
        }) { return foundAddress }
        else {
            return AddressInfo(
                number: number, streetAddress: street, city: city, state: state, zip: zip,
                result: OpportunityZoneResult(resultStatus: "Address Match Not Found", belongsToOpportunityZones: "Unknown", censusTractNumber: nil, category: nil)
            )
        }
    }
    func checkMultipleAddresses(input: String) async throws -> [AddressInfo] {
        try await Task.sleep(nanoseconds: 1_500_000_000); if input.contains("13150") && input.contains("Worldgate Drive") { return [sampleAddresses[0]] }; return []
    }
    func findZonesByRegion(state: String, county: String?) async throws -> [OpportunityZone] {
        try await Task.sleep(nanoseconds: 1_200_000_000); guard !state.isEmpty else { throw NSError(domain: "MockDataService", code: 400, userInfo: [NSLocalizedDescriptionKey: "State cannot be empty."])}; if state.uppercased() == "XX" { throw NSError(domain: "MockDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated Server Error for State XX."])}; let stateFiltered = sampleZones.filter { $0.state.uppercased() == state.uppercased() }; if let county = county, !county.isEmpty { let countyFiltered = stateFiltered.filter { $0.county?.lowercased() == county.lowercased() }; return countyFiltered } else { return stateFiltered }
    }
    
    // --- Added for direct access in previews if needed ---
    // These provide controlled access without redeclaring
    func getSampleAddresses() -> [AddressInfo] { return sampleAddresses }
    func getSampleZones() -> [OpportunityZone] { return sampleZones }
}


// MARK: - View Models (State Management) - NO CHANGES HERE
// ... (Keep SingleAddressViewModel and StateCountyViewModel as they were) ...
@MainActor
class SingleAddressViewModel: ObservableObject {
    @Published var number: String = ""
    @Published var street: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zip: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var resultAddress: AddressInfo? = nil
    private let dataService: MockDataService
    init(dataService: MockDataService = MockDataService()) { self.dataService = dataService }
    var canSubmit: Bool { !number.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty && !isLoading }
    func checkAddress() { guard canSubmit else { errorMessage = "Please fill in all address fields."; return }; isLoading = true; errorMessage = nil; resultAddress = nil; Task { do { let addressResult = try await dataService.checkSingleAddress(number: number, street: street, city: city, state: state, zip: zip); self.resultAddress = addressResult; self.isLoading = false } catch { self.errorMessage = error.localizedDescription; self.isLoading = false } } }
}

@MainActor
class StateCountyViewModel: ObservableObject {
    @Published var selectedState: String = ""
    @Published var county: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var opportunityZones: [OpportunityZone] = []
    @Published private(set) var searched: Bool = false
    private let dataService: MockDataService
    let states = ["", "VA", "CA", "MD", "NY", "TX", "XX"]
    init(dataService: MockDataService = MockDataService()) { self.dataService = dataService }
    var canSubmit: Bool { !selectedState.isEmpty && !isLoading }
    func findZones() { guard canSubmit else { errorMessage = "Please select a state."; return }; isLoading = true; errorMessage = nil; opportunityZones = []; searched = true; Task { do { let zonesResult = try await dataService.findZonesByRegion(state: selectedState, county: county.isEmpty ? nil : county); self.opportunityZones = zonesResult; self.isLoading = false } catch { self.errorMessage = error.localizedDescription; self.isLoading = false } } }
}


// MARK: - SwiftUI Views - NO CHANGES HERE
// ... (Keep ContentView, SingleAddressCheckView, AddressResultView, StateCountyCheckView, OpportunityZoneRow as they were) ...
// ... (Also keep the Keyboard Helper extension) ...
struct ContentView: View {
    var body: some View { TabView { SingleAddressCheckView().tabItem { Label("Single Address", systemImage: "location.magnifyingglass") }; StateCountyCheckView().tabItem { Label("State/County", systemImage: "map") }; Text("Bulk Address Check (Not Implemented)").tabItem { Label("Bulk Check", systemImage: "doc.text.magnifyingglass") } } }
}
struct SingleAddressCheckView: View {
    @StateObject private var viewModel = SingleAddressViewModel(); var body: some View { NavigationView { VStack(alignment: .leading, spacing: 15) { Text("Enter Address Details").font(.headline); TextField("Building Number", text: $viewModel.number).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.numbersAndPunctuation); TextField("Street Name", text: $viewModel.street).textFieldStyle(RoundedBorderTextFieldStyle()); TextField("City", text: $viewModel.city).textFieldStyle(RoundedBorderTextFieldStyle()); HStack { TextField("State (e.g., VA)", text: $viewModel.state).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.allCharacters); TextField("Zip Code", text: $viewModel.zip).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.numberPad) }; Button { viewModel.checkAddress() } label: { HStack { Spacer(); if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Check Opportunity Zone") }; Spacer() }.padding().background(viewModel.canSubmit ? Color.blue : Color.gray).foregroundColor(.white).cornerRadius(8) }.disabled(!viewModel.canSubmit); if let errorMessage = viewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red).padding(.top) } else if viewModel.isLoading { ProgressView("Checking...").padding(.top) } else if let result = viewModel.resultAddress { AddressResultView(addressInfo: result).padding(.top) }; Spacer() }.padding().navigationTitle("Single Address Check") }.onTapGesture { hideKeyboard() } }
}
struct AddressResultView: View {
    let addressInfo: AddressInfo; var body: some View { VStack(alignment: .leading, spacing: 8) { Text("Result for: \(addressInfo.fullAddress)").font(.headline); Divider(); if let result = addressInfo.result { HStack { Text("In Opportunity Zone:").fontWeight(.medium); Text(result.belongsToOpportunityZones).foregroundColor(result.belongsToOpportunityZones == "Yes" ? .green : (result.belongsToOpportunityZones == "No" ? .orange : .gray)).fontWeight(.bold) }; HStack { Text("Status:").fontWeight(.medium); Text(result.resultStatus) }; if let tract = result.censusTractNumber, !tract.isEmpty { HStack { Text("Census Tract:").fontWeight(.medium); Text(tract) } }; if let category = result.category, !category.isEmpty { HStack { Text("Category:").fontWeight(.medium); Text(category) } } } else { Text("Result pending or not available.").foregroundColor(.gray) } }.padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(10) }
}
struct StateCountyCheckView: View {
    @StateObject private var viewModel = StateCountyViewModel(); var body: some View { NavigationView { VStack(alignment: .leading, spacing: 15) { Text("Select Region").font(.headline); HStack { Text("State:"); Picker("Select State", selection: $viewModel.selectedState) { ForEach(viewModel.states, id: \.self) { state in Text(state.isEmpty ? "Select State" : state).tag(state) } }.pickerStyle(.menu).tint(.blue) }; TextField("County (Optional)", text: $viewModel.county).textFieldStyle(RoundedBorderTextFieldStyle()); Button { viewModel.findZones() } label: { HStack { Spacer(); if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Find Opportunity Zones") }; Spacer() }.padding().background(viewModel.canSubmit ? Color.blue : Color.gray).foregroundColor(.white).cornerRadius(8) }.disabled(!viewModel.canSubmit); if let errorMessage = viewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red).padding(.top) } else if viewModel.isLoading { ProgressView("Searching...").padding(.top) } else if viewModel.searched && viewModel.opportunityZones.isEmpty { Text("No Opportunity Zones found for this selection.").foregroundColor(.gray).padding(.top) } else if !viewModel.opportunityZones.isEmpty { List { Section("Found Zones in \(viewModel.selectedState)\(viewModel.county.isEmpty ? "" : " (\(viewModel.county))")") { ForEach(viewModel.opportunityZones) { zone in OpportunityZoneRow(zone: zone) } } }.listStyle(.plain).padding(.top) }; Spacer() }.padding().navigationTitle("State/County Search") }.onTapGesture { hideKeyboard() } }
}
struct OpportunityZoneRow: View {
    let zone: OpportunityZone; var body: some View { VStack(alignment: .leading) { Text("Tract: \(zone.censusTractNumber)").font(.headline); HStack { Text("County:"); Text(zone.county ?? "N/A") }.font(.subheadline).foregroundColor(.gray); if let type = zone.tractType { Text("Type: \(type)").font(.caption) } } }
}
#if canImport(UIKit)
extension View { func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) } }
#endif

// MARK: - SwiftUI Previews

#if DEBUG // Ensure previews are only compiled in Debug builds

struct SingleAddressCheckView_Previews: PreviewProvider {
    
    // FIX 1: Moved helper function OUTSIDE previews computed property, made static
    static func createViewModel() -> SingleAddressViewModel {
        SingleAddressViewModel(dataService: MockDataService())
    }
    
    // Access sample data via a method on the service instance
    static let mockService = MockDataService() // Create one instance for previews
    static let sampleAddresses = mockService.getSampleAddresses()
    
    static var previews: some View {
        Group {
            // 1. Idle State (Initial Load)
            SingleAddressCheckView(viewModel: createViewModel())
                .previewDisplayName("1. Idle")
            
            // 2. Input Entered State
            let vmInput = createViewModel()
            vmInput.number = "13150"
            vmInput.street = "Worldgate Drive"
            vmInput.city = "Herndon"
            vmInput.state = "VA"
            vmInput.zip = "20171"
            SingleAddressCheckView(viewModel: vmInput)
                .previewDisplayName("2. Input Entered")
            
            // 3. Loading State
            let vmLoading = createViewModel()
            vmLoading.number = "1600" // Use different data than input state
            vmLoading.street = "Amphitheatre Pkwy"
            vmLoading.city = "Mountain View"
            vmLoading.state = "CA"
            vmLoading.zip = "94043"
            vmLoading.isLoading = true // Manually set loading state
            SingleAddressCheckView(viewModel: vmLoading)
                .previewDisplayName("3. Loading")
            
            // 4. Success State - Is Opportunity Zone
            let vmSuccessYes = createViewModel()
            // Use sample data directly fetched from service
            if !sampleAddresses.isEmpty { vmSuccessYes.resultAddress = sampleAddresses[0] }
            SingleAddressCheckView(viewModel: vmSuccessYes)
                .previewDisplayName("4. Success - Is OZ")
            
            // 5. Success State - Is NOT Opportunity Zone
            let vmSuccessNo = createViewModel()
            if sampleAddresses.count > 1 { vmSuccessNo.resultAddress = sampleAddresses[1] }
            SingleAddressCheckView(viewModel: vmSuccessNo)
                .previewDisplayName("5. Success - Not OZ")
            
            // 6. Success State - Address Not Found/Unknown
            let vmSuccessUnknown = createViewModel()
            vmSuccessUnknown.resultAddress = AddressInfo(number: "123", streetAddress: "Fake St", city: "Nowhere", state: "XX", zip: "00000", result: OpportunityZoneResult(resultStatus: "Address Match Not Found", belongsToOpportunityZones: "Unknown", censusTractNumber: nil, category:nil))
            SingleAddressCheckView(viewModel: vmSuccessUnknown)
                .previewDisplayName("6. Success - Unknown/Not Found")
            
            // 7. Error State - API/Server Error
            let vmError = createViewModel()
            vmError.number = "999"; vmError.street="Err"; vmError.city="Err"; vmError.state="XX"; vmError.zip="111"
            vmError.errorMessage = "Simulated Server Error - Cannot process."
            SingleAddressCheckView(viewModel: vmError)
                .previewDisplayName("7. Error - API")
            
            // 8. Input Incomplete (Button Disabled)
            let vmIncomplete = createViewModel()
            vmIncomplete.number = "123"
            SingleAddressCheckView(viewModel: vmIncomplete)
                .previewDisplayName("8. Input Incomplete")
        }
    }
}

struct StateCountyCheckView_Previews: PreviewProvider {
    
    // FIX 1: Moved helper function OUTSIDE previews computed property, made static
    static func createViewModel() -> StateCountyViewModel {
        StateCountyViewModel(dataService: MockDataService())
    }
    
    // FIX 1: Moved helper constant OUTSIDE previews computed property, made static
    // Also fetch via method call for consistency
    static let mockService = MockDataService() // Create one instance for previews
    static let mockZones = mockService.getSampleZones()
    
    static var previews: some View {
        Group {
            // 1. Idle State
            StateCountyCheckView(viewModel: createViewModel())
                .previewDisplayName("1. Idle")
            
            // 2. State Selected (Button Enabled)
            let vmStateSelected = createViewModel()
            vmStateSelected.selectedState = "VA"
            StateCountyCheckView(viewModel: vmStateSelected)
                .previewDisplayName("2. State Selected")
            
            // 3. State & County Entered (Button Enabled)
            let vmStateCountySelected = createViewModel()
            vmStateCountySelected.selectedState = "CA"
            vmStateCountySelected.county = "Santa Clara"
            StateCountyCheckView(viewModel: vmStateCountySelected)
                .previewDisplayName("3. State & County Entered")
            
            // 4. Loading State
            let vmLoading = createViewModel()
            vmLoading.selectedState = "MD"
            vmLoading.isLoading = true // Manually set loading state
            StateCountyCheckView(viewModel: vmLoading)
                .previewDisplayName("4. Loading")
            
            // 5. Success - Zones Found (State Only - VA)
            let vmSuccessState = createViewModel()
            vmSuccessState.selectedState = "VA"
            vmSuccessState.opportunityZones = mockZones.filter { $0.state == "VA" }
            vmSuccessState.searched = true
            StateCountyCheckView(viewModel: vmSuccessState)
                .previewDisplayName("5. Success - State Only (VA)")
            
            // 6. Success - Zones Found (State & County - CA/Santa Clara)
            let vmSuccessCounty = createViewModel()
            vmSuccessCounty.selectedState = "CA"
            vmSuccessCounty.county = "Santa Clara"
            vmSuccessCounty.opportunityZones = mockZones.filter { $0.state == "CA" && $0.county == "Santa Clara" }
            vmSuccessCounty.searched = true
            StateCountyCheckView(viewModel: vmSuccessCounty)
                .previewDisplayName("6. Success - State & County (CA)")
            
            // 7. Success - No Zones Found (Valid State/County - e.g., State with no zones in mock)
            let vmSuccessNone = createViewModel()
            vmSuccessNone.selectedState = "NY"
            vmSuccessNone.opportunityZones = []
            vmSuccessNone.searched = true
            StateCountyCheckView(viewModel: vmSuccessNone)
                .previewDisplayName("7. Success - No Zones Found (NY)")
            
            // 8. Success - No Zones Found (Valid State, but Invalid County for that State)
            let vmSuccessNoneCounty = createViewModel()
            vmSuccessNoneCounty.selectedState = "VA"
            vmSuccessNoneCounty.county = "NonExistentCounty"
            vmSuccessNoneCounty.opportunityZones = []
            vmSuccessNoneCounty.searched = true
            StateCountyCheckView(viewModel: vmSuccessNoneCounty)
                .previewDisplayName("8. Success - No Zones Found (County)")
            
            // 9. Error State - API/Server Error
            let vmError = createViewModel()
            vmError.selectedState = "XX"
            vmError.errorMessage = "Simulated Server Error for State XX."
            vmError.searched = true
            StateCountyCheckView(viewModel: vmError)
                .previewDisplayName("9. Error - API")
            
            // 10. Input Incomplete (Button Disabled)
            let vmIncomplete = createViewModel()
            StateCountyCheckView(viewModel: vmIncomplete)
                .previewDisplayName("10. Input Incomplete")
            
        }
    }
}
#endif
