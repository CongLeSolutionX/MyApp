////
////  V2.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//import SwiftUI
//import Foundation // Needed for UUID
//
//// --- Data Model ---
//struct Department: Identifiable {
//    let id = UUID()
//    let name: String
//    let logoSymbolName: String // Using SF Symbols as placeholders
//    let datasetCount: Int
//}
//
//// --- Simulated Data Service ---
//// In a real app, this would perform network requests or database queries.
//struct DataService {
//    // Function to simulate fetching data asynchronously
//    static func fetchDepartmentsAsync() async throws -> [Department] {
//        print("Starting asynchronous fetch...")
//        // Simulate network delay (e.g., 1.5 seconds)
//        try await Task.sleep(for: .seconds(1.5))
//
//        // Simulate potential network error (uncomment to test error handling)
//        // enum FetchError: Error { case networkUnavailable }
//        // throw FetchError.networkUnavailable
//
//        // Generate 60 sample departments by repeating the original list
//        let baseDepartments: [Department] = [
//            Department(name: "California Department\nof State Hospitals", logoSymbolName: "cross.case.fill", datasetCount: 5),
//            Department(name: "California Department\nof Tax and Fee Administration", logoSymbolName: "dollarsign.circle.fill", datasetCount: 38),
//            Department(name: "California Department\nof Technology", logoSymbolName: "server.rack", datasetCount: 15),
//            Department(name: "California Department\nof Toxic Substances Control", logoSymbolName: "testtube.2", datasetCount: 2),
//            Department(name: "California Department\nof Water Resources", logoSymbolName: "drop.fill", datasetCount: 546),
//            Department(name: "California Emergency\nMedical Services Authority", logoSymbolName: "staroflife.fill", datasetCount: 3),
//            Department(name: "California Employment\nDevelopment Department", logoSymbolName: "briefcase.fill", datasetCount: 17),
//            Department(name: "California Employment\nTraining Panel", logoSymbolName: "person.2.fill", datasetCount: 1),
//            Department(name: "California Energy\nCommission", logoSymbolName: "bolt.fill", datasetCount: 10),
//            Department(name: "California Environmental\nProtection Agency", logoSymbolName: "leaf.fill", datasetCount: 10),
//            Department(name: "California Franchise\nTax Board", logoSymbolName: "banknote.fill", datasetCount: 104),
//            Department(name: "California Governor's Office\nof Business and Economic Development", logoSymbolName: "building.2.fill", datasetCount: 5)
//        ]
//
//        var generatedDepartments: [Department] = []
//        for i in 0..<5 { // Repeat 5 times to get 60
//            generatedDepartments.append(contentsOf: baseDepartments.map {
//                // Create slightly different instances if needed, though UUID handles uniqueness
//                Department(name: "\($0.name) (\(i+1))", logoSymbolName: $0.logoSymbolName, datasetCount: $0.datasetCount + i)
//            })
//        }
//
//        print("Asynchronous fetch completed successfully.")
//        return generatedDepartments
//    }
//}
//
//
//// --- Card View (Unchanged) ---
//struct DepartmentCardView: View {
//    let department: Department
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Logo Placeholder
//            Image(systemName: department.logoSymbolName)
//                .resizable()
//                .scaledToFit()
//                .frame(height: 60)
//                .foregroundColor(.accentColor)
//                .padding(.top)
//
//            // Department Name
//            Text(department.name)
//                .font(.headline)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .fixedSize(horizontal: false, vertical: true)
//
//            // Dataset Count
//            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity, minHeight: 180)
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}
//
//// --- Main Content View (Updated for Async) ---
//struct ContentView: View {
//    // Define grid layout
//    let columns: [GridItem] = [
//        GridItem(.adaptive(minimum: 150, maximum: 200))
//    ]
//
//    // State variables to manage data and loading status
//    @State private var departments: [Department] = []
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil // Optional string to hold error messages
//
//    var body: some View {
//        NavigationView {
//            Group { // Use Group to switch content based on state
//                if isLoading {
//                    ProgressView("Loading Departments...") // Loading indicator
//                        .scaleEffect(1.5) // Make spinner slightly larger
//                        .padding()
//                } else if let errorMsg = errorMessage {
//                    VStack(spacing: 20) {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.red)
//                        Text("Failed to load departments")
//                            .font(.title2)
//                        Text(errorMsg)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                        Button("Retry") {
//                            // Clear error and trigger loading again
//                            errorMessage = nil
//                            Task {
//                                await loadDepartments()
//                            }
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .padding(.top)
//                    }
//                    .padding()
//                } else if departments.isEmpty {
//                     Text("No departments found.") // Message if fetch succeeds but returns empty
//                        .foregroundColor(.secondary)
//                } else {
//                    // Display the grid once data is loaded
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            ForEach(departments) { department in
//                                DepartmentCardView(department: department)
//                            }
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .navigationTitle("CA Departments")
//            .task { // Runs the async task when the view appears
//                // Avoid reloading if data already exists (e.g., navigating back)
//                if departments.isEmpty && errorMessage == nil {
//                     await loadDepartments()
//                }
//            }
//            // Example: Add pull-to-refresh if needed
//            // .refreshable {
//            //     await loadDepartments()
//            // }
//        }
//        // Use .navigationViewStyle(.stack) on iPad if single column desired
//        // .navigationViewStyle(.stack)
//    }
//
//    // --- Async Function to Load Data ---
//    private func loadDepartments() async {
//        isLoading = true
//        errorMessage = nil // Clear previous errors before loading
//
//        do {
//            let fetchedDepartments = try await DataService.fetchDepartmentsAsync()
//            // Update the UI on the main thread
//            // Although .task handles this often, explicit MainActor is safest
//             await MainActor.run {
//                self.departments = fetchedDepartments
//                self.isLoading = false
//             }
//        } catch {
//            // Handle errors
//             await MainActor.run {
//                self.errorMessage = "Error fetching data: \(error.localizedDescription)"
//                self.isLoading = false
//                self.departments = [] // Clear potentially stale data
//             }
//            print("Error occurred during fetch: \(error)")
//        }
//    }
//}
//
//// --- App Entry Point (Standard) ---
///*
//@main
//struct DepartmentApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
//
//// --- SwiftUI Previews ---
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview in different states
//        ContentView() // Default preview (will show loading initially)
//
//        // Preview loaded state
//        ContentView(departments: [
//             Department(name: "Preview Dept 1", logoSymbolName: "star.fill", datasetCount: 10),
//             Department(name: "Preview Dept 2", logoSymbolName: "heart.fill", datasetCount: 5)
//        ])
//        .previewDisplayName("Loaded State")
//
//        // Preview error state
//        ContentView(errorMessage: "Network connection lost.")
//         .previewDisplayName("Error State")
//
//        // Preview loading state explicitly
//         ContentView(isLoading: true)
//         .previewDisplayName("Loading State")
//    }
//}
//
//// Add initializer to ContentView for easier preview setup
//extension ContentView {
//    init(departments: [Department]) {
//        _departments = State(initialValue: departments)
//        _isLoading = State(initialValue: false)
//        _errorMessage = State(initialValue: nil)
//    }
//    init(errorMessage: String) {
//         _departments = State(initialValue: [])
//         _isLoading = State(initialValue: false)
//        _errorMessage = State(initialValue: errorMessage)
//    }
//     init(isLoading: Bool) {
//         _departments = State(initialValue: [])
//         _isLoading = State(initialValue: isLoading)
//        _errorMessage = State(initialValue: nil)
//    }
//}
//
//
//struct DepartmentCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        DepartmentCardView(department: Department(name: "Preview Department", logoSymbolName: "gear", datasetCount: 25))
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//}
