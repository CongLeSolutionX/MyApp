////
////  LiquidGoldMusicPlayerView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import Foundation // Needed for URL
//
//// MARK: - Data Models (Mirroring the JSON Structure)
//// (Copied from the previous response - essential for the views to work)
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
//        if let urlString = images.first(where: { $0.width == 640 })?.url {
//             return URL(string: urlString)
//        } else if let urlString = images.first(where: { $0.width == 300 })?.url {
//            return URL(string: urlString)
//        } else if let urlString = images.first?.url {
//            return URL(string: urlString)
//        }
//        return nil
//    }
//
//    var listImageURL: URL? {
//         if let urlString = images.first(where: { $0.width == 300 })?.url {
//             return URL(string: urlString)
//         } else if let urlString = images.first(where: { $0.width == 64 })?.url {
//             return URL(string: urlString)
//         } else if let urlString = images.first?.url {
//             return URL(string: urlString)
//         }
//        return nil
//    }
//
//    var formattedArtists: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    func formattedReleaseDate() -> String {
//        switch release_date_precision {
//        case "year":
//            return release_date
//        case "month":
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM"
//            if let date = formatter.date(from: release_date) {
//                formatter.dateFormat = "MMM yyyy"
//                return formatter.string(from: date)
//            }
//            return release_date
//        case "day":
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//             if let date = formatter.date(from: release_date) {
//                 return date.formatted(date: .long, time: .omitted)
//             }
//            return release_date
//        default:
//            return release_date
//        }
//    }
//}
//
//// MARK: - Artist
//struct Artist: Codable, Identifiable, Hashable {
//    let id: String
//    let external_urls: ExternalUrls?
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
//// MARK: - Sample Data Provider
//// (Includes the shortened JSON from the previous example for brevity)
//struct SampleData {
//    static let albumsResponse: SpotifySearchResponse? = {
//        let jsonString = """
//        {
//          "albums": {
//            "href": "...", "limit": 3, "next": "...", "offset": 0, "previous": null, "total": 800,
//            "items": [
//              {
//                "album_type": "album", "total_tracks": 6, "available_markets": [],
//                "external_urls": { "spotify": "https://open.spotify.com/album/6KJgxZYve2dbchVjw3MxBQ" },
//                "href": "...", "id": "6KJgxZYve2dbchVjw3MxBQ",
//                "images": [
//                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273528f5d5bc76597cd876e3cb2", "width": 640 },
//                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02528f5d5bc76597cd876e3cb2", "width": 300 },
//                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851528f5d5bc76597cd876e3cb2", "width": 64 }
//                ],
//                "name": "Steamin' [Rudy Van Gelder edition]", "release_date": "1961", "release_date_precision": "year", "type": "album", "uri": "...",
//                "artists": [ { "external_urls": { "spotify": "..." }, "href": "...", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "..." } ]
//              },
//              {
//                "album_type": "compilation", "total_tracks": 11, "available_markets": [],
//                "external_urls": { "spotify": "https://open.spotify.com/album/5SaMVD3JhB3JU9A66Xwj0E" },
//                "href": "...", "id": "5SaMVD3JhB3JU9A66Xwj0E",
//                "images": [
//                  { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b273f50bf8084da59379dd7f968e", "width": 640 },
//                  { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e02f50bf8084da59379dd7f968e", "width": 300 },
//                  { "height": 64, "url": "https://i.scdn.co/image/ab67616d00004851f50bf8084da59379dd7f968e", "width": 64 }
//                ],
//                "name": "20th Century Masters: Millennium Collection", "release_date": "2000-08-08", "release_date_precision": "day", "type": "album", "uri": "...",
//                "artists": [ { "external_urls": { "spotify": "..." }, "href": "...", "id": "0LyfQWJT6nXafLPZqxe9Of", "name": "Various Artists", "type": "artist", "uri": "..." } ]
//              },
//              {
//                 "album_type": "album", "total_tracks": 21, "available_markets": [],
//                 "external_urls": { "spotify": "https://open.spotify.com/album/4sb0eMpDn3upAFfyi4q2rw" },
//                 "href": "...", "id": "4sb0eMpDn3upAFfyi4q2rw",
//                 "images": [
//                   { "height": 640, "url": "https://i.scdn.co/image/ab67616d0000b2730ebc17239b6b18ba88cfb8ca", "width": 640 },
//                   { "height": 300, "url": "https://i.scdn.co/image/ab67616d00001e020ebc17239b6b18ba88cfb8ca", "width": 300 },
//                   { "height": 64, "url": "https://i.scdn.co/image/ab67616d000048510ebc17239b6b18ba88cfb8ca", "width": 64 }
//                 ],
//                 "name": "Kind Of Blue (Legacy Edition)", "release_date": "1959-08-17", "release_date_precision": "day", "type": "album", "uri": "...",
//                 "artists": [ { "external_urls": { "spotify": "..." }, "href": "...", "id": "0kbYTNQb4Pb1rPbbaF0pT4", "name": "Miles Davis", "type": "artist", "uri": "..." } ]
//               }
//            ]
//          }
//        }
//        """
//        guard let data = jsonString.data(using: .utf8) else { return nil }
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase // Optional: if your models use camelCase keys
//        return try? decoder.decode(SpotifySearchResponse.self, from: data)
//    }()
//
//    static let sampleAlbumItems: [AlbumItem] = albumsResponse?.albums.items ?? []
//}
//
//// MARK: - SwiftUI Views
//
//// MARK: - Theme Modifier
//extension View {
//    func liquidGoldCardBackground() -> some View {
//        self
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.orange.opacity(0.75), Color.yellow.opacity(0.6)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//            )
//            .cornerRadius(15)
//            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4) // Slightly softer shadow
//    }
//}
//
//// MARK: - Reusable Async Image View
//// (Copied from previous example - essential for cards and overlay)
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
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.secondary.opacity(0.1)) // Placeholder background
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill) // Ensure image fills its bounds
//                    case .failure:
//                        Image(systemName: "photo.fill") // Error placeholder
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(.secondary.opacity(0.5))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.secondary.opacity(0.1))
//                    @unknown default:
//                        Image(systemName: "questionmark.diamond.fill") // Unknown state placeholder
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(.secondary.opacity(0.5))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .background(Color.secondary.opacity(0.1))
//                    }
//                }
//            } else {
//                 // No URL placeholder
//                Image(systemName: "music.note.list")
//                     .resizable()
//                     .scaledToFit()
//                     .foregroundColor(.secondary.opacity(0.5))
//                     .frame(maxWidth: .infinity, maxHeight: .infinity)
//                     .background(Color.secondary.opacity(0.1))
//            }
//        }
//    }
//}
//
//// MARK: - Main View with Grid and Overlay Logic
//struct LiquidGoldMusicPlayerView: View {
//    @State private var albums: [AlbumItem] = SampleData.sampleAlbumItems
//    @State private var selectedAlbum: AlbumItem? = nil // State to control the overlay
//    @Namespace private var animation // Namespace for matched geometry effect
//
//    // Define grid layout
//    private let columns: [GridItem] = [
//        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 20) // Responsive grid
//    ]
//
//    var body: some View {
//        // Use ZStack for layering the overlay
//        ZStack {
//            NavigationView {
//                ScrollView {
//                    LazyVGrid(columns: columns, spacing: 20) { // Use defined columns and spacing
//                        ForEach(albums) { album in
//                             // Only show the card if it's not the currently selected one for the overlay
////                             if selectedAlbum?.id != album.id {
////                                AlbumCard(album: album, animation: animation)
////                                    .onTapGesture {
////                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { // Smooth spring animation
////                                            selectedAlbum = album
////                                        }
////                                    }
////                             } else {
//                                 // Placeholder to keep grid spacing consistent during animation
//                                 Rectangle()
//                                     .fill(Color.clear)
//                                     .frame(height: 200) // Approximate height of the card
////                             }
//                        }
//                    }
//                    .padding() // Padding around the grid
//                }
//                .background( // Apply a dark gradient background to the main view
//                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.gray.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
//                        .ignoresSafeArea()
//                 )
//                .navigationTitle("Golden Releases")
//                .navigationBarTitleDisplayMode(.large)
//                .toolbarColorScheme(.dark, for: .navigationBar) // Ensure nav bar text is light
//
//            }
//            .navigationViewStyle(.stack) // Use stack style
//            .disabled(selectedAlbum != nil) // Disable interaction behind overlay
//
//            // Overlay Layer
//            if let album = selectedAlbum {
//                AlbumDetailOverlay(album: album, selectedAlbum: $selectedAlbum, animation: animation)
//                    .zIndex(1) // Ensure overlay is on top
//            }
//        }
//        .preferredColorScheme(.dark) // Maintain dark theme for consistency
//    }
//}
//
//// MARK: - Representing a single interactive Album Card
//struct AlbumCard: View {
//    let album: AlbumItem
////    var animation: Namespace.ID
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) { // Added spacing
//            AlbumImageView(url: album.listImageURL) // Use the reusable image view
////                .matchedGeometryEffect(id: "albumArt\(album.id)", in: animation) // Match image
//                .aspectRatio(1, contentMode: .fill) // Make image fill square space
//                .frame(height: 140) // Control card image height
//                .clipped() // Clip image content
//                .cornerRadius(8) // Rounded image corners
//
//            VStack(alignment: .leading, spacing: 2) { // Tighter spacing for text
//                Text(album.name)
//                    .font(.headline)
////                    .matchedGeometryEffect(id: "albumName\(album.id)", in: animation) // Match name
//                    .lineLimit(1)
//                    .foregroundColor(.black.opacity(0.8)) // Darker text for gold background
//
//                Text(album.formattedArtists)
//                    .font(.caption)
//                    .foregroundColor(.black.opacity(0.6)) // Slightly lighter secondary text
//                    .lineLimit(1)
//            }
//        }
//        .padding(12) // Padding inside the card
//        .liquidGoldCardBackground() // Apply the theme modifier
//        .frame(minHeight: 200) // Ensure cards have a minimum height
//    }
//}
//struct AlbumDetailView_Previews: PreviewProvider {
//    static let mockArtist = Artist(id: "artist1", external_urls: nil, href: "", name: "Miles Davis Mock", type: "artist", uri: "")
//    // Use 640px image for detail view
//    static let mockImage = SpotifyImage(height: 640, url: "https://i.scdn.co/image/ab67616d0000b2737ab89c25093ea3787b1995b4", width: 640)
//    static let mockAlbum = AlbumItem(id: "1weenld61qoidwYuZ1GESA", album_type: "album", total_tracks: 5, available_markets: ["US", "GB"], external_urls: ExternalUrls(spotify: "https://open.spotify.com/album/1weenld61qoidwYuZ1GESA"), href: "", images: [mockImage], name: "Kind Of Blue (Preview)", release_date: "1959-08-17", release_date_precision: "day", type: "album", uri: "spotify:album:1weenld61qoidwYuZ1GESA", artists: [mockArtist])
//
//    static var previews: some View {
//        NavigationView { // Wrap in NavigationView for realistic preview
//            AlbumCard(album: mockAlbum)
//        }
//        .preferredColorScheme(.dark) // Essential for retro theme
//    }
//}
//
//// MARK: - Overlay View displaying Album Details and Play Button
//struct AlbumDetailOverlay: View {
//    let album: AlbumItem
//    @Binding var selectedAlbum: AlbumItem? // Binding to dismiss the overlay
//    @Environment(\.openURL) var openURL // To open Spotify link
//    var animation: Namespace.ID
//
//    var body: some View {
//        ScrollView { // Allow scrolling if content exceeds screen height
//            VStack(spacing: 20) { // Increased spacing for overlay elements
//                // Album Art (Animated)
//                AlbumImageView(url: album.bestImageURL)
//                    .matchedGeometryEffect(id: "albumArt\(album.id)", in: animation)
//                    .aspectRatio(1, contentMode: .fit) // Fit ensures entire artwork is visible
//                    .frame(width: min(UIScreen.main.bounds.width * 0.7, 300)) // Responsive width
//                    .cornerRadius(15) // Softer corners for larger image
//                    .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
//                    .padding(.top, 50) // Add padding from the top edge
//
//                // Album Title and Artist (Animated)
//                VStack(spacing: 5) {
//                    Text(album.name)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .matchedGeometryEffect(id: "albumName\(album.id)", in: animation)
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//
//                    Text(album.formattedArtists)
//                        .font(.title3) // Slightly larger artist font
//                        .foregroundColor(.white.opacity(0.8))
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//
//                // Details Section (Type, Release Date, Tracks) - Non-animated
//                HStack (spacing: 15){
//                    VStack {
//                        Text("TYPE")
//                            .font(.caption)
//                            .foregroundColor(.yellow.opacity(0.7))
//                        Text(album.album_type.capitalized)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                    }
//                       Divider().frame(height: 30).background(Color.yellow.opacity(0.5))
//                       VStack {
//                           Text("RELEASED")
//                               .font(.caption)
//                               .foregroundColor(.yellow.opacity(0.7))
//                           Text(album.formattedReleaseDate())
//                               .font(.headline)
//                               .foregroundColor(.white)
//                       }
//                       Divider().frame(height: 30).background(Color.yellow.opacity(0.5))
//                       VStack {
//                           Text("TRACKS")
//                               .font(.caption)
//                               .foregroundColor(.yellow.opacity(0.7))
//                           Text("\(album.total_tracks)")
//                               .font(.headline)
//                               .foregroundColor(.white)
//                       }
//                }
//                 .padding(.vertical, 10)
//                 .padding(.horizontal, 20)
//                 .background(.white.opacity(0.1))
//                 .cornerRadius(10)
//
//                // Liquid Gold Play Button
//                Button {
//                    // Action: Open Spotify URL
//                     if let url = URL(string: album.external_urls.spotify) {
//                         openURL(url)
//                     }
//                } label: {
//                    HStack {
//                        Image(systemName: "play.fill")
//                        Text("Play on Spotify")
//                            .fontWeight(.semibold)
//                    }
//                    .foregroundColor(.black.opacity(0.8)) // Dark text on gold button
//                    .padding(.vertical, 12)
//                    .padding(.horizontal, 30)
//                    .background(
//                         Capsule().fill(LinearGradient(colors: [Color.yellow, Color.orange.opacity(0.8)], startPoint: .top, endPoint: .bottom))
//                     )
//                    .shadow(color: .yellow.opacity(0.5), radius: 5, y: 3)
//                }
//                .padding(.top, 10) // Add space above button
//
//                Spacer() // Push content upwards
//
//            } // End Main VStack
//            .padding(.horizontal) // Overall horizontal padding for the overlay content
//            .frame(maxWidth: .infinity) // Ensure VStack takes full width
//
//        } // End ScrollView
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make overlay cover screen
//        .background( // Dark, semi-transparent background for the overlay
//            Color.black.opacity(0.85)
//                .ignoresSafeArea()
//                .onTapGesture { // Allow tapping background to dismiss
//                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                        selectedAlbum = nil
//                    }
//                }
//        )
//        .overlay(alignment: .topTrailing) { // Add close button
//             Button {
//                 withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                     selectedAlbum = nil
//                 }
//             } label: {
//                 Image(systemName: "xmark.circle.fill")
//                     .font(.title)
//                     .foregroundColor(.white.opacity(0.7))
//                     .padding()
//                     .contentShape(Rectangle()) // Increase tappable area
//             }
//             .padding(.top,40) // Adjust top padding for status bar etc.
//         }
//        .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Fade in/out transition
//        .zIndex(1) // Keep overlay on top during transitions
//    }
//}
//
//// MARK: - Preview Providers
//struct LiquidGoldMusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LiquidGoldMusicPlayerView()
//    }
//}
//
//// MARK: - App Entry Point (Optional Example)
///*
// @main
// struct LiquidGoldApp: App {
//     var body: some Scene {
//         WindowGroup {
//             LiquidGoldMusicPlayerView()
//         }
//     }
// }
// */
