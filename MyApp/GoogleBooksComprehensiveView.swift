//
//  GoogleBooksComprehensiveView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
import Foundation
import UIKit // Needed for UIApplication and UIWindowScene

// MARK: - Google Books API Response Structures (GoogleBooksAPIModels.swift content)
// ... (Structs: BookResponse, BookItem, VolumeInfo, ImageLinks, etc. as defined in the previous response) ...
struct BookResponse: Codable {
    let kind: String?
    let totalItems: Int?
    let items: [BookItem]?
}

struct BookItem: Codable, Identifiable {
    let kind: String?
    let id: String // Use API ID as Identifiable
    let etag: String?
    let selfLink: String?
    let volumeInfo: VolumeInfo?
    let saleInfo: SaleInfo?
    let accessInfo: AccessInfo?
    let searchInfo: SearchInfo?
}

struct VolumeInfo: Codable {
    let title: String?
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String? // Date can be YYYY or YYYY-MM-DD
    let description: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let readingModes: ReadingModes?
    let pageCount: Int?
    let printType: String?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let maturityRating: String?
    let allowAnonLogging: Bool?
    let contentVersion: String?
    let panelizationSummary: PanelizationSummary?
    let imageLinks: ImageLinks?
    let language: String?
    let previewLink: String?
    let infoLink: String?
    let canonicalVolumeLink: String?
}

struct IndustryIdentifier: Codable {
    let type: String?
    let identifier: String?
}

struct ReadingModes: Codable {
    let text: Bool?
    let image: Bool?
}

struct PanelizationSummary: Codable {
    let containsEpubBubbles: Bool?
    let containsImageBubbles: Bool?
}

struct ImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
}

struct SaleInfo: Codable {
    let country: String?
    let saleability: String?
    let isEbook: Bool?
}

struct AccessInfo: Codable {
    let country: String?
    let viewability: String?
    let embeddable: Bool?
    let publicDomain: Bool?
    let textToSpeechPermission: String?
    let epub: EpubAccess?
    let pdf: PdfAccess?
    let webReaderLink: String?
    let accessViewStatus: String?
    let quoteSharingAllowed: Bool?
}

struct EpubAccess: Codable {
    let isAvailable: Bool?
    let acsTokenLink: String?
}

struct PdfAccess: Codable {
    let isAvailable: Bool?
    let acsTokenLink: String?
}

struct SearchInfo: Codable {
    let textSnippet: String?
}

// Helper struct to decode potential Google API error messages
struct GoogleAPIErrorResponse: Codable {
    let error: GoogleAPIErrorDetail
}

struct GoogleAPIErrorDetail: Codable {
    let code: Int?
    let message: String?
    // let errors: [GoogleAPIErrorItem]? // Uncomment if needed
}

/* // Example if 'errors' field is needed
 struct GoogleAPIErrorItem: Codable {
 let domain: String?
 let reason: String?
 let message: String?
 }
 */

// MARK: - API Service (GoogleBooksAPIService.swift content)
// ... (GoogleBooksAPIService class and APIError enum as defined previously, REMEMBER TO ADD YOUR API KEY) ...
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case missingData
    case specificError(String) // For API-returned error messages
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL constructed for the API request was invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError(let error):
            // Try to get more specific decoding error info
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context): return "Decoding Error: Key '\(key.stringValue)' not found. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .valueNotFound(let type, let context): return "Decoding Error: Value of type '\(type)' not found. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .typeMismatch(let type, let context): return "Decoding Error: Type mismatch for type '\(type)'. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .dataCorrupted(let context): return "Decoding Error: Data corrupted. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                @unknown default: return "An unknown decoding error occurred: \(error.localizedDescription)"
                }
            }
            return "Failed to decode the data: \(error.localizedDescription)"
        case .missingData:
            return "The API response was missing expected data."
        case .specificError(let message):
            return "API Error: \(message)"
        }
    }
}

class GoogleBooksAPIService: ObservableObject {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    // --- ⚠️ IMPORTANT: Replace with your actual API Key ⚠️ ---
    private let apiKey = "YOUR_API_KEY" // <--- PASTE YOUR KEY HERE
    // --- ⚠️ IMPORTANT: If no key, comment out the line above AND the line adding the key item below ---
    
    private let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        // Optional: Configure decoder if needed (e.g., date strategies)
        // decoder.dateDecodingStrategy = .iso8601 // If dates were full ISO8601
    }
    
    // Generic function to fetch books
    func fetchBooks(query: String, filter: String? = nil, printType: String = "all", orderBy: String = "relevance", maxResults: Int = 10, startIndex: Int = 0) async throws -> [BookItem] {
        guard !query.isEmpty else {
            print("Search query cannot be empty.")
            return [] // Return empty array for empty query
        }
        
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: String(maxResults)),
            URLQueryItem(name: "startIndex", value: String(startIndex)),
            URLQueryItem(name: "printType", value: printType), // e.g., "books", "magazines", "all"
            URLQueryItem(name: "orderBy", value: orderBy) // e.g., "relevance", "newest"
        ]
        
        if let filterValue = filter, !filterValue.isEmpty {
            // Filters like "ebooks", "free-ebooks", "paid-ebooks", "full", "partial"
            queryItems.append(URLQueryItem(name: "filter", value: filterValue))
        }
        
        // --- Only add the API key if it's defined ---
        if !apiKey.isEmpty && apiKey != "YOUR_API_KEY" {
            queryItems.append(URLQueryItem(name: "key", value: apiKey))
        }
        // --- End API Key logic ---
        
        components?.queryItems = queryItems
        
        // Ensure encoding handles spaces and special characters robustly
        components?.percentEncodedQuery = components?
            .queryItems?
            .map { item -> String in
                let key = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let value = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return "\(key)=\(value)"
            }
            .joined(separator: "&")
        
        guard let url = components?.url else {
            print("Error: Could not create URL from components: \(components.debugDescription)")
            throw APIError.invalidURL
        }
        
        print("Fetching books from URL: \(url.absoluteString)") // Log the URL
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("API Response Status Code: \(httpResponse.statusCode)")
            
            // --- Optional Debugging: Print raw response ---
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("Raw Response (Status \(httpResponse.statusCode)):\n\(jsonString)\n---")
            // }
            // --- End Debugging ---
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to decode error message from Google if possible
                if let errorDetail = try? decoder.decode(GoogleAPIErrorResponse.self, from: data) {
                    print("Decoded API Error: \(errorDetail.error)")
                    throw APIError.specificError("\(errorDetail.error.message ?? "Unknown reason") (Code: \(errorDetail.error.code ?? httpResponse.statusCode))")
                } else {
                    print("API request failed with status code \(httpResponse.statusCode), but couldn't decode specific error message.")
                    throw APIError.invalidResponse // Fallback generic error
                }
            }
            
            // --- Attempt to Decode Success Response ---
            do {
                let bookResponse = try decoder.decode(BookResponse.self, from: data)
                guard bookResponse.items != nil || bookResponse.totalItems == 0 else {
                    // Handle cases where 'items' might be missing even on success, though API docs say it should be there or totalItems=0
                    print("API returned success (2xx) but 'items' array is missing and totalItems is not 0. Query: \(query)")
                    // Decide if this is an error or just no results
                    if bookResponse.totalItems == nil {
                        throw APIError.missingData // Treat as missing data if totalItems is also nil
                    } else {
                        return [] // Treat as no results if totalItems is non-nil (likely 0)
                    }
                }
                return bookResponse.items ?? [] // Return empty array if items is nil but totalItems was 0
                
            } catch let decodingError as DecodingError {
                print("Decoding Error (Status \(httpResponse.statusCode)): \(decodingError)")
                // Provide specific decoding error context
                switch decodingError {
                case .keyNotFound(let key, let context): print("Key '\(key.stringValue)' not found:", context.debugDescription); print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                case .valueNotFound(let value, let context): print("Value '\(value)' not found:", context.debugDescription); print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                case .typeMismatch(let type, let context): print("Type '\(type)' mismatch:", context.debugDescription); print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                case .dataCorrupted(let context): print("Data corrupted:", context.debugDescription); print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: "."))
                @unknown default: print("Unknown decoding error")
                }
                // Re-throw specifically as decodingError
                throw APIError.decodingError(decodingError)
            } catch {
                // Catch any other errors during the decoding phase of a 2xx response
                print("Error during decoding phase after successful status code: \(error)")
                throw APIError.decodingError(error)
            }
            // --- End Decode Success ---
            
        } catch let urlError as URLError {
            print("URLSession Error: \(urlError)")
            throw APIError.requestFailed(urlError)
        } catch let apiError as APIError {
            // Just rethrow APIErrors we've already categorized
            throw apiError
        } catch {
            // Catch any other unexpected errors during the fetch process
            print("Generic Fetch Error: \(error)")
            throw APIError.requestFailed(error)
        }
    }
}

