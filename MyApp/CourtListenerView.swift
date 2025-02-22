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

/// A more detailed cluster structure (fetched from the cluster's resource_uri).
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

// MARK: - Docket Model
/// Docket detail structure updated according to the provided JSON.
/// Many fields are optional, allowing us to handle unexpected missing data.
struct DocketDetailItem: Codable, Identifiable {
    let id: Int
    let resource_uri: String
    let court: String?
    let court_id: String?
    let original_court_info: String?
    let idb_data: String?
    let clusters: [String]?
    let audio_files: [String]?
    let assigned_to: String?
    let referred_to: String?
    let absolute_url: String?
    let date_created: String?
    let date_modified: String?
    let source: Int?
    let appeal_from_str: String?
    let assigned_to_str: String?
    let referred_to_str: String?
    let panel_str: String?
    let date_last_index: String?
    let date_cert_granted: String?
    let date_cert_denied: String?
    let date_argued: String?
    let date_reargued: String?
    let date_reargument_denied: String?
    let date_filed: String?
    let date_terminated: String?
    let date_last_filing: String?
    let case_name_short: String?
    let case_name: String?
    let case_name_full: String?
    let slug: String?
    let docket_number: String?
    let docket_number_core: String?
    let blocked: Bool?
    let appeal_from: String?
    let parent_docket: String?
    let tags: [String]?
    let panel: [String]?
    
    // Note: You may want to show more fields in the UI,
    // so feel free to expand or reorganize as needed.
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
        
        // Replace with your actual CourtListener token
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
                let decodedDetail = try JSONDecoder().decode(DetailedClusterItem.self, from: data)
                DispatchQueue.main.async {
                    self?.detail = decodedDetail
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

/// View model for docket details.
class DocketDetailViewModel: ObservableObject {
    @Published var docketDetail: DocketDetailItem?
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    
    private let docketURL: String
    
    init(docketURL: String) {
        self.docketURL = docketURL
    }
    
    func fetchDocket() {
        guard let url = URL(string: docketURL) else {
            errorMessage = "Invalid docket URL."
            showAlert = true
            return
        }
        
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
                let decodedDocket = try JSONDecoder().decode(DocketDetailItem.self, from: data)
                DispatchQueue.main.async {
                    self?.docketDetail = decodedDocket
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Docket decoding error: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - Views

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
                        Text("Date Filed: \(detail.date_filed)")
                        Text("Slug: \(detail.slug)")
                        HStack {
                            Text("Blocked:")
                            Text(detail.blocked ? "Yes" : "No")
                                .foregroundColor(detail.blocked ? .red : .green)
                        }
                        
                        // Hyperlink to the docket
                        NavigationLink(
                            destination: DocketDetailView(viewModel: DocketDetailViewModel(docketURL: detail.docket))
                        ) {
                            Text("Docket: \(detail.docket)")
                                .foregroundColor(.blue)
                                .underline()
                        }
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

/// View for displaying the docket details.
struct DocketDetailView: View {
    @ObservedObject var viewModel: DocketDetailViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading docket...")
            } else if let docket = viewModel.docketDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Show relevant data, using optional coalescing to avoid crashes.
                        Text("Docket ID: \(String(docket.id))")
                            .font(.headline)
                        
                        Text("URI: \(docket.resource_uri)")
                            .font(.subheadline)
                        
                        if let courtID = docket.court_id {
                            Text("Court ID: \(courtID)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        if let docketNum = docket.docket_number {
                            Text("Docket Number: \(docketNum)")
                        } else {
                            Text("Docket Number: N/A")
                                .foregroundColor(.secondary)
                        }
                        
                        if let created = docket.date_created {
                            Text("Date Created: \(created)")
                                .font(.footnote)
                        }
                        
                        if let modified = docket.date_modified {
                            Text("Date Modified: \(modified)")
                                .font(.footnote)
                        }
                        
                        if let docketCaseName = docket.case_name {
                            Text("Case Name: \(docketCaseName)")
                                .font(.body)
                                .padding(.top, 6)
                        }
                        
                        if let blocked = docket.blocked {
                            HStack {
                                Text("Blocked:")
                                Text(blocked ? "Yes" : "No")
                                    .foregroundColor(blocked ? .red : .green)
                            }
                            .font(.footnote)
                        }
                        
                        if let slug = docket.slug {
                            Text("Slug: \(slug)")
                                .font(.footnote)
                        }
                    }
                    .padding()
                }
            } else {
                Text("No docket information available.")
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
        .navigationTitle("Docket Detail")
        .onAppear {
            viewModel.fetchDocket()
        }
    }
}

// MARK: - Preview
struct CourtListenerView_Previews: PreviewProvider {
    static var previews: some View {
        CourtListenerView()
    }
}
