////
////  AppDesign.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//
//// MARK: - Data Models (Model Layer)
//import Foundation
//
//// Represents the overall API Response structure
//struct APIResponse<T: Codable>: Codable {
//    let jsonapi: JSONAPIMeta?
//    let data: [T]
//    let meta: ResponseMetadata?
//    let links: ResponseLinks?
//}
//
//struct JSONAPIMeta: Codable {
//    let version: String?
//    let meta: JSONAPILinksContainer?
//}
//
//struct JSONAPILinksContainer: Codable {
//    let links: JSONAPISelfLink?
//}
//
//struct JSONAPISelfLink: Codable {
//    let `self`: Link?
//}
//
//// Represents a single HSR Early Termination Notice record
//struct Notice: Codable, Identifiable {
//    let type: String
//    let id: String
//    let links: RecordLinks?
//    let attributes: NoticeAttributes?
//    // Relationships are present but seem minimal/null in examples,
//    // can be fleshed out if needed.
//    // let relationships: NoticeRelationships?
//}
//
//struct RecordLinks: Codable {
//    let `self`: Link?
//}
//
//// Attributes of a Notice record
//struct NoticeAttributes: Codable {
//    let title: String?
//    let created: String? // Consider converting to Date
//    let updated: String? // Consider converting to Date
//    let acquiredParty: String?
//    let acquiringParty: String?
//    let date: String? // Consider converting to Date
//    let acquiredEntities: [String]?
//    let transactionNumber: String?
//    let tags: [String]?
//
//    // Use CodingKeys to map JSON keys with hyphens/different names
//    enum CodingKeys: String, CodingKey {
//        case title, created, updated, date, tags
//        case acquiredParty = "acquired-party"
//        case acquiringParty = "acquiring-party"
//        case acquiredEntities = "acquired-entities"
//        case transactionNumber = "transaction-number"
//    }
//}
//
//// Metadata included in the response (for pagination, counts)
//struct ResponseMetadata: Codable {
//    // Using flexible String type as per docs, though Int might be appropriate
//    let count: String? // Or Int? - Total records for the query (if single item, often 1)
//    let page: String?  // Or Int?
//    let pagesTotal: String? // Or Int?
//    let recordsThisPage: String? // Or Int?
//    let recordsTotal: String? // Or Int?
//
//     enum CodingKeys: String, CodingKey {
//        case count, page
//        case pagesTotal = "pages-total"
//        case recordsThisPage = "records-this-page"
//        case recordsTotal = "records-total"
//     }
//}
//
//// Links included in the response (self-link for the request)
//struct ResponseLinks: Codable {
//    let `self`: Link?
//    // Could add first, next, prev, last if API supports them
//}
//
//struct Link: Codable {
//    let href: String?
//}
//
//// Custom Error Type
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case requestFailed(Error)
//    case invalidResponse
//    case decodingError(Error)
//    case badRequest(String?) // 400
//    case unauthorized(String?) // 403 (Bad API Key)
//    case notFound(String?) // 404
//    case rateLimitExceeded(String?) // 429
//    case serverError(statusCode: Int, message: String?)
//    case unknown(statusCode: Int)
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "Invalid URL constructed."
//        case .requestFailed(let err): return "Network request failed: \(err.localizedDescription)"
//        case .invalidResponse: return "Received an invalid response from the server."
//        case .decodingError(let err): return "Failed to decode response: \(err.localizedDescription)"
//        case .badRequest(let msg): return "Bad Request (400): \(msg ?? "No details")"
//        case .unauthorized(let msg): return "Unauthorized (403): Check API Key. \(msg ?? "")"
//        case .notFound(let msg): return "Not Found (404): \(msg ?? "Endpoint not found")"
//        case .rateLimitExceeded(let msg): return "Rate Limit Exceeded (429): \(msg ?? "Try again later")"
//        case .serverError(let code, let msg): return "Server Error (\(code)): \(msg ?? "No details")"
//        case .unknown(let code): return "Unknown error with status code: \(code)"
//        }
//    }
//}
//
//
//// MARK: - API Service Layer (FTCService)
//
//import Foundation
//import Combine // Or use async/await directly
//
//class FTCService {
//    private let baseURL = URL(string: "https://api.ftc.gov/v0/hsr-early-termination-notices")!
//    private let apiKey: String // Should be securely stored/provided
//    private let session: URLSession
//
//    // Initializer to inject API key and optional URLSession for testing
//    init(apiKey: String, session: URLSession = .shared) {
//        // IMPORTANT: Never hardcode API keys in production code.
//        // Use secure storage like Keychain or configuration files.
//        self.apiKey = apiKey
//        self.session = session
//    }
//
//    // Fetches a list of notices, supporting filtering, sorting, pagination
//    func fetchNotices(
//        filters: [FilterOption] = [],
//        sort: SortOption? = nil,
//        pagination: PaginationOption? = nil
//    ) async throws -> APIResponse<Notice> {
//
//        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
//            throw APIError.invalidURL
//        }
//
//        var queryItems = [URLQueryItem]()
//
//        // 1. Add API Key (unless provided via header later)
//        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
//
//        // 2. Add Filters
//        queryItems.append(contentsOf: filters.flatMap { $0.queryItems })
//
//        // 3. Add Sorting
//        if let sortOption = sort {
//            queryItems.append(contentsOf: sortOption.queryItems)
//        }
//
//        // 4. Add Pagination
//        if let pageOption = pagination {
//            queryItems.append(contentsOf: pageOption.queryItems)
//        }
//
//        components.queryItems = queryItems.isEmpty ? nil : queryItems
//        // Ensure percent encoding is handled correctly, especially for nested keys
//        components.percentEncodedQuery = components.percentEncodedQuery?
//            .replacingOccurrences(of: "+", with: "%2B") // Ensure '+' is encoded if needed
//             // Drupal JSON:API often uses [] which URLComponents might encode, ensure they are correct
//            .replacingOccurrences(of: "%5B", with: "[")
//            .replacingOccurrences(of: "%5D", with: "]")
//
//        guard let url = components.url else {
//             print("Failed URL: \(components.string ?? "N/A")")
//            throw APIError.invalidURL
//        }
//
//         print("Requesting URL: \(url.absoluteString)") // For debugging
//
//        // --- Network Request ---
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        // Optionally add API key as header instead of query param:
//        // request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
//        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept") // Good practice for JSON:API
//
//        let (data, response) = try await session.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.invalidResponse
//        }
//
//        // --- Handle HTTP Status Codes ---
//        switch httpResponse.statusCode {
//        case 200:
//            // Decode successful response
//            do {
//                let decoder = JSONDecoder()
//                // decoder.dateDecodingStrategy = .iso8601 // If dates need conversion
//                let apiResponse = try decoder.decode(APIResponse<Notice>.self, from: data)
//                return apiResponse
//            } catch {
//                print("Decoding Error: \(error)") // Log detailed decoding error
//                 if let jsonString = String(data: data, encoding: .utf8) {
//                        print("Failed JSON: \(jsonString)") // Log the raw JSON
//                    }
//                throw APIError.decodingError(error)
//            }
//        case 400: throw APIError.badRequest(String(data: data, encoding: .utf8))
//        case 403: throw APIError.unauthorized(String(data: data, encoding: .utf8))
//        case 404: throw APIError.notFound(String(data: data, encoding: .utf8))
//        case 429: throw APIError.rateLimitExceeded(String(data: data, encoding: .utf8))
//        case 500...599: throw APIError.serverError(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8))
//        default: throw APIError.unknown(statusCode: httpResponse.statusCode)
//        }
//    }
//
//    // Fetches a single notice by its ID (using the filter mechanism)
//    func fetchNotice(id: String) async throws -> APIResponse<Notice> {
//        let idFilter = FilterOption.valueMatch(field: "id", value: id)
//        return try await fetchNotices(filters: [idFilter])
//    }
//}
//
//// MARK: - Helper Structs for Query Parameters
//
//struct FilterOption {
//    let field: String
//    let value: String
//    let path: String? // For date conditions
//    let conditionOperator: String? // For date conditions or title CONTAINS etc.
//    let filterOperator: String? // e.g., value, condition
//
//    // Simple Key-Value Filter: ?filter[field_name][value]=VALUE
//    static func valueMatch(field: String, value: String) -> FilterOption {
//        FilterOption(field: field, value: value, path: nil, conditionOperator: nil, filterOperator: "value")
//    }
//
//     // Title Contains: ?filter[title][operator]=CONTAINS&filter[title][value]=Foo
//    static func titleContains(keyword: String) -> FilterOption {
//         FilterOption(field: "title", value: keyword, path: nil, conditionOperator: "CONTAINS", filterOperator: "operator")
//    }
//
//     // Title Exact Phrase: ?filter[title][value]="Exact Phrase"
//    static func titleExactPhrase(phrase: String) -> FilterOption {
//        // Ensure phrase is wrapped in quotes for the API
//        let quotedPhrase = "\"\(phrase)\""
//        return FilterOption(field: "title", value: quotedPhrase, path: nil, conditionOperator: nil, filterOperator: "value")
//    }
//
//    // Transaction Number: ?filter[transaction-number][value]=20110728
//    static func transactionNumber(_ number: String) -> FilterOption {
//        FilterOption(field: "transaction-number", value: number, path: nil, conditionOperator: nil, filterOperator: "value")
//    }
//
//    // Date Filter: ?filter[date][condition][path]=date&filter[date][condition][operator]==&filter[date][condition][value]=YYYY-MM-DD
//    static func dateEquals(_ dateString: String) -> FilterOption {
//        FilterOption(field: "date", value: dateString, path: "date", conditionOperator: "==", filterOperator: "condition")
//        // Add more date operators (>, <, etc.) as needed
//    }
//
//    // Computed property to generate URLQueryItem array
//    var queryItems: [URLQueryItem] {
//        var items: [URLQueryItem] = []
//        if let filterOp = filterOperator {
//            if filterOp == "value" {
//                 items.append(URLQueryItem(name: "filter[\(field)][value]", value: value))
//            } else if filterOp == "operator" {
//                 // Handles CONTAINS for title
//                items.append(URLQueryItem(name: "filter[\(field)][operator]", value: conditionOperator))
//                items.append(URLQueryItem(name: "filter[\(field)][value]", value: value))
//            } else if filterOp == "condition" {
//                // Handles date filtering
//                if let p = path, let op = conditionOperator {
//                    items.append(URLQueryItem(name: "filter[\(field)][condition][path]", value: p))
//                    items.append(URLQueryItem(name: "filter[\(field)][condition][operator]", value: op))
//                    items.append(URLQueryItem(name: "filter[\(field)][condition][value]", value: value))
//                }
//            } else {
//                 // Default fallback or simple filter: ?filter[field]=value
//                 items.append(URLQueryItem(name: "filter[\(field)]", value: value))
//            }
//
//        } else {
//             // Simple filter if no operator specified
//            items.append(URLQueryItem(name: "filter[\(field)]", value: value))
//        }
//        return items
//    }
//}
//
//struct SortOption {
//    enum Direction: String {
//        case ascending = "ASC"
//        case descending = "DESC"
//    }
//
//    let field: String // e.g., "created", "changed", "title" (use 'title' for sorting by title attribute)
//    let direction: Direction
//
//    // Computed property to generate URLQueryItem array: ?sort[sort_field_alias][path]=attribute_field&sort[sort_field_alias][direction]=ASC/DESC
//    // The alias ('title' in the example ?sort[title][path]=created) seems arbitrary but required by the API structure.
//    // We'll use the field name itself as the alias for simplicity here.
//    var queryItems: [URLQueryItem] {
//        [
//            URLQueryItem(name: "sort[\(field)][path]", value: field),
//            URLQueryItem(name: "sort[\(field)][direction]", value: direction.rawValue)
//        ]
//    }
//}
//
//struct PaginationOption {
//    let limit: Int // items_per_page
//    let offset: Int
//
//    // Computed property to generate URLQueryItem array: ?page[limit]=10&page[offset]=0
//    var queryItems: [URLQueryItem] {
//        [
//            URLQueryItem(name: "page[limit]", value: String(limit)),
//            URLQueryItem(name: "page[offset]", value: String(offset))
//        ]
//    }
//}
//
//
//// MARK: -  ViewModels (ViewModel Layer)
//import Foundation
//import Combine // Or use State variables with async/await tasks
//
//// ViewModel for the list of notices
//@MainActor // Ensures UI updates happen on the main thread
//class NoticesListViewModel: ObservableObject {
//    @Published var notices: [Notice] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var currentSort: SortOption? = SortOption(field: "date", direction: .descending) // Default sort
//    @Published var currentFilters: [FilterOption] = []
//    @Published var canLoadMore: Bool = true // Assume more can be loaded initially
//
//    private let ftcService: FTCService
//    private var currentPageOffset: Int = 0
//    private let itemsPerPage: Int = 20 // Configurable page size
//
//    init(ftcService: FTCService) {
//        self.ftcService = ftcService
//    }
//
//    // Function to load the first page or reload with new filters/sort
//    func loadInitialNotices() {
//        // Reset state before loading
//        currentPageOffset = 0
//        notices = []
//        canLoadMore = true
//        errorMessage = nil
//        isLoading = true
//
//        Task {
//            await fetchNotices()
//        }
//    }
//
//    // Function to load the next page of results
//    func loadMoreNotices() {
//        guard !isLoading, canLoadMore else { return } // Prevent multiple concurrent loads
//
//        isLoading = true
//        currentPageOffset += itemsPerPage
//
//        Task {
//           await fetchNotices()
//        }
//    }
//
//    // Central fetching logic used by initial load and load more
//    private func fetchNotices() async {
//         // Keep track if it's an initial load or load more
//        let isInitialLoad = (currentPageOffset == 0)
//
//        let pagination = PaginationOption(limit: itemsPerPage, offset: currentPageOffset)
//
//        do {
//            let response = try await ftcService.fetchNotices(
//                filters: currentFilters,
//                sort: currentSort,
//                pagination: pagination
//            )
//
//            if isInitialLoad {
//                self.notices = response.data
//            } else {
//                // Append new results, avoiding duplicates just in case
//                let existingIDs = Set(self.notices.map { $0.id })
//                let newNotices = response.data.filter { !existingIDs.contains($0.id) }
//                self.notices.append(contentsOf: newNotices)
//            }
//
//            // Determine if more pages exist based on metadata
//             let totalRecords = Int(response.meta?.recordsTotal ?? "0") ?? 0
//             self.canLoadMore = self.notices.count < totalRecords // Update ability to load more
//
//            self.errorMessage = nil // Clear error on success
//        } catch {
//            // Handle potential duplicate errors if loading more immediately after an error
//            if !(error is APIError && currentPageOffset > 0) {
//               self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//             }
//             // If loading more failed, arguably decrement offset or allow retry?
//             if !isInitialLoad { currentPageOffset -= itemsPerPage } // Revert offset on failure
//             self.canLoadMore = false // Stop loading more on error for now
//              print("Fetch Error: \(error)")
//        }
//        self.isLoading = false
//    }
//
//    // Functions to update filters/sort and trigger reload
//    func applyFilters(_ newFilters: [FilterOption]) {
//        currentFilters = newFilters
//        loadInitialNotices()
//    }
//
//    func applySort(_ newSort: SortOption?) {
//        currentSort = newSort
//        loadInitialNotices()
//    }
//
//    // Example: Add a search term filter
//     func searchByTitle(_ searchTerm: String) {
//         // Remove existing title filters first
//         currentFilters.removeAll { $0.field == "title" }
//         if !searchTerm.isEmpty {
//             // Use CONTAINS for general search, or valueMatch for exact
//             currentFilters.append(FilterOption.titleContains(keyword: searchTerm))
//         }
//         loadInitialNotices()
//     }
//}
//
//// ViewModel for the detail view (simpler, holds the selected notice)
//@MainActor
//class NoticeDetailViewModel: ObservableObject {
//    @Published var notice: Notice
//
//    init(notice: Notice) {
//        self.notice = notice
//    }
//}
//
//
//// MARK: - SwiftUI Views (View Layer - Conceptual)
//
//import SwiftUI
//
//// Main List View
//struct NoticesListView: View {
//    @StateObject var viewModel: NoticesListViewModel
//     @State private var searchTerm: String = "" // For a search bar
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Optional: Search Bar
//                 TextField("Search by Title...", text: $searchTerm)
//                     .padding()
//                     .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .onSubmit { // Trigger search on submit
//                         viewModel.searchByTitle(searchTerm)
//                     }
//
//                 // Optional: Filter/Sort Buttons
//                 HStack {
//                     // Button to show filter sheet
//                     // Button to show sort options (e.g., Picker)
//                     Spacer()
//                 }.padding(.horizontal)
//
//                if viewModel.isLoading && viewModel.notices.isEmpty {
//                    ProgressView("Loading...")
//                        .frame(maxHeight: .infinity)
//                } else if let errorMessage = viewModel.errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding()
//                        .frame(maxHeight: .infinity)
//                } else {
//                    List {
//                        ForEach(viewModel.notices) { notice in
//                            NavigationLink(destination: NoticeDetailView(notice: notice)) {
//                                NoticeRow(notice: notice)
//                            }
//                             // Logic for loading more items
//                            .onAppear {
//                                 if notice.id == viewModel.notices.last?.id && viewModel.canLoadMore {
//                                     viewModel.loadMoreNotices()
//                                 }
//                            }
//                        }
//                         // Show loading indicator at the bottom while loading more
//                         if viewModel.isLoading && !viewModel.notices.isEmpty {
//                             ProgressView()
//                                .frame(maxWidth: .infinity, alignment: .center)
//                         }
//                    }
//                     .refreshable { // Pull-to-refresh
//                         viewModel.loadInitialNotices()
//                     }
//                }
//            }
//            .navigationTitle("HSR Notices")
//            .onAppear {
//                 if viewModel.notices.isEmpty { // Load initially only if empty
//                     viewModel.loadInitialNotices()
//                 }
//            }
//        }
//    }
//}
//
//// Row for the List View
//struct NoticeRow: View {
//     let notice: Notice
//
//     var body: some View {
//         VStack(alignment: .leading) {
//             Text(notice.attributes?.title ?? "No Title")
//                 .font(.headline)
//             HStack {
//                 Text("Acquiring: \(notice.attributes?.acquiringParty ?? "N/A")")
//                 Spacer()
//                 Text("Acquired: \(notice.attributes?.acquiredParty ?? "N/A")")
//             }
//             .font(.subheadline)
//             .foregroundColor(.gray)
//             Text("Date: \(formattedDate(notice.attributes?.date))")
//                 .font(.caption)
//             Text("Transaction: \(notice.attributes?.transactionNumber ?? "N/A")")
//                    .font(.caption)
//         }
//         .padding(.vertical, 4)
//     }
//
//     private func formattedDate(_ dateString: String?) -> String {
//         guard let dateString = dateString else { return "N/A" }
//         // Basic formatting, ideally use DateFormatter for robustness
//         return String(dateString.prefix(10)) // Extract YYYY-MM-DD part
//     }
// }
//
//// Detail View for a Single Notice
//struct NoticeDetailView: View {
//    // Either pass the whole notice or use a dedicated ViewModel
//     @StateObject var viewModel: NoticeDetailViewModel
//
//     init(notice: Notice) {
//         _viewModel = StateObject(wrappedValue: NoticeDetailViewModel(notice: notice))
//     }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text(viewModel.notice.attributes?.title ?? "No Title")
//                    .font(.largeTitle)
//
//                DetailRow(label: "Transaction #", value: viewModel.notice.attributes?.transactionNumber)
//                DetailRow(label: "Date", value: viewModel.notice.attributes?.date) // Format date properly
//                DetailRow(label: "Acquiring Party", value: viewModel.notice.attributes?.acquiringParty)
//                DetailRow(label: "Acquired Party", value: viewModel.notice.attributes?.acquiredParty)
//
//                Text("Acquired Entities:")
//                    .font(.headline)
//                if let entities = viewModel.notice.attributes?.acquiredEntities, !entities.isEmpty {
//                    ForEach(entities, id: \.self) { entity in
//                        Text("- \(entity)")
//                    }
//                } else {
//                    Text("N/A").italic()
//                }
//
//                 Divider()
//
//                 DetailRow(label: "Record ID", value: viewModel.notice.id)
//                 DetailRow(label: "Created", value: viewModel.notice.attributes?.created) // Format date
//                 DetailRow(label: "Updated", value: viewModel.notice.attributes?.updated) // Format date
//
//            }
//            .padding()
//        }
//        .navigationTitle("Notice Details")
//         .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// Helper View for Detail Rows
//struct DetailRow: View {
//    let label: String
//    let value: String?
//
//    var body: some View {
//        HStack(alignment: .top) {
//            Text("\(label):")
//                .fontWeight(.bold)
//                .frame(width: 150, alignment: .leading) // Adjust width as needed
//            Text(value ?? "N/A")
//                 .frame(maxWidth: .infinity, alignment: .leading)
//        }
//    }
//}
//
//// --- App Entry Point ---
///*
// @main
// struct HSRApp: App {
//     // Securely provide the API key here
//     // IMPORTANT: Replace "DEMO_KEY" with your actual key management strategy
//     private let ftcService = FTCService(apiKey: ProcessInfo.processInfo.environment["FTC_API_KEY"] ?? "DEMO_KEY")
//
//     var body: some Scene {
//         WindowGroup {
//             NoticesListView(viewModel: NoticesListViewModel(ftcService: ftcService))
//         }
//     }
// }
// */
//
//#Preview("NoticesListView") {
//    let ftcService = FTCService(apiKey: ProcessInfo.processInfo.environment["FTC_API_KEY"] ?? "DEMO_KEY")
//    NoticesListView(viewModel: NoticesListViewModel(ftcService: ftcService))
//}