// MARK: - Data Mapping Utilities (DataMapping.swift content)
// ... (Extensions and helper functions as defined previously) ...
extension BookItem {
    func toNewsArticle() -> NewsArticle {
        let publisherName = self.volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName) // Use helper
        
        let headline = self.volumeInfo?.title ?? "Untitled Book"
        // Prioritize thumbnail, fallback to smallThumbnail
        let thumbnailURL = self.volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? self.volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        let smallThumbnailURL = self.volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString() ?? thumbnailURL
        
        // Combine description or snippet for more content
        let descriptiveText = self.searchInfo?.textSnippet ?? self.volumeInfo?.description ?? "No description available."
        // Basic HTML stripping (could be improved with regex or libraries)
        let cleanDescription = descriptiveText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        return NewsArticle(
            id: UUID(), // New UUID for view model identity
            source: source,
            headline: headline,
            // Store URL strings or empty string
            imageName: thumbnailURL ?? "",
            timeAgo: formatPublishedDate(self.volumeInfo?.publishedDate),
            // Include clean description
            descriptionText: cleanDescription,
            // Not really applicable from book data, set default
            isLargeCard: true,
            // Store small URL or fallback to main/empty
            smallImageName: smallThumbnailURL
        )
    }
    
    func toHeadlineArticle(categoryOverride: String? = nil) -> HeadlineArticle {
        let publisherName = self.volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName)
        let thumbnailURL = self.volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? self.volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        
        // Use the first category from the book, or the override, or default
        let category = categoryOverride ?? self.volumeInfo?.categories?.first ?? "General"
        
        return HeadlineArticle(
            id: UUID(),
            category: category,
            source: source,
            headline: self.volumeInfo?.title ?? "Untitled Book",
            imageName: thumbnailURL ?? "", // Store URL
            timeAgo: formatPublishedDate(self.volumeInfo?.publishedDate),
            relatedArticles: [] // Needs separate logic/queries
        )
    }
    
    func toFollowingArticle(topicName: String) -> FollowingArticle {
        let publisherName = self.volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName)
        let thumbnailURL = self.volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? self.volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        
        return FollowingArticle(
            id: UUID(),
            source: source,
            // Combine topic and title
            headline: "\(topicName): \(self.volumeInfo?.title ?? "Untitled Book")".trimmingCharacters(in: .whitespacesAndNewlines),
            timeAgo: formatPublishedDate(self.volumeInfo?.publishedDate),
            imageName: thumbnailURL ?? "" // Store URL
        )
    }
    
    func toShowcaseArticle() -> ShowcaseArticle {
        let thumbnailURL = self.volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? self.volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        let categoryTag = self.volumeInfo?.categories?.first?.uppercased() // Use first category as tag
        
        return ShowcaseArticle(
            id: UUID(),
            // Use authors or publisher as context
            context: self.volumeInfo?.authors?.joined(separator: ", ") ?? self.volumeInfo?.publisher,
            headline: self.volumeInfo?.title ?? "Untitled Book",
            imageName: thumbnailURL ?? "", // Store URL
            topicTag: categoryTag
        )
    }
}

// Helper to create NewsSource from publisher
func createSourceFromPublisher(_ publisher: String?) -> NewsSource {
    return NewsSource(
        // Use ID based on name for potential reuse if needed, else UUID is fine
        // id: publisher ?? UUID().uuidString,
        name: publisher ?? "Unknown Publisher",
        // Use a consistent SF Symbol for book publishers
        logoName: "book.closed.fill"
    )
}

// Helper function to format published date strings (YYYY, YYYY-MM, YYYY-MM-DD)
func formatPublishedDate(_ dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else { return "Date Unknown" }
    
    let dateFormatter = DateFormatter()
    var parsedDate: Date?
    
    // Try formats from most specific to least specific
    let potentialFormats = ["yyyy-MM-dd", "yyyy-MM", "yyyy"]
    for format in potentialFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            parsedDate = date
            break // Stop once a format matches
        }
    }
    
    guard let date = parsedDate else {
        // If parsing failed, return the original string (might be just 'yyyy' or malformed)
        return dateString
    }
    
    // Use RelativeDateTimeFormatter for user-friendly output like "2 yrs ago"
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    // Optional: Set formatting context if needed
    // formatter.formattingContext = .beginningOfSentence
    return formatter.localizedString(for: date, relativeTo: Date())
}

// Helper to ensure image URLs are HTTPS
extension String {
    func secureUrlString() -> String {
        return self.replacingOccurrences(of: "http://", with: "https://")
    }
}

// MARK: - Data Models & Extensions (View Models)

enum FollowedItemType {
    case library, saved, topic, search
}

struct NewsSource: Identifiable {
    // Use String for ID if mapping from API data like publisher name, else UUID
    var id: String { name } // Make ID derivable from name for simplicity
    let name: String
    let logoName: String // Now intended to be an SF Symbol name string
}

struct NewsArticle: Identifiable {
    let id: UUID // Keep UUID for SwiftUI list identity
    let source: NewsSource
    let headline: String
    let imageName: String // Holds Image URL string
    let timeAgo: String
    let descriptionText: String? // Added description
    let isLargeCard: Bool // May not be needed if layout is consistent
    let smallImageName: String? // Holds Small Image URL string or nil
    
    // Removed static placeholders
}

struct HeadlineArticle: Identifiable {
    let id: UUID
    let category: String
    let source: NewsSource
    let headline: String
    let imageName: String // URL string
    let timeAgo: String
    var relatedArticles: [RelatedArticle] // Remains placeholder until implemented
    
    // Removed static placeholders
}

struct RelatedArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String
    
    // Example placeholders if needed for HeadlinesView development before API integration
    static var placeholderCNN: RelatedArticle { RelatedArticle(id: UUID(), source: NewsSource(name: "CNN", logoName: "newspaper.fill"), headline: "Related: CNN Analysis", timeAgo: "2h ago") }
    static var placeholderNYT: RelatedArticle { RelatedArticle(id: UUID(), source: NewsSource(name: "NY Times", logoName: "newspaper.fill"), headline: "Related: NYT Opinion", timeAgo: "90m ago") }
}

