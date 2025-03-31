//
//  FullAppImplementation.swift
//  MyApp
//
//  Created by Cong Le on [Today’s Date].
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Models & API Response Structures

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
    let publishedDate: String?
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

// Helper for API error messages
struct GoogleAPIErrorResponse: Codable {
    let error: GoogleAPIErrorDetail
}

struct GoogleAPIErrorDetail: Codable {
    let code: Int?
    let message: String?
}

// MARK: - API Error Enum

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case missingData
    case specificError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL constructed for the API request was invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError(let error):
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    return "Decoding Error: Key '\(key.stringValue)' not found. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    return "Decoding Error: Value of type '\(type)' not found. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .typeMismatch(let type, let context):
                    return "Decoding Error: Type mismatch for type '\(type)'. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                case .dataCorrupted(let context):
                    return "Decoding Error: Data corrupted. Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                @unknown default:
                    return "An unknown decoding error occurred."
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

// MARK: - API Service

class GoogleBooksAPIService: ObservableObject {
    private let baseURL = "https://www.googleapis.com/books/v1/volumes"
    // --- IMPORTANT: Replace below API key with your actual key ---
    private let apiKey = "YOUR_API_KEY"
    
    private let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        // Configure decoder if needed.
    }
    
    func fetchBooks(query: String, filter: String? = nil, printType: String = "all", orderBy: String = "relevance", maxResults: Int = 10, startIndex: Int = 0) async throws -> [BookItem] {
        guard !query.isEmpty else {
            print("Search query cannot be empty.")
            return []
        }
        
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "maxResults", value: String(maxResults)),
            URLQueryItem(name: "startIndex", value: String(startIndex)),
            URLQueryItem(name: "printType", value: printType),
            URLQueryItem(name: "orderBy", value: orderBy)
        ]
        
        if let filterValue = filter, !filterValue.isEmpty {
            queryItems.append(URLQueryItem(name: "filter", value: filterValue))
        }
        
        if !apiKey.isEmpty && apiKey != "YOUR_API_KEY" {
            queryItems.append(URLQueryItem(name: "key", value: apiKey))
        }
        
        components?.queryItems = queryItems
        
        // Ensure proper encoding for spaces and special characters.
        components?.percentEncodedQuery = components?.queryItems?.map { item in
            let key = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let value = item.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        guard let url = components?.url else {
            print("Invalid URL components: \(components.debugDescription)")
            throw APIError.invalidURL
        }
        
        print("Fetching books from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            print("HTTP Response Status: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorDetail = try? decoder.decode(GoogleAPIErrorResponse.self, from: data) {
                    throw APIError.specificError("\(errorDetail.error.message ?? "Unknown error") (Code: \(errorDetail.error.code ?? httpResponse.statusCode))")
                } else {
                    throw APIError.invalidResponse
                }
            }
            
            do {
                let bookResponse = try decoder.decode(BookResponse.self, from: data)
                guard bookResponse.items != nil || bookResponse.totalItems == 0 else {
                    if bookResponse.totalItems == nil {
                        throw APIError.missingData
                    } else {
                        return []
                    }
                }
                return bookResponse.items ?? []
            } catch let decodingError as DecodingError {
                print("Decoding error: \(decodingError)")
                throw APIError.decodingError(decodingError)
            }
        } catch let error as URLError {
            print("URLSession error: \(error)")
            throw APIError.requestFailed(error)
        } catch {
            print("Fetch error: \(error)")
            throw APIError.requestFailed(error)
        }
    }
}

// MARK: - Data Mapping & Helpers

