//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
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

// MARK: - Data Models (Matching OpenAPI Schemas)

struct Address: Codable, Identifiable {
    var id = UUID() // Added for Identifiable conformance
    // *** RENAMED 'Result' to 'APIResultDetails' to avoid conflict with Swift.Result ***
    var result: APIResultDetails?
    var streetAddress: String?
    var city: String?
    var state: String?
    var zip: String?

    // Add CodingKeys if JSON keys differ from struct properties
}

// *** RENAMED 'struct Result' to 'struct APIResultDetails' ***
struct APIResultDetails: Codable {
    var resultStatus: String?
    var belongsToOpportunityZones: String? // Consider using Bool if values are consistent ("true"/"false")
    var censusTractNumber: String?
    var category: String?
}

struct AddressCollection: Codable {
    var addressList: [Address]?
}

struct OpportunityZone: Codable, Identifiable {
    let id = UUID() // Added for Identifiable conformance
    var state: String?
    var county: String?
    var censusTractNumber: String?
    var tractType: String?
    var acsDataSource: String?
}

struct OpportunityZoneCollection: Codable {
    var opportunityZoneList: [OpportunityZone]?
}

// MARK: - API Error Handling

enum APIError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case invalidURL
    case unknown(String = "An unknown error occurred.")

    var errorDescription: String? {
        switch self {
        case .networkError(let error): return "Network Error: \(error.localizedDescription)"
        case .decodingError(let error): return "Decoding Error: \(error.localizedDescription)"
        case .serverError(let code, let msg): return "Server Error \(code): \(msg ?? "No details")"
        case .invalidURL: return "Invalid API endpoint URL."
        case .unknown(let msg): return msg
        }
    }
}

// MARK: - Placeholder API Service

// NOTE: Replace these with actual network calls using URLSession or a library
struct APIService {

    // Placeholder for /addresscheck
    // Completion uses Swift.Result, which is now unambiguous
    func checkSingleAddress(number: String, street: String, city: String, state: String, zip: String, completion: @escaping (Result<[Address], APIError>) -> Void) {
        print("Simulating API Call: /addresscheck for \(number) \(street)...")
        // Simulate a successful response after a delay
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             // Construct mock data using the renamed APIResultDetails
             let mockResult = APIResultDetails(resultStatus: "Success", belongsToOpportunityZones: "true", censusTractNumber: "1234567890", category: "Urban")
             let mockAddress = Address(result: mockResult, streetAddress: "\(number) \(street)", city: city, state: state, zip: zip)

             // .success now correctly refers to Swift.Result.success
             completion(.success([mockAddress]))

            // To simulate an error:
            // completion(.failure(.serverError(statusCode: 500, message:"Simulated server error")))
         }
    }

    // Placeholder for /addressvalidation
    // Completion uses Swift.Result
    func validateAddresses(addressListData: String, completion: @escaping (Result<AddressCollection, APIError>) -> Void) {
        print("Simulating API Call: /addressvalidation with data:\n\(addressListData)")
        // Simulate a successful response
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             // Construct mock data
             let addresses = addressListData.split(separator: "\n").map { line -> Address in
                 let parts = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                 // Use renamed APIResultDetails
                 let mockResult = APIResultDetails(resultStatus: Bool.random() ? "Success" : "Partial", belongsToOpportunityZones: Bool.random() ? "true" : "false", censusTractNumber: "\(Int.random(in: 10000...99999))", category: "Mixed")
                 return Address(result: mockResult, streetAddress: parts.count > 1 ? "\(parts[0]) \(parts[1])" : "N/A", city: parts.count > 2 ? parts[2] : "N/A", state: parts.count > 3 ? parts[3] : "N/A", zip: parts.count > 4 ? parts[4] : "N/A")
             }
             let mockCollection = AddressCollection(addressList: addresses)

             // .success now correctly refers to Swift.Result.success
             completion(.success(mockCollection))

            // To simulate an error:
            // completion(.failure(.networkError(URLError(.timedOut))))
         }
    }

    // Placeholder for /censustracts
    // Completion uses Swift.Result
    func getCensusTracts(state: String, county: String?, completion: @escaping (Result<OpportunityZoneCollection, APIError>) -> Void) {
        print("Simulating API Call: /censustracts for State: \(state), County: \(county ?? "N/A")")
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             // Construct mock data
             let mockZone1 = OpportunityZone(state: state, county: county ?? "Any County", censusTractNumber: "111111", tractType: "Qualified", acsDataSource: "ACS 2020")
             let mockZone2 = OpportunityZone(state: state, county: county ?? "Another County", censusTractNumber: "222222", tractType: "Low Income", acsDataSource: "ACS 2020")
             let mockCollection = OpportunityZoneCollection(opportunityZoneList: [mockZone1, mockZone2])

             // .success now correctly refers to Swift.Result.success
             completion(.success(mockCollection))

            // To simulate an error:
             // completion(.failure(.serverError(statusCode: 404, message: "No records found for \(state)/\(county ?? "")")))
         }
    }
}


