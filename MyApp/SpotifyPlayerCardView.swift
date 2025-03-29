//
//  SpotifyPlayerCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// --- Data Model ---
struct Song: Identifiable {
    let id = UUID()
    var title: String
    var artist: String
    var isPlaying: Bool = false
    // In a real app, you might have an album art URL or UIImage here
}

// --- ViewModel ---
class MusicPlayerViewModel: ObservableObject {
    @Published var songs: [Song]

    init() {
        // Sample data based on the image
        self.songs = [
            Song(title: "Time in a Bottle", artist: "Jim Croce", isPlaying: true),
            Song(title: "My Way", artist: "Frank Sinatra", isPlaying: false),
            Song(title: "Lemon Tree", artist: "Fools Garden", isPlaying: false)
        ]
    }

    // Placeholder function to simulate changing the playing song
    func selectSong(_ songToPlay: Song) {
        for i in songs.indices {
            songs[i].isPlaying = (songs[i].id == songToPlay.id)
        }
    }
}

// --- Main View ---
struct ContentView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()

    var body: some View {
        ZStack {
            // Background Dim color (similar to the image)
            Color.black.opacity(0.9).ignoresSafeArea()

            // Currently Playing Card
            CurrentlyPlayingCard(viewModel: viewModel)
        }
    }
}

// --- Currently Playing Card View ---
struct CurrentlyPlayingCard: View {
    @ObservedObject var viewModel: MusicPlayerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header (Icon + Text)
            HeaderView()

            // Song List
            VStack(spacing: 15) {
                ForEach(viewModel.songs) { song in
                    SongRowView(song: song)
                        // Add tap gesture to simulate selection
                        .onTapGesture {
                            viewModel.selectSong(song)
                        }
                        // Add a subtle hover effect if desired (macOS/iPadOS)
                        // .background(Color.gray.opacity(0.001)) // To make onTapGesture work reliably on whole row
                        // .contentShape(Rectangle()) // Ensure tap gesture applies to the whole row area
                }
            }
        }
        .padding() // Padding inside the card
        .background(Color.white)
        .cornerRadius(15)
        .padding() // Padding around the card
        .shadow(radius: 5) // Optional shadow
    }
}

// --- Header View ---
struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            // A simple representation of the Spotify-like icon
            Image(systemName: "music.note.list") // Placeholder icon
                .font(.system(size: 24))
                .foregroundColor(.green)
                .frame(width: 50, height: 50)
                .background(Color.green.opacity(0.2))
                .clipShape(Circle())
                // Adding the background stripes (simplified)
                .background(
                    VStack(spacing: 5) {
                        ForEach(0..<3) { _ in
                           Capsule()
                             .fill(Color.yellow.opacity(0.3))
                             .frame(height: 6)
                       }
                    }
                    .frame(width: 60) // Slightly wider than the circle
                    .offset(y: -2) // Adjust position slightly if needed
                )

            Text("Currently Playing")
                .font(.system(size: 18, weight: .bold)) // Adjusted size slightly
                .foregroundColor(.black)
        }
    }
}

// --- Song Row View ---
struct SongRowView: View {
    let song: Song

    var body: some View {
        HStack(spacing: 15) {
            // Playing/Paused Indicator
            Group {
                if song.isPlaying {
                    Image(systemName: "waveform") // Represents the loading bars
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .frame(width: 25) // Fixed width for alignment
                } else {
                    Image(systemName: "play.fill") // Represents the play icon
                        .font(.system(size: 16)) // Slightly smaller
                        .foregroundColor(.black)
                        .frame(width: 25) // Fixed width for alignment
                }
            }
             .frame(height: 40) // Match album art height

            // Album Cover Placeholder
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.2)) // Using opacity for light gray
                .frame(width: 40, height: 40)

            // Song Title and Artist
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.system(size: 16)) // Main title font
                    .foregroundColor(.black)
                Text(song.artist)
                    .font(.system(size: 12)) // Smaller artist font
                    .foregroundColor(.gray) // Secondary color
            }

            Spacer() // Pushes text content to the left
        }
    }
}

// --- Previews ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
