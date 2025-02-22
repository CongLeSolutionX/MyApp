//
//  CaseLookUp.swift
//  MyApp
//
//  Created by Cong Le on 2/21/25.

import SwiftUI
import Foundation

// MARK: - Models

struct CitationLookupItem: Codable {
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

struct CitationCluster: Codable {
    let resourceURI: String?
    let attorneys: String?

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
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    Text("Waiting for data...")
                }
            }
            .navigationTitle("Citation Lookup")
        }
        .task {
            await fetchCitationData()
        }
    }

    // MARK: - Network Request

    private func fetchCitationData() async {
        guard let url = URL(string: "https://www.courtlistener.com/api/rest/v4/citation-lookup/") else {
            await MainActor.run {
                errorMessage = "Invalid URL."
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token YOUR_TOKEN_API_HERE", forHTTPHeaderField: "Authorization")
        // Commonly used when posting form data
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let postBody = "text=Obergefell v. Hodges (576 U.S. 644) established the right to marriage among same-sex couples"
        request.httpBody = postBody.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    errorMessage = "No valid response."
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                await MainActor.run {
                    errorMessage = "Request returned status code \(httpResponse.statusCode)."
                }
                return
            }

            let decoded = try JSONDecoder().decode([CitationLookupItem].self, from: data)
            await MainActor.run {
                lookupResults = decoded
            }

            if let prettyString = prettyPrintJSON(decoded) {
                print(prettyString)
            } else {
                print("Could not format JSON.")
            }

        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Re-encodes an Encodable object into a pretty-printed JSON string. Returns `nil` if encoding fails.
    func prettyPrintJSON<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to encode JSON: \(error)")
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    CitationLookupView()
}
