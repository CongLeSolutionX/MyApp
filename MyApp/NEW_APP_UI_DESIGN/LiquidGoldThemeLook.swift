////
////  LiquidGoldThemeLook.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// Strategy: Liquid Gold Style Modifier
//extension View {
//    func liquidGoldCard() -> some View {
//        self
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.85), Color.yellow.opacity(0.7)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//            )
//            .cornerRadius(15)
//            .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
//    }
//}
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
//// MARK: - LiquidGold Music Player Main View
//struct LiquidGoldMusicPlayerView: View {
//    @State private var albums: [AlbumItem] = SampleData.sampleAlbumItems
//    @State private var selectedAlbum: AlbumItem?
//    @Namespace private var animation
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
//                    ForEach(albums) { album in
//                        AlbumCard(album: album, animation: animation)
//                            .onTapGesture {
//                                selectedAlbum = album
//                            }
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Golden Hits")
//            .overlay {
//                if let album = selectedAlbum {
//                    AlbumDetailOverlay(album: album, selectedAlbum: $selectedAlbum, animation: animation)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Album Card Individual Views
//struct AlbumCard: View {
//    let album: AlbumItem
//    var animation: Namespace.ID
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            AsyncImage(url: album.listImageURL) { image in
//                image.resizable().scaledToFill()
//            } placeholder: {
//                Rectangle().fill(Color.yellow.opacity(0.6))
//            }
//            .matchedGeometryEffect(id: "albumArt\(album.id)", in: animation)
//            .frame(height: 140)
//            .clipped()
//            .cornerRadius(8)
//            
//            Text(album.name)
//                .font(.headline)
//                .matchedGeometryEffect(id: "albumName\(album.id)", in: animation)
//                .lineLimit(1)
//                .foregroundStyle(.primary)
//            
//            Text(album.formattedArtists)
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .lineLimit(1)
//        }
//        .padding()
//        .liquidGoldCard()
//    }
//}
//
//// MARK: - Animated Detail Overlay with Liquid Gold Player
//struct AlbumDetailOverlay: View {
//    let album: AlbumItem
//    @Binding var selectedAlbum: AlbumItem?
//    var animation: Namespace.ID
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            AsyncImage(url: album.bestImageURL) { image in
//                image.resizable().scaledToFill()
//            } placeholder: {
//                Rectangle().fill(Color.yellow.opacity(0.7))
//            }
//            .matchedGeometryEffect(id: "albumArt\(album.id)", in: animation)
//            .frame(width: 250, height: 250)
//            .clipped()
//            .cornerRadius(20)
//            .shadow(radius: 8)
//            
//            Text(album.name)
//                .font(.title)
//                .fontWeight(.bold)
//                .matchedGeometryEffect(id: "albumName\(album.id)", in: animation)
//                .foregroundColor(.white)
//                .padding(.horizontal)
//                .multilineTextAlignment(.center)
//            
//            Text(album.formattedArtists)
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.8))
//            
//            // Liquid Gold Play Button
//            Button(action: {
//                // Future music playback integration here
//            }) {
//                HStack {
//                    Image(systemName: "play.fill")
//                        .foregroundColor(.white)
//                    Text("Play Album")
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical, 12)
//                .padding(.horizontal, 25)
//                .background(Capsule().fill(LinearGradient(colors: [Color.orange, Color.yellow], startPoint: .top, endPoint: .bottom)))
//            }
//            .shadow(radius: 5)
//            .padding(.top,20)
//            
//            Spacer()
//            
//            Button(action: { selectedAlbum = nil }) {
//                Circle()
//                    .fill(.white.opacity(0.2))
//                    .overlay(
//                        Image(systemName: "xmark")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                    )
//                    .frame(width: 40, height: 40)
//            }
//            .padding(.bottom,50)
//        }
//        .padding(.top, 50)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .liquidGoldCard()
//        .background(Color.black.opacity(0.75).ignoresSafeArea())
//        .transition(.opacity.animation(.easeInOut))
//    }
//}
//
//// MARK: - Preview
//struct LiquidGoldMusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LiquidGoldMusicPlayerView()
//            .preferredColorScheme(.dark) // Emphasize luxury look
//    }
//}
