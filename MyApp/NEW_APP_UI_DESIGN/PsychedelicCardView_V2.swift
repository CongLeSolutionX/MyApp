////
////  PsychedelicCardView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//import UIKit
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
//    
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
//// MARK: - Data Models (already defined and unchanged)
//
//// MARK: - Optimized AlbumCard View
//struct AlbumCard: View {
//    let album: AlbumItem
//    @State private var animateGradient = false
//    
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            ZStack {
//                AsyncImage(url: album.bestImageURL) { phase in
//                    switch phase {
//                    case .success(let image):
//                        image.resizable().scaledToFill()
//                    default:
//                        PlaceholderGradient()
//                    }
//                }
//                .overlay(animatedGradient)
//                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                .frame(height: 350)
//                .shadow(radius: 8)
//                
//                PsychedelicWave()
//                    .opacity(0.3)
//                    .blendMode(.overlay)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//            }
//            
//            albumInfoStack
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .onAppear {
//            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
//                animateGradient.toggle()
//            }
//        }
//    }
//    
//    private var albumInfoStack: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(album.name)
//                .font(.custom("Bodoni 72 Oldstyle", size: 20))
//                .bold()
//                .foregroundStyle(.white)
//                .lineLimit(1)
//                .shadow(radius: 2)
//            
//            Text(album.formattedArtists)
//                .font(.subheadline)
//                .foregroundStyle(.white.opacity(0.85))
//                .lineLimit(1)
//            
//            HStack(spacing: 4) {
//                Text(album.formattedReleaseDate())
//                Text("• \(album.total_tracks) tracks")
//            }
//            .font(.caption)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(.thinMaterial)
//            .clipShape(Capsule())
//            
//            if let spotifyURL = URL(string: album.external_urls.spotify) {
//                Button(action: {
//                    UIApplication.shared.open(spotifyURL)
//                }) {
//                    Label("Play on Spotify", systemImage: "play.fill")
//                        .font(.caption.bold())
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 6)
//                        .background(Color.green.opacity(0.85))
//                        .clipShape(Capsule())
//                }
//            }
//        }
//        .padding()
//    }
//    
//    private var animatedGradient: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [.pink, .purple, .blue, .green, .yellow, .orange]),
//            startPoint: animateGradient ? .bottomLeading : .topTrailing,
//            endPoint: animateGradient ? .topTrailing : .bottomLeading
//        )
//        .opacity(0.2)
//        .blendMode(.overlay)
//        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)
//    }
//}
//
//// MARK: - Placeholder Gradient View
//struct PlaceholderGradient: View {
//    var body: some View {
//        Rectangle()
//            .foregroundStyle(
//                LinearGradient(colors: [.purple, .blue],
//                               startPoint: .topLeading,
//                               endPoint: .bottomTrailing)
//            )
//    }
//}
//
//// MARK: - Wave Animated Background
//struct PsychedelicWave: View {
//    @State private var animate = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            WaveShape(phase: animate ? .pi * 2 : 0, amplitude: 20)
//                .fill(
//                    LinearGradient(colors: [.orange, .pink, .purple, .blue], startPoint: .top, endPoint: .bottom)
//                )
//                .frame(width: geometry.size.width, height: geometry.size.height)
//                .offset(y: animate ? -10 : 10)
//                .animation(.linear(duration: 5).repeatForever(autoreverses: true), value: animate)
//        }
//        .onAppear { animate.toggle() }
//    }
//}
//
//struct WaveShape: Shape {
//    var phase: CGFloat
//    var amplitude: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        path.move(to: CGPoint(x: 0, y: rect.midY))
//        
//        for x in stride(from: 0, through: rect.width, by: 10) {
//            let scaledX = (x / rect.width) * (.pi * 2)
//            let normalizedY = sin(scaledX + phase)
//            let y = normalizedY * amplitude + rect.midY
//            path.addLine(to: CGPoint(x: x, y: y))
//        }
//        
//        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
//        path.addLine(to: CGPoint(x: 0, y: rect.height))
//        path.closeSubpath()
//        return path
//    }
//}
//
//// MARK: - Main Album List View
//struct PsychedelicMusicPlayerView: View {
//    let albums: [AlbumItem] = SampleData.sampleAlbumItems
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(albums) { album in
//                        NavigationLink(destination: AlbumDetailView(album: album)) {
//                            AlbumCard(album: album)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("Psychedelic Music")
//            .background(Color.black.edgesIgnoringSafeArea(.all))
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Album Detail (Basic Implementation)
//struct AlbumDetailView: View {
//    let album: AlbumItem
//    
//    var body: some View {
//        ScrollView {
//            AlbumCard(album: album)
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
//// MARK: - Preview Providers
//#Preview {
//    PsychedelicMusicPlayerView()
//}
