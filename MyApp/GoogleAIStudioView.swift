//
//  GoogleAIStudioView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI

// MARK: - Data Model for API Key Info
struct APIKeyInfo: Identifiable {
    let id = UUID()
    var projectNumber: String
    var projectName: String
    var apiKey: String
    var createdDate: String // Using String for simplicity, Date would be better
    var plan: String
    var isFreeTier: Bool
}

// Sample Data
let sampleApiKeys: [APIKeyInfo] = [
    APIKeyInfo(projectNumber: "...5517", projectName: "Google Books", apiKey: "...IWHA", createdDate: "Mar 27, 2025", plan: "Tier 1", isFreeTier: false),
    APIKeyInfo(projectNumber: "...3668", projectName: "Gemini API", apiKey: "...FBQk", createdDate: "Feb 5, 2025", plan: "Free", isFreeTier: true)
]

// MARK: - Main Content View
struct GoogleAIStudioView: View {
    @State private var selectedSidebarItem: String? = "API keys" // Default selection

    var body: some View {
        // Use NavigationSplitView for sidebar layout
        NavigationSplitView {
            SidebarView(selectedItem: $selectedSidebarItem)
        } detail: {
            // Show content based on selection, default to APIKeysView
            // In a real app, this would dynamically switch based on selectedSidebarItem
            APIKeysContentView()
        }
        .preferredColorScheme(.dark) // Enforce dark mode to match screenshot
    }
}

// MARK: - Sidebar Navigation View
struct SidebarView: View {
    @Binding var selectedItem: String?
    let sidebarBackgroundColor = Color(.sRGB, red: 0.1, green: 0.12, blue: 0.13, opacity: 1.0)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Google AI Studio")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.top)

            Button {
                // Action for Get API Key
            } label: {
                Label("Get API key", systemImage: "key.fill")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity) // Make button full width
            }
            .buttonStyle(.borderedProminent) // Gives a background color
            .tint(.blue) // Approximate button color
            .padding(.horizontal)
            .padding(.bottom)

            // List for navigation items
            List(selection: $selectedItem) {
                Section {
                    NavigationLink(value: "Create Prompt") { Label("Create Prompt", systemImage: "square.and.pencil") }
                    NavigationLink(value: "Stream Realtime") { Label("Stream Realtime", systemImage: "mic.fill") }
                    NavigationLink(value: "Starter Apps") { Label("Starter Apps", systemImage: "sparkles.square.filled.on.square")}
                    NavigationLink(value: "Tune a Model") { Label("Tune a Model", systemImage: "slider.horizontal.3") }
                    NavigationLink(value: "Library") { Label("Library", systemImage: "books.vertical.fill") }
                }

                Text("No prompts yet").font(.caption).foregroundColor(.gray) // Placeholder as seen

                Section {
                    NavigationLink(value: "Prompt Gallery") { Label("Prompt Gallery", systemImage: "square.grid.2x2.fill") }
                }

                Section {
                     // Using "doc.text.magnifyingglass" as a placeholder SFSymbol
                    NavigationLink(value: "API documentation") { Label("API documentation", systemImage: "doc.text.magnifyingglass") }
                    // Using "bubble.left.and.bubble.right.fill" as placeholder
                    NavigationLink(value: "Developer forum") { Label("Developer forum", systemImage: "bubble.left.and.bubble.right.fill") }
                    NavigationLink(value: "Changelog") {
                        HStack {
                            Image(systemName: "list.bullet.rectangle.portrait")
                            Text("Changelog")
                            Spacer()
                            Text("NEW")
                                .font(.caption2)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .tag("API keys") // Associate the section containing API keys with this tag if needed

            }
            .listStyle(.sidebar) // Standard sidebar list style

            Spacer() // Pushes Settings to the bottom

            Divider()

            // Settings and Back Button Area
            HStack {
                Label("Settings", systemImage: "gear")
                Spacer()
                Image(systemName: "chevron.left") // Back arrow simulation
            }
            .padding()
        }
        .background(sidebarBackgroundColor) // Match dark sidebar color
        .foregroundColor(.white) // Default text color for the sidebar
    }
}

// MARK: - Main Content Area for API Keys
struct APIKeysContentView: View {
    let mainBackgroundColor = Color(.sRGB, red: 0.15, green: 0.16, blue: 0.17, opacity: 1.0)
    let codeBlockBackgroundColor = Color(.sRGB, red: 0.2, green: 0.21, blue: 0.22, opacity: 1.0)
    let tableHeaderBackgroundColor = Color(.sRGB, red: 0.2, green: 0.21, blue: 0.22, opacity: 1.0)

