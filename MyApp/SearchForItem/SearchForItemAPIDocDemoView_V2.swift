//
//  SearchForItemAPIDocDemoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//


import SwiftUI
import Foundation // Needed for URL

// MARK: - Data Models (Mirroring the JSON Structure)

// MARK: - Spotify Search Response Wrapper
struct SpotifySearchResponse: Codable, Hashable {
    let albums: Albums
}

// MARK: - Albums Container
struct Albums: Codable, Hashable {
    let href: String
    let limit: Int
    let next: String? // Optional because it can be null
    let offset: Int
    let previous: String? // Optional because it can be null
    let total: Int
    let items: [AlbumItem]
}

// MARK: - Album Item
struct AlbumItem: Codable, Identifiable, Hashable {
    let id: String // Use Spotify's ID as the identifiable ID
    let album_type: String
    let total_tracks: Int
    let available_markets: [String]
    let external_urls: ExternalUrls
    let href: String
    let images: [SpotifyImage]
    let name: String
    let release_date: String
    let release_date_precision: String
    let type: String // Often the same as album_type
    let uri: String
    let artists: [Artist]

    // Helper to get the best image URL (e.g., largest or medium)
    var bestImageURL: URL? {
        // Prioritize 300px or 640px image, fall back to the first one
        if let urlString = images.first(where: { $0.width == 640 })?.url { // Prefer largest for detail view
             return URL(string: urlString)
        } else if let urlString = images.first(where: { $0.width == 300 })?.url {
            return URL(string: urlString)
        } else if let urlString = images.first?.url {
            return URL(string: urlString)
        }
        return nil
    }

     // Helper for smaller image in list
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

    // Helper to format artist names
    var formattedArtists: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

     // Helper to format release date based on precision - usable in multiple views
    func formattedReleaseDate() -> String {
        switch release_date_precision {
        case "year":
            return release_date
        case "month":
            // Attempt to format YYYY-MM
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            if let date = formatter.date(from: release_date) {
                formatter.dateFormat = "MMM yyyy"
                return formatter.string(from: date)
            }
            return release_date // Fallback
        case "day":
             // Attempt to format YYYY-MM-DD
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
             if let date = formatter.date(from: release_date) {
                // Use localized date style for detail view if possible
                return date.formatted(date: .long, time: .omitted) // e.g., August 17, 1959
            }
            return release_date // Fallback
        default:
            return release_date
        }
    }
}

// MARK: - Artist
struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let external_urls: ExternalUrls
    let href: String
    let name: String
    let type: String
    let uri: String
}

// MARK: - Image
struct SpotifyImage: Codable, Hashable {
    let height: Int? // Sometimes height/width might be null? Make optional just in case.
    let url: String
    let width: Int?
}

// MARK: - External URLs
struct ExternalUrls: Codable, Hashable {
    let spotify: String
}

