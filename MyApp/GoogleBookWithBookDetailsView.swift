//
//  GoogleBookView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import Combine

// MARK: - Data Models (No change from previous)

/// Unified data model for displaying books in the UI (Primarily for List Row).
struct Book: Identifiable { // Keep this simple version for the list row if preferred
    let id: String
    let title: String
    let authors: String // Combined authors string
    let thumbnailURL: URL?

    // Initializer to map from API's BookItem
    init(from item: BookItem) {
        self.id = item.id
        self.title = item.volumeInfo.title ?? "No Title"
        self.authors = item.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author"
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

struct BookItem: Decodable, Identifiable { // Make identifiable
    let kind: String?
    let id: String
    let etag: String?
    let selfLink: String?
    let volumeInfo: VolumeInfo
    // saleInfo, accessInfo, searchInfo can be added if needed
}

struct VolumeInfo: Decodable {
    let title: String?
    let subtitle: String? // Added subtitle
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
    let small: String? // Added for potentially larger image
    let medium: String?
    let large: String?
    let extraLarge: String?

    // Helper to get the best available image URL, preferring larger sizes
    var bestAvailableImageURLString: String? {
        medium ?? large ?? small ?? thumbnail ?? smallThumbnail ?? extraLarge // Order preference
    }
}

// MARK: - API Endpoints (No change)

enum GoogleBooksAPIEndpoint {
    case search(query: String, maxResults: Int, startIndex: Int)

    var path: String {
        switch self {
        case .search:
            return "/books/v1/volumes"
        }
    }

    func queryItems(apiKey: String) -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: "key", value: apiKey)]
        switch self {
        case .search(let query, let maxResults, let startIndex):
            items.append(URLQueryItem(name: "q", value: query))
            items.append(URLQueryItem(name: "maxResults", value: "\(maxResults)"))
            items.append(URLQueryItem(name: "startIndex", value: "\(startIndex)"))
            items.append(URLQueryItem(name: "printType", value: "books"))
        }
        return items
    }
}

// MARK: - API Errors (No change)

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

// MARK: - Authentication (API Key) (No change)

struct AuthCredentials {
    static let googleBooksAPIKey = "YOUR_API_KEY_HERE" // <-- REPLACE THIS
}

// MARK: - Data Service (Modified to publish BookItems)

