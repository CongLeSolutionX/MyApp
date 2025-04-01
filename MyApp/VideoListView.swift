//
//  VideoListView.swift
//  MyApp
//
//  Created by Cong Le on 3/31/25.
//

import Foundation
import SwiftUI // Included for the example usage view

// --- 1. Data Models (Codable Structs) ---
// These structs mirror the JSON structure returned by the YouTube Data API v3 videos.list endpoint.

struct VideoListResponse: Codable {
    let kind: String?
    let etag: String?
    let items: [VideoItem]
    let pageInfo: PageInfo?
}

struct VideoItem: Codable, Identifiable { // Identifiable is useful for SwiftUI lists
    let kind: String?
    let etag: String?
    let id: String // The Video ID
    let snippet: VideoSnippet?          // Included if 'snippet' is in 'part'
    let contentDetails: VideoContentDetails? // Included if 'contentDetails' is in 'part'
    // Add other parts like 'statistics', 'status' if needed and requested
}

struct VideoSnippet: Codable {
    let publishedAt: String // Consider using DateFormatter if needed: "yyyy-MM-dd'T'HH:mm:ssZ"
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnails
    let channelTitle: String
    let tags: [String]? // Optional field
    let categoryId: String?
    // Add other snippet fields if needed
}

struct Thumbnails: Codable {
    // Using backticks because 'default' is a reserved keyword
    let `default`: ThumbnailDetail?
    let medium: ThumbnailDetail?
    let high: ThumbnailDetail?
    let standard: ThumbnailDetail?
    let maxres: ThumbnailDetail?
}

struct ThumbnailDetail: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct VideoContentDetails: Codable {
    // Duration is in ISO 8601 format (e.g., "PT2M34S")
    // Parsing this requires a helper function (not included)
    let duration: String
    let dimension: String? // e.g., "2d", "3d"
    let definition: String? // e.g., "hd", "sd"
    let caption: String? // "true" or "false"
    let licensedContent: Bool?
    // Add other contentDetails fields if needed
}

struct PageInfo: Codable {
    let totalResults: Int?
    let resultsPerPage: Int?
}

// --- 2. Custom Error Type ---

enum YouTubeError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case apiKeyMissing
    case unknown(Error?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API endpoint URL is invalid."
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Received an invalid response from the server (Status code: \(statusCode))."
        case .decodingError(let error):
            // Provide more specific decoding error info if possible
            if let decodingError = error as? DecodingError {
                 return "Failed to decode JSON response: \(decodingError.localizedDescription) - \(detailedDecodingError(decodingError))"
            }
            return "Failed to decode JSON response: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "YouTube API Key is missing. Please provide a valid key."
        case .unknown(let error):
             return "An unknown error occurred: \(error?.localizedDescription ?? "No details available")"
        }
    }

     // Helper to get more details from DecodingError
     private func detailedDecodingError(_ error: DecodingError) -> String {
         switch error {
         case .typeMismatch(let type, let context):
             return "Type mismatch for type \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
         case .valueNotFound(let type, let context):
             return "Value not found for type \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
         case .keyNotFound(let key, let context):
             return "Key not found: \(key.stringValue) at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
         case .dataCorrupted(let context):
             return "Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)"
         @unknown default:
             return "An unknown decoding error occurred."
         }
     }
}

// --- 3. API Service Class ---

class YouTubeDataService {

    private let apiKey: String? // Should be loaded securely!
    private let baseURL = "https://www.googleapis.com/youtube/v3/videos"

    init(apiKey: String? = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"]) {
        // Example: Try to load from environment variable first
        // In a real app, use a more robust configuration management system
        self.apiKey = apiKey
         if apiKey == nil || apiKey?.isEmpty == true {
             print("⚠️ WARNING: YouTube API Key not found. Please set the YOUTUBE_API_KEY environment variable or pass it during initialization.")
         }
    }

