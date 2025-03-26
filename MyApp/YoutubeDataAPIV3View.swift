//
//  YoutubeDataAPIV3View.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI
import Combine

// MARK: - Data Models (Simplified)

// Unified model for display in the UI
struct YouTubeVideo: Identifiable {
    let id: String // Video ID
    let title: String
    let description: String
    let channelTitle: String
    let thumbnailUrl: URL?
    // Add other properties as needed (e.g., view count, publish date)
}

// --- API Response Models (Matching Typical YouTube JSON) ---

struct YouTubeSearchResponse: Decodable {
    let items: [SearchResultItem]?
}

struct SearchResultItem: Decodable, Identifiable {
    let id: ResourceId
    let snippet: SearchSnippet?
}

struct ResourceId: Decodable, Hashable {
    let videoId: String?
    // kind might also be here (e.g., "youtube#video")
}

struct SearchSnippet: Decodable {
    let publishedAt: String?
    let channelId: String?
    let title: String?
    let description: String?
    let thumbnails: Thumbnails?
    let channelTitle: String?
}

struct Thumbnails: Decodable {
    let `default`: ThumbnailDetail?
    let medium: ThumbnailDetail?
    let high: ThumbnailDetail?
}

struct ThumbnailDetail: Decodable {
    let url: String?
    let width: Int?
    let height: Int?
}

// Example for video details (if fetching details by ID)
struct YouTubeVideoListResponse: Decodable {
     let items: [VideoItem]?
}

struct VideoItem: Decodable, Identifiable {
    let id: String // Video ID is top-level here
    let snippet: VideoSnippet?
    let statistics: VideoStatistics?
    // Add contentDetails, status, etc. as needed
}

struct VideoSnippet: Decodable {
    // Similar to SearchSnippet, but might have variations
    let publishedAt: String?
    let channelId: String?
    let title: String?
    let description: String?
    let thumbnails: Thumbnails?
    let channelTitle: String?
    let tags: [String]?
    let categoryId: String?
}

struct VideoStatistics: Decodable {
    let viewCount: String? // Often strings in YouTube API
    let likeCount: String?
    let dislikeCount: String? // May be deprecated/hidden
    let favoriteCount: String?
    let commentCount: String?
}


// MARK: - API Key Management

struct APIKeyManager {
    /// IMPORTANT: NEVER hardcode API keys in production code.
    /// Use secure storage (Keychain) or configuration files loaded securely.
    /// This is for demonstration purposes ONLY.
    static let apiKey = "YOUR_YOUTUBE_API_KEY_HERE" // Replace with your actual key

    static func checkKeyValidity() -> Bool {
        return apiKey != "YOUR_YOUTUBE_API_KEY_HERE" && !apiKey.isEmpty
    }
}

// MARK: - API Endpoints

enum YouTubeAPIEndpoint {
    case search(query: String, maxResults: Int = 10)
    case videoDetails(videoId: String) // Example for fetching details

    var path: String {
        switch self {
        case .search:
            return "/youtube/v3/search"
        case .videoDetails:
            return "/youtube/v3/videos"
        }
    }

    // Parameters specific to each endpoint
    var queryParameters: [URLQueryItem] {
        var params = [URLQueryItem(name: "key", value: APIKeyManager.apiKey)]

        switch self {
        case .search(let query, let maxResults):
            params.append(contentsOf: [
                URLQueryItem(name: "part", value: "snippet"), // Essential parameter
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: "video"), // Search only for videos
                URLQueryItem(name: "maxResults", value: String(maxResults))
            ])
        case .videoDetails(let videoId):
             params.append(contentsOf: [
                 URLQueryItem(name: "part", value: "snippet,statistics"), // Fetch snippet & stats
                 URLQueryItem(name: "id", value: videoId)
             ])
        }
        return params
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed(Error? = nil) // Include underlying decoding error
    case noData
    case apiKeyMissingOrInvalid
    case youtubeError(message: String) // For specific YouTube API errors
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed(let underlyingError):
            var baseMessage = "Failed to decode the API response."
            if let error = underlyingError {
                baseMessage += " Details: \(error.localizedDescription)"
            }
            return baseMessage
        case .noData:
            return "No data was returned from the API."
        case .apiKeyMissingOrInvalid:
            return "YouTube API Key is missing or invalid. Please provide a valid key."
        case .youtubeError(let message):
            return "YouTube API Error: \(message)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Service

final class YouTubeDataService: ObservableObject {
    @Published var videos: [YouTubeVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://www.googleapis.com"
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check for API Key early
        if !APIKeyManager.checkKeyValidity() {
             self.errorMessage = APIError.apiKeyMissingOrInvalid.localizedDescription
        }
    }