extension BookItem {
    func toNewsArticle() -> NewsArticle {
        let publisherName = volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName)
        let headline = volumeInfo?.title ?? "Untitled Book"
        let thumbnailURL = volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        let smallThumbnailURL = volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString() ?? thumbnailURL
        let descriptiveText = searchInfo?.textSnippet ?? volumeInfo?.description ?? "No description available."
        let cleanDescription = descriptiveText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        return NewsArticle(
            id: UUID(),
            source: source,
            headline: headline,
            imageName: thumbnailURL ?? "",
            timeAgo: formatPublishedDate(volumeInfo?.publishedDate),
            descriptionText: cleanDescription,
            isLargeCard: true,
            smallImageName: smallThumbnailURL
        )
    }
    
    func toHeadlineArticle(categoryOverride: String? = nil) -> HeadlineArticle {
        let publisherName = volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName)
        let thumbnailURL = volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        let category = categoryOverride ?? volumeInfo?.categories?.first ?? "General"
        return HeadlineArticle(
            id: UUID(),
            category: category,
            source: source,
            headline: volumeInfo?.title ?? "Untitled Book",
            imageName: thumbnailURL ?? "",
            timeAgo: formatPublishedDate(volumeInfo?.publishedDate),
            relatedArticles: []
        )
    }
    
    func toFollowingArticle(topicName: String) -> FollowingArticle {
        let publisherName = volumeInfo?.publisher ?? "Unknown Publisher"
        let source = createSourceFromPublisher(publisherName)
        let thumbnailURL = volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        return FollowingArticle(
            id: UUID(),
            source: source,
            headline: "\(topicName): \(volumeInfo?.title ?? "Untitled Book")".trimmingCharacters(in: .whitespacesAndNewlines),
            timeAgo: formatPublishedDate(volumeInfo?.publishedDate),
            imageName: thumbnailURL ?? ""
        )
    }
    
    func toShowcaseArticle() -> ShowcaseArticle {
        let thumbnailURL = volumeInfo?.imageLinks?.thumbnail?.secureUrlString() ?? volumeInfo?.imageLinks?.smallThumbnail?.secureUrlString()
        let categoryTag = volumeInfo?.categories?.first?.uppercased()
        return ShowcaseArticle(
            id: UUID(),
            context: volumeInfo?.authors?.joined(separator: ", ") ?? volumeInfo?.publisher,
            headline: volumeInfo?.title ?? "Untitled Book",
            imageName: thumbnailURL ?? "",
            topicTag: categoryTag
        )
    }
}

func createSourceFromPublisher(_ publisher: String?) -> NewsSource {
    return NewsSource(name: publisher ?? "Unknown Publisher", logoName: "book.closed.fill")
}

func formatPublishedDate(_ dateString: String?) -> String {
    guard let dateString = dateString, !dateString.isEmpty else { return "Date Unknown" }
    
    let dateFormatter = DateFormatter()
    var parsedDate: Date?
    let potentialFormats = ["yyyy-MM-dd", "yyyy-MM", "yyyy"]
    for format in potentialFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            parsedDate = date
            break
        }
    }
    guard let date = parsedDate else { return dateString }
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}

extension String {
    func secureUrlString() -> String {
        self.replacingOccurrences(of: "http://", with: "https://")
    }
}

// MARK: - Data Models for UI

enum FollowedItemType {
    case library, saved, topic, search
}

struct NewsSource: Identifiable {
    var id: String { name }
    let name: String
    let logoName: String
}

struct NewsArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let imageName: String
    let timeAgo: String
    let descriptionText: String?
    let isLargeCard: Bool
    let smallImageName: String?
}

struct HeadlineArticle: Identifiable {
    let id: UUID
    let category: String
    let source: NewsSource
    let headline: String
    let imageName: String
    let timeAgo: String
    var relatedArticles: [RelatedArticle]
}

struct RelatedArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String
    
    static var placeholderCNN: RelatedArticle {
        RelatedArticle(id: UUID(), source: NewsSource(name: "CNN", logoName: "newspaper.fill"), headline: "Related: CNN Analysis", timeAgo: "2h ago")
    }
    static var placeholderNYT: RelatedArticle {
        RelatedArticle(id: UUID(), source: NewsSource(name: "NY Times", logoName: "newspaper.fill"), headline: "Related: NYT Opinion", timeAgo: "90m ago")
    }
}