    let curlCommand = """
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=GEMINI_API_KEY" \\
        -H 'Content-Type: application/json' \\
        -X POST \\
        -d '{
          "contents": [{
            "parts": [{"text": "Explain how AI works"}]
          }]
        }'
    """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("API keys")
                    .font(.largeTitle)
                    .fontWeight(.medium)

                Text("Quickly test the Gemini API")
                    .font(.headline)
                    .foregroundColor(.gray)

                Link("API quickstart guide", destination: URL(string: "https://developers.google.com/gemini/api/quickstart")!) // Example URL

                // Code Block Section
                VStack(alignment: .leading) {
                    Text(curlCommand)
                        .font(.system(.body, design: .monospaced)) // Monospaced font for code
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure text fills width
                        .background(codeBlockBackgroundColor)
                        .cornerRadius(8)
                        .overlay( // Add border if needed
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )

                    HStack {
                        Button {} label: { Image(systemName: "doc.on.doc") } // Copy icon
                        Button {} label: { Image(systemName: "arrow.down.circle") } // Download icon (placeholder)
                        Spacer()
                        Text("Use code with caution.")
                            .font(.caption)
                            .foregroundColor(.yellow) // Caution color
                    }
                    .padding(.top, 5)
                    .foregroundColor(.gray) // Default button icon color
                }

                Button {
                    // Action for Create API Key
                } label: {
                    Label("Create API key", systemImage: "key.fill")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15) // Give some horizontal padding
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .cornerRadius(8)

                Text("Your API keys are listed below. You can also view and manage your project and API keys in Google Cloud.")
                    .font(.callout)

                // API Keys Table/List
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row
                    APIKeyHeaderView()
                        .background(tableHeaderBackgroundColor)

                    Divider().background(Color.gray.opacity(0.5))

                    // Data Rows
                    ForEach(sampleApiKeys) { keyInfo in
                        APIKeyRowView(keyInfo: keyInfo)
                        Divider().background(Color.gray.opacity(0.5))
                    }
                }
                .background(codeBlockBackgroundColor) // Shared background for the table area
                 .cornerRadius(8)
                 .overlay( // Add border if needed
                     RoundedRectangle(cornerRadius: 8)
                         .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                 )

                Text("Remember to use API keys securely. Don't share or embed them in public code. Use of Gemini API from a billing-enabled project is subject to pay-as-you-go pricing.")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .padding(30) // Add overall padding to the main content area
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill
        .background(mainBackgroundColor) // Match dark background
        .foregroundColor(.white) // Default text color
    }
}

// MARK: - API Key Table Header Row
struct APIKeyHeaderView: View {
    var body: some View {
        Grid(alignment: .leading) {
            GridRow {
                Text("Project number").bold().gridCellAnchor(.leading)
                Text("Project name").bold().gridCellAnchor(.leading)
                Text("API key").bold().gridCellAnchor(.leading)
                Text("Created").bold().gridCellAnchor(.leading)
                Text("Plan").bold().gridCellAnchor(.leading)
                Text("").frame(width: 40) // Placeholder for delete button column
            }
             // Align content within grid cells
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - API Key Table Data Row
struct APIKeyRowView: View {
    let keyInfo: APIKeyInfo

    var body: some View {
        Grid(alignment: .leading) {
            GridRow(alignment: .top) { // Align row content to the top
                Text(keyInfo.projectNumber)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .gridCellAnchor(.leading)

                HStack {
                    Text(keyInfo.projectName)
                        .lineLimit(1)
                    Image(systemName: "arrow.up.right.square") // External link icon
                        .foregroundColor(.gray)
                }
                .gridCellAnchor(.leading)

                Text(keyInfo.apiKey)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .gridCellAnchor(.leading)

                Text(keyInfo.createdDate)
                    .gridCellAnchor(.leading)

                // Plan Details Column
                 VStack(alignment: .leading) {
                    Text(keyInfo.plan).bold()
                    if keyInfo.isFreeTier {
                        Link("Set up Billing", destination: URL(string: "#")!) // Placeholder URL
                    } else {
                        Link("Go to billing", destination: URL(string: "#")!) // Placeholder URL
                    }
                    Link("View usage data", destination: URL(string: "#")!) // Placeholder URL
                }
                 .font(.caption)
                 .gridCellAnchor(.leading)

                // Delete Button
                Button {
                    // Delete Action
                } label: {
                    Image(systemName: "trash")
                }
                 .foregroundColor(.gray)
                 .gridCellAnchor(.center) // Center the delete icon
                  .frame(width: 40)
            }
             // Align content within grid cells
              .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - Preview Provider
#Preview {
    GoogleAIStudioView()
}