struct FollowedItem: Identifiable {
    let id: UUID
    let name: String
    let imageName: String? // Could be URL or asset name if mixed
    let iconName: String? // SF Symbol name
    let type: FollowedItemType
    
    // Static examples for the "Recently Followed" section which isn't API driven yet
    static var placeholderLibrary: FollowedItem { FollowedItem(id: UUID(), name: "Library", imageName: nil, iconName: "books.vertical.fill", type: .library) }
    static var placeholderSaved: FollowedItem { FollowedItem(id: UUID(), name: "Saved stories", imageName: nil, iconName: "bookmark.fill", type: .saved) }
    // Topic could potentially fetch its image URL if stored
    static var placeholderTopic: FollowedItem { FollowedItem(id: UUID(), name: "Search: Swift", imageName: nil, iconName: "magnifyingglass", type: .topic) }
    static var placeholderSearch: FollowedItem { FollowedItem(id: UUID(), name: "Search...", imageName: nil, iconName: "plus.magnifyingglass", type: .search) }
    
}

struct FollowingArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String
    let imageName: String // URL string
    
    // Removed static placeholders
}

struct FollowedTopicGroup: Identifiable {
    let id: UUID // Could be the topic query string
    let topicName: String
    let topicImageName: String? // URL or SF Symbol name string
    var articles: [FollowingArticle]
    
    // Removed static placeholders
}

struct ShowcaseArticle: Identifiable {
    let id: UUID
    let context: String?
    let headline: String
    let imageName: String // URL string
    let topicTag: String? // e.g., "BUSINESS"
    
    // Removed static placeholders
}

struct NewsShowcaseSource: Identifiable {
    var id: String { source.id } // ID based on source
    let source: NewsSource
    var articles: [ShowcaseArticle]
    let timeAgo: String // How long ago the showcase was 'updated' (use fetch time)
    
    // Removed static placeholders
}

struct NewsSourceCategory: Identifiable {
    var id: String { name } // ID based on category name
    let name: String
    var sources: [NewsSource] // Publishers related to this category
    
    // Removed static placeholders
}

// MARK: - Reusable UI Components
// ... (All component views: TopBarView, WeatherWidget, HeaderView, etc.) ...
// IMPORTANT: Update all `Image(name: ...)` calls within these components
// to use `AsyncImage(url: URL(string: ...))` for network URLs
// or `Image(systemName: ...)` for SF Symbols.

// Helper view for displaying AsyncImage with placeholders and error handling
struct NetworkImageView: View {
    let urlString: String?
    let placeholderSymbol: String // SF Symbol for placeholder/error
    let configuration: (Image) -> AnyView // Closure to configure the loaded image
    
    init(
        urlString: String?,
        placeholderSymbol: String = "photo.fill",
        @ViewBuilder configuration: @escaping (Image) -> AnyView = { AnyView($0.resizable()) } // Default config
    ) {
        self.urlString = urlString
        self.placeholderSymbol = placeholderSymbol
        self.configuration = configuration
    }
    
    var body: some View {
        Group { // Use Group to avoid applying frame modifiers multiple times
            if let urlString = urlString, let url = URL(string: urlString.secureUrlString()) { // Ensure HTTPS
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Loader
                    case .success(let image):
                        configuration(image) // Apply custom configuration
                    case .failure:
                        Image(systemName: placeholderSymbol) // Error placeholder
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: placeholderSymbol) // Placeholder if URL is nil/invalid
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
            }
        }
        // Apply a background color to prevent transparent backgrounds during loading/error
        .background(Color(.systemGray5)) // Or any subtle background
    }
}

// Generic Top Bar for Headlines and Following
struct TopBarView: View {
    let title: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.gray) // Make icons visible
            Spacer()
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            // Placeholder Profile Image - Keep using asset or SF Symbol
            Image(systemName: "person.crop.circle.fill") // Use SF Symbol
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray) // Color the symbol
            // .clipShape(Circle()) // Not needed for SF Symbol
            // .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
        }
        .padding(.horizontal)
        .frame(height: 44) // Standard navigation bar height
    }
}

// Special Top Bar for Newsstand with subtitle
struct TopBarNewsstand: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.gray)
                Spacer()
                Text("Newsstand")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                // Placeholder to balance the layout - Profile button is overlaid in NewsstandView
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal)
            .frame(height: 44)
            
            // Subtitle removed as API data (publishers) doesn't directly map to "Suggested Sources" easily
            // Text("Suggested Sources")
            //     .font(.caption)
            //     .foregroundColor(.gray)
            //     .frame(maxWidth: .infinity, alignment: .center)
            //     .padding(.bottom, 5)
        }
        .padding(.bottom, 5) // Retain some bottom padding
    }
}

// Weather Widget for ForYou header (Remains hardcoded)
struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("72°F") // Updated placeholder
                .fontWeight(.medium)
            Image(systemName: "sun.max.fill") // Sunny icon
                .renderingMode(.original)
                .font(.title3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(20)
    }
}

// Header for ForYou screen
struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your briefing") // Title could be dynamic later
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            WeatherWidget() // Keep placeholder weather widget
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// "Top stories" Link button for ForYou screen
struct TopStoriesLinkView: View {
    // This could trigger a specific search in the future
    var action: () -> Void = { print("Top stories tapped - Action TBD") }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("Top stories") // Title could be dynamic e.g., "Today's Top Books"
                    .font(.headline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .foregroundColor(.accentColor)
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 8)
    }
}

// Category selector for Headlines screen
struct CategorySelectorView: View {
    // Use relevant book/subject categories
    let categories = ["Featured", "Fiction", "Non-Fiction", "Science", "History", "Technology", "Business", "Arts"]
    @Binding var selectedCategory: String
    var categorySelectedAction: (String) -> Void // Closure to perform action
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    CategoryTab(text: category, isSelected: selectedCategory == category)
                        .onTapGesture {
                            if selectedCategory != category { // Prevent re-selecting same category
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                                categorySelectedAction(category) // Trigger action/reload
                            }
                        }
                }
            }
            .padding(.horizontal)
            .frame(height: 40)
        }
        .background(Color.black)
    }
}

// Individual category tab for Headlines screen
struct CategoryTab: View {
    let text: String
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .accentColor : .gray)
            Rectangle() // Underline indicator
                .frame(height: 3)
                .foregroundColor(isSelected ? .accentColor : .clear)
                .cornerRadius(1.5)
                .padding(.horizontal, 4)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// Main News Card view (now uses NetworkImageView)
struct MainNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo.fill") { image in
                AnyView( // Use AnyView to allow applying modifiers
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill frame
                )
            }
            .frame(height: 200) // Container frame
            .clipped() // Clip the content
            .cornerRadius(10)
            .padding(.bottom, 4)
            
            HStack(spacing: 6) {
                // Use SF Symbol for source 'logo'
                Image(systemName: article.source.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray) // Style the symbol
                    .padding(2) // Add padding if needed
                // .cornerRadius(4) // Corner radius might look odd on symbols
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Text(article.headline) // Display original headline
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(2) // Limit headline lines
            
            if let description = article.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(3) // Limit description lines
                    .padding(.top, 1)
            }
            
            HStack {
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                // Action Icons (placeholders)
                Image(systemName: "bookmark") // Example action
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "square.and.arrow.up") // Share action
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "ellipsis") // More options
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
            
            Divider().padding(.top, 8)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// Small News Card view (now uses NetworkImageView)