    // MARK: - Public API Data Fetching
    func fetchData(for endpoint: YouTubeAPIEndpoint) {
        guard APIKeyManager.checkKeyValidity() else {
            handleError(.apiKeyMissingOrInvalid)
            return
        }

        isLoading = true
        errorMessage = nil
        // Consider clearing old data depending on desired UX
        // videos = []

        makeDataRequest(endpoint: endpoint)
    }

    private func makeDataRequest(endpoint: YouTubeAPIEndpoint) {
        var components = URLComponents(string: baseURLString)
        components?.path = endpoint.path
        components?.queryItems = endpoint.queryParameters

        guard let url = components?.url else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // YouTube API Key is in query params, no special headers needed for basic GET

        print("Requesting URL: \(url.absoluteString)") // For debugging

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed("Did not receive a valid HTTP response.")
                }

                print("HTTP Status Code: \(httpResponse.statusCode)") // For debugging

                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to decode YouTube's error format
                    if let errorDetail = try? JSONDecoder().decode(YouTubeErrorResponse.self, from: data) {
                         throw APIError.youtubeError(message: errorDetail.error.message ?? "Unknown YouTube error")
                    }
                    // Fallback generic error message
                    throw APIError.requestFailed("Received HTTP \(httpResponse.statusCode)")
                }
                return data
            }
            .decode(type: endpoint.expectedResponseType, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main) // Switch to main thread for UI updates
            .sink { [weak self] completionResult in
                self?.isLoading = false
                switch completionResult {
                case .finished:
                    print("API request finished successfully.")
                    break // Success is handled in receiveValue
                case .failure(let error):
                    // Handle decoding errors specifically
                    if let decodingError = error as? DecodingError {
                         self?.handleError(APIError.decodingFailed(decodingError))
                    } else {
                         let apiError = (error as? APIError) ?? APIError.unknown(error)
                         self?.handleError(apiError)
                    }
                }
            } receiveValue: { [weak self] decodedResponse in
                 // Process the successfully decoded response
                 self?.processApiResponse(decodedResponse, for: endpoint)
            }
            .store(in: &cancellables)
    }

     // Helper to determine response type for decoding
     private func determineResponseType(for endpoint: YouTubeAPIEndpoint) -> Decodable.Type {
        switch endpoint {
        case .search:
            return YouTubeSearchResponse.self
        case .videoDetails:
             return YouTubeVideoListResponse.self // Assuming details endpoint returns this
        }
    }
    
    // Added helper to process API Response
     private func processApiResponse(_ response: Decodable, for endpoint: YouTubeAPIEndpoint) {
         switch endpoint {
         case .search:
             guard let searchResponse = response as? YouTubeSearchResponse else {
                 handleError(APIError.decodingFailed())
                 return
             }
             // Map SearchResultItem to YouTubeVideo
             self.videos = searchResponse.items?.compactMap { item in
                 guard let videoId = item.id.videoId, let snippet = item.snippet else { return nil }
                 return YouTubeVideo(
                     id: videoId,
                     title: snippet.title ?? "No Title",
                     description: snippet.description ?? "",
                     channelTitle: snippet.channelTitle ?? "No Channel",
                      thumbnailUrl: URL(string: snippet.thumbnails?.medium?.url ?? snippet.thumbnails?.default?.url ?? "")
                 )
             } ?? []

         case .videoDetails:
             guard let videoResponse = response as? YouTubeVideoListResponse else {
                 handleError(APIError.decodingFailed())
                 return
             }
             // This example just overwrites the list with the details of one video,
             // Adjust based on actual UX needs (e.g., updating an existing item)
             self.videos = videoResponse.items?.compactMap { item in
                  guard let snippet = item.snippet else { return nil }
                 // You might want to merge this with existing search results or display separately
                 return YouTubeVideo(
                     id: item.id, // Video ID is top-level here
                     title: snippet.title ?? "No Title",
                     description: snippet.description ?? "",
                     channelTitle: snippet.channelTitle ?? "No Channel",
                     thumbnailUrl: URL(string: snippet.thumbnails?.medium?.url ?? snippet.thumbnails?.default?.url ?? "")
                     // Could add statistics here too
                 )
             } ?? []
         }
          if self.videos.isEmpty {
             // If mapping results in empty array but no error occurred during request/decoding
             // it might mean the API returned empty results. Avoid setting an error message here.
             print("API returned successfully but yielded no processable video items.")
         }
     }


    // MARK: - Error Handling
    private func handleError(_ error: APIError) {
        DispatchQueue.main.async { // Ensure UI updates happen on the main thread
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("API Error: \(error.localizedDescription)") // Log for debugging
        }
    }
    
     // MARK: - Clear Local Data
     func clearLocalData() {
         self.videos.removeAll()
         self.errorMessage = nil // Also clear any error message
         self.isLoading = false // Ensure loading indicator is off
     }
}


