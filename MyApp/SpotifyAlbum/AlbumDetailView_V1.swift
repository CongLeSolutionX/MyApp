////
////  SpotifyAlbumView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Simplified for direct use with provided JSON)
//// In a real app, these would conform to Codable for API fetching.
//
//struct AlbumData {
//    let albumType: String = "album"
//    let totalTracks: Int = 18
//    let spotifyUrl: String = "https://open.spotify.com/album/4aawyAB9vmqN3uQ7FjRGTy"
//    let images: [ImageData] = [
//        ImageData(url: "https://i.scdn.co/image/ab67616d0000b2732c5b24ecfa39523a75c993c4", height: 640, width: 640),
//        ImageData(url: "https://i.scdn.co/image/ab67616d00001e022c5b24ecfa39523a75c993c4", height: 300, width: 300),
//        ImageData(url: "https://i.scdn.co/image/ab67616d000048512c5b24ecfa39523a75c993c4", height: 64, width: 64)
//    ]
//    let name: String = "Global Warming"
//    let releaseDate: String = "2012-11-16"
//    let releaseDatePrecision: String = "day"
//    let artists: [ArtistData] = [
//        ArtistData(name: "Pitbull")
//    ]
//    let tracks: TrackListData = TrackListData(items: [
//        // Including only a few sample tracks for brevity
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Sensato")], discNumber: 1, durationMs: 85400, explicit: true, name: "Global Warming (feat. Sensato)", trackNumber: 1),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "TJR")], discNumber: 1, durationMs: 206120, explicit: false, name: "Don't Stop the Party (feat. TJR)", trackNumber: 2),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Christina Aguilera")], discNumber: 1, durationMs: 229506, explicit: false, name: "Feel This Moment (feat. Christina Aguilera)", trackNumber: 3),
//        TrackData(artists: [ArtistData(name: "Pitbull")], discNumber: 1, durationMs: 207440, explicit: false, name: "Back in Time - featured in \"Men In Black 3\"", trackNumber: 4),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Chris Brown")], discNumber: 1, durationMs: 221133, explicit: false, name: "Hope We Meet Again (feat. Chris Brown)", trackNumber: 5),
//        // ... Add other tracks if needed for a fuller representation
//         TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "USHER"), ArtistData(name: "AFROJACK")], discNumber: 1, durationMs: 243160, explicit: true, name: "Party Ain't Over (feat. Usher & Afrojack)", trackNumber: 6),
//         TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Jennifer Lopez")], discNumber: 1, durationMs: 196920, explicit: false, name: "Drinks for You (Ladies Anthem) (feat. J. Lo)", trackNumber: 7)
//    ], total: 18)
//    let copyrights: [CopyrightData] = [
//        CopyrightData(text: "(P) 2012 RCA Records, a division of Sony Music Entertainment", type: "P")
//    ]
//    let label: String = "Mr.305/Polo Grounds Music/RCA Records"
//    let popularity: Int = 55 // Added from JSON
//}
//
//struct ImageData {
//    let url: String
//    let height: Int
//    let width: Int
//}
//
//struct ArtistData: Identifiable {
//    let id = UUID() // Make identifiable for ForEach
//    let name: String
//}
//
//struct TrackListData {
//    let items: [TrackData]
//    let total: Int
//}
//
//struct TrackData: Identifiable {
//    let id = UUID() // Make identifiable for ForEach
//    let artists: [ArtistData]
//    let discNumber: Int
//    let durationMs: Int
//    let explicit: Bool
//    let name: String
//    let trackNumber: Int
//}
//
//struct CopyrightData {
//    let text: String
//    let type: String
//}
//
//// MARK: - Helper Functions
//
//func formatDuration(ms: Int) -> String {
//    let totalSeconds = ms / 1000
//    let minutes = totalSeconds / 60
//    let seconds = totalSeconds % 60
//    return String(format: "%d:%02d", minutes, seconds)
//}
//
//func formatArtists(artists: [ArtistData]) -> String {
//    return artists.map { $0.name }.joined(separator: ", ")
//}
//
//func extractYear(from dateString: String) -> String {
//    let components = dateString.split(separator: "-")
//    return components.first.map(String.init) ?? ""
//}
//
//// MARK: - SwiftUI View
//
//struct AlbumDetailView: View {
//    // In a real app, this would be fetched or passed in.
//    let albumData = AlbumData()
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                // --- Header ---
//                AlbumHeaderView(albumData: albumData)
//
//                Divider()
//
//                // --- Metadata ---
//                AlbumMetadataView(albumData: albumData)
//
//                Divider()
//
//                // --- Track List ---
//                TrackListView(tracks: albumData.tracks.items)
//
//            }
//            .padding()
//        }
//        .navigationTitle(albumData.name) // Sets the title in a Navigation View context
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Subviews
//
//struct AlbumHeaderView: View {
//    let albumData: AlbumData
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 12) {
//            AsyncImage(url: URL(string: albumData.images.first?.url ?? "")) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .cornerRadius(8)
//                    .shadow(radius: 5)
//            } placeholder: {
//                Rectangle()
//                    .fill(.secondary.opacity(0.3))
//                    .aspectRatio(1.0, contentMode: .fit) // Maintain square aspect ratio
//                    .cornerRadius(8)
//                    .overlay(ProgressView())
//            }
//            .frame(maxWidth: 300) // Limit image size
//
//            Text(albumData.name)
//                .font(.title2)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//
//            Text(formatArtists(artists: albumData.artists))
//                .font(.headline)
//                .foregroundColor(.secondary)
//
//            Text("\(albumData.albumType.capitalized) • \(extractYear(from: albumData.releaseDate))")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            if let url = URL(string: albumData.spotifyUrl) {
//                Link(destination: url) {
//                    Text("Listen on Spotify")
//                        .font(.footnote)
//                        .fontWeight(.medium)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .background(.green)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.top, 5)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .center) // Center the header content
//    }
//}
//
//struct AlbumMetadataView: View {
//    let albumData: AlbumData
//
//    var body: some View {
//         VStack(alignment: .leading, spacing: 4) {
//             Text("\(albumData.totalTracks) tracks")
//                 .font(.footnote)
//                 .foregroundColor(.secondary)
//             Text("Label: \(albumData.label)")
//                 .font(.footnote)
//                 .foregroundColor(.secondary)
//             if let copyright = albumData.copyrights.first {
//                 Text(copyright.text)
//                     .font(.caption)
//                     .foregroundColor(.gray)
//             }
//             // Optional: Display Popularity
//             HStack {
//                 Text("Popularity:")
//                     .font(.footnote)
//                     .foregroundColor(.secondary)
//                 ProgressView(value: Double(albumData.popularity), total: 100.0)
//                      .progressViewStyle(LinearProgressViewStyle(tint: .green))
//                      .frame(height: 5)
//             }
//         }
//         .frame(maxWidth: .infinity, alignment: .leading) // Align metadata to the left
//    }
//}
//
//struct TrackListView: View {
//    let tracks: [TrackData]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Tracks")
//                .font(.headline)
//                .padding(.bottom, 5)
//
//            ForEach(tracks) { track in
//                TrackRow(track: track)
//                Divider().padding(.leading, 40) // Indent divider
//            }
//        }
//    }
//}
//
//struct TrackRow: View {
//    let track: TrackData
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            Text("\(track.trackNumber)")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .frame(width: 25, alignment: .trailing) // Align track numbers
//
//            VStack(alignment: .leading) {
//                 HStack {
//                     Text(track.name)
//                         .font(.body)
//                         .lineLimit(1) // Prevent long titles from wrapping excessively
//                     if track.explicit {
//                         Text("E")
//                             .font(.caption)
//                             .fontWeight(.bold)
//                             .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
//                             .background(Color.secondary.opacity(0.6))
//                             .foregroundColor(.white)
//                             .clipShape(RoundedRectangle(cornerRadius: 4))
//                     }
//                 }
//                 Text(formatArtists(artists: track.artists))
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//                     .lineLimit(1) // Prevent multiple artists taking too much space
//             }
//
//            Spacer() // Pushes duration to the right
//
//            Text(formatDuration(ms: track.durationMs))
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 5) // Add some vertical padding to rows
//    }
//}
//
//// MARK: - Preview
//
//struct AlbumDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView { // Wrap in NavigationView for previewing title
//             AlbumDetailView()
//        }
//    }
//}
