//
//  GetCurrentlyPlayingTrackView.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import Foundation

// MARK: - Main Response Structure
struct CurrentlyPlayingResponse: Codable, Identifiable {
    let id = UUID() // Add identifiable conformance for potential list usage
    let device: Device?
    let repeatState: String? // e.g., "off", "track", "context"
    let shuffleState: Bool?
    let context: PlaybackContext?
    let timestamp: Int?
    let progressMs: Int?
    let isPlaying: Bool?
    let item: PlayableItem?
    let currentlyPlayingType: String? // e.g., "track", "episode"
    let actions: PlayerActions?

    enum CodingKeys: String, CodingKey {
        case device
        case repeatState = "repeat_state"
        case shuffleState = "shuffle_state"
        case context, timestamp
        case progressMs = "progress_ms"
        case isPlaying = "is_playing"
        case item
        case currentlyPlayingType = "currently_playing_type"
        case actions
    }
}

// MARK: - Device Information
struct Device: Codable, Identifiable {
    let id: String?
    let isActive: Bool?
    let isPrivateSession: Bool?
    let isRestricted: Bool?
    let name: String?
    let type: String? // e.g., "computer", "speaker", "smartphone"
    let volumePercent: Int?
    let supportsVolume: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name, type
        case volumePercent = "volume_percent"
        case supportsVolume = "supports_volume"
    }
}

// MARK: - Playback Context
struct PlaybackContext: Codable {
    let type: String? // e.g., "album", "playlist", "artist"
    let href: String?
    let externalUrls: ExternalUrls?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case type, href
        case externalUrls = "external_urls"
        case uri
    }
}

// MARK: - Playable Item (Track/Episode)
struct PlayableItem: Codable, Identifiable {
    let album: Album?
    let artists: [Artist]?
    let availableMarkets: [String]?
    let discNumber: Int?
    let durationMs: Int?
    let explicit: Bool?
    let externalIds: ExternalIds?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let isPlayable: Bool?
    // let linkedFrom: LinkedFrom? // Simplified for this example
    let restrictions: Restrictions?
    let name: String? // Track or Episode name
    let popularity: Int?
    let previewUrl: String?
    let trackNumber: Int?
    let type: String? // "track" or "episode"
    let uri: String?
    let isLocal: Bool?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        // case linkedFrom = "linked_from"
        case restrictions, name, popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }
}

// MARK: - Album Information
struct Album: Codable, Identifiable {
    let albumType: String?
    let totalTracks: Int?
    let availableMarkets: [String]?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let images: [ImageInfo]?
    let name: String?
    let releaseDate: String?
    let releaseDatePrecision: String?
    let restrictions: Restrictions?
    let type: String?
    let uri: String?
    let artists: [Artist]? // Sometimes simplified artist info is nested here too

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case totalTracks = "total_tracks"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case restrictions, type, uri, artists
    }
}

// MARK: - Artist Information
struct Artist: Codable, Identifiable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let name: String?
    let type: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// MARK: - Image Information
struct ImageInfo: Codable, Hashable { // Hashable for potential use in ForEach
    let url: String?
    let height: Int?
    let width: Int?
}

// MARK: - External URLs
struct ExternalUrls: Codable {
    let spotify: String?
}

// MARK: - External IDs
struct ExternalIds: Codable {
    let isrc: String?
    let ean: String?
    let upc: String?
}

// MARK: - Restrictions
struct Restrictions: Codable {
    let reason: String? // e.g., "market", "explicit"
}

// MARK: - Player Actions
struct PlayerActions: Codable {
    let interruptingPlayback: Bool?
    let pausing: Bool?
    let resuming: Bool?
    let seeking: Bool?
    let skippingNext: Bool?
    let skippingPrev: Bool?
    let togglingRepeatContext: Bool?
    let togglingShuffle: Bool?
    let togglingRepeatTrack: Bool?
    let transferringPlayback: Bool?

     enum CodingKeys: String, CodingKey {
        case interruptingPlayback = "interrupting_playback"
        case pausing, resuming, seeking
        case skippingNext = "skipping_next"
        case skippingPrev = "skipping_prev"
        case togglingRepeatContext = "toggling_repeat_context"
        case togglingShuffle = "toggling_shuffle"
        case togglingRepeatTrack = "toggling_repeat_track"
        case transferringPlayback = "transferring_playback"
    }
}

