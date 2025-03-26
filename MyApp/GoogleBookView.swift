//
//  GoogleBookView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Unified data model for displaying books in the UI.
struct Book: Identifiable {
    let id: String
    let title: String
    let authors: String // Combined authors string
    let description: String?
    let thumbnailURL: URL?

    // Initializer to map from API's BookItem
    init(from item: BookItem) {
        self.id = item.id
        self.title = item.volumeInfo.title ?? "No Title"
        self.authors = item.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author"
        self.description = item.volumeInfo.description
        // Prefer thumbnail, fallback to smallThumbnail
        let urlString = item.volumeInfo.imageLinks?.thumbnail ?? item.volumeInfo.imageLinks?.smallThumbnail
        self.thumbnailURL = URL(string: urlString ?? "")
    }
}

// API Response Models (Matching Google Books JSON structure)
struct GoogleBooksResponse: Decodable {
    let kind: String?
    let totalItems: Int
    let items: [BookItem]? // Items can be missing if no results
}

struct BookItem: Decodable, Identifiable { // Make identifiable for potential direct use
    let kind: String?
    let id: String
    let etag: String?
    let selfLink: String?
    let volumeInfo: VolumeInfo
    // saleInfo, accessInfo, searchInfo can be added if needed
}

struct VolumeInfo: Decodable {
    let title: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let pageCount: Int?
    let printType: String?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let maturityRating: String?
    let allowAnonLogging: Bool?
    let contentVersion: String?
    let imageLinks: ImageLinks?
    let language: String?
    let previewLink: String?
    let infoLink: String?
    let canonicalVolumeLink: String?
}

struct IndustryIdentifier: Decodable {
    let type: String? // e.g., "ISBN_10", "ISBN_13"
    let identifier: String?
}

struct ImageLinks: Decodable {
    let smallThumbnail: String?
    let thumbnail: String?
}

// MARK: - API Endpoints

enum GoogleBooksAPIEndpoint {
    case search(query: String, maxResults: Int, startIndex: Int)
    // Could add .getBookDetails(volumeId: String) later

    var path: String {
        switch self {
        case .search:
            return "/books/v1/volumes"
        }
    }

    // Helper to generate query items including the API key
    func queryItems(apiKey: String) -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: "key", value: apiKey)]
        switch self {
        case .search(let query, let maxResults, let startIndex):
            items.append(URLQueryItem(name: "q", value: query))
            items.append(URLQueryItem(name: "maxResults", value: "\(maxResults)"))
            items.append(URLQueryItem(name: "startIndex", value: "\(startIndex)"))
            // Add other parameters like filter, orderBy if needed
            items.append(URLQueryItem(name: "printType", value: "books")) // Example filter
        }
        return items
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData // Explicitly for empty 'items' array or 404
    case apiKeyMissing
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL endpoint."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed:
            return "Failed to decode the response from the server."
        case .noData:
            return "No books found matching the criteria."
        case .apiKeyMissing:
            return "API Key is missing. Please add it to AuthCredentials."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication (API Key)

struct AuthCredentials {
    // --- IMPORTANT ---
    // In a real app, DO NOT hardcode the API Key.
    // Use secure storage (Keychain) or build configurations/plist.
    static let googleBooksAPIKey = "YOUR_API_KEY_HERE" // <-- REPLACE THIS
}

// MARK: - Data Service

