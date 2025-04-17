////
////  GetCurrentlyPlayingTrackView.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//
//struct CurrentlyPlayingView: View {
//    // Assume this data is passed into the view after parsing the JSON
//    let currentlyPlayingData: CurrentlyPlayingResponse?
//
//    var body: some View {
//        VStack(spacing: 15) {
//            if let data = currentlyPlayingData, let item = data.item {
//                // MARK: - Album Art
//                AlbumArtView(imageUrl: item.album?.images?.first?.url)
//                    .padding(.top)
//
//                // MARK: - Track Info
//                TrackInfoView(trackName: item.name, artistName: item.artists?.map { $0.name ?? "" }.joined(separator: ", "))
//                    .padding(.horizontal)
//
//                // MARK: - Progress Bar
//                ProgressBarView(
//                    progressMs: data.progressMs,
//                    durationMs: item.durationMs
//                )
//                .padding(.horizontal)
//
//                // MARK: - Playback Controls
//                PlaybackControlsView(
//                    isPlaying: data.isPlaying ?? false,
//                    actions: data.actions,
//                    shuffleState: data.shuffleState ?? false,
//                    repeatState: data.repeatState ?? "off"
//                )
//                .padding(.horizontal)
//
//                // MARK: - Device Info
//                DeviceInfoView(device: data.device)
//                    .padding(.bottom)
//
//                Spacer() // Push content to the top
//
//            } else {
//                // MARK: - Placeholder/Loading State
//                ContentUnavailableView(
//                    "Nothing Playing",
//                     systemImage: "music.note.list",
//                    description: Text("Open Spotify on another device to control playback.")
//                )
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the VStack take available space
//        .background(Color(.systemGroupedBackground)) // Example background
//    }
//}
//
//// MARK: - Sub-Views for Better Organization
//
//struct AlbumArtView: View {
//    let imageUrl: String?
//
//    var body: some View {
//        AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//                    .frame(width: 250, height: 250) // Consistent size
//                    .background(Color.secondary.opacity(0.2))
//            case .success(let image):
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                 .shadow(radius: 8) // Add a subtle shadow
//            case .failure:
//                Image(systemName: "music.note")
//                    .font(.system(size: 100))
//                    .foregroundColor(.secondary)
//                    .frame(width: 250, height: 250)
//                    .background(Color.secondary.opacity(0.2))
//            @unknown default:
//                EmptyView()
//            }
//        }
//        .frame(width: 250, height: 250) // Define frame for the image area
//        .cornerRadius(8) // Rounded corners for the album art
//    }
//}
//
//struct TrackInfoView: View {
//    let trackName: String?
//    let artistName: String?
//
//    var body: some View {
//        VStack {
//            Text(trackName ?? "Unknown Track")
//                .font(.title2)
//                .fontWeight(.bold)
//                .lineLimit(1) // Prevent long track names from wrapping excessively
//
//            Text(artistName ?? "Unknown Artist")
//                .font(.title3)
//                .foregroundColor(.secondary)
//                .lineLimit(1)
//        }
//        .multilineTextAlignment(.center)
//    }
//}
//
//struct ProgressBarView: View {
//    let progressMs: Int?
//    let durationMs: Int?
//
//    private var progressValue: Double {
//        guard let progress = progressMs, let duration = durationMs, duration > 0 else { return 0.0 }
//        return Double(progress) / Double(duration)
//    }
//
//    var body: some View {
//        VStack(spacing: 5) {
//            ProgressView(value: progressValue)
//                .tint(.primary) // Make progress bar match text color
//
//            HStack {
//                Text(formatTime(milliseconds: progressMs))
//                Spacer()
//                Text(formatTime(milliseconds: durationMs))
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//        }
//    }
//}
//
//struct PlaybackControlsView: View {
//    let isPlaying: Bool
//    let actions: PlayerActions?
//    let shuffleState: Bool
//    let repeatState: String // "off", "track", "context"
//
//    var body: some View {
//        HStack(spacing: 30) { // Increased spacing for controls
//            // Shuffle Button
//            Button { /* Action */ } label: {
//                Image(systemName: "shuffle")
//                    .font(.title2)
//                    .foregroundColor(shuffleState ? .accentColor : .secondary) // Highlight if active
//            }
//            .disabled(!(actions?.togglingShuffle ?? false)) // Disable based on API actions
//
//            // Previous Button
//            Button { /* Action */ } label: {
//                Image(systemName: "backward.fill")
//                    .font(.title)
//            }
//             .disabled(!(actions?.skippingPrev ?? false))
//
//            // Play/Pause Button
//            Button { /* Action */ } label: {
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.system(size: 50)) // Make play/pause larger
//            }
//            .disabled(isPlaying ? !(actions?.pausing ?? false) : !(actions?.resuming ?? false))
//
//            // Next Button
//            Button { /* Action */ } label: {
//                Image(systemName: "forward.fill")
//                     .font(.title)
//            }
//            .disabled(!(actions?.skippingNext ?? false))
//
//            // Repeat Button
//            Button { /* Action */ } label: {
//                let repeatIcon = (repeatState == "track") ? "repeat.1" : "repeat"
//                Image(systemName: repeatIcon)
//                     .font(.title2)
//                    .foregroundColor(repeatState != "off" ? .accentColor : .secondary) // Highlight if active
//            }
//            // Disable based on either context or track repeat action availability
//            .disabled(!(actions?.togglingRepeatContext ?? false) && !(actions?.togglingRepeatTrack ?? false))
//        }
//         .foregroundColor(.primary) // Default color for enabled buttons
//    }
//}
//
//struct DeviceInfoView: View {
//    let device: Device?
//
//    var body: some View {
//         HStack {
//            Spacer() // Push to center alignment (or adjust as needed)
//            Image(systemName: deviceIcon(type: device?.type))
//            Text(device?.name ?? "Unknown Device")
//            if let volume = device?.volumePercent, device?.supportsVolume ?? false {
//                 // Optionally show volume if supported
//                 Text("(\(volume)%)")
//            }
//            Spacer()
//        }
//        .font(.caption)
//        .foregroundColor(.secondary) // Less prominent text
//        .padding(.top, 5) // Add some space above device info
//    }
//}
//
//// MARK: - Preview
//struct CurrentlyPlayingView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Example with data loaded (replace with actual parsed data or a mock)
//        CurrentlyPlayingView(currentlyPlayingData: sampleData)
//
//        // Example when nothing is playing
//        CurrentlyPlayingView(currentlyPlayingData: nil)
//    }
//
//    // Sample data for preview (use your real JSON data structure)
//    static var sampleData: CurrentlyPlayingResponse {
//         // Create a mock CurrentlyPlayingResponse instance based on your JSON
//         // This is a simplified example
//         return CurrentlyPlayingResponse(
//            device: Device(id: "123", isActive: true, isPrivateSession: false, isRestricted: false, name: "My MacBook Pro", type: "Computer", volumePercent: 75, supportsVolume: true),
//            repeatState: "context",
//            shuffleState: true,
//            context: PlaybackContext(type: "playlist", href: nil, externalUrls: nil, uri: nil),
//            timestamp: Int(Date().timeIntervalSince1970 * 1000),
//            progressMs: 65000, // 1 minute 5 seconds
//            isPlaying: true,
//            item: PlayableItem(
//                album: Album(albumType: "album", totalTracks: 12, availableMarkets: nil, externalUrls: nil, href: nil, id: "alb1", images: [ImageInfo(url: "https://i.scdn.co/image/ab67616d0000b273 BLAH", height: 640, width: 640)], name: "Awesome Album", releaseDate: "2023", releaseDatePrecision: "year", restrictions: nil, type: "album", uri: nil, artists: []),
//                artists: [Artist(externalUrls: nil, href: nil, id: "art1", name: "Cool Artist", type: "artist", uri: nil)],
//                availableMarkets: nil,
//                discNumber: 1,
//                durationMs: 240000, // 4 minutes
//                explicit: false,
//                externalIds: nil,
//                externalUrls: nil,
//                href: nil,
//                id: "track1",
//                isPlayable: true,
//                restrictions: nil,
//                name: "The Best Song Ever",
//                popularity: 85,
//                previewUrl: nil,
//                trackNumber: 3,
//                type: "track",
//                uri: nil,
//                isLocal: false
//            ),
//            currentlyPlayingType: "track",
//            actions: PlayerActions(interruptingPlayback: true, pausing: true, resuming: true, seeking: true, skippingNext: true, skippingPrev: true, togglingRepeatContext: true, togglingShuffle: true, togglingRepeatTrack: true, transferringPlayback: true)
//         )
//    }
//}
//
//