// Helper function to format milliseconds to MM:SS
func formatTime(milliseconds: Int?) -> String {
    guard let ms = milliseconds, ms > 0 else { return "0:00" }
    let totalSeconds = ms / 1000
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%d:%02d", minutes, seconds)
}

// Helper function to get device icon
func deviceIcon(type: String?) -> String {
    switch type?.lowercased() {
    case "computer": return "desktopcomputer"
    case "smartphone": return "iphone"
    case "speaker": return "speaker.wave.2.fill"
    case "tv": return "tv"
    case "avr": return "hifireceiver" // Example
    case "stb": return "appletv"     // Example
    case "audiodongle": return "airpodspro.chargingcase.wireless" // Example
    case "castvideo", "castaudio": return "airplayaudio" // Example
    default: return "questionmark.circle"
    }
}


import SwiftUI

struct CurrentlyPlayingView: View {
    // Assume this data is passed into the view after parsing the JSON
    let currentlyPlayingData: CurrentlyPlayingResponse?

    var body: some View {
        VStack(spacing: 15) {
            if let data = currentlyPlayingData, let item = data.item {
                // MARK: - Album Art
                AlbumArtView(imageUrl: item.album?.images?.first?.url)
                    .padding(.top)

                // MARK: - Track Info
                TrackInfoView(trackName: item.name, artistName: item.artists?.map { $0.name ?? "" }.joined(separator: ", "))
                    .padding(.horizontal)

                // MARK: - Progress Bar
                ProgressBarView(
                    progressMs: data.progressMs,
                    durationMs: item.durationMs
                )
                .padding(.horizontal)

                // MARK: - Playback Controls
                PlaybackControlsView(
                    isPlaying: data.isPlaying ?? false,
                    actions: data.actions,
                    shuffleState: data.shuffleState ?? false,
                    repeatState: data.repeatState ?? "off"
                )
                .padding(.horizontal)

                // MARK: - Device Info
                DeviceInfoView(device: data.device)
                    .padding(.bottom)

                Spacer() // Push content to the top

            } else {
                // MARK: - Placeholder/Loading State
                ContentUnavailableView(
                    "Nothing Playing",
                     systemImage: "music.note.list",
                    description: Text("Open Spotify on another device to control playback.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the VStack take available space
        .background(Color(.systemGroupedBackground)) // Example background
    }
}

// MARK: - Sub-Views for Better Organization

struct AlbumArtView: View {
    let imageUrl: String?

    var body: some View {
        AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 250, height: 250) // Consistent size
                    .background(Color.secondary.opacity(0.2))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                 .shadow(radius: 8) // Add a subtle shadow
            case .failure:
                Image(systemName: "music.note")
                    .font(.system(size: 100))
                    .foregroundColor(.secondary)
                    .frame(width: 250, height: 250)
                    .background(Color.secondary.opacity(0.2))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 250, height: 250) // Define frame for the image area
        .cornerRadius(8) // Rounded corners for the album art
    }
}

struct TrackInfoView: View {
    let trackName: String?
    let artistName: String?

    var body: some View {
        VStack {
            Text(trackName ?? "Unknown Track")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1) // Prevent long track names from wrapping excessively

            Text(artistName ?? "Unknown Artist")
                .font(.title3)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .multilineTextAlignment(.center)
    }
}

struct ProgressBarView: View {
    let progressMs: Int?
    let durationMs: Int?

    private var progressValue: Double {
        guard let progress = progressMs, let duration = durationMs, duration > 0 else { return 0.0 }
        return Double(progress) / Double(duration)
    }

    var body: some View {
        VStack(spacing: 5) {
            ProgressView(value: progressValue)
                .tint(.primary) // Make progress bar match text color

            HStack {
                Text(formatTime(milliseconds: progressMs))
                Spacer()
                Text(formatTime(milliseconds: durationMs))
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let actions: PlayerActions?
    let shuffleState: Bool
    let repeatState: String // "off", "track", "context"

    var body: some View {
        HStack(spacing: 30) { // Increased spacing for controls
            // Shuffle Button
            Button { /* Action */ } label: {
                Image(systemName: "shuffle")
                    .font(.title2)
                    .foregroundColor(shuffleState ? .accentColor : .secondary) // Highlight if active
            }
            .disabled(!(actions?.togglingShuffle ?? false)) // Disable based on API actions

            // Previous Button
            Button { /* Action */ } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
            }
             .disabled(!(actions?.skippingPrev ?? false))

            // Play/Pause Button
            Button { /* Action */ } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50)) // Make play/pause larger
            }
            .disabled(isPlaying ? !(actions?.pausing ?? false) : !(actions?.resuming ?? false))

            // Next Button
            Button { /* Action */ } label: {
                Image(systemName: "forward.fill")
                     .font(.title)
            }
            .disabled(!(actions?.skippingNext ?? false))

            // Repeat Button
            Button { /* Action */ } label: {
                let repeatIcon = (repeatState == "track") ? "repeat.1" : "repeat"
                Image(systemName: repeatIcon)
                     .font(.title2)
                    .foregroundColor(repeatState != "off" ? .accentColor : .secondary) // Highlight if active
            }
            // Disable based on either context or track repeat action availability
            .disabled(!(actions?.togglingRepeatContext ?? false) && !(actions?.togglingRepeatTrack ?? false))
        }
         .foregroundColor(.primary) // Default color for enabled buttons
    }
}

struct DeviceInfoView: View {
    let device: Device?