// Helper struct for decoding YouTube API error responses
struct YouTubeErrorResponse: Decodable {
    let error: YouTubeErrorDetail
}

struct YouTubeErrorDetail: Decodable {
    let code: Int?
    let message: String?
    let errors: [YouTubeErrorReason]?
}

struct YouTubeErrorReason: Decodable {
    let message: String?
    let domain: String?
    let reason: String?
}

// Extension on the Endpoint enum to help with decoding
extension YouTubeAPIEndpoint {
    var expectedResponseType: Decodable.Type {
        switch self {
        case .search:
            return YouTubeSearchResponse.self
        case .videoDetails:
            return YouTubeVideoListResponse.self // Specify the correct response type
        }
    }
}


// MARK: - SwiftUI Views

struct YoutubeDataAPIV3View: View {
    @StateObject private var dataService = YouTubeDataService()
    @State private var searchQuery: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search YouTube", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true) // Optional: disable autocorrect for search
                    Button {
                       performSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .disabled(searchQuery.trimmingCharacters(in: .whitespaces).isEmpty || dataService.isLoading) // Disable if empty or loading
                }
                .padding(.horizontal)

                // Results / Loading / Error View
                if dataService.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if let errorMessage = dataService.errorMessage {
                     Spacer()
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                         Button("Clear Data") {
                              dataService.clearLocalData()
                          }
                          .buttonStyle(.bordered)
                     }
                    Spacer()

                } else if dataService.videos.isEmpty {
                     Spacer()
                     Text("No videos found. Try a different search.")
                         .foregroundColor(.secondary)
                     Spacer()
                }
                else {
                    // Display video list
                    List(dataService.videos) { video in
                        VideoRow(video: video)
                             // Add NavigationLink if implementing detail view
                             // .onTapGesture {
                             //     // Fetch details for video.id or navigate
                             //     dataService.fetchData(for: .videoDetails(videoId: video.id))
                             // }
                    }
                    .listStyle(PlainListStyle()) // Optional: Different list style
                }
                 // Add a Clear button outside the conditional logic if needed always
                 // Button("Clear Results") { dataService.clearLocalData() }.padding()
            }
            .navigationTitle("YouTube Search")
            // Add Toolbar item for clearing data if desired
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Clear", role: .destructive) {
                          dataService.clearLocalData()
                     }
                     .disabled(dataService.videos.isEmpty && dataService.errorMessage == nil) // Disable if nothing to clear
                 }
             }
        }
         // Display initial API key check message if needed
          .onAppear {
              if !APIKeyManager.checkKeyValidity() {
                  // Optionally reinforce the API key error message on appear
                  // dataService.handleError(.apiKeyMissingOrInvalid)
              }
          }
    }
    
     private func performSearch() {
         let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespaces)
         if !trimmedQuery.isEmpty {
             dataService.fetchData(for: .search(query: trimmedQuery))
             // Hide keyboard (optional)
             UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
         }
     }

}

// Simple Row View for the List
struct VideoRow: View {
    let video: YouTubeVideo

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Use AsyncImage for loading thumbnails
            AsyncImage(url: video.thumbnailUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                         .frame(width: 120, height: 67.5) // Standard 16:9 aspect ratio placeholder
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(width: 120, height: 67.5) // Match placeholder size
                         .clipped() // Crop if needed
                         .cornerRadius(4)
                case .failure:
                    Image(systemName: "video.slash.fill") // Placeholder on failure
                         .foregroundColor(.secondary)
                         .frame(width: 120, height: 67.5)
                         .background(Color.gray.opacity(0.1))
                         .cornerRadius(4)
                @unknown default:
                    EmptyView()
                }
            }
             .frame(width: 120, height: 67.5) // Consistent frame size

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2) // Limit title lines
                Text(video.channelTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3) // Limit description lines
            }
            Spacer() // Pushes content to the left
        }
        .padding(.vertical, 4) // Add some vertical padding to rows
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        YoutubeDataAPIV3View()
    }
}
