//
//  MethodListView.swift
//  MyApp
//
//  Created by Cong Le on 3/3/25.
//

import SwiftUI

// MARK: - Data Models

struct Method: Codable, Identifiable {
    // Using name as a unique identifier
    var id: String { name }
    let url: String
    let name: String
    let full_name: String?
    let description: String
    let paper: Paper?
    let introduced_year: Int
    let source_url: String?
    let source_title: String?
    let code_snippet_url: String?
    let num_papers: Int
    let collections: [CollectionItem]
}

struct Paper: Codable {
    let title: String
    let url: String
}

struct CollectionItem: Codable, Identifiable {
    // Assuming each collection name is unique in context
    var id: String { collection }
    let collection: String
    let area_id: String
    let area: String
}

// MARK: - View Model

class MethodsViewModel: ObservableObject {
    @Published var methods: [Method] = []
    
    func loadMethods() {
        // Locate the JSON file bundled with the project.
        guard let url = Bundle.main.url(forResource: "methods-long", withExtension: "json") else {
            print("Unable to locate methods.json.")
            return
        }
        
        do {
            // Decode the JSON data into an array of Method objects.
            let data = try Data(contentsOf: url)
            let decodedMethods = try JSONDecoder().decode([Method].self, from: data)
            DispatchQueue.main.async {
                self.methods = decodedMethods
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}

// MARK: - SwiftUI View

struct MethodListView: View {
    @StateObject private var viewModel = MethodsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.methods) { method in
                VStack(alignment: .leading, spacing: 8) {
                    // Display the method title and introductory year.
                    Text(method.full_name ?? "NO FULL NAME")
                        .font(.headline)
                    Text("Introduced: \(method.introduced_year)")
                        .font(.subheadline)
                    
                    // Display the description text.
                    Text(method.description)
                        .font(.body)
                    
                    // If available, show the paper as a clickable link.
                    if let paper = method.paper,
                       let paperURL = URL(string: paper.url) {
                        Link("Paper: \(paper.title)", destination: paperURL)
                            .foregroundColor(.blue)
                    }
                    
                    // If the source details are available, display them.
                    if let sourceTitle = method.source_title,
                       let sourceURLString = method.source_url,
                       let sourceURL = URL(string: sourceURLString),
                       !sourceTitle.isEmpty {
                        Link("Source: \(sourceTitle)", destination: sourceURL)
                            .foregroundColor(.blue)
                    }
                    
                    // Display collections as tags.
                    if !method.collections.isEmpty {
                        HStack {
                            Text("Collections:")
                                .font(.subheadline)
                            ForEach(method.collections) { collection in
                                Text(collection.collection)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Methods")
        }
        .onAppear {
            viewModel.loadMethods()
        }
    }
}

// MARK: - Root Content View

struct MethodListContentView: View {
    var body: some View {
        MethodListView()
    }
}

// MARK: - Previews

struct MethodListContentView_Previews: PreviewProvider {
    static var previews: some View {
        MethodListContentView()
    }
}
