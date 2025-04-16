//
//  SearchForItemAPIDocDemoView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI
// Combine is not strictly needed for this URLSession implementation,
// but might be kept for potential future uses.
// import Combine

// MARK: - Data Models (Mirroring the JSON Structure - Unchanged)

// MARK: - Spotify Search Response Wrapper
struct SpotifySearchResponse: Codable, Hashable {
    let albums: Albums
}

// MARK: - Albums Container
struct Albums: Codable, Hashable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [AlbumItem]
}

// MARK: - Album Item
struct AlbumItem: Codable, Identifiable, Hashable {
    let id: String
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]? // Make optional as it might not always be present or relevant
    let external_urls: ExternalUrls
    let href: String
    let images: [SpotifyImage]
    let name: String
    let release_date: String
    let release_date_precision: String
    let type: String
    let uri: String
    let artists: [Artist]

    // Helper to get the best image URL (e.g., largest or medium) - Unchanged
    var bestImageURL: URL? {
        if let urlString = images.first(where: { $0.width == 640 })?.url {
             return URL(string: urlString)
        } else if let urlString = images.first(where: { $0.width == 300 })?.url {
            return URL(string: urlString)
        } else if let urlString = images.first?.url {
             return URL(string: urlString)
        }
        return nil
    }

    // Helper for smaller image in list - Unchanged
    var listImageURL: URL? {
         if let urlString = images.first(where: { $0.width == 300 })?.url {
            return URL(string: urlString)
        } else if let urlString = images.first(where: { $0.width == 64 })?.url {
             return URL(string: urlString)
        } else if let urlString = images.first?.url {
             return URL(string: urlString)
        }
        return nil
    }

    // Helper to format artist names - Unchanged
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    // Helper to format release date based on precision - Unchanged
    func formattedReleaseDate() -> String {
        // Using specific date formatters for robustness
        let dateFormatter = DateFormatter()
        switch release_date_precision {
        case "year":
            dateFormatter.dateFormat = "yyyy"
            if let date = dateFormatter.date(from: release_date) {
                return dateFormatter.string(from: date) // Just the year
            }
        case "month":
            dateFormatter.dateFormat = "yyyy-MM"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "MMM yyyy" // e.g., Nov 1957
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
             if let date = dateFormatter.date(from: release_date) {
                return date.formatted(date: .long, time: .omitted) // e.g., August 17, 1959
            }
        default:
            // Fallback if precision is unknown or format doesn't match attentes
             break // Fall through to return original string
        }
        return release_date // Sensible fallback
    }
}

// MARK: - Artist - Unchanged
struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls
    let href: String
    let name: String
    let type: String
    let uri: String
}

// MARK: - Image - Unchanged
struct SpotifyImage: Codable, Hashable {
    let height: Int?
    let url: String
    let width: Int?
}

// MARK: - External URLs - Unchanged
struct ExternalUrls: Codable, Hashable {
    let spotify: String
}

// MARK: - API Service Helper

// !!! --- CRITICAL SECURITY WARNING --- !!!
// Replace this placeholder with a securely obtained token via OAuth 2.0 flow.
// DO NOT ship an app with a hardcoded token.
let placeholderSpotifyToken = "YOUR_SPOTIFY_BEARER_TOKEN_HERE" // <--- Replace with your actual token for testing ONLY

enum SpotifyAPIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int) // Includes HTTP status code
    case decodingError(Error)
    case invalidToken // Specific error for token issues

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API endpoint URL was invalid."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let statusCode): return "Received an invalid server response (Status Code: \(statusCode))."
        case .decodingError(let error): return "Failed to decode the server response: \(error.localizedDescription)"
        case .invalidToken: return "Invalid or expired Spotify API token."
        }
    }
}

struct SpotifyAPIService {
    static let shared = SpotifyAPIService()
    private let baseURL = "https://api.spotify.com/v1/search"