// MARK: - SwiftUI Views

struct ContentView: View {
    var body: some View {
        TabView {
            AddressCheckView()
                .tabItem {
                    Label("Single Check", systemImage: "magnifyingglass")
                }

            AddressValidationView()
                .tabItem {
                    Label("Batch Validate", systemImage: "list.bullet.rectangle")
                }

            CensusTractView()
                .tabItem {
                    Label("Census Tracts", systemImage: "map")
                }
        }
    }
}

// MARK: - Single Address Check View
struct AddressCheckView: View {
    @State private var number: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""

    @State private var isLoading = false
    @State private var searchResult: Address?
    @State private var errorMessage: String?
    @State private var showingAlert = false

    private let apiService = APIService()

    var body: some View {
        NavigationView {
            Form {
                Section("Enter Address") {
                    TextField("Building Number", text: $number)
                    TextField("Street Name", text: $street)
                    TextField("City", text: $city)
                    TextField("State (e.g., VA)", text: $state)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true) // Often useful for state codes
                    TextField("Zip Code", text: $zip)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Check Opportunity Zone") {
                        performSearch()
                    }
                    .disabled(isLoading || inputsInvalid)
                }

                if isLoading {
                    HStack { // Center the ProgressView
                        Spacer()
                        ProgressView("Checking...")
                        Spacer()
                    }
                }

                if let result = searchResult {
                    Section("Result") {
                        AddressResultView(address: result)
                    }
                }
            }
            .navigationTitle("Single Address Check")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
            }
            // Dismiss keyboard when scrolling the form
            .onTapGesture {
                 hideKeyboard()
            }
        }
         // Dismiss keyboard when switching tabs - apply to NavigationView
        .onDisappear {
             hideKeyboard()
        }
    }

    private var inputsInvalid: Bool {
        number.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func performSearch() {
        hideKeyboard()
        isLoading = true
        searchResult = nil
        errorMessage = nil

        apiService.checkSingleAddress(number: number, street: street, city: city, state: state, zip: zip) { result in
            isLoading = false
            switch result {
            case .success(let addresses):
                // API returns an array, assuming we only care about the first/only result for a single check
                searchResult = addresses.first
                if searchResult == nil {
                    handleError(APIError.unknown("No address result returned."))
                }
            case .failure(let error):
                handleError(error)
            }
        }
    }

    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        showingAlert = true
        // Optionally clear search result on error
        // searchResult = nil
    }

     private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Batch Address Validation View
struct AddressValidationView: View {
    // Default text for the TextEditor
    private let placeholderText = "Enter addresses (one per line):\nnumber, street, city, state, zip\ne.g., 13150, Worldgate Drive, Herndon, VA, 20171"
    @State private var addressInput: String = "" // Start empty

    @State private var isLoading = false
    @State private var validationResults: [Address] = []
    @State private var errorMessage: String?
    @State private var showingAlert = false

