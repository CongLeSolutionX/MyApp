////
////  SynthwaveView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//import Foundation // Needed for URL
//
//// MARK: - Data Models (Reusing from previous response)
//// ... (Paste the SpotifySearchResponse, Albums, AlbumItem, Artist, SpotifyImage, ExternalUrls structs here) ...
//// MARK: - Spotify Search Response Wrapper
//struct SpotifySearchResponse: Codable, Hashable {
//    let albums: Albums
//}
//
//// MARK: - Albums Container
//struct Albums: Codable, Hashable {
//    let href: String
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//    let items: [AlbumItem]
//}
//
//// MARK: - Album Item
//struct AlbumItem: Codable, Identifiable, Hashable {
//    let id: String
//    let album_type: String
//    let total_tracks: Int
//    let available_markets: [String]
//    let external_urls: ExternalUrls
//    let href: String
//    let images: [SpotifyImage]
//    let name: String
//    let release_date: String
//    let release_date_precision: String
//    let type: String
//    let uri: String
//    let artists: [Artist]
//
//    var bestImageURL: URL? {
//        images.first(where: { $0.width == 640 })?.url.flatMap(URL.init) ??
//        images.first(where: { $0.width == 300 })?.url.flatMap(URL.init) ??
//        images.first?.url.flatMap(URL.init)
//    }
//
//     var listImageURL: URL? {
//         images.first(where: { $0.width == 300 })?.url.flatMap(URL.init) ??
//         images.first(where: { $0.width == 64 })?.url.flatMap(URL.init) ??
//         images.first?.url.flatMap(URL.init)
//    }
//
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    // Basic year extraction for card display
//    var releaseYear: String {
//        guard release_date_precision == "day" || release_date_precision == "month" || release_date_precision == "year" else {
//            return release_date // return original if format unknown
//        }
//        return String(release_date.prefix(4)) // Take first 4 chars for year
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
//    let height: Int?
//    let url: String
//    let width: Int?
//}
//
//// MARK: - External URLs
//struct ExternalUrls: Codable, Hashable {
//    let spotify: String
//}
//
//// MARK: - Sample Data Provider (Reusing from previous response)
//// ... (Paste the SampleData struct here) ...
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
//              // Add more items if needed for testing scrolling
//            ]
//          }
//        }
//        """
//        guard let data = jsonString.data(using: .utf8) else { return nil }
//        let decoder = JSONDecoder()
//        //decoder.keyDecodingStrategy = .convertFromSnakeCase // If needed, but keys match here
//        return try? decoder.decode(SpotifySearchResponse.self, from: data)
//    }()
//
//    static let sampleAlbumItems: [AlbumItem] = albumsResponse?.albums.items ?? []
//}
//
//// MARK: - Synthwave Color Palette
//extension Color {
//    static let synthBackground = Color(hex: "#1A0A2B") // Deep purple/blue
//    static let synthCardBackground = Color(hex: "#2A1B3D") // Slightly lighter purple
//    static let synthNeonPink = Color(hex: "#F92A82")   // Bright Pink
//    static let synthNeonCyan = Color(hex: "#00FFFF")    // Bright Cyan
//    static let synthLightPink = Color(hex: "#FF8AC3")   // Lighter pink for secondary text
//    static let synthSubtleCyan = Color(hex: "#7FFFD4")   // Softer cyan for accents/progress
//}
//
//// Helper to initialize Color from hex string
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0) // Default black
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: - List View using Cards
//struct SpotifyAlbumListView: View {
//    @State private var albums: [AlbumItem] = SampleData.sampleAlbumItems
//    @State private var searchInfo: Albums? = SampleData.albumsResponse?.albums
//
//    let columns = [GridItem(.flexible())] // Define 1 column for a vertical list feel
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                // Optionally display search metadata header here if needed
//                if let info = searchInfo {
//                     SearchMetadataHeader(totalResults: info.total, limit: info.limit, offset: info.offset)
//                        .padding(.horizontal)
//                        .padding(.bottom, 5)
//                }
//
//                // Use LazyVGrid for card layout
//                LazyVGrid(columns: columns, spacing: 20) { // Spacing between cards
//                    ForEach(albums) { album in
//                        AlbumCardView(album: album)
//                    }
//                }
//                .padding(.horizontal) // Padding for the grid itself
//                .padding(.top)
//            }
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [.synthBackground, .black]), // Dark gradient
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea() // Extend gradient behind safe areas
//            )
//            .navigationTitle("Synthwave Albums")
//            .navigationBarTitleDisplayMode(.large) // Or .inline
//            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure nav bar text is light
//
//        }
//        // Apply dark color scheme for status bar etc. if desired
//        .preferredColorScheme(.dark)
//
//    }
//}
//
//// MARK: - Reusable View for Loading Album Images Asynchronously (Reuse from previous)
//// ... (Paste the AlbumImageView struct here) ...
//struct AlbumImageView: View {
//    let url: URL?
//
//    var body: some View {
//        Group {
//            if let url = url {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                             .frame(maxWidth: .infinity, maxHeight: .infinity)
//                             .background(Color.synthCardBackground.opacity(0.5)) // Use synth color
//                    case .success(let image):
//                        image.resizable().scaledToFit()
//                    case .failure:
//                        Image(systemName: "photo.fill") // Placeholder for error
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(Color.synthLightPink.opacity(0.6)) // Use synth color
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.synthCardBackground.opacity(0.5))
//                    @unknown default:
//                        Image(systemName: "questionmark.diamond.fill")
//                             .resizable()
//                             .scaledToFit()
//                             .foregroundColor(Color.synthLightPink.opacity(0.6)) // Use synth color
//                             .frame(maxWidth: .infinity, maxHeight: .infinity)
//                             .background(Color.synthCardBackground.opacity(0.5))
//                    }
//                }
//            } else {
//                Image(systemName: "music.note.list") // Placeholder if no URL
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(Color.synthLightPink.opacity(0.6)) // Use synth color
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.synthCardBackground.opacity(0.5))
//            }
//        }
//    }
//}
//
//// MARK: - Synthwave Album Card View
//struct AlbumCardView: View {
//    let album: AlbumItem
//    @State private var isPlaying: Bool = false // Placeholder state
//    @State private var progress: Double = 0.3 // Placeholder progress
//    @State private var isTapped: Bool = false // For tap animation
//
//    var body: some View {
//        ZStack {
//            // Card Background
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.synthCardBackground)
//                // .fill(.ultraThinMaterial) // Alternative glassy background
//
//            // Content VStack
//            VStack(spacing: 0) { // Reduce spacing
//                // Album Image
//                AlbumImageView(url: album.listImageURL) // Use listImageURL for potentially smaller size
//                    .aspectRatio(1, contentMode: .fit) // Keep it square
//                    // Apply corner radius *only* to top corners if desired
//                    .clipShape(RoundedRectangleCorner(radius: 15, corners: [.topLeft, .topRight]))
//
//                // Info Section with Padding
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(album.name)
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundColor(.synthNeonPink)
//                            .lineLimit(1)
//
//                        Text(album.formattedArtists)
//                            .font(.subheadline)
//                            .foregroundColor(.synthLightPink)
//                            .lineLimit(1)
//                    }
//                    Spacer()
//                    Text(album.releaseYear) // Use extracted year
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.synthNeonCyan)
//                        .padding(.leading, 5)
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//               // .background(Color.synthCardBackground.opacity(0.6)) // Subtle background dim
//
//                // Divider (Optional)
//               // Rectangle()
//               //     .frame(height: 1)
//               //     .foregroundColor(Color.synthNeonPink.opacity(0.3))
//               //     .padding(.horizontal, 12)
//
//                // Player Controls Section
//                HStack {
//                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                        .foregroundColor(.synthNeonCyan)
//                        .imageScale(.large)
//                        .frame(width: 40, height: 40) // Make tap target larger
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            isPlaying.toggle() // Toggle placeholder state
//                        }
//
//                    // Progress Bar Placeholder
//                    GeometryReader { geometry in
//                         ZStack(alignment: .leading) {
//                             Capsule() // Background track
//                                 .fill(Color.synthNeonPink.opacity(0.3))
//                                 .frame(height: 6)
//                             Capsule() // Progress fill
//                                 .fill(Color.synthNeonCyan)
//                                 .frame(width: geometry.size.width * CGFloat(progress), height: 6) // Use placeholder progress
//                         }
//                         .clipShape(Capsule()) // Ensure the ZStack respects the capsule shape
//                    }
//                    .frame(height: 6) // Constrain height of GeometryReader
//                    .padding(.horizontal, 5)
//
//                    Image(systemName: "ellipsis") // Options or Like icon placeholder
//                         .foregroundColor(.synthNeonPink)
//                         .imageScale(.medium)
//                         .frame(width: 40, height: 40)
//                         .contentShape(Rectangle()) // Make tap target larger
//                         .onTapGesture {
//                              // Action for options
//                         }
//                }
//                .padding(.horizontal, 12)
//                .padding(.bottom, 10) // Add padding below controls
//               // .background(Color.synthCardBackground.opacity(0.6)) // Subtle background dim
//            } // End Content VStack
//
//            // Neon Border Overlay
//            RoundedRectangle(cornerRadius: 15)
//                .stroke(Color.synthNeonCyan.opacity(0.7), lineWidth: 1.5) // Neon border
//
//        } // End ZStack
//        .compositingGroup() // Improves shadow rendering performance
//        .shadow(color: .synthNeonPink.opacity(0.5), radius: 8, x: 0, y: 4) // Neon Glow effect
//        .scaleEffect(isTapped ? 0.98 : 1.0) // Scale down slightly on tap
//        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)
//        .onTapGesture {
//            // Handle card tap - e.g., navigate, play, expand
//            isTapped = true
//            // Reset after a short delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                isTapped = false
//                // Add navigation or play logic here if needed
//            }
//        }
//    }
//}
//
//// MARK: - Header View (Reuse from previous)
//struct SearchMetadataHeader: View {
//    let totalResults: Int
//    let limit: Int
//    let offset: Int
//
//    var body: some View {
//        HStack {
//            Text("Total: \(totalResults)")
//            Spacer()
//            Text("Showing \(offset + 1)-\(min(offset + limit, totalResults))")
//        }
//        .font(.caption)
//        .foregroundColor(Color.synthLightPink.opacity(0.8)) // Use synth color
//        .padding(.top, 8)
//    }
//}
//
//// Helper for applying corner radius to specific corners
//struct RoundedRectangleCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - Preview Providers
//struct SpotifyAlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyAlbumListView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//    }
//}
//
//struct AlbumCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        if let firstAlbum = SampleData.sampleAlbumItems.first {
//             AlbumCardView(album: firstAlbum)
//                .padding(50) // Add padding around the single card
//                .background(Color.synthBackground) // Show against dark background
//                .previewLayout(.sizeThatFits)
//                .preferredColorScheme(.dark)
//        } else {
//             Text("No sample data")
//        }
//    }
//}
