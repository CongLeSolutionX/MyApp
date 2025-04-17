//
//  SynthwaveView.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI
import UIKit
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
        if let urlString = images.first(where: { $0.width == 300 || $0.width == 640 })?.url {
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
    
    func formattedReleaseDate() -> String {
        let dateFormatter = DateFormatter()
        switch release_date_precision {
        case "year":
            dateFormatter.dateFormat = "yyyy"
            if let date = dateFormatter.date(from: release_date) {
                return dateFormatter.string(from: date)
            }
        case "month":
            dateFormatter.dateFormat = "yyyy-MM"
            if let date = dateFormatter.date(from: release_date) {
                dateFormatter.dateFormat = "MMM yyyy"
                return dateFormatter.string(from: date)
            }
        case "day":
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: release_date) {
                return date.formatted(date: .long, time: .omitted)
            }
        default: break
        }
        return release_date
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
        let jsonString = """
        {
          "albums": {
            "href": "https://api.spotify.com/v1/search?offset=0&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
            "limit": 20,
            "next": "https://api.spotify.com/v1/search?offset=20&limit=20&query=remaster%2520track%3ADoxy%2520artist%3AMiles%2520Davis&type=album&include_external=audio&locale=en-US,en;q%3D0.9,vi;q%3D0.8,ko;q%3D0.7,ja;q%3D0.6",
            "offset": 0,
            "previous": null,
            "total": 800,
            "items": [
              {
                "album_type": "album",
                "total_tracks": 6,
                "available_markets": [],
                "external_urls": { "spotify": "https://open.spotify.com/album/6KJgxZYve2dbchVjw3MxBQ" },
                "href": "https://api.spotify.com/v1/albums/6KJgxZYve2dbchVjw3MxBQ",
                "id": "6KJgxZYve2dbchVjw3MxBQ",
                "images": [
                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273528f5d5bc76597cd876e3cb2", "width": 640 },
                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02528f5d5bc76597cd876e3cb2", "width": 300 },
                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851528f5d5bc76597cd876e3cb2", "width": 64 }
                ],
                "name": "Steamin' [Rudy Van Gelder edition]",
                "release_date": "1961",
                "release_date_precision": "year",
                "type": "album",
                "uri": "spotify:album:6KJgxZYve2dbchVjw3MxBQ",
                "artists": [
                  { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" }
                ]
              },
              {
                "album_type": "compilation",
                "total_tracks": 11,
                "available_markets": [],
                "external_urls": { "spotify": "https://open.spotify.com/album/5SaMVD3JhB3JU9A66Xwj0E" },
                "href": "https://api.spotify.com/v1/albums/5SaMVD3JhB3JU9A66Xwj0E",
                "id": "5SaMVD3JhB3JU9A66Xwj0E",
                "images": [
                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273f50bf8084da59379dd7f968e", "width": 640 },
                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02f50bf8084da59379dd7f968e", "width": 300 },
                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851f50bf8084da59379dd7f968e", "width": 64 }
                ],
                "name": "20th Century Masters: The Millennium Collection: Best Of The '80s",
                "release_date": "2000-08-08",
                "release_date_precision": "day",
                "type": "album",
                "uri": "spotify:album:5SaMVD3JhB3JU9A66Xwj0E",
                "artists": [
                  { "external_urls": { "spotify": "https://open.spotify.com/artist/0LyfQWJT6nXafLPZqxe9Of" }, "href": "https://api.spotify.com/v1/artists/0LyfQWJT6nXafLPZqxe9Of", "id": "0LyfQWJT6nXafLPZqxe9Of", "name": "Various Artists", "type": "artist", "uri": "spotify:artist:0LyfQWJT6nXafLPZqxe9Of" }
                ]
              },
              {
                 "album_type": "album",
                 "total_tracks": 21,
                 "available_markets": [],
                 "external_urls": { "spotify": "https://open.spotify.com/album/4sb0eMpDn3upAFfyi4q2rw" },
                 "href": "https://api.spotify.com/v1/albums/4sb0eMpDn3upAFfyi4q2rw",
                 "id": "4sb0eMpDn3upAFfyi4q2rw",
                 "images": [
                   { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2730ebc17239b6b18ba88cfb8ca", "width": 640 },
                   { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e020ebc17239b6b18ba88cfb8ca", "width": 300 },
                   { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048510ebc17239b6b18ba88cfb8ca", "width": 64 }
                 ],
                 "name": "Kind Of Blue (Legacy Edition)",
                 "release_date": "1959-08-17",
                 "release_date_precision": "day",
                 "type": "album",
                 "uri": "spotify:album:4sb0eMpDn3upAFfyi4q2rw",
                 "artists": [
                   { "external_urls": { "spotify": "https://open.spotify.com/artist/0kbYTNQb4Pb1rPbbaF0pT4" }, "href": "https://api.spotify.com/v1/artists/0kbYTNQb4Pb1rPbbaF0pT4", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "spotify:artist:0kbYTNQb4Pb1rPbbaF0pT4" }
                 ]
               }
            ]
          }
        }
        """
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(SpotifySearchResponse.self, from: data)
    }()

    static let sampleAlbumItems: [AlbumItem] = albumsResponse?.albums.items ?? []
    static let firstAlbum: AlbumItem? = sampleAlbumItems.first // For previewing detail view
}
//struct SpotifyAlbumSynthWaveUI: View {
//    let albums: [AlbumItem] = SampleData.sampleAlbumItems // Use your actual parsed data here
//    
//    var body: some View {
//        ZStack {
//            SynthWaveBackground() // Synth-Wave styled background
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    Text("SynthWave Jazz")
//                        .font(.system(size: 34, weight: .heavy, design: .monospaced))
//                        .foregroundStyle(LinearGradient(
//                            colors: [.pink, .purple, .cyan],
//                            startPoint: .leading,
//                            endPoint: .trailing))
//                        .shadow(color: .pink, radius: 5, x: 0, y: 0)
//                        .padding()
//                    
//                    ForEach(albums) { album in
//                        AlbumCard(album: album)
//                    }
//                }.padding()
//            }
//        }
//    }
//}
//
//// MARK: Synth-Wave Aesthetic Background
//struct SynthWaveBackground: View {
//    var body: some View {
//        LinearGradient(
//            colors: [Color.black, Color.purple.opacity(0.9), Color.black],
//            startPoint: .top,
//            endPoint: .bottom)
//        .ignoresSafeArea()
//        .overlay(
//            GeometryReader { geo in
//                VStack(spacing: geo.size.height/15) {
//                    ForEach(0..<16) { _ in
//                        Rectangle()
//                            .fill(Color.cyan.opacity(0.05))
//                            .frame(height: 1)
//                    }
//                }
//            }
//        )
//    }
//}
//
//// MARK: Card-Based Album UI Component
//struct AlbumCard: View {
//    let album: AlbumItem
//    @Environment(\.openURL) var openURL
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(LinearGradient(
//                    colors: [Color.purple.opacity(0.6), Color.black],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(LinearGradient(
//                            colors: [.cyan, .purple],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing),
//                        lineWidth: 2)
//                )
//                .shadow(color: .purple.opacity(0.7), radius: 10, x: 5, y: 5)
//            
//            VStack(alignment: .leading) {
//                AsyncImage(url: album.bestImageURL) { phase in
//                    if let image = phase.image {
//                        image.resizable()
//                             .scaledToFit()
//                             .clipShape(RoundedRectangle(cornerRadius: 10))
//                             .shadow(radius: 10)
//                    } else if phase.error != nil {
//                        Color.black.opacity(0.2)
//                    } else {
//                        ProgressView()
//                    }
//                }.frame(height: 200)
//                
//                Text(album.name)
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding(.top, 6)
//                    .shadow(radius: 2)
//                
//                Text(album.formattedArtists)
//                    .font(.subheadline)
//                    .foregroundColor(.cyan)
//                    .shadow(radius: 2)
//                
//                HStack {
//                    SynthWavePlayButton(url: album.external_urls.spotify)
//                    Spacer()
//                    Text(album.formattedReleaseDate())
//                        .font(.footnote)
//                        .foregroundColor(.white.opacity(0.7))
//                }
//                .padding(.top, 6)
//                
//            }.padding()
//        }
//        .padding(.horizontal, 10)
//    }
//}
//
//// MARK: SynthWave Neon-Styled Play Button
//struct SynthWavePlayButton: View {
//    let url: String
//    @Environment(\.openURL) var openURL
//    
//    var body: some View {
//        Button(action: {
//            if let spotifyURL = URL(string: url) {
//                openURL(spotifyURL)
//            }
//        }) {
//            HStack {
//                Image(systemName: "play.fill")
//                    .font(.headline)
//                Text("Play Now")
//                    .font(.system(size: 12, weight: .bold))
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(LinearGradient(
//                colors: [.pink, .purple, .cyan],
//                startPoint: .leading,
//                endPoint: .trailing))
//            .foregroundColor(.black)
//            .clipShape(Capsule())
//            .shadow(color: .cyan.opacity(0.7), radius: 5, x: 0, y: 0)
//        }
//    }
//}
//
//#if DEBUG //Preview for SwiftUI Canvas
//struct SpotifyAlbumSynthWaveUI_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumSynthWaveUI()
//    }
//}
//#endif