    func searchAlbums(query: String, limit: Int = 20) async throws -> SpotifySearchResponse {
        // 1. Validate Token (Basic Check)
        guard !placeholderSpotifyToken.isEmpty, placeholderSpotifyToken != "YOUR_SPOTIFY_BEARER_TOKEN_HERE" else {
            print("❌ Error: Spotify Bearer Token is missing or is the placeholder value.")
            throw SpotifyAPIError.invalidToken
        }

        // 2. Construct URL Safely
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query), // Automatically handles encoding
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "include_external", value: "audio"),
            URLQueryItem(name: "limit", value: String(limit))
            // Add offset here for pagination if needed later
        ]

        guard let url = components?.url else {
            print("❌ Error: Could not create valid URL.")
            throw SpotifyAPIError.invalidURL
        }

        // 3. Create URLRequest with Authentication Header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(placeholderSpotifyToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15 // Set a reasonable timeout

        print("🚀 Making API Request to: \(url.absoluteString)") // Debugging

        // 4. Perform Network Request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 5. Validate HTTP Response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpotifyAPIError.invalidResponse(0) // Or a custom code
            }

            print("🚦 HTTP Status Code: \(httpResponse.statusCode)") // Debugging

            guard (200...299).contains(httpResponse.statusCode) else {
                // Handle specific auth errors if possible
                if httpResponse.statusCode == 401 {
                    throw SpotifyAPIError.invalidToken
                }
                 // Provide more detailed error from response body if possible
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("❌ Server Error Body: \(responseBody)")
                }
                throw SpotifyAPIError.invalidResponse(httpResponse.statusCode)
            }

            // 6. Decode JSON Response
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SpotifySearchResponse.self, from: data)
                print("✅ Successfully decoded \(searchResponse.albums.items.count) albums.")
                return searchResponse
            } catch {
                print("❌ Error: Failed to decode JSON.")
                 if let jsonString = String(data: data, encoding: .utf8) {
                     print("📄 Received JSON String: \(jsonString)") // Log the raw JSON on failure
                 }
                throw SpotifyAPIError.decodingError(error)
            }
        } catch let error where !(error is CancellationError) { // Don't treat cancellation as a network error
             print("❌ Error: Network request failed - \(error)")
            // More specific error handling could be added here
            if let urlError = error as? URLError {
                // Handle specific URLErrors like .notConnectedToInternet
                throw SpotifyAPIError.networkError(urlError)
            }
            // Re-throw other errors or wrap them
            throw error is SpotifyAPIError ? error : SpotifyAPIError.networkError(error)
        }
    }
}

// MARK: - SwiftUI Views

// MARK: - Main List View with Search
struct SpotifyAlbumListView: View {
    @State private var searchQuery: String = ""
    @State private var displayedAlbums: [AlbumItem] = [] // Start empty, filled by search
    @State private var isLoading: Bool = false
    @State private var searchInfo: Albums? = nil // Store the whole Albums metadata block
    @State private var currentError: SpotifyAPIError? = nil // Hold potential API errors

