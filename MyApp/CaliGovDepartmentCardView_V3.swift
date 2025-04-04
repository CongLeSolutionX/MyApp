//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI
import Foundation

// --- Data Model (Unchanged) ---
struct Department: Identifiable, Hashable { // Added Hashable for NavigationLink stability
    let id = UUID()
    let name: String
    let logoSymbolName: String // Using SF Symbols as placeholders
    let datasetCount: Int

    // Conformance to Hashable (using id is sufficient and common)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Department, rhs: Department) -> Bool {
        lhs.id == rhs.id
    }
}

// --- Simulated Data Service (Unchanged) ---
struct DataService {
    static func fetchDepartmentsAsync() async throws -> [Department] {
        print("Starting asynchronous fetch...")
        try await Task.sleep(for: .seconds(1.5))

        // Simulate potential network error
        // enum FetchError: Error { case networkUnavailable }
        // if Bool.random() { throw FetchError.networkUnavailable } // Randomly fail sometimes

        let baseDepartments: [Department] = [
            Department(name: "California Department\nof State Hospitals", logoSymbolName: "cross.case.fill", datasetCount: 5),
            Department(name: "California Department\nof Tax and Fee Administration", logoSymbolName: "dollarsign.circle.fill", datasetCount: 38),
            Department(name: "California Department\nof Technology", logoSymbolName: "server.rack", datasetCount: 15),
            Department(name: "California Department\nof Toxic Substances Control", logoSymbolName: "testtube.2", datasetCount: 2),
            Department(name: "California Department\nof Water Resources", logoSymbolName: "drop.fill", datasetCount: 546),
            Department(name: "California Emergency\nMedical Services Authority", logoSymbolName: "staroflife.fill", datasetCount: 3),
            Department(name: "California Employment\nDevelopment Department", logoSymbolName: "briefcase.fill", datasetCount: 17),
            Department(name: "California Employment\nTraining Panel", logoSymbolName: "person.2.fill", datasetCount: 1),
            Department(name: "California Energy\nCommission", logoSymbolName: "bolt.fill", datasetCount: 10),
            Department(name: "California Environmental\nProtection Agency", logoSymbolName: "leaf.fill", datasetCount: 10),
            Department(name: "California Franchise\nTax Board", logoSymbolName: "banknote.fill", datasetCount: 104),
            Department(name: "California Governor's Office\nof Business and Economic Development", logoSymbolName: "building.2.fill", datasetCount: 5)
        ]

        var generatedDepartments: [Department] = []
        for i in 0..<5 {
            generatedDepartments.append(contentsOf: baseDepartments.map {
                 // Give each generated department a unique-ish name for demo purposes
                 Department(name: "\($0.name) (\(i+1))", logoSymbolName: $0.logoSymbolName, datasetCount: $0.datasetCount + Int.random(in: -2...5*i))
            })
        }

        print("Asynchronous fetch completed successfully.")
        return generatedDepartments
    }
}

// --- Card View (Unchanged) ---
struct DepartmentCardView: View {
    let department: Department

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: department.logoSymbolName)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .foregroundColor(.accentColor)
                .padding(.top)

            Text(department.name)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Prevent text truncation issues

            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer() // Pushes content towards top
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180) // Ensure consistent card height
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- NEW: Department Detail View ---
struct DepartmentDetailView: View {
    let department: Department

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // Larger Logo
                Image(systemName: department.logoSymbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundColor(.accentColor)
                    .padding(.top, 30)

                // Department Name - Title
                Text(department.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Dataset Count Info
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s") Available")
                }
                .font(.title3)
                .foregroundColor(.secondary)

                Divider()
                    .padding(.horizontal)

                // Placeholder for more details
                VStack(alignment: .leading, spacing: 10) {
                   Text("About this Department")
                        .font(.title2)
                        .fontWeight(.semibold)

                   Text("This section would contain a detailed description of the \(department.name), its mission, responsibilities, key personnel, links to important resources, and access to its open datasets.")
                        .font(.body)

                    // Example Placeholder Button
                    Button("Visit Department Website") {
                        // Action to open URL (requires import SafariServices or handling elsewhere)
                        print("Attempting to visit website for \(department.name)...")
                    }
                    .buttonStyle(.bordered)
                    .padding(.top)
                }
                .padding(.horizontal)

                Spacer() // Pushes content to the top within the ScrollView Vstack
            }
            .frame(maxWidth: .infinity) // Ensure VStack takes full width
        }
        .navigationTitle(department.name) // Set the navigation bar title dynamically
        .navigationBarTitleDisplayMode(.inline) // Use smaller title in nav bar
    }
}

