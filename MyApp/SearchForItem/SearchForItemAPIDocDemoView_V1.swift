////
////  Untitled.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//
//import SwiftUI
//import Foundation // Needed for URL
//
//// MARK: - Spotify Search Response Wrapper
//struct SpotifySearchResponse: Codable, Hashable {
//    let albums: Albums
//}
//
//// MARK: - Albums Container
//struct Albums: Codable, Hashable {
//    let href: String
//    let limit: Int
//    let next: String? // Optional because it can be null
//    let offset: Int
//    let previous: String? // Optional because it can be null
//    let total: Int
//    let items: [AlbumItem]
//}
//
//// MARK: - Album Item
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String // Use Spotify's ID as the identifiable ID
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String // Often the same as album_type
//    let uri: String
//    let artists: [Artist]
//
//    // Helper to get the best image URL (e.g., largest or medium)
//    var bestImageURL: URL? {
//        // Prioritize 300px or 640px image, fall back to the first one
//        if let urlString = images.first(where: { $0.width == 300 || $0.width == 640 })?.url {
//            return URL(string: urlString)
//        } else if let urlString = images.first?.url {
//            return URL(string: urlString)
//        }
//        return nil
//    }
//
//    // Helper to format artist names
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// MARK: - Artist
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls
//    let href: String
//    let name: String
//    let type: String
//    let uri: String
//}
//
//// MARK: - Image
//struct SpotifyImage: Codable, Hashable {
//    let height: Int? // Sometimes height/width might be null? Make optional just in case.
//    let url: String
//    let width: Int?
//}
//
//// MARK: - External URLs
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String
//}
//
//
//// MARK: - Sample Data Provider
//struct SampleData {
//    static let albumsResponse: SpotifySearchResponse? = {
//        let jsonString = """
//        {
//          "albums": {
//            "href": "https://api.spotify.com/v1/search?offset=0&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
//            "limit": 20,
//            "next": "https://api.spotify.com/v1/search?offset=20&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
//            "offset": 0,
//            "previous": null,
//            "total": 800,
//            "items": [
//              {
//                "album_type": "album",
//                "total_tracks": 6,
//                "available_markets": [],
//                "external_urls": { "spotify": "https://open.spotify.com/album/6KJgxZYve2dbchVjw3MxBQ" },
//                "href": "https://api.spotify.com/v1/albums/6KJgxZYve2dbchVjw3MxBQ",
//                "id": "6KJgxZYve2dbchVjw3MxBQ",
//                "images": [
//                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273528f5d5bc76597cd876e3cb2", "width": 640 },
//                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02528f5d5bc76597cd876e3cb2", "width": 300 },
//                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851528f5d5bc76597cd876e3cb2", "width": 64 }
//                ],
//                "name": "Steamin' [Rudy Van Gelder edition]",
//                "release_date": "1961",
//                "release_date_precision": "year",
//                "type": "album",
//                "uri": "spotify:album:6KJgxZYve2dbchVjw3MxBQ",
//                "artists": [
//                  { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" }
//                ]
//              },
//              {
//                "album_type": "compilation",
//                "total_tracks": 11,
//                "available_markets": [],
//                "external_urls": { "spotify": "https://open.spotify.com/album/5SaMVD3JhB3JU9A66Xwj0E" },
//                "href": "https://api.spotify.com/v1/albums/5SaMVD3JhB3JU9A66Xwj0E",
//                "id": "5SaMVD3JhB3JU9A66Xwj0E",
//                "images": [
//                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273f50bf8084da59379dd7f968e", "width": 640 },
//                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02f50bf8084da59379dd7f968e", "width": 300 },
//                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851f50bf8084da59379dd7f968e", "width": 64 }
//                ],
//                "name": "20th Century Masters: The Millennium Collection: Best Of The '80s",
//                "release_date": "2000-08-08",
//                "release_date_precision": "day",
//                "type": "album",
//                "uri": "spotify:album:5SaMVD3JhB3JU9A66Xwj0E",
//                "artists": [
//                  { "external_urls": { "spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of" }, "href": "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of", "id": "0LyfQWJT6nXafLPZqxe9Of", "name": "Various Artists", "type": "artist", "uri": "spotify:artist:0LyfQWJT6nXafLPZqxe9Of" }
//                ]
//              },
//              {
//                 "album_type": "album",
//                 "total_tracks": 21,
//                 "available_markets": [],
//                 "external_urls": { "spotify": "https://open.spotify.com/album/4sb0eMpDn3upAFfyi4q2rw" },
//                 "href": "https://api.spotify.com/v1/albums/4sb0eMpDn3upAFfyi4q2rw",
//                 "id": "4sb0eMpDn3upAFfyi4q2rw",
//                 "images": [
//                   { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2730ebc17239b6b18ba88cfb8ca", "width": 640 },
//                   { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e020ebc17239b6b18ba88cfb8ca", "width": 300 },
//                   { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048510ebc17239b6b18ba88cfb8ca", "width": 64 }
//                 ],
//                 "name": "Kind Of Blue (Legacy Edition)",
//                 "release_date": "1959-08-17",
//                 "release_date_precision": "day",
//                 "type": "album",
//                 "uri": "spotify:album:4sb0eMpDn3upAFfyi4q2rw",
//                 "artists": [
//                   { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" }
//                 ]
//               }
//            ]
//          }
//        }
//        """
//        guard let data = jsonString.data(using: .utf8) else { return nil }
//        let decoder = JSONDecoder()
//        return try? decoder.decode(SpotifySearchResponse.self, from: data)
//    }()
//
//    static let sampleAlbumItems: [AlbumItem] = albumsResponse?.albums.items ?? []
//    static let firstAlbum: AlbumItem? = sampleAlbumItems.first // For previewing detail view
//}
//
//import SwiftUI
//
//// MARK: - Main View displaying the list of albums
//struct SpotifyAlbumListView: View {
//    // In a real app, this would be @StateObject or @ObservedObject VM
//    @State private var albums: [AlbumItem] = SampleData.sampleAlbumItems
//    @State private var searchInfo: Albums? = SampleData.albumsResponse?.albums
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // Display Search Metadata (Optional)
//                if let info = searchInfo {
//                    SearchMetadataHeader(
//                        totalResults: info.total,
//                        limit: info.limit,
//                        offset: info.offset
//                    )
//                    .padding(.horizontal)
//                }
//
//                // List of Albums
//                List(albums) { album in
//                    AlbumRow(album: album)
//                        // Optional: Add navigation later
//                        // NavigationLink(destination: AlbumDetailView(album: album)) {
//                        //     AlbumRow(album: album)
//                        // }
//                }
//                .listStyle(PlainListStyle()) // Use plain style for less inset
//            }
//            .navigationTitle("Album Results")
//        }
//    }
//}
//
//// MARK: - Header View for Search Metadata
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("Total: \(totalResults)")
//            Spacer()
//             Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//        }
//        .font(.caption)
//        .foregroundColor(.secondary)
//        .padding(.vertical, 4)
//    }
//}
//
//// MARK: - View for a single row in the album list
//struct AlbumRow: View {
//    let album: AlbumItem
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 15) {
//            // Album Cover Image
//            AlbumImageView(url: album.bestImageURL)
//                .frame(width: 60, height: 60) // Fixed size for consistency
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//                 .shadow(radius: 2)
//
//            // Album Details
//            VStack(alignment: .leading, spacing: 4) {
//                Text(album.name)
//                    .font(.headline)
//                    .lineLimit(2) // Allow up to 2 lines for album name
//
//                Text(album.formattedArtists)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//
//                HStack {
//                     Text(album.album_type.capitalized)
//                         .font(.caption2)
//                         .padding(.horizontal, 5)
//                         .padding(.vertical, 2)
//                         .background(Color.gray.opacity(0.2))
//                         .clipShape(Capsule())
//
//                     Text("Released: \(formattedReleaseDate(album: album))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//
//                    Spacer() // Push date to the right if needed within HStack context
//
//                }
//
//                 Text("\(album.total_tracks) Tracks")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//
//            }
//            Spacer() // Pushes content to the left
//        }
//        .padding(.vertical, 5) // Add some padding between rows
//    }
//
//    // Helper to format release date based on precision
//    private func formattedReleaseDate(album: AlbumItem) -> String {
//        switch album.release_date_precision {
//        case "year":
//            return album.release_date
//        case "month":
//            // Attempt to format YYYY-MM
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM"
//            if let date = formatter.date(from: album.release_date) {
//                formatter.dateFormat = "MMM yyyy"
//                return formatter.string(from: date)
//            }
//            return album.release_date // Fallback
//        case "day":
//             // Attempt to format YYYY-MM-DD
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//             if let date = formatter.date(from: album.release_date) {
//                formatter.dateFormat = "MMM d, yyyy" // e.g., Aug 17, 1959
//                return formatter.string(from: date)
//            }
//            return album.release_date // Fallback
//        default:
//            return album.release_date
//        }
//    }
//}
//
//// MARK: - Reusable View for Loading Album Images Asynchronously
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        Group {
//            if let url = url {
//                // Use AsyncImage for network images (iOS 15+)
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView() // Show loading indicator
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    case .failure:
//                        Image(systemName: "photo.fill") // Placeholder for error
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(.secondary)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                Image(systemName: "music.note.list") // Placeholder if no URL
//                     .resizable()
//                     .aspectRatio(contentMode: .fit)
//                     .foregroundColor(.secondary)
//                     .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//        .background(Color.secondary.opacity(0.1)) // Subtle background
//    }
//}
//
//// MARK: - Preview Provider
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//    }
//}
////
////// Example Usage (Typically in your App struct)
////@main
//// struct YourApp: App {
////     var body: some Scene {
////         WindowGroup {
////             SpotifyAlbumListView()
////         }
////     }
//// }
