//
//  CaliGovDepartmentCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI

// --- Data Model ---
struct Department: Identifiable {
    let id = UUID()
    let name: String
    let logoSymbolName: String // Using SF Symbols as placeholders
    let datasetCount: Int
}

// --- Sample Data based on the image ---
// Note: SF Symbols are chosen to represent the logos conceptually.
// For a real app, you would use actual image assets.
let departmentData: [Department] = [
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

// --- Card View ---
struct DepartmentCardView: View {
    let department: Department

    var body: some View {
        VStack(spacing: 10) {
            // Logo Placeholder
            Image(systemName: department.logoSymbolName)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .foregroundColor(.accentColor) // Use accent color for the symbol
                .padding(.top)

            // Department Name
            Text(department.name)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true) // Allow text wrapping

            // Dataset Count
            Text("\(department.datasetCount) Dataset\(department.datasetCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(.secondary) // Lighter text color

            Spacer() // Pushes content to the top
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180) // Ensure cards have a consistent minimum height
        .background(Color(.systemGray6)) // Light gray background for the card
        .cornerRadius(12) // Rounded corners
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}

// --- Main Content View ---
struct CaliGovDepartmentCardView: View {
    // Define grid layout: adaptive columns means it fits as many as possible
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200)) // Adjust min/max for desired card size
    ]

    @State private var departments: [Department] = departmentData

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(departments) { department in
                        DepartmentCardView(department: department)
                    }
                }
                .padding() // Padding around the grid
            }
            .navigationTitle("CA Departments") // Title for the view
        }
    }
}

// --- App Entry Point ---
// You would typically have this in a separate file (e.g., YourAppNameApp.swift)
// but including it here for a single-file example.
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

// --- SwiftUI Preview ---
// Useful for seeing the design in Xcode's preview canvas
struct CaliGovDepartmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        CaliGovDepartmentCardView()
    }
}

struct DepartmentCardView_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentCardView(department: departmentData[0])
            .padding()
            .previewLayout(.sizeThatFits) // Preview the card itself
    }
}
