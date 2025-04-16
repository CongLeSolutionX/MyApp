////
////  AlbumDetailView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import Combine // Needed for state management observation if it were more complex
//
//// MARK: - Data Models (Unchanged from previous, ensure Identifiable)
//struct AlbumData {
//    // ... (Keep the same mock data as before)
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
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Sensato")], discNumber: 1, durationMs: 85400, explicit: true, name: "Global Warming (feat. Sensato)", trackNumber: 1, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "TJR")], discNumber: 1, durationMs: 206120, explicit: false, name: "Don't Stop the Party (feat. TJR)", trackNumber: 2, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Christina Aguilera")], discNumber: 1, durationMs: 229506, explicit: false, name: "Feel This Moment (feat. Christina Aguilera)", trackNumber: 3, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull")], discNumber: 1, durationMs: 207440, explicit: false, name: "Back in Time - featured in \"Men In Black 3\"", trackNumber: 4, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Chris Brown")], discNumber: 1, durationMs: 221133, explicit: false, name: "Hope We Meet Again (feat. Chris Brown)", trackNumber: 5, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "USHER"), ArtistData(name: "AFROJACK")], discNumber: 1, durationMs: 243160, explicit: true, name: "Party Ain't Over (feat. Usher & Afrojack)", trackNumber: 6, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
//        TrackData(artists: [ArtistData(name: "Pitbull"), ArtistData(name: "Jennifer Lopez")], discNumber: 1, durationMs: 196920, explicit: false, name: "Drinks for You (Ladies Anthem) (feat. J. Lo)", trackNumber: 7, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3")
//        // ... Add more tracks if needed
//    ], total: 18)
//    let copyrights: [CopyrightData] = [
//        CopyrightData(text: "(P) 2012 RCA Records, a division of Sony Music Entertainment", type: "P")
//    ]
//    let label: String = "Mr.305/Polo Grounds Music/RCA Records"
//    let popularity: Int = 55
//}
//
//struct ImageData {
//    let url: String
//    let height: Int
//    let width: Int
//}
//
//struct ArtistData: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct TrackListData {
//    let items: [TrackData]
//    let total: Int
//}
//
//struct TrackData: Identifiable {
//    let id = UUID() // Essential for tracking selection
//    let artists: [ArtistData]
//    let discNumber: Int
//    let durationMs: Int
//    let explicit: Bool
//    let name: String
//    let trackNumber: Int
//    // Add a mock URL for sharing
//    var mockTrackUrl: String { "https://open.spotify.com/track/mock-\(id.uuidString.prefix(8))" }
//    let audioURL: String? // <<<< ADDED: URL for actual playback
//}
//
//struct CopyrightData {
//    let text: String
//    let type: String
//}
//
//// MARK: - Helper Functions (Unchanged)
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
//// MARK: - Share Sheet Helper
//// Needs to be defined to use UIActivityViewController in SwiftUI
//struct ActivityViewController: UIViewControllerRepresentable {
//    var activityItems: [Any]
//    var applicationActivities: [UIActivity]? = nil
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}
//
//// MARK: - SwiftUI View
//
//struct AlbumDetailView: View {
//    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
//    let albumData = AlbumData()
//    
//    // --- State Variables ---
//    @State private var currentlyPlayingTrackId: UUID? = nil // Track which track is "playing"
//    @State private var showingShareSheet = false
//    @State private var itemToShare: ActivityViewController? = nil
//    @State private var showingQueueAlert = false
//    @State private var queuedTrackName = ""
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                AlbumHeaderView(albumData: albumData)
//                Divider()
//                AlbumMetadataView(albumData: albumData)
//                Divider()
//                TrackListView(
//                    tracks: albumData.tracks.items,
//                    onSelectArtist: { _ in // Callback for artist tap
//                        print("Artist tapped!")
//                    },
//                    onAddToQueue: { trackName in // Callback for queue tap
//                        queuedTrackName = trackName
//                        showingQueueAlert = true
//                    },
//                    onShareTrack: { track in // Callback for share tap
//                        // Prepare items to share
//                        let shareText = "Check out \"\(track.name)\" by \(formatArtists(artists: track.artists)) on Spotify!"
//                        if let url = URL(string: track.mockTrackUrl) {
//                            itemToShare = ActivityViewController(activityItems: [shareText, url])
//                        } else {
//                            itemToShare = ActivityViewController(activityItems: [shareText])
//                        }
//                        showingShareSheet = true
//                    }
//                )
//            }
//            .padding()
//        }
//        .navigationTitle(albumData.name)
//        .navigationBarTitleDisplayMode(.inline)
//        .alert("Track Added", isPresented: $showingQueueAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("\"\(queuedTrackName)\" added to your queue (simulated).")
//        }
//        .sheet(item: $itemToShare) { item in // Changed from isPresented to item for safer presentation
//            item // Present the ActivityViewController
//        }
//    }
//}
//
//// MARK: - Subviews (Updated)
//
//struct AlbumHeaderView: View { // No functional changes needed here for now
//    let albumData: AlbumData
//    
//    var body: some View {
//        VStack(alignment: .center, spacing: 12) {
//            AsyncImage(url: URL(string: albumData.images.first?.url ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(maxWidth: 300, maxHeight: 300) // Give placeholder size
//                        .background(Color.secondary.opacity(0.1))
//                        .cornerRadius(8)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .cornerRadius(8)
//                        .shadow(radius: 5)
//                case .failure:
//                    Image(systemName: "photo") // Fallback icon
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxWidth: 300, maxHeight: 300)
//                        .padding(50)
//                        .background(Color.secondary.opacity(0.1))
//                        .foregroundColor(.secondary)
//                        .cornerRadius(8)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(maxWidth: 300)
//            
//            Text(albumData.name)
//                .font(.title2)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//            
//            NavigationLink(destination: ArtistDetailView(artistName: formatArtists(artists: albumData.artists))) {
//                
//                Text(formatArtists(artists: albumData.artists))
//                    .font(.headline)
//                    .foregroundStyle(.secondary) // More semantic
//                
//            }
//            .buttonStyle(.plain)
//            
//            Text("\(albumData.albumType.capitalized) • \(extractYear(from: albumData.releaseDate))")
//                .font(.subheadline)
//                .foregroundStyle(.gray)
//            
//            if let url = URL(string: albumData.spotifyUrl) {
//                Link(destination: url) {
//                    Label("Listen on Spotify", systemImage: "play.circle.fill") // Add icon
//                        .font(.footnote)
//                        .fontWeight(.medium)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .background(.green)
//                        .foregroundStyle(.white)
//                        .clipShape(Capsule())
//                }
//                .padding(.top, 5)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .center)
//    }
//}
//
//struct AlbumMetadataView: View { // No functional changes needed here
//    let albumData: AlbumData
//    // ... (Keep the same as before)
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("\(albumData.totalTracks) tracks")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//            Text("Label: \(albumData.label)")
//                .font(.footnote)
//                .foregroundStyle(.secondary)
//                .lineLimit(1) // Prevent long labels taking too much space
//            if let copyright = albumData.copyrights.first {
//                Text(copyright.text)
//                    .font(.caption)
//                    .foregroundStyle(.gray)
//                    .lineLimit(1)
//            }
//            HStack {
//                Text("Popularity:")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//                ProgressView(value: Double(albumData.popularity), total: 100.0)
//                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
//                    .frame(height: 5)
//                    .accessibilityLabel("Popularity score \(albumData.popularity) out of 100") // Accessibility
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//struct TrackListView: View {
//    @EnvironmentObject var audioPlayerManager: AudioPlayerManager // Needs access too
//    let tracks: [TrackData]
//    //@Binding var currentlyPlayingTrackId: UUID? // Receive binding
//    // Callbacks for interactions
//    let onSelectArtist: (String) -> Void
//    let onAddToQueue: (String) -> Void
//    let onShareTrack: (TrackData) -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Tracks")
//                .font(.headline)
//                .padding(.bottom, 5)
//            
//            ForEach(tracks) { track in
//                TrackRow(
//                    track: track,
//                    // isPlaying and onPlayTap are removed, handled internally via manager
//                    onArtistTap: onSelectArtist, // Pass callback through
//                    onQueueTap: { onAddToQueue(track.name) },
//                    onShareTap: { onShareTrack(track) }
//                )
//                // Pass the environment object implicitly or explicitly if needed: .environmentObject(audioPlayerManager)
//                Divider().padding(.leading, 40)
//            }
//        }
//    }
//}
//
//// Add Identifiable conformance for the item parameter in .sheet
//extension ActivityViewController: Identifiable {
//    var id: UUID { UUID() } // Simple identifiable conformance
//}
//
//struct TrackRow: View {
//    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
//    let track: TrackData
//    //    let isPlaying: Bool
//    //    let onPlayTap: () -> Void
//    let onArtistTap: (String) -> Void
//    let onQueueTap: () -> Void
//    let onShareTap: () -> Void
//    
//    // Determine if *this* track is the one currently playing/paused
//    var isPlaying: Bool {
//        audioPlayerManager.currentlyPlayingTrackID == track.id && audioPlayerManager.isPlaying
//    }
//    var isCurrentlySelectedTrack: Bool {
//        audioPlayerManager.currentlyPlayingTrackID == track.id
//    }
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 12) { // Reduced spacing slightly
//            // --- Icon Logic ---
//            Group {
//                if isCurrentlySelectedTrack { // Show icon if selected (playing or paused)
//                    Image(systemName: isPlaying ? "pause.fill" : "play.fill") // Show play/pause icon
//                        .foregroundStyle(.green)
//                        .frame(width: 25, alignment: .center)
//                } else {
//                    Text("\(track.trackNumber)")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                        .frame(width: 25, alignment: .trailing)
//                }
//            }
//            .padding(.trailing, 5)
//            
//            // --- Main Track Info (Tappable for playing/pausing) ---
//            // Changed from Button to simple tap gesture on HStack content
//            HStack {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(track.name)
//                            .font(.body)
//                            .lineLimit(1)
//                            .foregroundStyle(isCurrentlySelectedTrack ? .green : .primary) // Highlight selected
//                        if track.explicit {
//                            // ... explicit badge ...
//                        }
//                    }
//                    
//                    // Artist Text - NavigationLink (from previous step)
//                    NavigationLink(destination: ArtistDetailView(artistName: formatArtists(artists: track.artists))) {
//                        Text(formatArtists(artists: track.artists))
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                            .lineLimit(1)
//                    }
//                    .buttonStyle(.plain)
//                }
//                Spacer()
//            }
//            .contentShape(Rectangle()) // Make the area tappable
//            .onTapGesture {
//                // Use the toggle function
//                audioPlayerManager.togglePlayPause(for: track.id, urlString: track.audioURL)
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            }
//            
//            Spacer() // Pushes actions and duration to the trailing edge
//            
//            // --- Action Buttons ---
//            HStack(spacing: 15) { // Consistent spacing
//                Button {
//                    onQueueTap()
//                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                } label: {
//                    Image(systemName: "plus.circle")
//                        .foregroundStyle(.secondary)
//                }
//                .buttonStyle(.plain)
//                
//                Button {
//                    onShareTap()
//                } label: {
//                    Image(systemName: "square.and.arrow.up")
//                        .foregroundStyle(.secondary)
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(.trailing, 5) // Add space before duration
//            
//            Text(formatDuration(ms: track.durationMs))
//                .font(.caption)
//                .foregroundStyle(.secondary)
//                .frame(width: 40, alignment: .trailing) // Fixed width for alignment
//        }
//        .padding(.vertical, 8)
//        .background(isCurrentlySelectedTrack ? Color.green.opacity(0.1) : Color.clear) // Subtle background highlight for selected track
//        .animation(.easeInOut(duration: 0.2), value: isCurrentlySelectedTrack) // Animate highlight change
//        .animation(.easeInOut, value: isPlaying) // Animate play/pause icon potentially
//        .onChange(of: audioPlayerManager.errorMessage) {
//            // Optional: Show an alert here if audioPlayerManager.errorMessage is not nil
//            print("Error from audioPlayerManager.errorMessage: \(String(describing: audioPlayerManager.errorMessage))")
//        }
//        
//    }
//}
//
//// MARK: - Preview
//
//struct AlbumDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            AlbumDetailView()
//        }
//        .preferredColorScheme(.dark) // Preview in dark mode too
//        .environmentObject(AudioPlayerManager()) // Provide for preview
//        
//        NavigationView {
//            AlbumDetailView()
//        }
//        .preferredColorScheme(.light)
//        .environmentObject(AudioPlayerManager()) // Provide for preview
//    }
//}