    var body: some View {
        NavigationView {
            ZStack { // ZStack for overlaying loading/error messages
                // Main content: List or placeholder text
                if !searchQuery.isEmpty && displayedAlbums.isEmpty && !isLoading && currentError == nil {
                    // Specific "No Results" state ONLY when search yields nothing
                    Text("No results found for \"\(searchQuery)\"")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchQuery.isEmpty && displayedAlbums.isEmpty && !isLoading && currentError == nil {
                    // Initial state before searching
                    Text("Enter a search term above to find albums.")
                        .foregroundColor(.secondary)
                         .multilineTextAlignment(.center)
                         .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                     // Display the list if there are albums
                    List {
                        // Optional: Display header with search metadata if available
                        if let info = searchInfo, !displayedAlbums.isEmpty {
                            SearchMetadataHeader(
                                totalResults: info.total,
                                limit: info.limit,
                                offset: info.offset
                            )
                            .listRowSeparator(.hidden) // Hide separator for header
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 16))
                         }

                        ForEach(displayedAlbums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                AlbumRow(album: album)
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                // Overlays for loading and errors
                 VStack { // Use VStack to potentially show error message below spinner
                    if isLoading {
                         ProgressView("Searching...")
                             .padding()
                             .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                             .shadow(radius: 5)
                             .transition(.opacity) // Smooth appearance
                    }

                    if let error = currentError {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .padding(.top , isLoading ? 10 : 0) // Add space below spinner if loading
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                     }
                    Spacer() // Push loading/error to the center top area
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 50) // Adjust padding as needed

            }
            .navigationTitle("Spotify Search")
            // --- Search Functionality ---
            .searchable(text: $searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search Albums or Artists")
            // --- Debounced Search Task ---
            .task(id: searchQuery) { // This task automatically cancels and restarts when searchQuery changes
                await performDebouncedSearch()
            }

        }
    }

    // --- Async function to perform the debounced search with REAL API call ---
    private func performDebouncedSearch() async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        // If the query becomes empty, clear results and stop loading/error
        guard !trimmedQuery.isEmpty else {
            displayedAlbums = []
            isLoading = false
            currentError = nil
            searchInfo = nil
            return
        }

        // --- Standard Debounce (Wait before triggering) ---
        do {
            // Wait for 800 milliseconds (slightly longer for network requests)
            try await Task.sleep(nanoseconds: 800_000_000)
        } catch {
            // Handle cancellation if the task is cancelled (user types quickly)
            print("Search task cancelled.")
            return // Exit if cancelled before debounce finishes
        }

        // --- Start API Request ---
        isLoading = true
        currentError = nil // Clear previous errors

        do {
            // Call the actual API service
            let response = try await SpotifyAPIService.shared.searchAlbums(query: trimmedQuery)
            // Update UI on the main thread (task implicitly does this after await)
            displayedAlbums = response.albums.items
            searchInfo = response.albums // Store pagination/total info
            print("API Search successful for '\(trimmedQuery)', found \(response.albums.total) total albums.")
        } catch let apiError as SpotifyAPIError {
            print("❌ API Error: \(apiError.localizedDescription)")
            displayedAlbums = [] // Clear results on error
            searchInfo = nil
            currentError = apiError // Display the error
        } catch {
            // Catch any other unexpected errors
             print("❌ Unexpected Error: \(error.localizedDescription)")
            displayedAlbums = []
            searchInfo = nil
            currentError = .networkError(error) // Wrap unknown errors
        }

        // --- Stop Loading ---
        isLoading = false
    }
}

// MARK: - Header View for Search Metadata (Unchanged)
struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
            Text("Total Results: \(totalResults)")
            Spacer()
            // Display page info only if limit > 0
            if limit > 0 {
               Text("Displaying \(offset + 1)-\(min(offset + limit, totalResults))")
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}

// MARK: - View for a single row in the album list (Unchanged)
struct AlbumRow: View {
    let album: AlbumItem

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AlbumImageView(url: album.listImageURL)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(album.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(album.formattedArtists)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                     Text(album.album_type.capitalized)
                         .font(.caption)
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
                         .background(Color.gray.opacity(0.15))
                         .clipShape(Capsule())

                     Text("• \(album.formattedReleaseDate())")
                        .font(.caption)
                        .foregroundColor(.gray)
                     Spacer()
                }
                .padding(.top, 1)

                Text("\(album.total_tracks) Tracks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

// MARK: - Album Detail View (Unchanged)
struct AlbumDetailView: View {
    let album: AlbumItem
    @Environment(\.openURL) var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AlbumImageView(url: album.bestImageURL)
                    .aspectRatio(1, contentMode: .fit) // Changed to fit for larger image
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal) // Add padding around the image

                VStack(alignment: .center, spacing: 4) { // Centered text below image
                    Text(album.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Text(album.formattedArtists)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity) // Ensure centering
                .padding(.horizontal)

                Divider().padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    DetailItem(label: "Type", value: album.album_type.capitalized)
                    DetailItem(label: "Released", value: album.formattedReleaseDate())
                    DetailItem(label: "Total Tracks", value: "\(album.total_tracks)")
                    // Conditionally add available markets if needed, can be very long
                    // if let markets = album.available_markets, !markets.isEmpty {
                    //     DetailItem(label: "Markets (\(markets.count))", value: markets.prefix(10).joined(separator: ", ") + (markets.count > 10 ? "..." : ""))
                    // }
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)

                if let spotifyURL = URL(string: album.external_urls.spotify) {
                    Button { openURL(spotifyURL) } label: {
                        HStack {
                           Image(systemName: "play.circle.fill") // Standard SF Symbol
                           // Or consider using a Spotify logo if you have assets
                            Text("Open in Spotify")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green) // Spotify Green (approx)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3) // Add subtle shadow
                    }
                    .buttonStyle(.plain) // Prevent list row styling if inside a list
                    .padding(.horizontal)
                    .padding(.bottom) // Add some bottom padding
                }

                Spacer() // Pushes content up if ScrollView has extra space
            }
            .padding(.vertical) // Padding for the entire VStack content
        }
        .navigationTitle(album.name) // Use album name for detail view title
        .navigationBarTitleDisplayMode(.inline) // Keep title small in detail view
    }
}

// MARK: - DetailItem Helper View (Unchanged)
struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) { // Align top for potentially multi-line values
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading) // Fixed width for label
            Text(value)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true) // Allow value to wrap
            Spacer() // Push content to the left
        }
    }
}

// MARK: - Reusable Async Image View (Unchanged)
struct AlbumImageView: View {
    let url: URL?