struct SmallNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    // Source Info
                    HStack(spacing: 6) {
                        Image(systemName: article.source.logoName) // SF Symbol logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    // Headline
                    Text(article.headline)
                        .font(.headline)
                        .fontWeight(.regular) // Slightly lighter weight for smaller card
                        .lineLimit(3)
                    
                    // Description (optional)
                    // if let description = article.descriptionText, !description.isEmpty {
                    //      Text(description)
                    //             .font(.caption)
                    //             .foregroundColor(.gray)
                    //             .lineLimit(2)
                    //             .padding(.top, 1)
                    // }
                    
                    Spacer(minLength: 4) // Push actions down
                    
                    // Time and Actions
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        // Conditionally show action icons
                        if !(article.descriptionText ?? "").isEmpty { // Example condition
                            Image(systemName: "bookmark")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                        Image(systemName: "ellipsis")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                Spacer() // Pushes image to the right
                // Network Image
                NetworkImageView(urlString: article.smallImageName ?? article.imageName, placeholderSymbol: "photo") { image in
                    AnyView(image.resizable().aspectRatio(contentMode: .fill))
                }
                .frame(width: 80, height: 80) // Standard small image size
                .clipped()
                .cornerRadius(8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            
            Divider()
        }
    }
}

// Full Coverage Button (Concept may not apply directly to books)
struct FullCoverageButton: View {
    var action: () -> Void = { print("Full Coverage - Action TBD") }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle") // Use a relevant icon
                Text("View Details") // Change text
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.secondary.opacity(0.3))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Related Story Card (Concept needs adaptation for books - e.g., "Other books by author")
struct RelatedStoryCardView: View {
    let relatedArticle: RelatedArticle // Keeping model, but data source TBD
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: relatedArticle.source.logoName) // SF Symbol logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
                Text(relatedArticle.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Text(relatedArticle.headline)
                .font(.footnote)
                .lineLimit(3)
            HStack {
                Text(relatedArticle.timeAgo)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .frame(width: 180) // Fixed width for horizontal scroll
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}

// Headline Story Block View (uses NetworkImageView)
struct HeadlineStoryBlockView: View {
    let article: HeadlineArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Image
            NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo.fill") { image in
                AnyView(image.resizable().aspectRatio(contentMode: .fill))
            }
            .frame(height: 200)
            .clipped()
            .padding(.bottom, 12)
            
            // Article Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: article.source.logoName) // SF Symbol logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    Text(article.source.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Text(article.headline)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(3)
                HStack {
                    Text(article.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Related Articles Section (Placeholder data for now)
            if !article.relatedArticles.isEmpty {
                Text("Related Stories") // Section title
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(article.relatedArticles) { related in
                            RelatedStoryCardView(relatedArticle: related)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .frame(height: 130) // Adjust height
            }
            
            // Use FullCoverageButton conceptually (View Details)
            FullCoverageButton()
            
            Divider().padding(.top, 12)
        }
        .padding(.bottom)
    }
}

// Followed Item view for Following screen (Uses SF Symbols primarily)
struct FollowedItemView: View {
    let item: FollowedItem
    var body: some View {
        VStack(spacing: 6) {
            ZStack { // Layer background and image/icon
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                // Prefer icon, then image (which is unlikely for these static items)
                if let iconName = item.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                } else if let imageName = item.imageName {
                    // Assuming imageName might be an asset name here, not URL
                    Image(imageName) // Or use NetworkImageView if URLs are possible
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            Text(item.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70) // Allow slightly wider text
        }
    }
}

// Recently Followed Section for Following screen (Uses static data for now)
struct RecentlyFollowedView: View {
    // Use static placeholder data for this section
    let items = [FollowedItem.placeholderLibrary, FollowedItem.placeholderSaved, FollowedItem.placeholderTopic, FollowedItem.placeholderSearch]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Activity") // Rename section
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        FollowedItemView(item: item)
                    }
                }
                .padding(.horizontal)
            }
            Divider().padding(.top, 12)
        }
        .padding(.top)
    }
}

