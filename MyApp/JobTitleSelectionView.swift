//
//  JobTitleSelectionView.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

// Represents a single job title item for the list
struct JobTitle: Identifiable {
    let id = UUID()
    let name: String
}

// The main view recreating the sheet content
struct JobTitleSelectionView: View {
    
    // State variable to hold the search text
    @State private var searchText = ""
    
    // Sample data for the job list
    let jobTitles = [
        JobTitle(name: "Software Engineer"),
        JobTitle(name: "Product Manager"),
        JobTitle(name: "Data Scientist"),
        JobTitle(name: "Software Engineering Manager"),
        JobTitle(name: "Technical Program Manager"),
        JobTitle(name: "Solution Architect"),
        JobTitle(name: "Program Manager")
        // Add more job titles as needed
    ]
    
    // Filtered list based on search text (basic example)
    var filteredJobTitles: [JobTitle] {
        if searchText.isEmpty {
            return jobTitles
        } else {
            return jobTitles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Sheet Handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8) // Adjusted padding

            // 2. Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search job families", text: $searchText)
                    .foregroundColor(.white)
                    .accentColor(.blue) // Sets the cursor color
                    // Set placeholder text color using an overlay or ZStack if needed
                    // For basic approach, default placeholder color might suffice
            }
            .padding(.horizontal)
            .padding(.vertical, 10) // Slightly reduced vertical padding
            .background(Color.gray.opacity(0.25)) // Slightly darker grey background
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom) // Add padding below the search bar

            // 3. Request Button
            Button(action: {
                // Action for requesting a title
                print("Request My Title tapped")
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Request My Title")
                }
                .foregroundColor(Color(UIColor.systemBlue)) // Use systemBlue for consistency
                .padding(.vertical, 10) // Add some vertical padding
                .frame(maxWidth: .infinity, alignment: .leading) // Align left
            }
            .padding(.horizontal) // Add horizontal padding to the button content
            .padding(.bottom) // Add padding below the button

            // 4. Section Header
            Text("TECHNOLOGY")
                .font(.caption) // Use caption font size
                .foregroundColor(.gray) // Grey color for the header
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8) // Padding below the header

            // 5. Job Title List
            ScrollView {
                VStack(alignment: .leading, spacing: 0) { // Remove spacing if dividers are used
                    ForEach(filteredJobTitles) { jobTitle in
                        JobTitleRow(title: jobTitle.name)
                        // Optional: Add a divider if desired visually
                        // Divider().background(Color.gray.opacity(0.3)).padding(.leading)
                    }
                }
            }
            // Let the ScrollView take the remaining space
            .frame(maxHeight: .infinity)

        }
        .padding(.top, 5) // Add slight padding at the very top below the handle
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Background for the sheet content area
        .preferredColorScheme(.dark) // Enforce dark mode for this view
    }
}

// Reusable view for each row in the job list
struct JobTitleRow: View {
    let title: String

    var body: some View {
        Button(action: {
             // Action when a job title row is tapped
             print("\(title) selected")
         }) {
             HStack(spacing: 15) { // Add spacing between icon and text
                 Image(systemName: "briefcase")
                     .foregroundColor(.gray) // Use system gray for icon

                 Text(title)
                     .foregroundColor(.white) // White text color

                 Spacer() // Pushes content to the left
             }
             .padding(.vertical, 12) // Adjust vertical padding for row height
             .padding(.horizontal) // Horizontal padding within the row
             .contentShape(Rectangle()) // Make the whole row tappable
         }
         .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid default button styling interfering
    }
}

// Preview Provider for easy testing in Xcode Canvas
struct JobTitleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        JobTitleSelectionView()
            // Simulate being presented as a sheet for preview
            .previewLayout(.fixed(width: 375, height: 600)) // Approximate sheet height
    }
}