    var body: some View {
        Group { // Use Group to avoid needing explicit type for conditional content
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack { // Center the progress view
                             Color.secondary.opacity(0.1) // Placeholder background
                             ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Use fill for rows, caller handles detail view fit
                    case .failure:
                         ZStack { // Center the placeholder icon
                             Color.secondary.opacity(0.1)
                             Image(systemName: "photo.fill")
                                 .resizable()
                                 .scaledToFit()
                                 .foregroundColor(.secondary.opacity(0.5))
                                 .padding(5) // Add padding around the icon
                         }
                    @unknown default:
                        ZStack {
                            Color.secondary.opacity(0.1)
                            Image(systemName: "questionmark.diamond.fill")
                                 .resizable()
                                 .scaledToFit()
                                 .foregroundColor(.secondary.opacity(0.5))
                                 .padding(5)
                        }
                    }
                }
            } else {
                 ZStack { // Placeholder if no URL
                     Color.secondary.opacity(0.1)
                     Image(systemName: "music.note.list")
                         .resizable()
                         .scaledToFit()
                         .foregroundColor(.secondary.opacity(0.5))
                         .padding(5)
                 }
            }
        }
        // Apply clipping and frame *outside* the Group/AsyncImage
    }
}

// MARK: - Preview Providers

// Preview for the main list view
struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
            .previewDisplayName("Initial/Empty")

        // --- Previews with Mock Data (for UI layout without API) ---
        // Create some mock items
        let mockArtist = Artist(id: "1", external_urls: ExternalUrls(spotify: ""), href: "", name: "Mock Artist", type: "artist", uri: "")
        let mockImage = SpotifyImage(height: 64, url: "https://via.placeholder.com/64", width: 64) // Use placeholder
        let mockItem1 = AlbumItem(id: "id1", album_type: "album", total_tracks: 10, available_markets: ["US"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Mock Album One - A Very Long Title to Test Wrapping", release_date: "2023-10-27", release_date_precision: "day", type: "album", uri: "", artists: [mockArtist])
        let mockItem2 = AlbumItem(id: "id2", album_type: "compilation", total_tracks: 5, available_markets: ["GB"], external_urls: ExternalUrls(spotify: ""), href: "", images: [mockImage], name: "Mock Compilation Two", release_date: "2022", release_date_precision: "year", type: "album", uri: "", artists: [mockArtist, mockArtist]) // Multiple artists

        SpotifyAlbumListView()
            .previewDisplayName("Initial/Empty")
//        SpotifyAlbumListView(displayedAlbums: [mockItem1, mockItem2], searchInfo: Albums(href: "", limit: 2, next: nil, offset: 0, previous: nil, total: 2, items: []))
//             .previewDisplayName("With Mock Results")

//         SpotifyAlbumListView(searchQuery: "Test", isLoading: true)
//              .previewDisplayName("Loading State")
//
//         SpotifyAlbumListView(searchQuery: "NonExistent", displayedAlbums: [])
//              .previewDisplayName("No Real Results")
//
//         SpotifyAlbumListView(currentError: .invalidToken)
//             .previewDisplayName("Error State (Token)")
//
//         SpotifyAlbumListView(isLoading: true, currentError: .networkError(URLError(.timedOut)))
//             .previewDisplayName("Loading with Error")
    }
}

// Preview for the detail view (still uses mock data is fine)
struct AlbumDetailView_Previews: PreviewProvider {
     static let mockArtist = Artist(id: "1", external_urls: ExternalUrls(spotify: "https://open.spotify.com"), href: "", name: "The Mockers", type: "artist", uri: "")
     static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640) // Use a real image URL for better preview
     static let mockAlbum = AlbumItem(id: "id1", album_type: "album", total_tracks: 12, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage, SpotifyImage(height: 300, url: "...", width: 300), SpotifyImage(height: 64, url: "...", width: 64)], name: "Preview Album Extravaganza Vol. 1", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "", artists: [mockArtist])

    static var previews: some View {
        NavigationView { // Wrap in NavigationView for realistic preview
             AlbumDetailView(album: mockAlbum)
        }
         .previewDisplayName("Detail View (Mock)")
    }
}

/*
// Example Usage (Typically in your App struct - Unchanged)
@main
struct YourApp: App {
     init() {
          // Basic check to remind about the token during development startup
          if placeholderSpotifyToken == "YOUR_SPOTIFY_BEARER_TOKEN_HERE" {
              print("⚠️ WARNING: Spotify Bearer Token is set to the placeholder. API calls will fail.")
              print("➡️ Please replace 'YOUR_SPOTIFY_BEARER_TOKEN_HERE' in the code with a valid token for testing.")
          }
     }

    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
        }
    }
}
*/