final class GoogleBooksDataService: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var totalItems: Int = 0 // Total results available from API
    @Published var currentSearchQuery: String = "" // Keep track for "Load More"
    @Published var currentPage: Int = 0 // For pagination (using startIndex)

    private let baseURLString = "https://www.googleapis.com"
    private var cancellables = Set<AnyCancellable>()
    private let resultsPerPage = 20 // How many items to fetch per page

    // Check if API key is provided
    private var apiKey: String? {
        let key = AuthCredentials.googleBooksAPIKey
        return (key.isEmpty || key == "YOUR_API_KEY_HERE") ? nil : key
    }

    // MARK: - Public API Data Fetching

    func fetchBooks(query: String, loadMore: Bool = false) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
             handleError(APIError.requestFailed("Search query cannot be empty."))
             return
         }
        guard let validApiKey = apiKey else {
            handleError(APIError.apiKeyMissing)
            return
        }

        isLoading = true
        errorMessage = nil

        if loadMore {
            // Increment page only if loading more for the *same* query
            if query == currentSearchQuery {
                 currentPage += 1
            } else {
                // New search query while "Load More" was triggered? Reset.
                currentPage = 0
                books = []
                totalItems = 0
            }

        } else {
            // New search, reset everything
            currentPage = 0
            books = []
            totalItems = 0
        }
        //Update the current search query
        currentSearchQuery = query


        let startIndex = currentPage * resultsPerPage
        let endpoint = GoogleBooksAPIEndpoint.search(query: query, maxResults: resultsPerPage, startIndex: startIndex)

        makeDataRequest(endpoint: endpoint, apiKey: validApiKey)
    }

    private func makeDataRequest(endpoint: GoogleBooksAPIEndpoint, apiKey: String) {
        var components = URLComponents(string: baseURLString)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryItems(apiKey: apiKey)

        guard let url = components?.url else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept") // Prefer JSON

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("No HTTP response received.")
                }

                // Check for common error status codes
                switch httpResponse.statusCode {
                case 200...299:
                    return data // Success
                case 400:
                    // Attempt to decode Google's error JSON
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Bad Request"
                    throw APIError.requestFailed("Bad Request: \(errorDetail)")
                case 401, 403:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Check API Key/Permissions"
                    throw APIError.requestFailed("Authentication/Authorization Failed: \(errorDetail)")
                case 404:
                     throw APIError.noData // Treat 404 as no data found specifically
                case 500...599:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Server Error"
                    throw APIError.requestFailed("Server Error (\(httpResponse.statusCode)): \(errorDetail)")

                default:
                     let errorDetail = Self.decodeGoogleError(from: data) ?? ""
                    throw APIError.requestFailed("HTTP Status Code \(httpResponse.statusCode). \(errorDetail)")
                }
            }
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Switch to main thread for UI updates
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                // This sink completion only handles upstream errors (network, decoding)
                // HTTP errors were converted to throws in tryMap
                if case .failure(let error) = completionResult {
                     self.isLoading = false // Ensure loading stops on upstream error
                     let apiError = (error as? APIError) ?? APIError.unknown(error)
                     self.handleError(apiError) // Handle the specific or unknown error
                 }

            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                self.totalItems = response.totalItems

                // Process received items
                let newBooks = response.items?.compactMap { Book(from: $0) } ?? []
                 if self.currentPage > 0 { // Check if it was a "load more" operation
                     self.books.append(contentsOf: newBooks) // Append results
                 } else {
                     self.books = newBooks // Replace results for a new search
                 }

                // Handle case where API returns totalItems > 0 but empty items array for a page
                if self.books.isEmpty && self.totalItems > 0 && self.currentPage == 0 {
                     self.handleError(APIError.noData) // Or a more specific message
                 } else if self.books.isEmpty && self.totalItems == 0 {
                     self.handleError(APIError.noData) // Definitely no books found
                 }


            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper to Decode Google Error JSON
    // Google often returns errors in a specific JSON format
    private struct GoogleErrorResponse: Decodable {
        struct ErrorInfo: Decodable {
            let message: String?
            let domain: String?
            let reason: String?
        }
        let error: ErrorInfo?
    }

    private static func decodeGoogleError(from data: Data) -> String? {
        let decoder = JSONDecoder()
        if let errorResponse = try? decoder.decode(GoogleErrorResponse.self, from: data) {
            return errorResponse.error?.message
        }
        // Fallback if decoding fails or format is different
        return String(data: data, encoding: .utf8)
    }


    // MARK: - Error Handling
    func handleError(_ error: APIError) {
        // Don't overwrite an existing error message if already loading failed
         if !isLoading {
             errorMessage = error.localizedDescription
         } else {
             // If still loading, schedule the error message update slightly later
             // This prevents flickering if isLoading is set to false immediately after
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                 self?.isLoading = false // Ensure loading is stopped
                 self?.errorMessage = error.localizedDescription
             }
         }
        print("API Error: \(error.localizedDescription)") // Log for debugging
    }

    // MARK: - Clear Data
    func clearData() {
        books = []
        totalItems = 0
        errorMessage = nil
        isLoading = false
        currentSearchQuery = ""
        currentPage = 0
        cancellables.forEach { $0.cancel() } // Cancel ongoing requests
        cancellables.removeAll()

    }
}

