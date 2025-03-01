//
//  GoogleBookVolumeView.swift
//  MyApp
//
//  Created by Cong Le on 3/1/25.
//

import SwiftUI

/// A simple SwiftUI representation of the "Working with Volumes" section
/// from the Google Books API reference materials.
/// API Doc: https://developers.google.com/books/docs/v1/using
struct GoogleBookVolumeView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Google Books API")) {
                    
                    NavigationLink(destination: SearchVolumesView()) {
                        Text("Performing a Search")
                    }
                    
                    NavigationLink(destination: RetrieveVolumeView()) {
                        Text("Retrieving a Specific Volume")
                    }
                    
                }
            }
            .navigationTitle("Working with Volumes")
        }
    }
}

// MARK: - Search Volumes View
struct SearchVolumesView: View {
    
    // Network call state management
    @State private var isLoading: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                Text("You can search for volumes by sending an HTTP GET request to:")
                    .padding(.bottom, 2)
                Text("https://www.googleapis.com/books/v1/volumes?q=search+terms")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Query Parameters")) {
                NavigationLink(destination: SearchParametersView()) {
                    Text("• Parameters Overview")
                }
            }
            
            Section(header: Text("Example Request")) {
                Text("GET https://www.googleapis.com/books/v1/volumes?q=flowers+inauthor:keyes&key=YOUR_API_KEY")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Response Highlights")) {
                Text("• Returns JSON with a list of matching volumes.\n" +
                     "• Each volume includes 'volumeInfo' (title, authors, etc.)\n" +
                     "• If authorized, may include user-specific data (e.g., purchased status).")
            }
            
            Section {
                Button(action: performSampleSearch) {
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading…")
                        }
                    } else {
                        Text("Perform Sample Search")
                    }
                }
            }
        }
        .navigationTitle("Performing a Search")
    }
    
    /// Sends a GET request to the Google Books API and prints JSON response.
    private func performSampleSearch() {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=flowers+inauthor:keyes&key=YOUR_API_KEY") else {
            print("Invalid URL.")
            return
        }
        
        isLoading = true
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Unexpected response status.")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response:\n\(jsonString)")
            } else {
                print("Unable to decode data to string.")
            }
        }
        task.resume()
    }
}

// MARK: - Retrieve Volume View
struct RetrieveVolumeView: View {
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                Text("Retrieve information for a specific volume by sending a GET request to:")
                    .padding(.bottom, 2)
                Text("https://www.googleapis.com/books/v1/volumes/volumeId")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Volume ID")) {
                Text("Volume IDs are unique strings, e.g. 'zyTCAlFPjgYC'.\n" +
                     "You can find the ID in search results or from the Google Books site.")
            }
            
            Section(header: Text("Example Request")) {
                Text("GET https://www.googleapis.com/books/v1/volumes/zyTCAlFPjgYC?key=YOUR_API_KEY")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Response Highlights")) {
                Text("• Returns JSON representing the volume you requested.\n" +
                     "• 'volumeInfo' includes title, authors, date, etc.\n" +
                     "• 'accessInfo' indicates eBook availability (epub, pdf).")
            }
        }
        .navigationTitle("Retrieving a Volume")
    }
}

// MARK: - Search Parameters View
struct SearchParametersView: View {
    var body: some View {
        List {
            Section(header: Text("Key Parameters")) {
                DisclosureGroup("q") {
                    Text("Full-text query string. Combine terms with '+', or special keywords\n" +
                         "like 'intitle:', 'inauthor:', 'inpublisher:', 'isbn:', etc.")
                }
                DisclosureGroup("download") {
                    Text("Restrict to volumes by download availability, e.g. 'epub'.")
                }
                DisclosureGroup("filter") {
                    Text("Restrict by volume availability: 'partial', 'full', 'free-ebooks', etc.")
                }
                DisclosureGroup("langRestrict") {
                    Text("Search results for a specific language, e.g. 'en' or 'fr'.")
                }
                DisclosureGroup("maxResults & startIndex") {
                    Text("Use these to paginate results (up to 40 max).")
                }
                DisclosureGroup("orderBy") {
                    Text("Change ordering: 'relevance' or 'newest'.")
                }
                DisclosureGroup("printType") {
                    Text("Restrict search to 'books' or 'magazines'.")
                }
                DisclosureGroup("projection") {
                    Text("Control how much data is returned: 'full' or 'lite'.")
                }
            }
        }
        .navigationTitle("Search Parameters")
    }
}

#Preview {
    GoogleBookVolumeView()
}
