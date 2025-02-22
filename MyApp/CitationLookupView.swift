//
//  CaseLookUp.swift
//  MyApp
//
//  Created by Cong Le on 2/21/25.
//

import SwiftUI

struct CitationLookupResponse: Decodable {
    // Adjust fields to match the JSON structure you need
    // This example captures a snippet of the attorneys text
    let attorneysSnippet: String

    enum CodingKeys: String, CodingKey {
        case attorneysSnippet = "06fc234206a7f21224e5ed49c6c5a110e736ed86" // Replace "text" with the actual key from your JSON
    }
}

struct CitationLookupView: View {
    @State private var citationResult: CitationLookupResponse?
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let citationResult = citationResult {
                    ScrollView {
                        Text(citationResult.attorneysSnippet)
                            .padding()
                    }
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    Text("Fetching citation lookup...")
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

    private func fetchCitationData() async {
        guard let url = URL(string: "https://www.courtlistener.com/api/rest/v4/citation-lookup/") else {
            errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Replace YOUR_API_TOKEN with your actual token
        request.setValue("Token YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
        
        // Adjust the POST data to match your query or form structure
        let postString = "text=Obergefell v. Hodges (576 U.S. 644) established the right to marriage among same-sex couples"
        request.httpBody = postString.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Request failed with response: \(response)"
                return
            }
            let decoded = try JSONDecoder().decode(CitationLookupResponse.self, from: data)
            citationResult = decoded
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    CitationLookupView()
}