// MARK: - SwiftUI Views

struct GoogleBookView: View {
    @StateObject private var dataService = GoogleBooksDataService()
    @State private var searchQuery: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar Area
                HStack {
                    TextField("Search for books...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { // Allow submitting with Return key
                             dataService.fetchBooks(query: searchQuery)
                           }
                    
                    Button {
                         dataService.fetchBooks(query: searchQuery)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if query is empty

                    Button {
                        searchQuery = ""
                        dataService.clearData()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                     .tint(.gray)
                     .opacity(searchQuery.isEmpty && dataService.books.isEmpty ? 0 : 1) // Hide if nothing to clear

                }
                .padding(.horizontal)
                .padding(.top)

                // Results Area
                if dataService.isLoading && dataService.books.isEmpty { // Show loading only on initial load
                      Spacer()
                      ProgressView("Searching...")
                      Spacer()
                  } else if let errorMessage = dataService.errorMessage {
                      Spacer()
                      Text(errorMessage)
                          .foregroundColor(.red)
                          .multilineTextAlignment(.center)
                          .padding()
                      Spacer()
                } else if dataService.books.isEmpty && !dataService.currentSearchQuery.isEmpty {
                     Spacer()
                     Text("No books found for \"\(dataService.currentSearchQuery)\".")
                         .foregroundColor(.secondary)
                     Spacer()
                 } else {
                     List {
                          ForEach(dataService.books) { book in
                              BookRowView(book: book)
                                   // Add task to fetch next page when the last item appears
                                   .onAppear {
                                        if book.id == dataService.books.last?.id &&
                                                              dataService.books.count < dataService.totalItems &&
                                                              !dataService.isLoading // Prevent multiple loads
                                         {
                                              dataService.fetchBooks(query: dataService.currentSearchQuery, loadMore: true)
                                         }
                                     }

                          }
                         // Optional explicit "Load More" button or indicator
                         if dataService.isLoading && !dataService.books.isEmpty {
                               ProgressView()
                                   .frame(maxWidth: .infinity, alignment: .center)
                                   .padding()
                          } else if dataService.books.count < dataService.totalItems && !dataService.books.isEmpty {
                             // You could add an explicit button here if you prefer over onAppear loading
                             // Button("Load More") { dataService.fetchBooks(query: dataService.currentSearchQuery, loadMore: true) }
                             //     .frame(maxWidth: .infinity, alignment: .center)
                           }

                     }
                    .listStyle(PlainListStyle()) // Use plain style for less visual clutter
                      .refreshable { // Allow pull-to-refresh for the current query
                           dataService.fetchBooks(query: dataService.currentSearchQuery)
                       }

                 }
            } // End VStack
             .navigationTitle("Google Books Search")
             .navigationBarTitleDisplayMode(.inline)

        } // End NavigationView
         .onAppear {
             // Trigger a default search on appear if desired
             // dataService.fetchBooks(query: "SwiftUI")
            // Check if API KEY is set
             if AuthCredentials.googleBooksAPIKey == "YOUR_API_KEY_HERE" {
                 dataService.handleError(.apiKeyMissing)
             }
         }

    }
}

// Separate Row View for better organization
struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: book.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "book.closed") // Placeholder icon
                        .foregroundColor(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 90) // Adjust size as needed
             .cornerRadius(4)


            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2) // Limit title lines
                Text(book.authors)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let description = book.description, !description.isEmpty {
                     Text(description)
                         .font(.caption)
                         .foregroundColor(.gray)
                         .lineLimit(3) // Limit description lines
                 }

            }
        }
        .padding(.vertical, 5)
    }
}


// MARK: - Preview

struct GoogleBookView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleBookView()
    }
}
