//
//  CaseLookUp.swift
//  MyApp
//
//  Created by Cong Le on 2/21/25.

import SwiftUI

// MARK: - Models

// Top-level item in the returned array
struct CitationLookupItem: Decodable {
    let citation: String?
    let normalizedCitations: [String]?
    let startIndex: Int?
    let endIndex: Int?
    let status: Int?
    let errorMessage: String?
    let clusters: [CitationCluster]?

    enum CodingKeys: String, CodingKey {
        case citation
        case normalizedCitations = "normalized_citations"
        case startIndex = "start_index"
        case endIndex = "end_index"
        case status
        case errorMessage = "error_message"
        case clusters
    }
}

// One item in the "clusters" array
struct CitationCluster: Decodable {
    let resourceURI: String?
    let attorneys: String?
    // Add other fields if needed

    enum CodingKeys: String, CodingKey {
        case resourceURI = "resource_uri"
        case attorneys
    }
}

// MARK: - View

struct CitationLookupView: View {
    @State private var lookupResults: [CitationLookupItem] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if !lookupResults.isEmpty {
                    // Example: Show the first cluster’s attorneys text from the first item.
                    // Adjust the display for your needs (list, multiple clusters, etc.).
                    if let firstCluster = lookupResults.first?.clusters?.first,
                       let attorneysText = firstCluster.attorneys,
                       !attorneysText.isEmpty {
                        ScrollView {
                            Text(attorneysText)
                                .padding()
                        }
                    } else {
                        Text("No attorney information found.")
                            .padding()
                    }
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    Text("Waiting for data...")
                }
            }
            .navigationTitle("Citation Lookup")
        }
        .onAppear {
            Task {
                await fetchCitationData()
            }
        }
    }

    // MARK: - Network Request
    
    private func fetchCitationData() async {
        guard let url = URL(string: "https://www.courtlistener.com/api/rest/v4/citation-lookup/") else {
            errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Replace YOUR_API_TOKEN with your actual token
        request.setValue("Token YOUR_TOKEN_API_HERE", forHTTPHeaderField: "Authorization")
        
        // The POST text matches what you tested in the shell command
        let postString = "text=Obergefell v. Hodges (576 U.S. 644) established the right to marriage among same-sex couples"
        request.httpBody = postString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Request returned an unexpected response."
                return
            }

            // Decoding the top-level JSON array into [CitationLookupItem].
            let decoded = try JSONDecoder().decode([CitationLookupItem].self, from: data)
            lookupResults = decoded
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
// MARK: - Preview
#Preview {
    CitationLookupView()
}