// Topic Header for Following screen (Uses SF Symbols or NetworkImageView)
struct TopicHeaderView: View {
    let group: FollowedTopicGroup
    @State private var isFollowed: Bool = true // Placeholder state
    var followToggleAction: (Bool) -> Void = { _ in print("Follow toggled") }
    var body: some View {
        HStack {
            // Display image if provided (URL or SF Symbol name)
            if let imageName = group.topicImageName {
                if imageName.contains(".") { // Crude check for system name vs URL/asset
                    NetworkImageView(urlString: imageName, placeholderSymbol: "tag.fill") { img in
                        AnyView(img.resizable().scaledToFit())
                    }
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
                } else {
                    Image(systemName: imageName) // Assume SF symbol if no dot
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                        .cornerRadius(4)
                }
            } else { // Default icon if no image
                Image(systemName: "tag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
                    .cornerRadius(4)
            }
            
            Text(group.topicName)
                .font(.headline)
                .fontWeight(.medium)
            Spacer()
            // Follow Button (placeholder functionality)
            Button {
                isFollowed.toggle()
                followToggleAction(isFollowed)
            } label: {
                Image(systemName: isFollowed ? "star.fill" : "star")
                    .foregroundColor(isFollowed ? Color.accentColor : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// Following Article Card (uses NetworkImageView)
struct FollowingArticleCardView: View {
    let article: FollowingArticle
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    // Source
                    HStack(spacing: 4) {
                        Image(systemName: article.source.logoName) // SF Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                        Text(article.source.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    // Headline
                    Text(article.headline)
                        .font(.subheadline)
                        .lineLimit(3)
                    
                    Spacer(minLength: 4) // Push actions down
                    
                    // Time & Actions
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "bookmark") // Action icon
                                .font(.callout)
                                .foregroundColor(.gray)
                            Image(systemName: "ellipsis")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                // Image
                NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo") { img in
                    AnyView(img.resizable().aspectRatio(contentMode: .fill))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider().padding(.leading) // Indented divider
        }
    }
}

// Floating Action Button in Following screen
struct AddFollowButton: View {
    // Action would likely present a search/add topic view
    var action: () -> Void = { print("Add Follow Tapped - TBD") }
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// News Showcase Section Header for Newsstand
struct NewsShowcaseSectionHeader: View {
    var seeAllAction: () -> Void = { print("News Showcase 'See All' Tapped - TBD") }
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Featured Books") // Adjusted Title
                    .font(.title3)
                    .fontWeight(.semibold)
                // Subtitle may not be relevant
                // Text("Stories selected by newsroom editors")
                //     .font(.caption)
                //     .foregroundColor(.gray)
            }
            Spacer()
            Button(action: seeAllAction) {
                Text("See All") // Text button might be clearer
                    .font(.callout)
                    .foregroundColor(.accentColor)
                // Image(systemName: "arrow.right")
                //     .font(.title3)
                //     .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top) // Top padding for the section
    }
}

// Showcase Article Row (uses NetworkImageView)
struct ShowcaseArticleRowView: View {
    let article: ShowcaseArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Topic Tag (if available)
            if let topic = article.topicTag, !topic.isEmpty {
                Text(topic)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.6)) // Use accent color
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(.bottom, 6)
            }
            
            HStack(alignment: .top, spacing: 8) { // Added spacing
                VStack(alignment: .leading, spacing: 2) {
                    // Context (e.g., Author)
                    if let context = article.context, !context.isEmpty {
                        Text(context)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    // Headline (Title)
                    Text(article.headline)
                        .font(.subheadline) // Slightly larger
                        .fontWeight(.medium) // Medium weight
                        .lineLimit(2) // Limit lines
                }
                Spacer()
                // Image
                NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo") { img in
                    AnyView(img.resizable().aspectRatio(contentMode: .fill))
                }
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 10) // Vertical padding for the row
    }
}

// News Showcase Card (uses NetworkImageView)
struct NewsShowcaseCardView: View {
    let showcase: NewsShowcaseSource
    @State private var isFollowed: Bool = false // Placeholder state
    var followToggleAction: (Bool) -> Void = { _ in print("Showcase Follow Toggled") }
    var optionsAction: () -> Void = { print("Showcase Options Tapped") }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                // Logo
                Image(systemName: showcase.source.logoName) // SF Symbol
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(height: 18) // Fixed height
                // Publisher Name
                Text(showcase.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
                // Follow Button (placeholder state)
                Button {
                    isFollowed.toggle()
                    followToggleAction(isFollowed)
                } label: {
                    Text(isFollowed ? "Following" : "Follow")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundColor(isFollowed ? .white : .accentColor)
                        .background(isFollowed ? Color.accentColor.opacity(0.7) : Color.secondary.opacity(0.3))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding([.horizontal, .top], 12)
            .padding(.bottom, 8)
            
            // List of Articles
            VStack(spacing: 0) {
                // Limit to max 3 articles per showcase card for brevity
                ForEach(showcase.articles.prefix(3).indices, id: \.self) { index in
                    ShowcaseArticleRowView(article: showcase.articles[index])
                        .padding(.horizontal, 12)
                    if index < showcase.articles.prefix(3).count - 1 {
                        Divider().padding(.leading, 12)
                    }
                }
            }
            
            // Footer
            HStack {
                Text("SHOWCASE") // Or use "BOOKS"
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray)
                Text("· \(showcase.timeAgo)") // Time since fetched/updated
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: optionsAction) { // More options
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(16)
        .frame(width: 300) // Fixed width for horizontal scroll
    }
}

// Source Category Section Header for Newsstand
struct SourceCategorySectionHeader: View {
    let categoryName: String
    // Action could lead to a view showing only publishers for this category
    var categoryTapAction: () -> Void = { print("Category Tapped - TBD") }
    var body: some View {
        HStack {
            Button(action: categoryTapAction) {
                HStack(spacing: 4) {
                    Text(categoryName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.white) // Ensure text color contrast
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

// Source Tile for Newsstand (uses SF Symbol)
struct SourceTileView: View {
    let source: NewsSource // Now represents a publisher
    // Action could lead to a view showing books by this publisher
    var tileTapAction: () -> Void = { print("Source Tile Tapped - TBD") }
    var body: some View {
        Button(action: tileTapAction) {
            VStack { // Display icon and name
                Image(systemName: source.logoName) // SF Symbol
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .frame(width: 35, height: 35) // Icon size
                    .padding(8)
                
                Text(source.name)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30) // Fixed height for text
            }
            .padding(5) // Overall padding
            .frame(width: 90, height: 90) // Square tile size
            .background(Color.secondary.opacity(0.2)) // Tile background
            .cornerRadius(12) // Rounded corners
        }
        .buttonStyle(.plain) // Make the entire tile tappable
    }
}

// TabBar Item view used in TabBar
struct TabBarItem: View {
    // ... (Keep TabBarItem as it was, uses SF Symbols) ...
    let icon: String
    let text: String
    var isSelected: Bool = false
    var isSpecial: Bool = false // For the Newsstand button style
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: isSelected && isSpecial ? 20 : 22))
                .offset(y: isSelected && isSpecial ? -2 : 0)
            Text(text)
                .font(.caption)
                .offset(y: isSelected && isSpecial ? 2 : 0)
        }
        .foregroundColor(isSelected ? (isSpecial ? .white : .accentColor) : .gray)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(
            ZStack {
                if isSelected && isSpecial {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: 65, height: 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected && isSpecial)
    }
}

// TabBar View at the bottom of the screen
struct TabBarView: View {
    // ... (Keep TabBarView as it was) ...
    @Binding var selectedTab: Int
    
    private var safeAreaBottom: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TabBarItem(icon: "doc.text.image.fill", text: "For you", isSelected: selectedTab == 0, isSpecial: false) // Changed icon
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 0 }
                TabBarItem(icon: "books.vertical.fill", text: "Headlines", isSelected: selectedTab == 1, isSpecial: false) // Changed icon
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 1 }
                TabBarItem(icon: "star.fill", text: "Following", isSelected: selectedTab == 2, isSpecial: false) // Keep icon
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 2 }
                TabBarItem(icon: "building.columns.fill", text: "Newsstand", isSelected: selectedTab == 3, isSpecial: true) // Changed icon
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 3 }
            }
            .frame(height: 50)
            .padding(.bottom, safeAreaBottom > 0 ? 0 : 8) // Adjust padding only if no safe area
        }
        // .background(.thinMaterial) // Apply background directly here in ZStack context
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// Profile Settings Sheet (Remains largely the same, uses placeholder info)
struct ProfileSettingsView: View {
    // ... (Keep ProfileSettingsView as it was, using placeholder names/assets) ...
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Profile Info Section
                    HStack(spacing: 15) {
                        ZStack(alignment: .bottomTrailing) {
                            // Use SF Symbol as placeholder
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.gray) // Color the symbol
                            // .overlay(Circle().stroke(Color.gray, lineWidth: 1)) // Optional border
                            
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.thinMaterial) // Use material background
                                .background(Circle().fill(.regularMaterial))
                                .offset(x: 5, y: 5)
                                .foregroundColor(.primary) // Adapts to light/dark
                        }
                        VStack(alignment: .leading) {
                            Text("Your Name") // Placeholder
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("your.email@example.com") // Placeholder
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Manage Account Button
                    Button("Manage your Account") { /* Action */ }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    Divider().background(Color.gray.opacity(0.5))
                    
                    // Action Rows Section 1
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "bell", text: "Notifications & shared") { /* Action */ }
                        actionRow(icon: "clock.arrow.circlepath", text: "My Activity") { /* Action */ }
                    }
                    
                    Divider().background(Color.gray.opacity(0.5))
                    
                    // Action Rows Section 2
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "gearshape", text: "App settings") { /* Action */ } // Renamed
                        actionRow(icon: "questionmark.circle", text: "Help & feedback") { /* Action */ }
                    }
                    
                    Divider().background(Color.gray.opacity(0.5))
                    
                    // Footer Section
                    HStack {
                        Button("Privacy Policy") { /* Action */ }.buttonStyle(.plain)
                        Text("·").foregroundColor(.gray)
                        Button("Terms of Service") { /* Action */ }.buttonStyle(.plain)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Use standard grouped background
            .foregroundColor(.primary) // Use primary color for text (adapts)
            .navigationTitle("Account") // Changed Title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary) // Adapts
                    }
                }
            }
        }
        .accentColor(.blue) // Standard iOS accent color
        // .preferredColorScheme(.dark) // Allow system preference or remove for default
    }
    
    @ViewBuilder
    private func actionRow(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(width: 25, alignment: .center)
                Text(text)
                    .foregroundColor(.primary) // Adapts
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Views (Updated with API calls and State)

// ForYou View
struct ForYouView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var mainArticle: NewsArticle? = nil
    @State private var otherArticles: [NewsArticle] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    // Define search terms (examples)
    private let mainQuery = "best sellers" // Changed query
    private let otherQuery = "new releases fiction" // Changed query
    
    var body: some View {
        // Use a Navigation View to embed the Header and allow potential future navigation
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // HeaderView() // Header now part of Navigation Title area
                    TopStoriesLinkView() // Keep link below header conceptually
                    
                    if isLoading && mainArticle == nil && otherArticles.isEmpty { // Show loader only on initial empty load
                        ProgressView("Loading stories...")
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if let error = errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Error Loading Books")
                                .font(.headline)
                                .padding(.top, 5)
                            Text(error) // Display the localized error description
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task { await loadData() }
                            }
                            .padding(.top)
                            .buttonStyle(.bordered)
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // Display fetched data
                        if let article = mainArticle {
                            MainNewsCardView(article: article)
                        } else if !isLoading {
                            // Show placeholder if main article failed but loading finished
                            Text("Could not load main story.")
                                .foregroundColor(.gray).padding()
                                .frame(maxWidth: .infinity)
                        }
                        
                        ForEach(otherArticles) { article in
                            SmallNewsCardView(article: article)
                        }
                        
                        if !isLoading && !otherArticles.isEmpty && errorMessage == nil {
                            Text("End of results")
                                .font(.caption).foregroundColor(.gray)
                                .padding().frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.bottom, 60) // Padding for TabBar
            }
            .background(Color.black.ignoresSafeArea()) // Background for scroll content
            .navigationTitle("Briefing") // Use Navigation Title instead of HeaderView
            .navigationBarTitleDisplayMode(.large)
            .toolbar { // Add weather widget to toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    WeatherWidget()
                }
            }
            .task { // Load data when view appears
                // Load only if data hasn't been loaded yet
                if mainArticle == nil && otherArticles.isEmpty {
                    await loadData()
                }
            }
            .refreshable { // Add pull-to-refresh
                await loadData(refresh: true)
            }
            
        }
        .accentColor(.white) // Ensure toolbar items are visible on black background
        .preferredColorScheme(.dark) // Force dark mode for this tab
    }
    
    private func loadData(refresh: Bool = false) async {
        // Only show full loading indicator on initial load, not refresh
        if !refresh && mainArticle == nil && otherArticles.isEmpty {
            isLoading = true
        }
        // Always clear error on new load attempt
        errorMessage = nil
        // Optionally clear old data immediately on refresh for smoother UI update
        if refresh {
            mainArticle = nil
            otherArticles = []
        }
        
        print("ForYouView: Loading data... Refresh: \(refresh)")
        
        async let mainFetch = apiService.fetchBooks(query: mainQuery, orderBy: "newest", maxResults: 1)
        async let othersFetch = apiService.fetchBooks(query: otherQuery, maxResults: 5, startIndex: 0)
        
        do {
            // Await concurrent fetches
            let mainItems = try await mainFetch
            let otherItems = try await othersFetch
            
            print("ForYouView: Fetched \(mainItems.count) main items, \(otherItems.count) other items.")
            
            if let firstBook = mainItems.first {
                mainArticle = firstBook.toNewsArticle()
            } else {
                print("No main article found for query: \(mainQuery)")
                mainArticle = nil // Explicitly set to nil if not found
            }
            
            otherArticles = otherItems.map { $0.toNewsArticle() }
            
        } catch {
            print("ForYouView: Error loading data - \(error)")
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            // Clear data on error to avoid showing stale info
            mainArticle = nil
            otherArticles = []
        }
        
        isLoading = false // Hide loader after completion or error
        print("ForYouView: Loading finished. Error: \(errorMessage ?? "None")")
    }
}