// MARK: - Sample Data Provider
struct SampleData {
    static let albumsResponse: SpotifySearchResponse? = {
        // Minified JSON to save space - full JSON could be loaded from a file too
        let jsonString = """
        {"albums":{"href":"https://api.spotify.com/...","limit":20,"next":"https://api.spotify.com/...","offset":0,"previous":null,"total":800,"items":[{"album_type":"album","total_tracks":6,"available_markets":[],"external_urls":{"spotify":"https://open.spotify.com/album/6KJgxZYve2dbchVjw3MxBQ"},"href":"https://api.spotify.com/v1/albums/6KJgxZYve2dbchVjw3MxBQ","id":"6KJgxZYve2dbchVjw3MxBQ","images":[{"height":640,"url":"https://i.scdn.co/image/ab67616d0000b273528f5d5bc76597cd876e3cb2","width":640},{"height":300,"url":"https://i.scdn.co/image/ab67616d00001e02528f5d5bc76597cd876e3cb2","width":300},{"height":64,"url":"https://i.scdn.co/image/ab67616d00004851528f5d5bc76597cd876e3cb2","width":64}],"name":"Steamin' [Rudy Van Gelder edition]","release_date":"1961","release_date_precision":"year","type":"album","uri":"spotify:album:6KJgxZYve2dbchVjw3MxBQ","artists":[{"external_urls":{"spotify":"https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4"},"href":"https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4","id":"0kbYTNQb4Pb1rPbbaF0pT4","name":"Miles Davis","type":"artist","uri":"spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4"}]},{"album_type":"compilation","total_tracks":11,"available_markets":[],"external_urls":{"spotify":"https://open.spotify.com/album/5SaMVD3JhB3JU9A66Xwj0E"},"href":"https://api.spotify.com/v1/albums/5SaMVD3JhB3JU9A66Xwj0E","id":"5SaMVD3JhB3JU9A66Xwj0E","images":[{"height":640,"url":"https://i.scdn.co/image/ab67616d0000b273f50bf8084da59379dd7f968e","width":640},{"height":300,"url":"https://i.scdn.co/image/ab67616d00001e02f50bf8084da59379dd7f968e","width":300},{"height":64,"url":"https://i.scdn.co/image/ab67616d00004851f50bf8084da59379dd7f968e","width":64}],"name":"20th Century Masters: The Millennium Collection: Best Of The '80s","release_date":"2000-08-08","release_date_precision":"day","type":"album","uri":"spotify:album:5SaMVD3JhB3JU9A66Xwj0E","artists":[{"external_urls":{"spotify":"https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of"},"href":"https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of","id":"0LyfQWJT6nXafLPZqxe9Of","name":"Various Artists","type":"artist","uri":"spotify:artist:0LyfQWJT6nXafLPZqxe9Of"}]},{"album_type":"album","total_tracks":21,"available_markets":[],"external_urls":{"spotify":"https://open.spotify.com/album/4sb0eMpDn3upAFfyi4q2rw"},"href":"https://api.spotify.com/v1/albums/4sb0eMpDn3upAFfyi4q2rw","id":"4sb0eMpDn3upAFfyi4q2rw","images":[{"height":640,"url":"https://i.scdn.co/image/ab67616d0000b2730ebc17239b6b18ba88cfb8ca","width":640},{"height":300,"url":"https://i.scdn.co/image/ab67616d00001e020ebc17239b6b18ba88cfb8ca","width":300},{"height":64,"url":"https://i.scdn.co/image/ab67616d000048510ebc17239b6b18ba88cfb8ca","width":64}],"name":"Kind Of Blue (Legacy Edition)","release_date":"1959-08-17","release_date_precision":"day","type":"album","uri":"spotify:album:4sb0eMpDn3upAFfyi4q2rw","artists":[{"external_urls":{"spotify":"https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4"},"href":"https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4","id":"0kbYTNQb4Pb1rPbbaF0pT4","name":"Miles Davis","type":"artist","uri":"spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4"}]}]}}}
        """
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        // Handle potential decoding errors gracefully in a real app
        return try? decoder.decode(SpotifySearchResponse.self, from: data)
    }()

    static let sampleAlbumItems: [AlbumItem] = albumsResponse?.albums.items ?? []
    static let firstAlbum: AlbumItem? = sampleAlbumItems.first // For previewing detail view
}

// MARK: - SwiftUI Views

// MARK: - Main View displaying the list of albums
struct SpotifyAlbumListView: View {
    // In a real app, this would be @StateObject or @ObservedObject VM
    @State private var albums: [AlbumItem] = SampleData.sampleAlbumItems
    @State private var searchInfo: Albums? = SampleData.albumsResponse?.albums

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) { // Use leading alignment and no spacing for header
                // Display Search Metadata (Optional)
                if let info = searchInfo {
                    SearchMetadataHeader(
                        totalResults: info.total,
                        limit: info.limit,
                        offset: info.offset
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 5) // Add slight padding below header
                }

                // List of Albums
                List { // Remove explicit data source, use ForEach inside if needed, or directly use album array if Identifiable
                    ForEach(albums) { album in
                        // Define the NavigationLink here
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumRow(album: album)
                        }
                        .listRowInsets(EdgeInsets()) // Remove default padding if desired for tighter look
                        .padding(.horizontal) // Add padding back to see divider lines
                        .padding(.vertical, 5) // Add vertical padding for spacing within the row content area
                    }
                }
                .listStyle(PlainListStyle()) // Use plain style for less inset and full-width separators
            }
            .navigationTitle("Album Results")
        }
    }
}

// MARK: - Header View for Search Metadata
struct SearchMetadataHeader: View {
    let totalResults: Int
    let limit: Int
    let offset: Int

    var body: some View {
        HStack {
            Text("Total: \(totalResults)")
            Spacer()
            Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.top, 8) // Add padding if needed, e.g., below navigation bar
    }
}