    private let apiService = APIService()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) { // Align content left
                Text("Enter addresses (one per line format: number, street, city, state, zip)")
                    .font(.caption)
                    .padding(.horizontal)
                    .padding(.top) // Add some top padding

                ZStack(alignment: .topLeading) { // Use ZStack for placeholder
                     TextEditor(text: $addressInput)
                        .frame(height: 200)
                        .border(Color.gray.opacity(0.5))
                        .padding(.horizontal)
                        .onAppear { // Set initial placeholder if empty
                            if addressInput.isEmpty {
                                // addressInput = placeholderText // This makes it editable text
                            }
                        }
                        // Ensure placeholder text appears correctly
                        .onChange(of: addressInput) { _ in } // Needed to update view on text change

                    // Actual placeholder using Text view over the TextEditor
                    if addressInput.isEmpty {
                        Text(placeholderText)
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 20) // Match TextEditor padding + border
                             .padding(.vertical, 8) // Approximate TextEditor internal padding
                             .allowsHitTesting(false) // Allow taps to go through to TextEditor
                    }
                 }


                HStack { // Center the button
                    Spacer()
                    Button("Validate Addresses") {
                        performValidation()
                    }
                    .disabled(isLoading || addressInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding()
                    Spacer()
                }


                if isLoading {
                   HStack {
                        Spacer()
                        ProgressView("Validating...")
                        Spacer()
                   }.padding()
                }

                 // Use else if to avoid showing empty list when loading
                 else if !validationResults.isEmpty {
                    List {
                        Section("Validation Results (\(validationResults.count))") {
                            ForEach(validationResults) { address in
                                AddressResultView(address: address)
                            }
                        }
                    }
                    // Give the list a frame to prevent it taking all space initially
                     .frame(maxHeight: .infinity)
                } else if !isLoading && validationResults.isEmpty && errorMessage == nil {
                     // Show a message if validation was run but returned no results
                     // You might want to refine this condition based on API behavior
                     HStack {
                          Spacer()
                          Text("No results to display.")
                               .foregroundColor(.gray)
                               .padding()
                          Spacer()
                     }
                }

                Spacer() // Pushes results list or message up
            }
            .navigationTitle("Batch Address Validation")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred."), dismissButton: .default(Text("OK")))
            }
            .onTapGesture { // Dismiss keyboard on background tap
                hideKeyboard()
            }
        }
         .onDisappear {
             hideKeyboard()
         }
    }

     private func performValidation() {
        hideKeyboard()
        isLoading = true
        // Clear previous results immediately when starting
        validationResults = []
        errorMessage = nil

        // Get the actual input, ignoring placeholder if it was used
        let inputText = addressInput == placeholderText ? "" : addressInput

        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isLoading = false
            // Maybe set an error message "Input cannot be empty"
            return
        }


        apiService.validateAddresses(addressListData: inputText) { result in
            isLoading = false
            switch result {
            case .success(let collection):
                validationResults = collection.addressList ?? []
                 if validationResults.isEmpty {
                      // Potentially set a non-error message here if needed
                      print("Validation successful but returned no results.")
                 }
            case .failure(let error):
                handleError(error)
            }
        }
    }

    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        showingAlert = true
        // Clear results on error
        validationResults = []
    }

     private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Census Tract View
struct CensusTractView: View {
    @State private var state: String = ""
    @State private var county: String = "" // Optional

    @State private var isLoading = false
    @State private var tractResults: [OpportunityZone] = []
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var searchPerformed = false // Track if search ran

    private let apiService = APIService()