struct FollowedItem: Identifiable {
    let id: UUID
    let name: String
    let imageName: String?
    let iconName: String?
    let type: FollowedItemType
    
    static var placeholderLibrary: FollowedItem {
        FollowedItem(id: UUID(), name: "Library", imageName: nil, iconName: "books.vertical.fill", type: .library)
    }
    static var placeholderSaved: FollowedItem {
        FollowedItem(id: UUID(), name: "Saved stories", imageName: nil, iconName: "bookmark.fill", type: .saved)
    }
    static var placeholderTopic: FollowedItem {
        FollowedItem(id: UUID(), name: "Search: Swift", imageName: nil, iconName: "magnifyingglass", type: .topic)
    }
    static var placeholderSearch: FollowedItem {
        FollowedItem(id: UUID(), name: "Search...", imageName: nil, iconName: "plus.magnifyingglass", type: .search)
    }
}

struct FollowingArticle: Identifiable {
    let id: UUID
    let source: NewsSource
    let headline: String
    let timeAgo: String
    let imageName: String
}

struct FollowedTopicGroup: Identifiable {
    let id: UUID
    let topicName: String
    let topicImageName: String?
    var articles: [FollowingArticle]
}

struct ShowcaseArticle: Identifiable {
    let id: UUID
    let context: String?
    let headline: String
    let imageName: String
    let topicTag: String?
}

struct NewsShowcaseSource: Identifiable {
    var id: String { source.id }
    let source: NewsSource
    var articles: [ShowcaseArticle]
    let timeAgo: String
}

struct NewsSourceCategory: Identifiable {
    var id: String { name }
    let name: String
    var sources: [NewsSource]
}

// MARK: - Reusable UI Components

struct NetworkImageView: View {
    let urlString: String?
    let placeholderSymbol: String
    let configuration: (Image) -> AnyView
    
    init(urlString: String?, placeholderSymbol: String = "photo.fill", @ViewBuilder configuration: @escaping (Image) -> AnyView = { AnyView($0.resizable()) }) {
        self.urlString = urlString
        self.placeholderSymbol = placeholderSymbol
        self.configuration = configuration
    }
    
    var body: some View {
        Group {
            if let urlString = urlString, let url = URL(string: urlString.secureUrlString()) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        configuration(image)
                    case .failure:
                        Image(systemName: placeholderSymbol)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: placeholderSymbol)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.systemGray5))
    }
}

struct TopBarView: View {
    let title: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundColor(.gray)
            Spacer()
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

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
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(.horizontal)
            .frame(height: 44)
        }
        .padding(.bottom, 5)
    }
}

struct WeatherWidget: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("72°F")
                .fontWeight(.medium)
            Image(systemName: "sun.max.fill")
                .renderingMode(.original)
                .font(.title3)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(20)
    }
}