// MARK: - View for a single row in the album list
struct AlbumRow: View {
    let album: AlbumItem

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Album Cover Image (using listImageURL helper)
            AlbumImageView(url: album.listImageURL)
                .frame(width: 50, height: 50) // Slightly smaller for list view
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1) // Subtle shadow

            // Album Details
            VStack(alignment: .leading, spacing: 3) { // Reduced spacing
                Text(album.name)
                    .font(.headline)
                    .lineLimit(2) // Allow up to 2 lines for album name

                Text(album.formattedArtists)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) { // Spacing between type and date
                     Text(album.album_type.capitalized)
                         .font(.caption) // Slightly larger than caption2
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
                         .background(Color.gray.opacity(0.15)) // Slightly darker background
                         .clipShape(Capsule())

                     // Use the helper method from the AlbumItem model
                     Text("• \(album.formattedReleaseDate())")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer() // Push date to the right if needed within HStack context
                }
                .padding(.top, 1) // Add tiny space above type/date

                Text("\(album.total_tracks) Tracks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer() // Pushes content to the left
        }
        // Row padding is handled by the List/NavigationLink combination now
    }
}

// MARK: - Album Detail View
struct AlbumDetailView: View {
    let album: AlbumItem
    @Environment(\.openURL) var openURL // Environment value to open URLs

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Larger Album Cover Image
                AlbumImageView(url: album.bestImageURL)
                    .aspectRatio(1, contentMode: .fit) // Make it square
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal) // Add horizontal padding

                // Album Title and Artist
                VStack(alignment: .center, spacing: 4) {
                    Text(album.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(album.formattedArtists)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity) // Center align text block
                .padding(.horizontal)

                Divider()

                // Key Details Section
                VStack(alignment: .leading, spacing: 10) {
                    DetailItem(label: "Type", value: album.album_type.capitalized)
                    DetailItem(label: "Released", value: album.formattedReleaseDate()) // Use helper here too
                    DetailItem(label: "Total Tracks", value: "\(album.total_tracks)")
                 //   DetailItem(label: "Available Markets", value: "\(album.available_markets.count)") // Optional: Show count
                }
                .padding(.horizontal)

                Divider()

                // Spotify Link Button
                if let spotifyURL = URL(string: album.external_urls.spotify) {
                    Button {
                        openURL(spotifyURL) // Action to open the URL
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill") // Example Spotify-like icon
                            Text("Open in Spotify")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green) // Spotify green
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                }

                 // Optional: Display Available Markets (might be too long)
                /*
                 VStack(alignment: .leading) {
                    Text("Available Markets (\(album.available_markets.count))")
                        .font(.headline)
                    Text(album.available_markets.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(5) // Limit lines to avoid excessive length
                }
                .padding()
                 */

                Spacer() // Push content to top
            }
            .padding(.vertical) // Add padding to the overall VStack
        }
        .navigationTitle(album.name) // Set nav title to album name
        .navigationBarTitleDisplayMode(.inline) // Keep title smaller
    }
}

// Helper view for consistent detail item display
struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading) // Align labels
            Text(value)
                .font(.body)
            Spacer() // Push value to the left if needed
        }
    }
}

// MARK: - Reusable View for Loading Album Images Asynchronously
struct AlbumImageView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url = url {
                // Use AsyncImage for network images (iOS 15+)
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show loading indicator
                             // Make ProgressView take up the available space
                             .frame(maxWidth: .infinity, maxHeight: .infinity)
                             .background(Color.secondary.opacity(0.1))
                    case .success(let image):
                        image
                            .resizable()
                            // .aspectRatio(contentMode: .fill) // Changed in DetailView
                           // .scaledToFill() // Let the caller handle aspect ratio
                    case .failure:
                        Image(systemName: "photo.fill") // Placeholder for error
                            .resizable()
                            .scaledToFit() // Use fit for placeholders
                            .foregroundColor(.secondary.opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.secondary.opacity(0.1))

                    @unknown default:
                         // Consider showing an error icon or placeholder
                        Image(systemName: "questionmark.diamond.fill")
                             .resizable()
                             .scaledToFit()
                             .foregroundColor(.secondary.opacity(0.5))
                             .frame(maxWidth: .infinity, maxHeight: .infinity)
                             .background(Color.secondary.opacity(0.1))
                    }
                }
            } else {
                 // Placeholder if no URL
                Image(systemName: "music.note.list")
                     .resizable()
                     .scaledToFit() // Use fit for placeholders
                     .foregroundColor(.secondary.opacity(0.5))
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(Color.secondary.opacity(0.1))
            }
        }
        // Removed background color from here to apply it within specific phases if needed
    }
}

// MARK: - Preview Providers
struct SpotifyAlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyAlbumListView()
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the detail view within a NavigationView for context
        NavigationView {
            // Provide a sample album for the preview
            if let sampleAlbum = SampleData.firstAlbum {
                AlbumDetailView(album: sampleAlbum)
            } else {
                Text("No sample album data available for preview.")
            }
        }
    }
}

/*
// Example Usage (Typically in your App struct)
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            SpotifyAlbumListView()
        }
    }
}
*/