final class GoogleBooksDataService: ObservableObject {
    // Change to publish the full BookItem for detail view access
    @Published var bookItems: [BookItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var totalItems: Int = 0
    @Published var currentSearchQuery: String = ""
    @Published var currentPage: Int = 0

    private let baseURLString = "https://www.googleapis.com"
    private var cancellables = Set<AnyCancellable>()
    private let resultsPerPage = 20

    private var apiKey: String? {
        let key = AuthCredentials.googleBooksAPIKey
        return (key.isEmpty || key == "YOUR_API_KEY_HERE") ? nil : key
    }

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
            if query == currentSearchQuery {
                 currentPage += 1
            } else {
                currentPage = 0
                bookItems = [] // Clear items for new search
                totalItems = 0
            }
        } else {
            currentPage = 0
            bookItems = [] // Clear items for new search
            totalItems = 0
        }
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
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("No HTTP response received.")
                }
                switch httpResponse.statusCode {
                case 200...299: return data
                case 400:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Bad Request"
                    throw APIError.requestFailed("Bad Request: \(errorDetail)")
                case 401, 403:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Check API Key/Permissions"
                    throw APIError.requestFailed("Authentication/Authorization Failed: \(errorDetail)")
                case 404: throw APIError.noData
                case 500...599:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? "Server Error"
                    throw APIError.requestFailed("Server Error (\(httpResponse.statusCode)): \(errorDetail)")
                default:
                    let errorDetail = Self.decodeGoogleError(from: data) ?? ""
                    throw APIError.requestFailed("HTTP Status Code \(httpResponse.statusCode). \(errorDetail)")
                }
            }
            .decode(type: GoogleBooksResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                guard let self = self else { return }
                if case .failure(let error) = completionResult {
                     self.isLoading = false
                     let apiError = (error as? APIError) ?? APIError.unknown(error)
                     self.handleError(apiError)
                 }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                self.totalItems = response.totalItems

                let newItems = response.items ?? []

                if self.currentPage > 0 {
                    self.bookItems.append(contentsOf: newItems) // Append directly
                } else {
                    self.bookItems = newItems // Replace directly
                }

                // Simplified check for no data after search attempt
                if self.bookItems.isEmpty && !self.currentSearchQuery.isEmpty {
                     self.handleError(APIError.noData)
                 }
            }
            .store(in: &cancellables)
    }

    private struct GoogleErrorResponse: Decodable {
        struct ErrorInfo: Decodable { let message: String?; let domain: String?; let reason: String? }
        let error: ErrorInfo?
    }

    private static func decodeGoogleError(from data: Data) -> String? {
        (try? JSONDecoder().decode(GoogleErrorResponse.self, from: data))?.error?.message ?? String(data: data, encoding: .utf8)
    }

    func handleError(_ error: APIError) {
         // Update error only if not currently loading or after a small delay
         if !isLoading {
             errorMessage = error.localizedDescription
         } else {
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                 self?.isLoading = false
                 self?.errorMessage = error.localizedDescription
             }
         }
         print("API Error: \(error.localizedDescription)")
     }

    func clearData() {
        bookItems = [] // Clear bookItems
        totalItems = 0
        errorMessage = nil
        isLoading = false
        currentSearchQuery = ""
        currentPage = 0
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

// MARK: - SwiftUI Views

// Main ContentView for Search and Results List
struct GoogleBookWithBookDetailsView: View {
    @StateObject private var dataService = GoogleBooksDataService()
    @State private var searchQuery: String = ""

    var body: some View {
        NavigationView { // Essential for NavigationLink
            VStack {
                // Search Bar Area (No change)
                HStack {
                    TextField("Search for books...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { dataService.fetchBooks(query: searchQuery) }
                    Button { dataService.fetchBooks(query: searchQuery) } label: { Image(systemName: "magnifyingglass") }
                        .disabled(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Button { searchQuery = ""; dataService.clearData() } label: { Image(systemName: "xmark.circle.fill") }
                        .tint(.gray)
                        .opacity(searchQuery.isEmpty && dataService.bookItems.isEmpty ? 0 : 1)
                }.padding([.horizontal, .top])

                // Results Area Logic (Updated to use bookItems)
                if dataService.isLoading && dataService.bookItems.isEmpty {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if let errorMessage = dataService.errorMessage {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red).multilineTextAlignment(.center).padding()
                    Spacer()
                } else if dataService.bookItems.isEmpty && !dataService.currentSearchQuery.isEmpty {
                    Spacer()
                    Text("No books found for \"\(dataService.currentSearchQuery)\".")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        // Iterate over bookItems
                        ForEach(dataService.bookItems) { item in
                            // NavigationLink wraps the row
                            NavigationLink(destination: BookDetailView(item: item)) {
                                BookRowView(item: item) // Pass the full BookItem
                                     .onAppear {
                                        if item.id == dataService.bookItems.last?.id &&
                                           dataService.bookItems.count < dataService.totalItems &&
                                           !dataService.isLoading {
                                               dataService.fetchBooks(query: dataService.currentSearchQuery, loadMore: true)
                                            }
                                        }
                            }
                        }

                        // Load More Indicator
                        if dataService.isLoading && !dataService.bookItems.isEmpty {
                             ProgressView().frame(maxWidth: .infinity, alignment: .center).padding()
                         }

                    } // End List
                    .listStyle(PlainListStyle())
                    .refreshable { dataService.fetchBooks(query: dataService.currentSearchQuery) }
                }
            } // End VStack
            .navigationTitle("Google Books Search")
            .navigationBarTitleDisplayMode(.inline)
        } // End NavigationView
        .onAppear { // API Key Check (No change)
            if AuthCredentials.googleBooksAPIKey == "YOUR_API_KEY_HERE" {
                dataService.handleError(.apiKeyMissing)
            }
        }
    } // End body
} // End ContentView

// Book Row View (Modified to accept BookItem)
struct BookRowView: View {
    let item: BookItem // Accept the full item
    private let bookDisplay: Book // Use the simplified model *internally* for row display convenience

    init(item: BookItem) {
        self.item = item
        self.bookDisplay = Book(from: item) // Create the display version
    }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: bookDisplay.thumbnailURL) { phase in // Use display model's URL
                switch phase {
                case .empty: ProgressView()
                case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                case .failure: Image(systemName: "book.closed").foregroundColor(.secondary)
                @unknown default: EmptyView()
                }
            }
            .frame(width: 60, height: 90).cornerRadius(4)

            VStack(alignment: .leading, spacing: 4) {
                Text(bookDisplay.title).font(.headline).lineLimit(2) // Use display model
                Text(bookDisplay.authors).font(.subheadline).foregroundColor(.secondary) // Use display model
                if let description = item.volumeInfo.description, !description.isEmpty { // Use full description if needed briefly
                    Text(description).font(.caption).foregroundColor(.gray).lineLimit(3)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// NEW: Book Detail View
struct BookDetailView: View {
    let item: BookItem // Receives the selected BookItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Header Section (Image, Title, Authors)
                HStack(alignment: .top, spacing: 15) {
                    AsyncImage(url: URL(string: item.volumeInfo.imageLinks?.bestAvailableImageURLString ?? "")) { phase in
                         switch phase {
                         case .empty: ProgressView().frame(height: 180)
                         case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                         case .failure: Image(systemName: "book.closed").font(.system(size: 60)).foregroundColor(.secondary)
                         @unknown default: EmptyView()
                         }
                     }
                    .frame(idealWidth: 120, maxWidth: 150, idealHeight: 180, maxHeight: 220)
                    .cornerRadius(6)
                    .shadow(radius: 3)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.volumeInfo.title ?? "No Title")
                            .font(.title2).bold()
                        if let subtitle = item.volumeInfo.subtitle, !subtitle.isEmpty {
                             Text(subtitle)
                                .font(.title3).italic().foregroundColor(.gray)
                         }

                        Text(item.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        // Rating (if available)
                        if let rating = item.volumeInfo.averageRating, let count = item.volumeInfo.ratingsCount {
                             HStack {
                                 ForEach(0..<5) { index in
                                     Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                         .foregroundColor(.orange)
                                 }
                                Text("(\(count))")
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                             }
                             .padding(.top, 5)
                         }
                    }
                    Spacer() // Pushes content to the left
                }
                .padding(.horizontal)
                .padding(.top)

                Divider()

                // Description Section
                if let description = item.volumeInfo.description, !description.isEmpty {
                     VStack(alignment: .leading) {
                         Text("Description").font(.headline)
                         // Use HTML rendering if needed, otherwise plain text
                         Text(description) // consider .lineSpacing() for better readability
                             .font(.body)
                     }
                     .padding(.horizontal)
                 } else {
                     Text("No description available.").font(.body).foregroundColor(.secondary).padding(.horizontal)
                 }

                Divider()

                // Details Section
                VStack(alignment: .leading, spacing: 8) {
                     Text("Details").font(.headline)
                     DetailRow(label: "Publisher", value: item.volumeInfo.publisher)
                     DetailRow(label: "Published Date", value: item.volumeInfo.publishedDate)
                     DetailRow(label: "Page Count", value: item.volumeInfo.pageCount?.description)
                     DetailRow(label: "Language", value: item.volumeInfo.language?.uppercased())
                     DetailRow(label: "Categories", value: item.volumeInfo.categories?.joined(separator: ", "))

                     // ISBNs
                     if let identifiers = item.volumeInfo.industryIdentifiers {
                          ForEach(identifiers, id: \.identifier) { identifier in
                               DetailRow(label: identifier.type?.replacingOccurrences(of: "_", with: " "), value: identifier.identifier)
                           }
                      }
                 }
                 .padding(.horizontal)

                // Links Section
                 if item.volumeInfo.previewLink != nil || item.volumeInfo.infoLink != nil {
                     Divider()
                     VStack(alignment: .leading) {
                          Text("Links").font(.headline)
                          HStack {
                              if let previewUrlString = item.volumeInfo.previewLink, let url = URL(string: previewUrlString) {
                                     Link("Preview", destination: url)
                                          .buttonStyle(.bordered)
                                }
                              if let infoUrlString = item.volumeInfo.infoLink, let url = URL(string: infoUrlString) {
                                     Link("More Info", destination: url)
                                          .buttonStyle(.bordered)
                                }
                           }
                      }
                      .padding(.horizontal)
                 }

            } // End Main VStack
            .padding(.bottom) // Add padding at the bottom of the scroll content
        } // End ScrollView
        .navigationTitle(item.volumeInfo.title ?? "Book Details")
        .navigationBarTitleDisplayMode(.inline) // Keep title compact
    }
}

// Helper view for Detail Rows
struct DetailRow: View {
    let label: String?
    let value: String?

    var body: some View {
        if let unwrappedValue = value, !unwrappedValue.isEmpty, let unwrappedLabel = label {
             HStack(alignment: .top) {
                 Text("\(unwrappedLabel):")
                     .font(.subheadline)
                     .fontWeight(.medium)
                     .foregroundColor(.secondary)
                     .frame(width: 120, alignment: .leading) // Align labels

                 Text(unwrappedValue)
                     .font(.subheadline)
                Spacer() // Pushes text to the left
            }
        } else {
            EmptyView() // Don't show row if value is nil or empty
        }
    }
}

// MARK: - Preview (No change needed if targetting ContentView)

struct GoogleBookView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleBookWithBookDetailsView()
    }
}