    var body: some View {
         NavigationView {
            VStack(alignment: .leading) {
                Form {
                    Section("Enter Location") {
                         TextField("State (e.g., VA)", text: $state)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                         TextField("County (Optional)", text: $county)
                             .disableAutocorrection(true)
                    }

                    HStack { // Center button
                        Spacer()
                        Button("Get Census Tracts") {
                            performSearch()
                        }
                        .disabled(isLoading || state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Spacer()
                    }
                }
                // Give form a limited height so list below is visible
                .frame(maxHeight: 220)


                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Fetching Data...")
                        Spacer()
                    }.padding()
                }

                // Show list only if not loading AND results exist
                else if !tractResults.isEmpty {
                     List {
                        Section("Opportunity Zone Tracts (\(tractResults.count))") {
                            ForEach(tractResults) { zone in
                                OpportunityZoneResultView(zone: zone)
                            }
                        }
                     }
                     .frame(maxHeight: .infinity) // Allow list to expand
                }
                // Show 'No results' message only if search ran, wasn't loading, and results are empty
                else if searchPerformed && !isLoading && tractResults.isEmpty {
                    HStack {
                        Spacer()
                        Text("No Opportunity Zone tracts found for the specified location.")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }

                 Spacer() // Pushes list or message up
            }
            .navigationTitle("Census Tract Lookup")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(errorMessage?.contains("found") ?? false ? "Not Found" : "Error"), // Better alert title for 404
                      message: Text(errorMessage ?? "An unknown error occurred."),
                      dismissButton: .default(Text("OK")))
            }
             .onTapGesture {
                hideKeyboard()
             }
        }
         .onDisappear {
            hideKeyboard()
         }
    }

     private func performSearch() {
        hideKeyboard()
        isLoading = true
        searchPerformed = true // Mark that a search attempt was made
        // Clear previous results immediately
        tractResults = []
        errorMessage = nil

        // Handle empty optional county
        let countyQuery = county.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : county

        apiService.getCensusTracts(state: state.trimmingCharacters(in: .whitespacesAndNewlines), county: countyQuery) { result in
            isLoading = false
            switch result {
            case .success(let collection):
                tractResults = collection.opportunityZoneList ?? []
                 // No error needed if successful but empty, UI shows "No results" message
                 print("Census tract search successful. Found \(tractResults.count) tracts.")
            case .failure(let error):
                // Specific user-friendly message for 404
                if case .serverError(statusCode: 404, _) = error {
                    // Set error message for the alert, but don't treat as critical app error
                    errorMessage = "No Opportunity Zone tracts found for the specified location."
                    // Still show the alert to inform the user
                    showingAlert = true
                    // Keep tractResults empty
                } else {
                     handleError(error) // Handle other errors normally
                }
            }
        }
    }

    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        showingAlert = true
        // Clear results on general error
        tractResults = []
    }

    private func hideKeyboard() {
       UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
   }
}


// MARK: - Reusable Result Row Views

struct AddressResultView: View {
    let address: Address

    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Add spacing
            Text("\(address.streetAddress ?? "N/A"), \(address.city ?? "N/A"), \(address.state ?? "N/A") \(address.zip ?? "N/A")")
                .font(.headline)
                .lineLimit(2) // Prevent very long addresses taking too much space

            // Use the renamed APIResultDetails
            if let result = address.result {
                HStack {
                    Text("In OZ:")
                        .font(.subheadline).fontWeight(.medium)
                    Text(result.belongsToOpportunityZones?.lowercased() == "true" ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundColor(result.belongsToOpportunityZones?.lowercased() == "true" ? .green : .red)
                    Spacer()
                    Text("Tract: \(result.censusTractNumber ?? "N/A")")
                        .font(.subheadline)
                }

                // Combine Status and Category if available
                let status = result.resultStatus ?? "N/A"
                let category = result.category ?? "N/A"
                Text("Status: \(status) | Category: \(category)")
                     .font(.caption)
                     .foregroundColor(.gray)

            } else {
                 Text("No result details available.")
                     .font(.subheadline)
                     .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 2) // Add slight vertical padding to row
    }
}

struct OpportunityZoneResultView: View {
    let zone: OpportunityZone

    var body: some View {
         VStack(alignment: .leading, spacing: 4) {
            Text("Tract: \(zone.censusTractNumber ?? "N/A")")
                 .font(.headline)
             Text("State: \(zone.state ?? "N/A"), County: \(zone.county ?? "N/A")")
                 .font(.subheadline)
                 .lineLimit(1)
             Text("Type: \(zone.tractType ?? "N/A") | Source: \(zone.acsDataSource ?? "N/A")")
                 .font(.caption)
                 .foregroundColor(.gray)
        }
         .padding(.vertical, 2)
    }
}

// MARK: - App Entry Point (If needed)
/*
 @main
 struct OpportunityZoneApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