    /// Fetches details for one or more YouTube videos.
    /// - Parameters:
    ///   - videoIds: An array of YouTube video IDs.
    ///   - parts: An array of strings specifying the resource parts to include (e.g., "snippet", "contentDetails").
    /// - Returns: An array of `VideoItem` objects containing the requested details.
    /// - Throws: A `YouTubeError` if the request fails or the response is invalid.
    func fetchVideoDetails(videoIds: [String], parts: [String] = ["snippet", "contentDetails"]) async throws -> [VideoItem] {

        guard let key = apiKey, !key.isEmpty else {
            throw YouTubeError.apiKeyMissing
        }

        guard !videoIds.isEmpty else {
            print("Info: No video IDs provided.")
            return [] // Return empty array if no IDs are given
        }

        guard var components = URLComponents(string: baseURL) else {
            throw YouTubeError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "part", value: parts.joined(separator: ",")),
            URLQueryItem(name: "id", value: videoIds.joined(separator: ",")),
            URLQueryItem(name: "key", value: key)
        ]

        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }

        print("Fetching YouTube Video Details from URL: \(url.absoluteString)") // For debugging

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30 // Set a reasonable timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw YouTubeError.unknown(nil) // Should ideally get an HTTPURLResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                 print("Error: Received status code \(httpResponse.statusCode)")
                 if let errorDataString = String(data: data, encoding: .utf8) {
                     print("Error Data: \(errorDataString)") // Print error body from YouTube API if possible
                 }
                 throw YouTubeError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                let videoResponse = try decoder.decode(VideoListResponse.self, from: data)
                return videoResponse.items
            } catch {
                 print("Decoding Error Details: \(error)")
                 if let decodingError = error as? DecodingError {
                        print(YouTubeError.decodingError(decodingError).localizedDescription) // Print detailed decoding error
                  }
                 throw YouTubeError.decodingError(error)
            }

        } catch let error as URLError {
            // Handle specific URL errors (timeout, no internet, etc.)
            throw YouTubeError.networkError(error)
        } catch let error as YouTubeError {
            // Re-throw specific YouTubeErrors we've already identified
            throw error
        } catch {
            // Catch any other unexpected errors
             throw YouTubeError.unknown(error)
        }
    }
}


// --- 4. Example Usage (SwiftUI View) ---

struct VideoListView: View {
    // IMPORTANT: Replace with your actual API Key loading mechanism
    // For testing you could temporarily hardcode, but REMOVE before committing/sharing
    // let service = YouTubeDataService(apiKey: "YOUR_ACTUAL_API_KEY_HERE")
    // --- OR --- (Better) Set Environment Variable YOUTUBE_API_KEY in Xcode scheme
     let service = YouTubeDataService() // Will try to load from environment

    @State private var videoItems: [VideoItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    // Example video IDs
    let videoIdsToFetch = ["M7lc1UVf-VE", "dQw4w9WgXcQ", "invalidID"]

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Video Details...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(videoItems) { item in
                        VideoRow(item: item)
                    }
                    .listStyle(.plain)
                }

                Spacer() // Push content up
            }
            .navigationTitle("YouTube Video Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        fetchVideos()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .task { // Use .task for automatic loading on appear
                 fetchVideos()
            }
        }
    }

    func fetchVideos() {
        // Prevent multiple simultaneous fetches
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        videoItems = [] // Clear previous results

        Task {
            do {
                // Request both snippet and content details
                let items = try await service.fetchVideoDetails(
                    videoIds: videoIdsToFetch,
                    parts: ["snippet", "contentDetails"]
                )
                self.videoItems = items
                if items.isEmpty && !videoIdsToFetch.isEmpty {
                     print("Info: API returned no items for the given IDs.")
                     // You might want errorMessage = "No video details found." here
                }
            } catch {
                 if let ytError = error as? YouTubeError {
                      self.errorMessage = ytError.localizedDescription
                 } else {
                      self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                 }
                print("Error fetching video details: \(error)")
            }
            isLoading = false
        }
    }
}

// Simple Row View to display video info
struct VideoRow: View {
    let item: VideoItem

    var body: some View {
        HStack(alignment: .top) {
            // AsyncImage requires iOS 15+
            if #available(iOS 15.0, *), let thumbnailUrl = item.snippet?.thumbnails.default?.url {
                AsyncImage(url: URL(string: thumbnailUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: CGFloat(item.snippet?.thumbnails.default?.width ?? Int(120.0)) ,
                       height: CGFloat(item.snippet?.thumbnails.default?.height ?? Int(90.0)))
                .clipped() // Clip if image is larger than frame
                 .cornerRadius(4)
            } else if (item.snippet?.thumbnails.default?.url) != nil {
                 // Fallback for older iOS (You'd need a custom image loader)
                 Rectangle()
                     .fill(.gray.opacity(0.3))
                     .frame(width: 120, height: 90)
                      .cornerRadius(4)
                     .overlay(Text("Image Load\nFailed").font(.caption2).multilineTextAlignment(.center))

            }


            VStack(alignment: .leading) {
                Text(item.snippet?.title ?? "No Title")
                    .font(.headline)
                    .lineLimit(2) // Limit title lines

                Text(item.snippet?.channelTitle ?? "No Channel")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Display duration (requires parsing ISO 8601 string - placeholder here)
                if let durationString = item.contentDetails?.duration {
                    Text("Duration: \(durationString)") // Placeholder
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text("ID: \(item.id)")
                     .font(.caption)
                     .foregroundColor(.gray)
            }
            Spacer() // Push content to the left
        }
        .padding(.vertical, 4)
    }
}

//// --- 5. App Entry Point (Example) ---
//// You would integrate `VideoListView` into your existing app structure.
//
//// @main // Uncomment if this is your main app file
//struct YouTubeAPITestApp: App {
//      var body: some Scene {
//        WindowGroup {
//             VideoListView()
//        }
//    }
//}
#Preview("Video List View") {
    VideoListView()
}