// --- Main Content View (Updated for Navigation) ---
struct ContentView: View {
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]

    @State private var departments: [Department] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView { // Essential for NavigationLink to work
            Group {
                if isLoading {
                    ProgressView("Loading Departments...")
                        .scaleEffect(1.5)
                        .padding()
                } else if let errorMsg = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable().scaledToFit().frame(width: 60, height: 60).foregroundColor(.red)
                        Text("Failed to load departments").font(.title2)
                        Text(errorMsg).font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
                        Button("Retry") {
                            errorMessage = nil
                            Task { await loadDepartments() }
                        }
                        .buttonStyle(.borderedProminent).padding(.top)
                    }
                    .padding()
                } else if departments.isEmpty {
                    Text("No departments found.")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(departments) { department in
                                // --- NavigationLink Added Here ---
                                NavigationLink(destination: DepartmentDetailView(department: department)) {
                                    DepartmentCardView(department: department)
                                }
                                // Style the link to avoid default blue text/tint on the card
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("CA Departments")
            .task {
                if departments.isEmpty && errorMessage == nil && !isLoading { // Add !isLoading check
                    await loadDepartments()
                }
            }
             .refreshable { // Optional: Add pull-to-refresh
                 await loadDepartments()
             }
        }
        // On iPad, stack style might be preferred if you don't want a sidebar
        // .navigationViewStyle(.stack)
    }

    // --- Async Function to Load Data (Unchanged Logic) ---
    private func loadDepartments() async {
        // Prevent concurrent loads if already loading
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetchedDepartments = try await DataService.fetchDepartmentsAsync()
            await MainActor.run {
                self.departments = fetchedDepartments
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.isLoading = false
                self.departments = []
            }
            print("Error occurred during fetch: \(error)")
        }
    }
}


// --- SwiftUI Previews ---

// Preview for Detail View
struct DepartmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Wrap in NavigationView for realistic preview
            DepartmentDetailView(department: Department(
                name: "Preview Department - Very Long Name for Testing Wrapping",
                logoSymbolName: "testtube.2",
                datasetCount: 123
            ))
        }
    }
}

// Previews for ContentView (Updated to use custom initializers)
struct ContentView_Previews: PreviewProvider {
     // Sample departments for preview
    static let previewDepts: [Department] = [
        Department(name: "Preview Dept 1", logoSymbolName: "star.fill", datasetCount: 10),
        Department(name: "Preview Dept 2", logoSymbolName: "heart.fill", datasetCount: 5),
        Department(name: "Preview Dept 3", logoSymbolName: "trash.fill", datasetCount: 0),
        Department(name: "Preview Dept 4", logoSymbolName: "car.fill", datasetCount: 99),
    ]
    
    static var previews: some View {
        // Preview in different states using initializers

        // Default (will show loading then likely loaded state in preview)
        ContentView()
            .previewDisplayName("Default Initial Load")

        // Loaded state
        ContentView(departments: previewDepts)
            .previewDisplayName("Loaded State")

        // Error state
        ContentView(errorMessage: "Network connection timed out. Please check your connection and try again.")
            .previewDisplayName("Error State")

        // Loading state explicitly
        ContentView(isLoading: true)
            .previewDisplayName("Loading State")
        
         // Empty state (successful fetch, no data)
        ContentView(departments: [])
             .previewDisplayName("Empty State (Loaded)")
    }
}

// Add/Keep initializers to ContentView for easier preview setup
 extension ContentView {
     // Initializer for controlled loaded state in previews
     init(departments: [Department]) {
         _departments = State(initialValue: departments)
         _isLoading = State(initialValue: false)
         _errorMessage = State(initialValue: nil)
     }
     // Initializer for controlled error state in previews
     init(errorMessage: String) {
         _departments = State(initialValue: [])
         _isLoading = State(initialValue: false)
         _errorMessage = State(initialValue: errorMessage)
     }
     // Initializer for controlled loading state in previews
     init(isLoading: Bool) {
         _departments = State(initialValue: [])
         _isLoading = State(initialValue: isLoading)
         _errorMessage = State(initialValue: nil)
     }
 }


struct DepartmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentCardView(department: Department(name: "Preview Department Card", logoSymbolName: "gear", datasetCount: 25))
            .padding()
            .previewLayout(.sizeThatFits) // Size card appropriately
    }
}