// Headlines View
struct HeadlinesView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var selectedCategory: String = "Featured" // Default category
    @State private var headlineStories: [HeadlineArticle] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // TopBar is added by MainTabView
            CategorySelectorView(selectedCategory: $selectedCategory) { newCategory in
                // Action closure for CategorySelectorView
                print("Category selected: \(newCategory)")
                headlineStories = [] // Clear old stories immediately
                Task {
                    await loadHeadlines()
                }
            }
            
            if isLoading && headlineStories.isEmpty {
                ProgressView("Loading Headlines...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Center loader
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundColor(.orange)
                    Text("Error Loading Headlines").font(.headline).padding(.top, 5)
                    Text(error).font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                    Button("Retry") { Task { await loadHeadlines() } }.padding(.top).buttonStyle(.bordered)
                }.padding().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !isLoading && headlineStories.isEmpty {
                Text("No books found for '\(selectedCategory)'") // Message when empty
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Center message
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) { // Use LazyVStack for performance
                        ForEach(headlineStories) { article in
                            HeadlineStoryBlockView(article: article)
                        }
                    }
                    .padding(.bottom, 60) // Padding for TabBar
                }
                .refreshable { await loadHeadlines(refresh: true) }
            }
        }
        .background(Color.black.ignoresSafeArea()) // Background for the entire tab content
        .task { // Load data when view first appears
            if headlineStories.isEmpty { // Only load if empty
                await loadHeadlines()
            }
        }
        // No separate task needed for category change, handled by CategorySelectorView's action
    }
    
    private func loadHeadlines(refresh: Bool = false) async {
        print("HeadlinesView: Loading for category '\(selectedCategory)'. Refresh: \(refresh)")
        if !refresh && headlineStories.isEmpty { isLoading = true } // Show loader only on initial empty load
        errorMessage = nil
        // Keep existing stories during refresh for smoother feel? Or clear like this:
        // if refresh { headlineStories = [] }
        
        // Map UI category name to potential Google Books API query terms
        let query: String
        switch selectedCategory {
        case "Featured": query = "google editors choice books" // Example query
        case "Fiction": query = "subject:fiction"
        case "Non-Fiction": query = "subject:non-fiction"
        case "Science": query = "subject:science"
        case "History": query = "subject:history"
        case "Technology": query = "subject:technology"
        case "Business": query = "subject:business"
        case "Arts": query = "subject:art"
        default: query = selectedCategory // Use category name directly as fallback
        }
        
        do {
            let items = try await apiService.fetchBooks(query: query, orderBy: "newest", maxResults: 15) // Fetch more for headlines
            print("HeadlinesView: Fetched \(items.count) items for query '\(query)'")
            
            // Use a background task to map data to avoid blocking UI thread if mapping is complex
            let mappedArticles = Task.detached {
                items.map { $0.toHeadlineArticle(categoryOverride: selectedCategory) } // Pass category if needed
            }
            headlineStories = await mappedArticles.value
            
        } catch {
            print("HeadlinesView: Error loading headlines - \(error)")
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            headlineStories = [] // Clear data on error
        }
        isLoading = false
        print("HeadlinesView: Loading finished for '\(selectedCategory)'. Error: \(errorMessage ?? "None")")
    }
}

