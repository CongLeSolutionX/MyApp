////
////  SpotifyEmbedView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import Foundation // Needed for Date
//
//struct TrackDetails {
//    let id: String // spotify:track:11dFghVXANMlKmJXsNCbNl
//    let title: String
//    let artistName: String
//    let albumTitle: String? // Optional for episodes/singles
//    let artworkURL: URL?
//    let durationMs: Int // Duration in milliseconds
//    let releaseDate: Date?
//    let description: String? // Could be lyrics snippet, show notes, etc.
//    let isEpisode: Bool // Differentiate styling/labels if needed
//
//    // Computed properties for display
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    var formattedReleaseDate: String {
//        guard let releaseDate else { return "N/A" }
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter.string(from: releaseDate)
//    }
//
//    // --- Mock Data Factory ---
//    static func mockTrack() -> TrackDetails {
//        return TrackDetails(
//            id: "spotify:track:11dFghVXANMlKmJXsNCbNl",
//            title: "Never Gonna Give You Up",
//            artistName: "Rick Astley",
//            albumTitle: "Whenever You Need Somebody",
//            artworkURL: URL(string: "https://i.scdn.co/image/ab67616d0000b2730c45d941ba59e17f5314a8a4"), // Example URL
//            durationMs: 213573, // 3:33
//            releaseDate: Calendar.current.date(from: DateComponents(year: 1987, month: 7, day: 27)),
//            description: "Released in 1987, this song became an international number-one hit and later an internet meme known as 'rickrolling'.",
//            isEpisode: false
//        )
//    }
//
//    static func mockEpisode() -> TrackDetails {
//         return TrackDetails(
//            id: "spotify:episode:7makk4oTQel546B0PZlDM5",
//            title: "Life at Spotify",
//            artistName: "Spotify: For the Record", // Show Name
//            albumTitle: "Spotify: For the Record", // Podcast Series Name (often same as show)
//            artworkURL: URL(string: "https://i.scdn.co/image/ab6765630000ba8a8a847b9630621b655357ecaa"), // Example URL
//            durationMs: 1783000, // Approx 29:43
//            releaseDate: Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 14)),
//            description: "We pull back the curtain and learn what life has been like for employees at Spotify over the past few months during the global pandemic. How have they navigated the unique challenges presented by this moment while continuing to build the Spotify experience?",
//            isEpisode: true
//         )
//    }
//}
//
//import SwiftUI
//
//struct TrackDetailsView: View {
//    // Receive the track data from the previous screen
//    let track: TrackDetails
//
//    // Environment value for dismissing the view (if presented modally)
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // --- Artwork ---
//                AsyncImage(url: track.artworkURL) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView() // Placeholder while loading
//                            .frame(height: 300) // Give it size
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .cornerRadius(8)
//                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
//                    case .failure:
//                        Image(systemName: track.isEpisode ? "mic.fill" : "music.note") // Fallback icon
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .padding(50)
//                            .frame(height: 300)
//                            .background(Color(.systemGray5))
//                            .foregroundColor(Color(.systemGray))
//                            .cornerRadius(8)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//                .frame(maxWidth: .infinity) // Center the image container itself
//                .padding(.bottom, 10) // Add some space below the image
//
//                // --- Metadata ---
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(track.title)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .lineLimit(2)
//                        .minimumScaleFactor(0.8) // Allow shrinking if title is very long
//
//                    Text(track.artistName)
//                        .font(.title2)
//                        .foregroundColor(.secondary)
//
//                    if let albumTitle = track.albumTitle, !track.isEpisode {
//                        Text("From \"\(albumTitle)\"")
//                            .font(.headline)
//                            .foregroundColor(.accentColor) // Or another color
//                            // Link to Album View (Future Enhancement)
//                            .onTapGesture {
//                                print("Navigate to Album: \(albumTitle)")
//                                // Navigation logic here
//                            }
//                    } else if let seriesTitle = track.albumTitle, track.isEpisode {
//                         Text("Podcast: \(seriesTitle)")
//                            .font(.headline)
//                            .foregroundColor(.purple) // Distinguish podcasts
//                            // Link to Podcast Series View (Future Enhancement)
//                            .onTapGesture {
//                                print("Navigate to Podcast Series: \(seriesTitle)")
//                                // Navigation logic here
//                            }
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
//
//                // --- Duration & Release Date ---
//                HStack {
//                    Label(track.formattedDuration, systemImage: "clock")
//                    Spacer()
//                    Label(track.formattedReleaseDate, systemImage: "calendar")
//                }
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//                Divider()
//
//                // --- Action Buttons ---
//                HStack(spacing: 20) {
//                    Button { print("Play Action Tapped: \(track.id)") } label: {
//                        Label("Play", systemImage: "play.circle.fill")
//                            .font(.title2)
//                            .frame(maxWidth: .infinity) // Make buttons fill space
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.green) // Spotify green-ish
//
//                    Button { print("Add Action Tapped: \(track.id)") } label: {
//                        Label("Add", systemImage: "plus.circle")
//                             .font(.title2)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.bordered)
//
//                    Button { print("Share Action Tapped: \(track.id)") } label: {
//                        Label("Share", systemImage: "square.and.arrow.up")
//                             .font(.title2)
//                    }
//                    .buttonStyle(.bordered)
//                }
//                .labelStyle(.iconOnly) // Show only icons for compactness, adjust if needed
//                .padding(.vertical, 5)
//
//                Divider()
//
//                // --- Description / Show Notes ---
//                if let description = track.description, !description.isEmpty {
//                    VStack(alignment: .leading) {
//                        Text(track.isEpisode ? "Episode Notes" : "About")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                            .padding(.bottom, 2)
//                        Text(description)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                    }
//                }
//
//                 // --- Related Content (Future Enhancement) ---
//                 // VStack(alignment: .leading) {
//                 //     Text("More by \(track.artistName)")
//                 //         .font(.title3).fontWeight(.semibold)
//                 //     ScrollView(.horizontal, showsIndicators: false) {
//                 //         HStack { /* Cards for other tracks/episodes */ }
//                 //     }
//                 // }
//                 // .padding(.top)
//
//                Spacer() // Pushes content up if ScrollView content is short
//            }
//            .padding() // Add padding around the entire VStack content
//        }
//        .navigationTitle(track.isEpisode ? "Episode Details" : "Track Details") // Dynamic Title
//        .navigationBarTitleDisplayMode(.inline) // More compact title
//        // Add a close button if presented modally
//        // .toolbar {
//        //     ToolbarItem(placement: .navigationBarLeading) {
//        //         Button("Close") { dismiss() }
//        //     }
//        // }
//    }
//}
//
//// MARK: - Preview
//
//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview within a NavigationView to see the title bar
//        NavigationView {
//            TrackDetailsView(track: TrackDetails.mockTrack())
//        }
//        .previewDisplayName("Track Details")
//
//        NavigationView {
//             TrackDetailsView(track: TrackDetails.mockEpisode())
//        }
//        .previewDisplayName("Episode Details")
//    }
//}