struct CategorySelectorView: View {
    let categories = ["Featured", "Fiction", "Non-Fiction", "Science", "History", "Technology", "Business", "Arts"]
    @Binding var selectedCategory: String
    var categorySelectedAction: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    CategoryTab(text: category, isSelected: selectedCategory == category)
                        .onTapGesture {
                            if selectedCategory != category {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                                categorySelectedAction(category)
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

struct CategoryTab: View {
    let text: String
    var isSelected: Bool
    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .accentColor : .gray)
            Rectangle()
                .frame(height: 3)
                .foregroundColor(isSelected ? .accentColor : .clear)
                .cornerRadius(1.5)
                .padding(.horizontal, 4)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct MainNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo.fill") { image in
                AnyView(image.resizable().aspectRatio(contentMode: .fill))
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(10)
            .padding(.bottom, 4)
            
            HStack(spacing: 6) {
                Image(systemName: article.source.logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(2)
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Text(article.headline)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            if let description = article.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .padding(.top, 1)
            }
            
            HStack {
                Text(article.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "bookmark")
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "square.and.arrow.up")
                    .font(.callout)
                    .foregroundColor(.gray)
                Image(systemName: "ellipsis")
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

struct SmallNewsCardView: View {
    let article: NewsArticle
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: article.source.logoName)
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
                    Text(article.headline)
                        .font(.headline)
                        .lineLimit(3)
                    Spacer(minLength: 4)
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        if !(article.descriptionText ?? "").isEmpty {
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
                Spacer()
                NetworkImageView(urlString: article.smallImageName ?? article.imageName, placeholderSymbol: "photo") { image in
                    AnyView(image.resizable().aspectRatio(contentMode: .fill))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            Divider()
        }
    }
}

struct FullCoverageButton: View {
    var action: () -> Void = { print("View Details - Action TBD") }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                Text("View Details")
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

struct RelatedStoryCardView: View {
    let relatedArticle: RelatedArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: relatedArticle.source.logoName)
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
        .frame(width: 180)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}

struct HeadlineStoryBlockView: View {
    let article: HeadlineArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo.fill") { image in
                AnyView(image.resizable().aspectRatio(contentMode: .fill))
            }
            .frame(height: 200)
            .clipped()
            .padding(.bottom, 12)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: article.source.logoName)
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
            
            if !article.relatedArticles.isEmpty {
                Text("Related Stories")
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
                .frame(height: 130)
            }
            
            FullCoverageButton()
            Divider().padding(.top, 12)
        }
        .padding(.bottom)
    }
}

struct FollowedItemView: View {
    let item: FollowedItem
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                if let iconName = item.iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                } else if let imageName = item.imageName {
                    Image(imageName)
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
                .frame(width: 70)
        }
    }
}

