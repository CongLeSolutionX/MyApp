//
//  GetPlaybackStateDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI

// MARK: - Placeholder Data Structures (Mirroring JSON for clarity)

// Note: In a real app, these would be Codable and populated from the JSON.
// For this UI design, we'll use them conceptually or with sample data.

struct SpotifyImage: Identifiable {
    let id = UUID()
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyArtist: Identifiable {
    let id = UUID() // Use actual ID from JSON in real app
    let name: String
}

struct SpotifyAlbum: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let images: [SpotifyImage]
    let artists: [SpotifyArtist] // Album artists might differ
}

struct SpotifyTrack: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let duration_ms: Int
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
}

struct SpotifyDevice: Identifiable {
    let id = UUID() // Use actual ID from JSON
    let name: String
    let type: String // e.g., "computer", "speaker"
    let volume_percent: Int?
    let is_active: Bool
    let supports_volume: Bool
}

struct SpotifyPlayerActions {
    let resuming: Bool
    let pausing: Bool
    let skipping_next: Bool
    let skipping_prev: Bool
    let toggling_shuffle: Bool
    let toggling_repeat_context: Bool
    let toggling_repeat_track: Bool
}

// Sample data for the preview
let sampleArtist = SpotifyArtist(name: "Example Artist")
let sampleAlbum = SpotifyAlbum(
    name: "Awesome Album",
    images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228", height: 300, width: 300)],
    artists: [sampleArtist]
)
let sampleTrack = SpotifyTrack(
    name: "The Best Song",
    duration_ms: 240000, // 4 minutes
    artists: [sampleArtist],
    album: sampleAlbum
)
let sampleDevice = SpotifyDevice(
    name: "Living Room Speaker",
    type: "speaker",
    volume_percent: 59,
    is_active: true,
    supports_volume: true
)
let sampleActions = SpotifyPlayerActions(
    resuming: true, pausing: true, skipping_next: true, skipping_prev: true,
    toggling_shuffle: true, toggling_repeat_context: true, toggling_repeat_track: true
)

// MARK: - SwiftUI View

struct SpotifyPlayerView: View {
    // These would be @State or passed in properties connected to the actual API data
    let device: SpotifyDevice? = sampleDevice
    let track: SpotifyTrack? = sampleTrack
    let isPlaying: Bool = true
    let progressMs: Int = 60000 // 1 minute
    let shuffleState: Bool = false
    let repeatState: String = "off" // "off", "track", "context"
    let actions: SpotifyPlayerActions = sampleActions

    // Helper to format milliseconds to mm:ss
    private func formatTime(_ ms: Int) -> String {
        let totalSeconds = ms / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Helper to get joined artist names
    private var artistNames: String {
        track?.artists.map { $0.name }.joined(separator: ", ") ?? "Unknown Artist"
    }

    // Calculate progress value (0.0 to 1.0)
    private var progressValue: Double {
        guard let track = track, track.duration_ms > 0 else { return 0.0 }
        return min(max(0.0, Double(progressMs) / Double(track.duration_ms)), 1.0)
    }

    var body: some View {
        VStack(spacing: 15) {
            // --- Album Artwork ---
            AsyncImage(url: URL(string: track?.album.images.first?.url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            } placeholder: {
                Rectangle() // Placeholder view
                    .fill(Color.secondary.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "music.note").font(.largeTitle).foregroundColor(.gray))
            }
            .padding(.horizontal)

            // --- Track Info ---
            VStack {
                Text(track?.name ?? "No Track Playing")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Text(artistNames)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                Text(track?.album.name ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .padding(.top, 1) // Small space before album name
            }
            .padding(.horizontal)

            // --- Progress Bar ---
            VStack(spacing: 4) {
                ProgressView(value: progressValue)
                    .tint(.accentColor) // Or specific Spotify green
                    .padding(.horizontal)

                HStack {
                    Text(formatTime(progressMs))
                    Spacer()
                    Text(formatTime(track?.duration_ms ?? 0))
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            }

            // --- Playback Controls ---
            HStack(spacing: 30) {
                // Shuffle Button
                Button { /* Action */ } label: {
                    Image(systemName: "shuffle")
                        .font(.title2)
                        .foregroundColor(shuffleState ? .accentColor : .primary) // Highlight if active
                }
                .disabled(!actions.toggling_shuffle)

                // Previous Button
                Button { /* Action */ } label: {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                .disabled(!actions.skipping_prev)

                // Play/Pause Button
                Button { /* Action */ } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50)) // Larger central button
                }
                .disabled(!(isPlaying ? actions.pausing : actions.resuming))

                // Next Button
                Button { /* Action */ } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
                .disabled(!actions.skipping_next)

                 // Repeat Button
                Button { /* Action */ } label: {
                    Image(systemName: repeatState == "track" ? "repeat.1" : "repeat")
                        .font(.title2)
                        .foregroundColor(repeatState != "off" ? .accentColor : .primary) // Highlight if active
                }
                .disabled(!(actions.toggling_repeat_context || actions.toggling_repeat_track))
            }
            .padding(.vertical)

            // --- Device Info ---
            HStack {
                Image(systemName: deviceIconName(device?.type ?? ""))
                Text(device?.name ?? "No Device")
                Spacer()
                if let volume = device?.volume_percent, device?.supports_volume == true {
                    Image(systemName: volumeIconName(volume))
                    Text("\(volume)%") // Optionally show volume %
                    // Could add a Slider here if needed
                }
                 if device?.is_active == true {
                     Circle()
                         .fill(Color.green)
                         .frame(width: 8, height: 8)
                         .padding(.leading, 4)
                 }

            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
//        .background(Color(UIColor.systemBackground)) // Adapt to light/dark mode
//        .cornerRadius(15)
//        .shadow(radius: 3) // Optional container shadow
    }

    // Helper for device icon
    private func deviceIconName(_ type: String) -> String {
        switch type.lowercased() {
            case "computer": return "desktopcomputer"
            case "smartphone": return "iphone"
            case "speaker": return "speaker.wave.2.fill"
            case "tv": return "tv.fill"
            case "avr": return "hifispeaker.and.homepodmini.fill" // Best guess
            case "stb": return "tv.and.hifispeaker.fill" // Best guess
            default: return "questionmark.diamond.fill"
        }
    }

    // Helper for volume icon
     private func volumeIconName(_ volume: Int) -> String {
        switch volume {
            case 0: return "speaker.slash.fill"
            case 1..<33: return "speaker.wave.1.fill"
            case 33..<66: return "speaker.wave.2.fill"
            default: return "speaker.wave.3.fill"
        }
    }
}

// MARK: - SwiftUI Preview

struct SpotifyPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyPlayerView()
            .previewLayout(.sizeThatFits) // Adjust layout for preview
            .padding() // Add padding around the preview itself
    }
}
