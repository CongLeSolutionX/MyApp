//
//  CourtListenerView.swift
//  MyApp
//
//  Created by Cong Le on 2/21/25.
//
import SwiftUI

// MARK: - Models

/// Main JSON response listing multiple clusters.
struct ClustersResponse: Codable {
    let results: [ClusterItem]
}

/// Minimal cluster listing fields that appear in the main list.
/// Additional fields can be added as needed for display.
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
    
    enum CodingKeys: String, CodingKey {
        case resource_uri
        case id
        case absolute_url
        case docket
        case date_filed
        case blocked
        case case_name_short
        case case_name
        case slug
    }
}

/// A more detailed cluster structure. Adjust fields to match
/// the JSON returned from each cluster's resource URI, if different.
struct DetailedClusterItem: Codable {
    let resource_uri: String
    let id: Int
    let absolute_url: String
    let docket: String
    let date_filed: String
    let blocked: Bool
    let case_name_short: String?
    let case_name: String?
    let slug: String
    // You can add more properties if the detail endpoint provides them.
    
    // This initializer can map from a simpler item if needed.
    init(from clusterItem: ClusterItem) {
        self.resource_uri = clusterItem.resource_uri
        self.id = clusterItem.id
        self.absolute_url = clusterItem.absolute_url
        self.docket = clusterItem.docket
        self.date_filed = clusterItem.date_filed
        self.blocked = clusterItem.blocked
        self.case_name_short = clusterItem.case_name_short
        self.case_name = clusterItem.case_name
        self.slug = clusterItem.slug
    }
}

// MARK: - ViewModels

/// Main view model for fetching the list of clusters.
class CourtListenerViewModel: ObservableObject {
    @Published var clusters: [ClusterItem] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    func fetchClusters() {
        guard let url = URL(string: "https://www.courtlistener.com/api/rest/v4/clusters/") else {
            errorMessage = "Invalid URL."
            return
        }
        
        let token = "YOUR_TOKEN_API_HERE" // Replace with your own API key
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
                    //print(decodedResponse)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

/// View model for fetching details of a single cluster item.
class ClusterDetailViewModel: ObservableObject {
    @Published var detail: DetailedClusterItem?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    
    private let clusterItem: ClusterItem
    
    init(item: ClusterItem) {
        self.clusterItem = item
    }
    
    /// Fetch more detailed information for a single cluster item.
    func fetchDetails() {
        guard let url = URL(string: clusterItem.resource_uri) else {
            errorMessage = "Invalid detail URL."
            showAlert = true
            return
        }
        
        let token = "06fc234206a7f21224e5ed49c6c5a110e736ed86" // Replace with your own API key
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
                    self?.showAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received."
                    self?.showAlert = true
                }
                return
            }
            
            do {
                // If the detail JSON structure matches the same fields in DetailedClusterItem,
                // we can decode directly. If it's different, adjust accordingly.
                let decodedDetail = try JSONDecoder().decode(DetailedClusterItem.self, from: data)
                DispatchQueue.main.async {
                    self?.detail = decodedDetail
                    //print(decodedDetail)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - Views

/// Main list of cluster items.
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
                        NavigationLink(destination: ClusterDetailView(viewModel: ClusterDetailViewModel(item: item))) {
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
            }
            .navigationTitle("CourtListener Data")
        }
        .onAppear {
            viewModel.fetchClusters()
        }
    }
}

/// Detail view for a single cluster item.
struct ClusterDetailView: View {
    @ObservedObject var viewModel: ClusterDetailViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading details...")
            } else if let detail = viewModel.detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(detail.case_name_short ?? detail.case_name ?? "No Title")
                            .font(.title2)
                            .padding(.bottom, 4)
                        Text("ID: \(detail.id)")
                        Text("Docket: \(detail.docket)")
                        Text("Blocked: \(detail.blocked ? "Yes" : "No")")
                        Text("Date Filed: \(detail.date_filed)")
                        Text("Slug: \(detail.slug)")
                    }
                    .padding()
                }
            } else {
                Text("No details available.")
                    .padding()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.fetchDetails()
        }
        .navigationTitle("Cluster Details")
    }
}

// MARK: - Preview

struct CourtListenerView_Previews: PreviewProvider {
    static var previews: some View {
        CourtListenerView()
    }
}