// Following View
struct FollowingView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    // Store followed topics/authors/queries (hardcoded examples for now)
    @State private var followedTopics: [String] = ["Swift Programming", "Artificial Intelligence", "Isaac Asimov"]
    @State private var topicGroups: [FollowedTopicGroup] = []
    @State private var isLoading: Bool = false
    @State private var errorMessages: [String: String] = [:] // Error per topic
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Use a List for better performance with sections and dynamic updates
            List {
                // Recently Followed Section (Static for now)
                //                  Section {
                //                       RecentlyFollowedView(items: [FollowedItem.placeholderLibrary, FollowedItem.placeholderSaved, FollowedItem.placeholderTopic, FollowedItem.placeholderSearch])
                //                            .listRowInsets(EdgeInsets()) // Remove default padding
                //                            .listRowSeparator(.hidden) // Hide separator for this row
                //                            .padding(.bottom, -10) // Pull next section up slightly
                //                  }
                
                // Sections for each followed topic
                ForEach($topicGroups) { $group in
                    Section {
                        if isLoading && group.articles.isEmpty && errorMessages[group.topicName] == nil {
                            ProgressView().frame(maxWidth: .infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                        } else if let error = errorMessages[group.topicName] {
                            Text("Error loading: \(error)")
                                .font(.caption).foregroundColor(.red)
                                .listRowSeparator(.hidden)
                        } else if group.articles.isEmpty && !isLoading {
                            Text("No recent books found.")
                                .font(.caption).foregroundColor(.gray)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(group.articles) { article in
                                FollowingArticleCardView(article: article)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)) // Adjust insets
                                    .listRowSeparator(.hidden) // Hide default separators, card has its own
                            }
                        }
                    } header: {
                        TopicHeaderView(group: group) { isFollowed in
                            // Handle follow toggle (remove topic / add back) - NEEDS IMPLEMENTATION
                            if !isFollowed {
                                if let index = followedTopics.firstIndex(of: group.topicName) {
                                    followedTopics.remove(at: index)
                                    // Also remove from topicGroups state
                                    topicGroups.removeAll { $0.topicName == group.topicName }
                                    // Persist this change (e.g., UserDefaults)
                                }
                            } else {
                                // Handle adding back - likely via search/add button
                            }
                            print("Follow status changed for \(group.topicName): \(isFollowed)")
                            
                        }.padding(.vertical, 5) // Reduce padding around header slightly
                    }
                    .listRowInsets(EdgeInsets()) // Remove insets for the section container itself
                    
                    // Add a visual separator between sections if needed (List might add its own)
                    //                       Divider()
                    //                           .listRowSeparator(.hidden)
                    //                           .listRowInsets(EdgeInsets())
                }
                
                // Add space at the bottom for the FAB
                Color.clear.frame(height: 80).listRowSeparator(.hidden)
                
            }
            .listStyle(.plain) // Use plain style to remove default inset groups etc.
            .background(Color.black.ignoresSafeArea()) // Background for the list
            .refreshable { await loadAllTopics() } // Refresh all followed topics
            .task { // Initial load for all topics
                if topicGroups.isEmpty {
                    await loadAllTopics()
                }
            }
            
            AddFollowButton() // Floating action button
                .padding(.trailing)
                .padding(.bottom, 65) // Padding from the bottom (above TabBar)
        }
        .preferredColorScheme(.dark) // Keep dark mode for consistency
    }
    
    // Load data for all followed topics concurrently
    private func loadAllTopics() async {
        print("FollowingView: Loading all topics...")
        isLoading = true
        errorMessages = [:] // Clear previous errors
        
        // Create tasks for each topic fetch
        await withTaskGroup(of: FollowedTopicGroup?.self) { group in
            for topic in followedTopics {
                group.addTask {
                    return await loadTopic(topicName: topic)
                }
            }
            
            // Collect results as they complete
            var newGroups: [FollowedTopicGroup] = []
            for await result in group {
                if let validGroup = result {
                    newGroups.append(validGroup)
                }
                // Errors are handled within loadTopic and stored in errorMessages
            }
            // Sort groups alphabetically, or keep original order
            topicGroups = newGroups.sorted { $0.topicName < $1.topicName }
            // Or to preserve `followedTopics` order:
            // topicGroups = followedTopics.compactMap { topicName in
            //     newGroups.first { $0.topicName == topicName }
            // }
            
        }
        isLoading = false
        print("FollowingView: Finished loading all topics.")
    }
    
    // Load data for a single topic
    private func loadTopic(topicName: String) async -> FollowedTopicGroup? {
        print("FollowingView: Loading topic '\(topicName)'")
        errorMessages.removeValue(forKey: topicName) // Clear previous error for this topic
        
        do {
            // Fetch few recent books for the topic/author/query
            let items = try await apiService.fetchBooks(query: topicName, orderBy: "newest", maxResults: 5)
            print("FollowingView: Fetched \(items.count) items for topic '\(topicName)'")
            
            // Map on background thread if needed
            let articles = await Task.detached { items.map { $0.toFollowingArticle(topicName: topicName) } }.value
            
            // Create the group
            // Try to find a relevant SF Symbol (simple example)
            let imageName: String? = topicName.lowercased().contains("swift") ? "swift" : (topicName.lowercased().contains("intelligence") ? "brain.head.profile" : "tag.fill")
            return FollowedTopicGroup(id: UUID(), topicName: topicName, topicImageName: imageName, articles: articles)
            
        } catch {
            print("FollowingView: Error loading topic '\(topicName)' - \(error)")
            let errorMessage: String
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            errorMessages[topicName] = errorMessage // Store error message
            // Return nil so this topic shows an error state
            return nil
        }
    }
}