    var body: some View {
         HStack {
            Spacer() // Push to center alignment (or adjust as needed)
            Image(systemName: deviceIcon(type: device?.type))
            Text(device?.name ?? "Unknown Device")
            if let volume = device?.volumePercent, device?.supportsVolume ?? false {
                 // Optionally show volume if supported
                 Text("(\(volume)%)")
            }
            Spacer()
        }
        .font(.caption)
        .foregroundColor(.secondary) // Less prominent text
        .padding(.top, 5) // Add some space above device info
    }
}

// MARK: - Preview
struct CurrentlyPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        // Example with data loaded (replace with actual parsed data or a mock)
        CurrentlyPlayingView(currentlyPlayingData: sampleData)

        // Example when nothing is playing
        CurrentlyPlayingView(currentlyPlayingData: nil)
    }

    // Sample data for preview (use your real JSON data structure)
    static var sampleData: CurrentlyPlayingResponse {
         // Create a mock CurrentlyPlayingResponse instance based on your JSON
         // This is a simplified example
         return CurrentlyPlayingResponse(
            device: Device(id: "123", isActive: true, isPrivateSession: false, isRestricted: false, name: "My MacBook Pro", type: "Computer", volumePercent: 75, supportsVolume: true),
            repeatState: "context",
            shuffleState: true,
            context: PlaybackContext(type: "playlist", href: nil, externalUrls: nil, uri: nil),
            timestamp: Int(Date().timeIntervalSince1970 * 1000),
            progressMs: 65000, // 1 minute 5 seconds
            isPlaying: true,
            item: PlayableItem(
                album: Album(albumType: "album", totalTracks: 12, availableMarkets: nil, externalUrls: nil, href: nil, id: "alb1", images: [ImageInfo(url: "https://i.scdn.co/image/ab67616d0000b273 BLAH", height: 640, width: 640)], name: "Awesome Album", releaseDate: "2023", releaseDatePrecision: "year", restrictions: nil, type: "album", uri: nil, artists: []),
                artists: [Artist(externalUrls: nil, href: nil, id: "art1", name: "Cool Artist", type: "artist", uri: nil)],
                availableMarkets: nil,
                discNumber: 1,
                durationMs: 240000, // 4 minutes
                explicit: false,
                externalIds: nil,
                externalUrls: nil,
                href: nil,
                id: "track1",
                isPlayable: true,
                restrictions: nil,
                name: "The Best Song Ever",
                popularity: 85,
                previewUrl: nil,
                trackNumber: 3,
                type: "track",
                uri: nil,
                isLocal: false
            ),
            currentlyPlayingType: "track",
            actions: PlayerActions(interruptingPlayback: true, pausing: true, resuming: true, seeking: true, skippingNext: true, skippingPrev: true, togglingRepeatContext: true, togglingShuffle: true, togglingRepeatTrack: true, transferringPlayback: true)
         )
    }
}


