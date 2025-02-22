//
//  CourtListenerView.swift
//  MyApp
//
//  Created by Cong Le on 2/21/25.
//

import SwiftUI

// MARK: - Model

struct ClustersResponse: Codable {
    let results: [ClusterItem]
}

struct ClusterItem: Codable, Identifiable {
    let resource_uri: String
    let id: Int
    let absolute_url: String
    let docket: String
    let date_filed: String
    let blocked: Bool
    let case_name_short: String?
    let case_name: String?
    let slug: String
    
    // Certain fields in the JSON may not always be present or can be null,
    // so we mark optional properties with Swift optionals.
    // The coding keys below let us map JSON keys to Swift property names.
    enum CodingKeys: String, CodingKey {
        case resource_uri
        case id
        case absolute_url
        case docket = "docket"
        case date_filed
        case blocked
        case case_name_short
        case case_name
        case slug
    }
}

// MARK: - ViewModel for Data Fetch

class CourtListenerViewModel: ObservableObject {
    @Published var clusters: [ClusterItem] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    func fetchClusters() {
        guard let url = URL(string: "https://www.courtlistener.com/api/rest/v4/clusters/") else {
            errorMessage = "Invalid URL."
            return
        }
        
        // Example authorization token. Replace or remove as appropriate.
        let token = "YOUR_TOKEN_API_HERE"
        
        var request = URLRequest(url: url)
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Request error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received."
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ClustersResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.clusters = decodedResponse.results
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - SwiftUI View

struct CourtListenerView: View {
    @StateObject private var viewModel = CourtListenerViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...").padding()
                } else if !viewModel.errorMessage.isEmpty {
                    Text("Error: \(viewModel.errorMessage)")
                        .padding()
                } else {
                    List(viewModel.clusters) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.case_name_short ?? item.case_name ?? "No Title")
                                .font(.headline)
                            Text("Filed: \(item.date_filed)")
                                .font(.subheadline)
                            Text("Slug: \(item.slug)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("Blocked:")
                                Text(item.blocked ? "Yes" : "No")
                                    .foregroundColor(item.blocked ? .red : .green)
                            }
                            .font(.footnote)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("CourtListener Data")
        }
        .onAppear {
            viewModel.fetchClusters()
        }
    }
}

// MARK: - Preview

struct CourtListenerView_Previews: PreviewProvider {
    static var previews: some View {
        CourtListenerView()
    }
}