// Newsstand View
struct NewsstandView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var showingProfileSheet = false // State for profile sheet
    
    // State for API data
    @State private var showcaseSources: [NewsShowcaseSource] = []
    @State private var sourceCategories: [NewsSourceCategory] = [] // Example categories
    @State private var isLoadingShowcase: Bool = false
    @State private var isLoadingCategories: Bool = false
    @State private var showcaseError: String? = nil
    @State private var categoryErrors: [String: String] = [:] // Error per category name
    
    // Define categories to fetch
    private let categoryNames = ["Technology", "Business", "Science Fiction", "History"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar with Profile button overlay
            HStack { TopBarNewsstand() }
                .frame(minHeight: 60) // Adjusted height
                .overlay(alignment: .topTrailing) {
                    // Placeholder profile button
                    Image(systemName:"person.crop.circle.fill")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                    // .clipShape(Circle()).overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                        .padding(.trailing).padding(.top, 7)
                        .contentShape(Circle()).onTapGesture { showingProfileSheet = true }
                }
                .background(Color.black)
            
            // Main content scroll view
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    // --- Showcase Section ---
                    NewsShowcaseSectionHeader() // Header: "Featured Books"
                    if isLoadingShowcase {
                        ProgressView().padding().frame(maxWidth: .infinity)
                    } else if let error = showcaseError {
                        Text("Error loading featured: \(error)")
                            .font(.caption).foregroundColor(.red).padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                if showcaseSources.isEmpty && !isLoadingShowcase {
                                    Text("No featured books found.")
                                        .font(.caption).foregroundColor(.gray)
                                        .frame(width: 200) // Placeholder width
                                } else {
                                    ForEach(showcaseSources) { showcase in
                                        NewsShowcaseCardView(showcase: showcase)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .frame(height: showcaseSources.isEmpty ? 60 : 300) // Adjust height based on content
                        // Needs calculation based on ShowcaseArticleRowView height
                    }
                    
                    // --- Category Sections ---
                    if isLoadingCategories && sourceCategories.isEmpty {
                        ProgressView("Loading Categories...").padding().frame(maxWidth: .infinity)
                    }
                    
                    ForEach(sourceCategories) { category in
                        SourceCategorySectionHeader(categoryName: category.name)
                        if let error = categoryErrors[category.name] {
                            Text("Error: \(error)")
                                .font(.caption).foregroundColor(.red).padding(.horizontal)
                        } else if category.sources.isEmpty && !isLoadingCategories {
                            Text("No publishers found for this category.")
                                .font(.caption).foregroundColor(.gray).padding(.horizontal)
                                .frame(height: 50) // Placeholder height
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(category.sources) { source in
                                        SourceTileView(source: source)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                            .frame(height: 110) // Fixed height for tile carousel
                        }
                    }
                }
                .padding(.bottom, 60) // Padding for TabBar
            }
            .background(Color.black.ignoresSafeArea()) // Background for scroll content
            .refreshable { await loadAllNewsstandData() } // Refresh action
            .task { // Initial load
                if showcaseSources.isEmpty && sourceCategories.isEmpty {
                    await loadAllNewsstandData()
                }
            }
        }
        .preferredColorScheme(.dark) // Keep dark
        .sheet(isPresented: $showingProfileSheet) { // Profile sheet
            ProfileSettingsView()
        }
    }
    
    // Function to load all data for the Newsstand tab
    private func loadAllNewsstandData() async {
        print("NewsstandView: Loading all data...")
        // Run showcase and category loading concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadShowcaseData() }
            group.addTask { await loadAllCategoryData() }
        }
        print("NewsstandView: Finished loading all data.")
    }
    
    // Load data for the Showcase section
    private func loadShowcaseData() async {
        isLoadingShowcase = true
        showcaseError = nil
        print("NewsstandView: Loading showcase data...")
        
        // Example query for featured/popular books
        let showcaseQuery = "subject:fiction+popular" // Or simply "popular books"
        
        do {
            let items = try await apiService.fetchBooks(query: showcaseQuery, maxResults: 10) // Fetch a few showcase items
            print("NewsstandView: Fetched \(items.count) items for showcase.")
            
            // Group books by publisher to create showcase cards
            let groupedByPublisher = Dictionary(grouping: items) { $0.volumeInfo?.publisher ?? "Unknown Publisher" }
            
            var newShowcases: [NewsShowcaseSource] = []
            let fetchTime = formatPublishedDate(Date().ISO8601Format(.iso8601)) // Use current time as 'update' time
            
            for (publisherName, books) in groupedByPublisher {
                // Skip if no books for this publisher
                guard !books.isEmpty else { continue }
                
                let source = createSourceFromPublisher(publisherName)
                let articles = books.map { $0.toShowcaseArticle() }
                newShowcases.append(NewsShowcaseSource(source: source, articles: articles, timeAgo: fetchTime))
            }
            // Sort showcases, e.g., by publisher name
            showcaseSources = newShowcases.sorted { $0.source.name < $1.source.name }
            
        } catch {
            print("NewsstandView: Error loading showcase - \(error)")
            if let apiError = error as? APIError { showcaseError = apiError.localizedDescription }
            else { showcaseError = error.localizedDescription }
            showcaseSources = [] // Clear on error
        }
        isLoadingShowcase = false
        print("NewsstandView: Showcase loading finished.")
    }
    
    // Load data for all categories concurrently
    private func loadAllCategoryData() async {
        isLoadingCategories = true
        categoryErrors = [:] // Clear old errors
        print("NewsstandView: Loading all category data...")
        
        await withTaskGroup(of: NewsSourceCategory?.self) { group in
            for categoryName in categoryNames {
                group.addTask {
                    await loadCategory(categoryName: categoryName)
                }
            }
            
            var newCategories: [NewsSourceCategory] = []
            for await result in group {
                if let category = result {
                    newCategories.append(category)
                }
            }
            // Sort categories alphabetically or keep predefined order
            sourceCategories = newCategories.sorted { $0.name < $1.name }
            //             sourceCategories = categoryNames.compactMap { name in // Preserve order
            //                 newCategories.first { $0.name == name }
            //             }
            
        }
        
        isLoadingCategories = false
        print("NewsstandView: Category loading finished.")
    }
    
    // Load publishers for a single category
    private func loadCategory(categoryName: String) async -> NewsSourceCategory? {
        categoryErrors.removeValue(forKey: categoryName)
        print("NewsstandView: Loading category '\(categoryName)'")
        let categoryQuery = "subject:\(categoryName.lowercased())" // Use subject search
        
        do {
            // Fetch books for the subject
            let items = try await apiService.fetchBooks(query: categoryQuery, maxResults: 20) // Fetch more items to find diverse publishers
            print("NewsstandView: Fetched \(items.count) items for category '\(categoryName)'")
            
            // Extract unique publishers from the results
            let publishers = Set(items.compactMap { $0.volumeInfo?.publisher })
            let sources = publishers.map { createSourceFromPublisher($0) }.sorted { $0.name < $1.name }
            
            // Return nil if no sources found? Or empty array? Decide based on UI preference.
            // if sources.isEmpty { return nil }
            
            return NewsSourceCategory(name: categoryName, sources: sources)
            
        } catch {
            print("NewsstandView: Error loading category '\(categoryName)' - \(error)")
            let errorMessage: String
            if let apiError = error as? APIError { errorMessage = apiError.localizedDescription }
            else { errorMessage = error.localizedDescription }
            categoryErrors[categoryName] = errorMessage
            return nil // Indicate error for this category
        }
    }
}

// MARK: - Main App Entry

// This assumes you have an @main App struct elsewhere that uses MainTabView as its root view.
// Example:
// @main
// struct YourAppNameApp: App {
//     var body: some Scene {
//         WindowGroup {
//             MainTabView()
//         }
//     }
// }

struct MainTabView: View {
    @State private var selectedTab: Int = 0 // Manages active tab
    
    // Computed property to determine if a generic top bar is needed
    private var currentTopBarTitle: String? {
        switch selectedTab {
        case 0: return nil         // ForYouView manages its own Nav title
        case 1: return "Books"     // Title for Headlines (now Books)
        case 2: return "Following"
        case 3: return nil         // NewsstandView manages its own top bar
        default: return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Conditionally display a generic TopBar for tabs that need it
            if let title = currentTopBarTitle {
                TopBarView(title: title)
                    .background(Color.black) // Explicit background for TopBar
            }
            
            // Content view with overlaid TabBar
            ZStack(alignment: .bottom) {
                currentContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Make content extend under the tab bar material
                    .padding(.bottom, -8) // Adjust if TabBar background causes issues
                
                // Apply background to TabBar itself
                TabBarView(selectedTab: $selectedTab)
                    .background(Color.black).opacity(0.85)
                //                    .background(.black.opacity(0.85).thinMaterial) // Dark, slightly transparent material
                
            }
        }
        .background(Color.black.ignoresSafeArea()) // Background for the whole tab view container
        .foregroundColor(.white) // Default text color for unstyled elements
        .tint(.blue) // Default iOS accent color (override per-tab if needed)
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private var currentContentView: some View {
        switch selectedTab {
        case 0:
            ForYouView()
        case 1:
            HeadlinesView()
        case 2:
            FollowingView()
        case 3:
            NewsstandView()
        default:
            ForYouView() // Fallback
        }
    }
}

// MARK: - SwiftUI Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView()
                .previewDisplayName("Main Tabs (Dark)")
                .preferredColorScheme(.dark)
            
            // Preview specific tabs if needed
            // ForYouView()
            //     .preferredColorScheme(.dark)
            //     .previewDisplayName("For You Tab")
            
            // HeadlinesView()
            //      .preferredColorScheme(.dark)
            //      .previewDisplayName("Headlines Tab")
            
            // FollowingView()
            //      .preferredColorScheme(.dark)
            //      .previewDisplayName("Following Tab")
            
            // NewsstandView()
            //      .preferredColorScheme(.dark)
            //      .previewDisplayName("Newsstand Tab")
            
            ProfileSettingsView()
                .previewDisplayName("Profile Sheet (System)")
            // .preferredColorScheme(.dark) // Let it use system setting
        }
    }
}
