////
////  RetroView.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//import SwiftUI
//
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
//// MARK: - Album Item
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]?
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String // "album"
//    let uri: String
//    let artists: [Artist]
//
//    // --- Helper computed properties (Unchanged) ---
//    var bestImageURL: URL? {
//        images.first { $0.width == 640 }?.urlObject ??
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var listImageURL: URL? {
//        images.first { $0.width == 300 }?.urlObject ??
//        images.first { $0.width == 64 }?.urlObject ??
//        images.first?.urlObject
//    }
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//    func formattedReleaseDate() -> String {
//        let dateFormatter = DateFormatter()
//        switch release_date_precision {
//        case "year":
//            dateFormatter.dateFormat = "yyyy"
//            if let date = dateFormatter.date(from: release_date) {
//                return dateFormatter.string(from: date)
//            }
//        case "month":
//            dateFormatter.dateFormat = "yyyy-MM"
//            if let date = dateFormatter.date(from: release_date) {
//                dateFormatter.dateFormat = "MMM yyyy"
//                return dateFormatter.string(from: date)
//            }
//        case "day":
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            if let date = dateFormatter.date(from: release_date) {
//                return date.formatted(date: .long, time: .omitted)
//            }
//        default: break
//        }
//        return release_date
//    }
//}
//
//// MARK: - Image
//struct SpotifyImage: Codable, Hashable {
//    let height: Int?
//    let url: String
//    let width: Int?
//
//    var urlObject: URL? { URL(string: url) }
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
//// MARK: - Data Models (already defined and unchanged)
//
//let retroGradients: [Color] = [
//  Color(red: 0.25, green: 0.12, blue: 0.4), // Deep purple
//  Color(red: 0.95, green: 0.29, blue: 0.56), // Neon pinkish
//  Color(red: 0.18, green: 0.5, blue: 0.96)    // Neon blue
//]
//
//extension View {
//  func neonGlow(_ color: Color, radius: CGFloat = 8) -> some View {
//    self
//      .shadow(color: color.opacity(0.75), radius: radius, x: 0, y: 0)
//      .shadow(color: color.opacity(0.5), radius: radius * 2, x: 0, y: 0)
//      .shadow(color: color.opacity(0.25), radius: radius * 3, x: 0, y: 0)
//  }
//}
//
//
//struct RetroAlbumCard: View {
//    let album: AlbumItem
//    
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            // Background Gradient
//            LinearGradient(
//                colors: retroGradients,
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .cornerRadius(18)
//            .neonGlow(.cyan)
//            
//            VStack(alignment: .leading, spacing: 12) {
//                
//                // Album Cover Image
//                AsyncImage(url: album.listImageURL) { phase in
//                    switch phase {
//                        case .success(let image):
//                            image.resizable()
//                                 .scaledToFit()
//                                 .cornerRadius(12)
//                                 .neonGlow(.pink, radius: 4)
//                        case .failure, .empty:
//                            Image(systemName: "music.note")
//                                .resizable()
//                                .scaledToFit()
//                                .opacity(0.3)
//                        @unknown default:
//                            EmptyView()
//                    }
//                }
//                .frame(maxHeight: 120)
//                
//                // Album Title
//                Text(album.name)
//                    .font(.title3.monospaced())
//                    .foregroundColor(.white)
//                    .bold()
//                
//                // Artist name
//                Text("🎙 \(album.formattedArtists)")
//                    .font(.subheadline.monospaced())
//                    .foregroundColor(.white.opacity(0.9))
//                
//                // Release date & track count
//                HStack {
//                    Text("📅 \(album.formattedReleaseDate())")
//                    Spacer()
//                    Text("🎶 \(album.total_tracks) tracks")
//                }
//                .font(.caption.monospaced().bold())
//                .foregroundColor(.white.opacity(0.8))
//                
//                Spacer().frame(height:8)
//            }
//            .padding()
//        }
//        .frame(height: 260)
//        .padding(.horizontal)
//    }
//}
//// MARK: - Album Detail (Basic Implementation)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//
//    var body: some View {
//        ScrollView {
//            RetroAlbumCard(album: album)
//                .padding(.top)
//
//            VStack(alignment: .leading, spacing: 16) {
//                Text("Artists")
//                    .font(.title2.bold())
//                HStack {
//                    ForEach(album.artists, id: \.id) { artist in
//                        Text(artist.name)
//                            .padding(8)
//                            .background(Capsule().fill(.thinMaterial))
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(album.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color.black)
//    }
//}
//
//struct RetroFuturisticMusicPlayerView: View {
//    let albums: [AlbumItem] = SampleData.sampleAlbumItems
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(albums) { album in
//                        NavigationLink(destination: AlbumDetailView(album: album)) {
//                            RetroAlbumCard(album: album)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("Retro-Futuristic Music")
//            .background(Color.black.edgesIgnoringSafeArea(.all))
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//#Preview("RetroFuturisticMusicPlayerView") {
//    RetroFuturisticMusicPlayerView()
//}