struct RecentlyFollowedView: View {
    let items = [FollowedItem.placeholderLibrary, FollowedItem.placeholderSaved, FollowedItem.placeholderTopic, FollowedItem.placeholderSearch]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Activity")
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

struct TopicHeaderView: View {
    let group: FollowedTopicGroup
    @State private var isFollowed: Bool = true
    var followToggleAction: (Bool) -> Void = { _ in print("Follow toggled") }
    var body: some View {
        HStack {
            if let imageName = group.topicImageName {
                if imageName.contains(".") {
                    NetworkImageView(urlString: imageName, placeholderSymbol: "tag.fill") { img in
                        AnyView(img.resizable().scaledToFit())
                    }
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
                } else {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                        .cornerRadius(4)
                }
            } else {
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

struct FollowingArticleCardView: View {
    let article: FollowingArticle
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: article.source.logoName)
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
                    Text(article.headline)
                        .font(.subheadline)
                        .lineLimit(3)
                    Spacer(minLength: 4)
                    HStack {
                        Text(article.timeAgo)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "bookmark")
                                .font(.callout)
                                .foregroundColor(.gray)
                            Image(systemName: "ellipsis")
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                NetworkImageView(urlString: article.imageName, placeholderSymbol: "photo") { img in
                    AnyView(img.resizable().aspectRatio(contentMode: .fill))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            Divider().padding(.leading)
        }
    }
}

struct AddFollowButton: View {
    var action: () -> Void = { print("Add Follow Tapped") }
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

struct NewsShowcaseSectionHeader: View {
    var seeAllAction: () -> Void = { print("News Showcase See All Tapped") }
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Featured Books")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Spacer()
            Button(action: seeAllAction) {
                Text("See All")
                    .font(.callout)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct SourceTileView: View {
    let source: NewsSource
    var tileTapAction: () -> Void = { print("Source Tile Tapped") }
    var body: some View {
        Button(action: tileTapAction) {
            VStack {
                Image(systemName: source.logoName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .frame(width: 35, height: 35)
                    .padding(8)
                Text(source.name)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
            }
            .padding(5)
            .frame(width: 90, height: 90)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TabBarItem: View {
    let icon: String
    let text: String
    var isSelected: Bool = false
    var isSpecial: Bool = false
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

struct TabBarView: View {
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
                TabBarItem(icon: "doc.text.image.fill", text: "For you", isSelected: selectedTab == 0, isSpecial: false)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 0 }
                TabBarItem(icon: "books.vertical.fill", text: "Headlines", isSelected: selectedTab == 1, isSpecial: false)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 1 }
                TabBarItem(icon: "star.fill", text: "Following", isSelected: selectedTab == 2, isSpecial: false)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 2 }
                TabBarItem(icon: "building.columns.fill", text: "Newsstand", isSelected: selectedTab == 3, isSpecial: true)
                    .contentShape(Rectangle())
                    .onTapGesture { selectedTab = 3 }
            }
            .frame(height: 50)
            .padding(.bottom, safeAreaBottom > 0 ? 0 : 8)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Feature Views

struct ForYouView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var mainArticle: NewsArticle? = nil
    @State private var otherArticles: [NewsArticle] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let mainQuery = "best sellers"
    private let otherQuery = "new releases fiction"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TopStoriesLinkView()
                    
                    if isLoading && mainArticle == nil && otherArticles.isEmpty {
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
                            Text(error)
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
                        if let article = mainArticle {
                            MainNewsCardView(article: article)
                        } else if !isLoading {
                            Text("Could not load main story.")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        ForEach(otherArticles) { article in
                            SmallNewsCardView(article: article)
                        }
                        
                        if !isLoading && !otherArticles.isEmpty && errorMessage == nil {
                            Text("End of results")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Briefing")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    WeatherWidget()
                }
            }
            .task {
                if mainArticle == nil && otherArticles.isEmpty {
                    await loadData()
                }
            }
            .refreshable {
                await loadData(refresh: true)
            }
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
    
    private func loadData(refresh: Bool = false) async {
        if !refresh && mainArticle == nil && otherArticles.isEmpty {
            isLoading = true
        }
        errorMessage = nil
        if refresh {
            mainArticle = nil
            otherArticles = []
        }
        async let mainFetch = apiService.fetchBooks(query: mainQuery, orderBy: "newest", maxResults: 1)
        async let othersFetch = apiService.fetchBooks(query: otherQuery, maxResults: 5, startIndex: 0)
        do {
            let mainItems = try await mainFetch
            let otherItems = try await othersFetch
            if let firstBook = mainItems.first {
                mainArticle = firstBook.toNewsArticle()
            } else {
                mainArticle = nil
            }
            otherArticles = otherItems.map { $0.toNewsArticle() }
        } catch {
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = "An unexpected error: \(error.localizedDescription)"
            }
            mainArticle = nil
            otherArticles = []
        }
        isLoading = false
    }
}

struct TopStoriesLinkView: View {
    var action: () -> Void = { print("Top stories tapped") }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("Top stories")
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

struct HeadlinesView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var selectedCategory: String = "Featured"
    @State private var headlineStories: [HeadlineArticle] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            CategorySelectorView(selectedCategory: $selectedCategory) { newCategory in
                headlineStories = []
                Task {
                    await loadHeadlines()
                }
            }
            if isLoading && headlineStories.isEmpty {
                ProgressView("Loading Headlines...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error Loading Headlines")
                        .font(.headline)
                        .padding(.top, 5)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await loadHeadlines() } }
                        .padding(.top)
                        .buttonStyle(.bordered)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !isLoading && headlineStories.isEmpty {
                Text("No books found for '\(selectedCategory)'")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(headlineStories) { article in
                            HeadlineStoryBlockView(article: article)
                        }
                    }
                    .padding(.bottom, 60)
                }
                .refreshable { await loadHeadlines(refresh: true) }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .task {
            if headlineStories.isEmpty {
                await loadHeadlines()
            }
        }
    }
    
    private func loadHeadlines(refresh: Bool = false) async {
        if !refresh && headlineStories.isEmpty { isLoading = true }
        errorMessage = nil
        let query: String
        switch selectedCategory {
        case "Featured": query = "google editors choice books"
        case "Fiction": query = "subject:fiction"
        case "Non-Fiction": query = "subject:non-fiction"
        case "Science": query = "subject:science"
        case "History": query = "subject:history"
        case "Technology": query = "subject:technology"
        case "Business": query = "subject:business"
        case "Arts": query = "subject:art"
        default: query = selectedCategory
        }
        
        do {
            let items = try await apiService.fetchBooks(query: query, orderBy: "newest", maxResults: 15)
            let mappedArticles = Task.detached {
                items.map { $0.toHeadlineArticle(categoryOverride: selectedCategory) }
            }
            headlineStories = await mappedArticles.value
        } catch {
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            headlineStories = []
        }
        isLoading = false
    }
}

struct FollowingView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var followedTopics: [String] = ["Swift Programming", "Artificial Intelligence", "Isaac Asimov"]
    @State private var topicGroups: [FollowedTopicGroup] = []
    @State private var isLoading: Bool = false
    @State private var errorMessages: [String: String] = [:]
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach($topicGroups) { $group in
                    Section {
                        if isLoading && group.articles.isEmpty && errorMessages[group.topicName] == nil {
                            ProgressView().frame(maxWidth: .infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                        } else if let error = errorMessages[group.topicName] {
                            Text("Error loading: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .listRowSeparator(.hidden)
                        } else if group.articles.isEmpty && !isLoading {
                            Text("No recent books found.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(group.articles) { article in
                                FollowingArticleCardView(article: article)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                    .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        TopicHeaderView(group: group) { isFollowed in
                            if !isFollowed {
                                if let index = followedTopics.firstIndex(of: group.topicName) {
                                    followedTopics.remove(at: index)
                                    topicGroups.removeAll { $0.topicName == group.topicName }
                                }
                            }
                            print("Follow status changed for \(group.topicName): \(isFollowed)")
                        }
                        .padding(.vertical, 5)
                    }
                }
                Color.clear.frame(height: 80).listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.black.ignoresSafeArea())
            .refreshable { await loadAllTopics() }
            .task {
                if topicGroups.isEmpty {
                    await loadAllTopics()
                }
            }
            AddFollowButton()
                .padding(.trailing)
                .padding(.bottom, 65)
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadAllTopics() async {
        isLoading = true
        errorMessages = [:]
        await withTaskGroup(of: FollowedTopicGroup?.self) { group in
            for topic in followedTopics {
                group.addTask {
                    return await loadTopic(topicName: topic)
                }
            }
            var newGroups: [FollowedTopicGroup] = []
            for await result in group {
                if let validGroup = result {
                    newGroups.append(validGroup)
                }
            }
            topicGroups = newGroups.sorted { $0.topicName < $1.topicName }
        }
        isLoading = false
    }
    
    private func loadTopic(topicName: String) async -> FollowedTopicGroup? {
        errorMessages.removeValue(forKey: topicName)
        do {
            let items = try await apiService.fetchBooks(query: topicName, orderBy: "newest", maxResults: 5)
            let articles = await Task.detached { items.map { $0.toFollowingArticle(topicName: topicName) } }.value
            let imageName: String? = topicName.lowercased().contains("swift") ? "swift" : (topicName.lowercased().contains("intelligence") ? "brain.head.profile" : "tag.fill")
            return FollowedTopicGroup(id: UUID(), topicName: topicName, topicImageName: imageName, articles: articles)
        } catch {
            let errorMessage: String
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            errorMessages[topicName] = errorMessage
            return nil
        }
    }
}

struct NewsstandView: View {
    @StateObject private var apiService = GoogleBooksAPIService()
    @State private var showingProfileSheet = false
    @State private var showcaseSources: [NewsShowcaseSource] = []
    @State private var sourceCategories: [NewsSourceCategory] = []
    @State private var isLoadingShowcase: Bool = false
    @State private var isLoadingCategories: Bool = false
    @State private var showcaseError: String? = nil
    @State private var categoryErrors: [String: String] = [:]
    
    private let categoryNames = ["Technology", "Business", "Science Fiction", "History"]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack { TopBarNewsstand() }
                .frame(minHeight: 60)
                .overlay(alignment: .topTrailing) {
                    Image(systemName:"person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                        .padding(.top, 7)
                        .contentShape(Circle())
                        .onTapGesture { showingProfileSheet = true }
                }
                .background(Color.black)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    NewsShowcaseSectionHeader()
                    if isLoadingShowcase {
                        ProgressView().padding().frame(maxWidth: .infinity)
                    } else if let error = showcaseError {
                        Text("Error loading featured: \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                if showcaseSources.isEmpty && !isLoadingShowcase {
                                    Text("No featured books found.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(width: 200)
                                } else {
                                    ForEach(showcaseSources) { showcase in
                                        NewsShowcaseCardView(showcase: showcase)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .frame(height: showcaseSources.isEmpty ? 60 : 300)
                    }
                    
                    if isLoadingCategories && sourceCategories.isEmpty {
                        ProgressView("Loading Categories...")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(sourceCategories) { category in
                        SourceCategorySectionHeader(categoryName: category.name)
                        if let error = categoryErrors[category.name] {
                            Text("Error: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else if category.sources.isEmpty && !isLoadingCategories {
                            Text("No publishers found for this category.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .frame(height: 50)
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
                            .frame(height: 110)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
            .background(Color.black.ignoresSafeArea())
            .refreshable { await loadAllNewsstandData() }
            .task {
                if showcaseSources.isEmpty && sourceCategories.isEmpty {
                    await loadAllNewsstandData()
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSettingsView()
        }
    }
    
    private func loadAllNewsstandData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadShowcaseData() }
            group.addTask { await loadAllCategoryData() }
        }
    }
    
    private func loadShowcaseData() async {
        isLoadingShowcase = true
        showcaseError = nil
        let showcaseQuery = "subject:fiction+popular"
        do {
            let items = try await apiService.fetchBooks(query: showcaseQuery, maxResults: 10)
            let groupedByPublisher = Dictionary(grouping: items) { $0.volumeInfo?.publisher ?? "Unknown Publisher" }
            var newShowcases: [NewsShowcaseSource] = []
            let fetchTime = formatPublishedDate(Date().ISO8601Format(.iso8601))
            for (publisherName, books) in groupedByPublisher where !books.isEmpty {
                let source = createSourceFromPublisher(publisherName)
                let articles = books.map { $0.toShowcaseArticle() }
                newShowcases.append(NewsShowcaseSource(source: source, articles: articles, timeAgo: fetchTime))
            }
            showcaseSources = newShowcases.sorted { $0.source.name < $1.source.name }
        } catch {
            if let apiError = error as? APIError { showcaseError = apiError.localizedDescription }
            else { showcaseError = error.localizedDescription }
            showcaseSources = []
        }
        isLoadingShowcase = false
    }
    
    private func loadAllCategoryData() async {
        isLoadingCategories = true
        categoryErrors = [:]
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
            sourceCategories = newCategories.sorted { $0.name < $1.name }
        }
        isLoadingCategories = false
    }
    
    private func loadCategory(categoryName: String) async -> NewsSourceCategory? {
        categoryErrors.removeValue(forKey: categoryName)
        let categoryQuery = "subject:\(categoryName.lowercased())"
        do {
            let items = try await apiService.fetchBooks(query: categoryQuery, maxResults: 20)
            let publishers = Set(items.compactMap { $0.volumeInfo?.publisher })
            let sources = publishers.map { createSourceFromPublisher($0) }.sorted { $0.name < $1.name }
            return NewsSourceCategory(name: categoryName, sources: sources)
        } catch {
            let errorMessage: String
            if let apiError = error as? APIError { errorMessage = apiError.localizedDescription }
            else { errorMessage = error.localizedDescription }
            categoryErrors[categoryName] = errorMessage
            return nil
        }
    }
}

struct NewsShowcaseCardView: View {
    let showcase: NewsShowcaseSource
    @State private var isFollowed: Bool = false
    var followToggleAction: (Bool) -> Void = { _ in print("Showcase Follow Toggled") }
    var optionsAction: () -> Void = { print("Showcase Options Tapped") }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: showcase.source.logoName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(height: 18)
                Text(showcase.source.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
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
            VStack(spacing: 0) {
                ForEach(showcase.articles.prefix(3).indices, id: \.self) { index in
                    ShowcaseArticleRowView(article: showcase.articles[index])
//                        .padding(.horizontal, 12)
                    if index < showcase.articles.prefix(3).count - 1 {
                        Divider().padding(.leading, 12)
                    }
                }
            }
            HStack {
                Text("SHOWCASE")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray)
                Text("· \(showcase.timeAgo)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: optionsAction) {
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
        .frame(width: 300)
    }
}
// Source Category Section Header for Newsstand
struct SourceCategorySectionHeader: View {
    let categoryName: String
    var categoryTapAction: () -> Void = { print("Category Tapped") }
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
            .buttonStyle(.plain) // Make the text tappable
            .foregroundColor(.white) // Ensure text color is white
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20) // More top padding for category sections
        .padding(.bottom, 8) // Space below header
    }
}

// Showcase Article Row for Newsstand card
struct ShowcaseArticleRowView: View {
    let article: ShowcaseArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional Topic Tag
            if let topic = article.topicTag {
                Text(topic)
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.4)) // Muted background
                    .cornerRadius(4)
                    .padding(.bottom, 6) // Space below tag
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    // Optional Context
                    if let context = article.context {
                        Text(context)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Text(article.headline)
                        .font(.subheadline)
                        .fontWeight(.regular) // Regular weight for showcase article
                        .lineLimit(3)
                }
                Spacer()
                 // Use custom image initializer
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70) // Slightly smaller image for row
                    .cornerRadius(8)
                    .clipped()
            }
        }
        .padding(.vertical, 10) // Vertical padding for the row
    }
}
// MARK: - Profile Settings

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 15) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.gray)
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.thinMaterial)
                                .background(Circle().fill(.regularMaterial))
                                .offset(x: 5, y: 5)
                                .foregroundColor(.primary)
                        }
                        VStack(alignment: .leading) {
                            Text("Your Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("your.email@example.com")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Button("Manage your Account") { }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Divider().background(Color.gray.opacity(0.5))
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "bell", text: "Notifications & shared") { }
                        actionRow(icon: "clock.arrow.circlepath", text: "My Activity") { }
                    }
                    Divider().background(Color.gray.opacity(0.5))
                    VStack(alignment: .leading, spacing: 0) {
                        actionRow(icon: "gearshape", text: "App settings") { }
                        actionRow(icon: "questionmark.circle", text: "Help & feedback") { }
                    }
                    Divider().background(Color.gray.opacity(0.5))
                    HStack {
                        Button("Privacy Policy") { }.buttonStyle(.plain)
                        Text("·").foregroundColor(.gray)
                        Button("Terms of Service") { }.buttonStyle(.plain)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .foregroundColor(.primary)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .accentColor(.blue)
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
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    private var currentTopBarTitle: String? {
        switch selectedTab {
        case 0: return nil
        case 1: return "Books"
        case 2: return "Following"
        case 3: return nil
        default: return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let title = currentTopBarTitle {
                TopBarView(title: title)
                    .background(Color.black)
            }
            ZStack(alignment: .bottom) {
                currentContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, -8)
                TabBarView(selectedTab: $selectedTab)
                    .background(Color.black).opacity(0.85)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .tint(.blue)
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
            ForYouView()
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView()
                .previewDisplayName("Main Tabs (Dark)")
                .preferredColorScheme(.dark)
            ProfileSettingsView()
                .previewDisplayName("Profile Sheet")
        }
    }
}

// @main App struct is assumed to be declared elsewhere, e.g.:
/*
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
*/
