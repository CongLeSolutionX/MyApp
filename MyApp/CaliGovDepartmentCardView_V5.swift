//
//  V5.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//


import SwiftUI
import Foundation // Needed for URL

// --- Data Model (Updated) ---
struct Department: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let logoSymbolName: String
    let websiteURL: String? // Added optional website URL
    let datasetCount: Int

    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Department, rhs: Department) -> Bool {
        lhs.id == rhs.id
    }
}

// --- Simulated Data Service (Updated with Website and specific data) ---
struct DataService {
    // Dictionary to hold descriptions based on a simplified key
    private static let departmentDescriptions: [String: String] = [
        // ... (previous descriptions) ...
        "california commission on teacher credentialing": "Ensures integrity, relevance, and high quality in the preparation, certification, and discipline of the educators who serve all of California's diverse students.", // Updated description snippet
        // ... (other descriptions) ...
    ]

     // Dictionary for Website URLs
     private static let departmentWebsites: [String: String] = [
         "california commission on teacher credentialing": "https://www.ctc.ca.gov/",
         // Add other websites as needed
         "california department of technology": "https://cdt.ca.gov/",
         "california department of water resources": "https://water.ca.gov/",
         "franchise tax board": "https://www.ftb.ca.gov/"
     ]


    // Helper to generate a key for the lookup
    private static func makeLookupKey(from name: String) -> String {
        return name.lowercased().replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func fetchDepartmentsAsync() async throws -> [Department] {
        print("Starting asynchronous fetch...")
        try await Task.sleep(for: .seconds(1.0)) // Slightly faster fetch

        // Base list of departments - fetch descriptions/websites dynamically
        let baseDepartmentsRaw: [(name: String, logo: String, count: Int)] = [
            ("California Commission on\nTeacher Credentialing", "graduationcap.fill", 3), // Specific data from image
            ("California Department\nof Tax and Fee Administration", "dollarsign.circle.fill", 38),
            ("California Department\nof Technology", "server.rack", 15),
            ("California Department\nof Toxic Substances Control", "testtube.2", 2),
            ("California Department\nof Water Resources", "drop.fill", 546),
            ("California Emergency\nMedical Services Authority", "staroflife.fill", 3),
            ("California Employment\nDevelopment Department", "briefcase.fill", 17),
            ("California Energy\nCommission", "bolt.fill", 10),
            ("California Environmental\nProtection Agency", "leaf.fill", 10),
            ("California Franchise\nTax Board", "banknote.fill", 104),
            ("California Governor's Office\nof Business and Economic Development", "building.2.fill", 5),
            ("California Department of Education", "book.closed.fill", 20),
            ("California Highway Patrol", "shield.lefthalf.filled", 8),
            ("California Department of\nParks and Recreation", "figure.hiking", 75) // Added newline for consistency
        ]

        var baseDepartments: [Department] = []
        for deptData in baseDepartmentsRaw {
             let key = makeLookupKey(from: deptData.name)
             // Adjust key for specific cases if needed (like Parks)
             let descriptionKey = key == "california department of parks and recreation" ? "california state parks" : key
             let description = departmentDescriptions[descriptionKey] ?? "Description not available."
             let website = departmentWebsites[key] // Fetch website using the exact key

             baseDepartments.append(Department(
                name: deptData.name,
                description: description,
                logoSymbolName: deptData.logo,
                websiteURL: website, // Assign fetched website URL
                datasetCount: deptData.count
             ))
        }


        // Generate more departments for scrolling demo (keeping it simple for clarity)
        // If you need many duplicates, uncomment the generation loop
        // var generatedDepartments: [Department] = []
        // for i in 0..<5 {
        //     generatedDepartments.append(contentsOf: baseDepartments.map { /* ... map with unique names ... */ })
        // }
        // return generatedDepartments

        print("Asynchronous fetch completed successfully.")
        return baseDepartments // Return only the base list for now
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
                .fixedSize(horizontal: false, vertical: true)

            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// --- Department Detail View (Updated based on image) ---
struct DepartmentDetailView: View {
    let department: Department

    var body: some View {
        ScrollView {
            // Main Content VStack
            VStack(alignment: .leading, spacing: 20) {

                // Header Section (Logo and Name centered)
                VStack(alignment: .center, spacing: 15) {
                    Image(systemName: department.logoSymbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100) // Slightly smaller logo
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)

                    Text(department.name)
                        .font(.title) // Slightly smaller title
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity) // Center the content within the header VStack

                Divider()

                // About Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(department.description)
                        .font(.body)

                    // Website Link (conditionally shown)
                    if let urlString = department.websiteURL, let url = URL(string: urlString) {
                        Link(destination: url) {
                            Label("Website: \(urlString)", systemImage: "safari.fill")
                                .font(.callout) // Smaller font for link
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding(.horizontal)

                 Divider()

                 // Datasets Section
                 VStack(alignment: .leading, spacing: 8) {
                     Text("Datasets (\(department.datasetCount))") // Include count in title
                         .font(.title2)
                         .fontWeight(.semibold)

                     // Placeholder for dataset list/search - reflecting the image structure
                     Text("Below you would find a list of datasets provided by this department. You could search and filter these datasets.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                     // --- Placeholder Dataset Examples (Reflecting Image) ---
                      // For demonstration - not dynamically loaded
                      if department.name.contains("Teacher Credentialing") {
                          DatasetPlaceholderView(title: "California Teacher Supply Report", formats: ["PDF", "ZIP"])
                          DatasetPlaceholderView(title: "California Teacher Candidates Academic Year 2016-2017", formats: ["CSV"])
                          DatasetPlaceholderView(title: "California Teacher Preparation Programs", formats: ["CSV", "DOCX"])
                      } else {
                          // Generic placeholder if not the specific department
                          Text("Dataset listing would appear here.")
                             .font(.body)
                             .foregroundColor(.gray)
                      }
                     // -------------------------------------------------------

                 }
                 .padding(.horizontal)


                Spacer() // Pushes content up if screen is large
            }
            .padding(.vertical) // Add some padding top/bottom of the main VStack
        }
        .navigationTitle(department.name.replacingOccurrences(of: "\n", with: " "))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// --- Helper View for Dataset Placeholder ---
struct DatasetPlaceholderView: View {
    let title: String
    let formats: [String]

    // Simple color map for format tags
    private func colorForFormat(_ format: String) -> Color {
        switch format.uppercased() {
        case "CSV": return .green
        case "PDF": return .red
        case "ZIP": return .orange
        case "DOCX": return .blue
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 1)
            HStack {
                ForEach(formats, id: \.self) { format in
                    Text(format)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(colorForFormat(format).opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.bottom, 8) // Spacing between dataset placeholders
    }
}


// --- Main Content View (Unchanged Structure) ---
struct ContentView: View {
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]

    @State private var departments: [Department] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
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
                                NavigationLink(destination: DepartmentDetailView(department: department)) {
                                    DepartmentCardView(department: department)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("CA Departments")
            .task {
                if departments.isEmpty && errorMessage == nil && !isLoading {
                    await loadDepartments()
                }
            }
             .refreshable {
                 await loadDepartments()
             }
        }
    }

    // Async Function Load (Unchanged)
    private func loadDepartments() async {
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


// --- SwiftUI Previews (Updated for new model and Detail View structure) ---

// Preview for Detail View
struct DepartmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Preview the specific Commission
            DepartmentDetailView(department: Department(
                name: "California Commission on\nTeacher Credentialing",
                description: "Ensures integrity, relevance, and high quality in the preparation, certification, and discipline of the educators who serve all of California's diverse students.",
                logoSymbolName: "graduationcap.fill",
                websiteURL: "https://www.ctc.ca.gov/",
                datasetCount: 3
            ))
            .previewDisplayName("Teacher Credentialing")

        }

         NavigationView {
            // Preview a generic department
             DepartmentDetailView(department: Department(
                 name: "Generic Preview Dept",
                 description: "Handles various tasks and provides essential services for the state.",
                 logoSymbolName: "building.columns.fill",
                 websiteURL: "https://preview.ca.gov",
                 datasetCount: 42
             ))
            .previewDisplayName("Generic Department")
         }
    }
}

// Previews for ContentView
struct ContentView_Previews: PreviewProvider {
    static let previewDepts: [Department] = [
        Department(name: "Preview Teacher Cred", description: "Handles teacher stuff.", logoSymbolName: "graduationcap.fill", websiteURL: "https://ctc.ca.gov", datasetCount: 3),
        Department(name: "Preview Taxes", description: "Manages taxes.", logoSymbolName: "dollarsign.circle.fill", websiteURL: nil, datasetCount: 38),
        Department(name: "Preview Parks", description: "Manages parks.", logoSymbolName: "figure.hiking", websiteURL: "https://parks.ca.gov", datasetCount: 75),
        Department(name: "Preview Tech", description: "Does tech.", logoSymbolName: "server.rack", websiteURL: "https://cdt.ca.gov", datasetCount: 15),
    ]

    static var previews: some View {
        ContentView(departments: previewDepts)
            .previewDisplayName("Loaded State")

        // Add other states if needed (Error, Loading, Empty)
        ContentView(errorMessage: "Preview Error")
             .previewDisplayName("Error State")
    }
}


// Initializers for ContentView Previews (Unchanged)
 extension ContentView {
     init(departments: [Department]) {
         _departments = State(initialValue: departments)
         _isLoading = State(initialValue: false)
         _errorMessage = State(initialValue: nil)
     }
     init(errorMessage: String) {
         _departments = State(initialValue: [])
         _isLoading = State(initialValue: false)
         _errorMessage = State(initialValue: errorMessage)
     }
     init(isLoading: Bool) {
         _departments = State(initialValue: [])
         _isLoading = State(initialValue: isLoading)
         _errorMessage = State(initialValue: nil)
     }
 }

// Preview for Card View (Updated)
struct DepartmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentCardView(department: Department(
            name: "Preview Card Dept",
            description: "Card desc.",
            logoSymbolName: "gear",
            websiteURL: nil,
            datasetCount: 25)
        )
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

// App Entry Point (Unchanged)
/*
 @main
 struct DepartmentApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
 */
