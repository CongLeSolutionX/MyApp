
import SwiftUI
import Combine

// MARK: - Data Models

struct SpotifyRemake_Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    // In a real app, a URL for an audio file or preview might be provided.
}

struct SpotifyRemake_Playlist {
    let id = UUID()
    let title: String
    let description: String
    let creator: String
    let artworkColor: Color
    let likes: Int
    let totalDuration: TimeInterval // in seconds
    let songs: [SpotifyRemake_Song]
}

struct SpotifyRemake_Ad: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String?
    let callToAction: String
    let backgroundColor: Color
}

// MARK: - Mock Data Store

struct MockDataStore {
    static let sampleSongs: [SpotifyRemake_Song] = [
        SpotifyRemake_Song(title: "Sunrise", artist: "Celestial Vibes"),
        SpotifyRemake_Song(title: "Midnight Run", artist: "Night Riders"),
        SpotifyRemake_Song(title: "Ocean Breeze", artist: "Cool Collective"),
        SpotifyRemake_Song(title: "City Lights", artist: "Urban Groove"),
        SpotifyRemake_Song(title: "Euphoria", artist: "Chill Nation"),
        SpotifyRemake_Song(title: "Rhythm Pulse", artist: "DJ Dynamic")
    ]
    
    static let discoverWeekly = SpotifyRemake_Playlist(
        title: "Discover Weekly",
        description: "Your personalized new music mix",
        creator: "Spotify",
        artworkColor: Color.purple,
        likes: 12000,
        totalDuration: 3600, // 1 hour
        songs: sampleSongs
    )
    
    static let advertiserAds: [SpotifyRemake_Ad] = [
        SpotifyRemake_Ad(title: "Gear up!", iconName: "headphones", callToAction: "Shop Now", backgroundColor: Color.orange),
        SpotifyRemake_Ad(title: "Discover trends", iconName: "flame.fill", callToAction: "Learn More", backgroundColor: Color.red),
        SpotifyRemake_Ad(title: "Fitness Pro", iconName: "figure.walk", callToAction: "Try It", backgroundColor: Color.green)
    ]
}

// MARK: - Player View Model

final class SpotifyRemake_PlayerViewModel: ObservableObject {
    @Published var currentSong: SpotifyRemake_Song? = nil
    @Published var isPlaying: Bool = false
    @Published var currentPlaylist: SpotifyRemake_Playlist? = nil
    
    // Simulated play a given song with an optional playlist context.
    func play(song: SpotifyRemake_Song, playlist: SpotifyRemake_Playlist? = nil) {
        currentPlaylist = playlist
        currentSong = song
        isPlaying = true
        print("Playing song: \(song.title) by \(song.artist)")
    }
    
    // Simulate a “play playlist” request by playing the first song.
    // In a real app you might shuffle, queue songs, or use a dedicated audio engine.
    func play(playlist: SpotifyRemake_Playlist) {
        guard let firstSong = playlist.songs.first else {
            print("Playlist \(playlist.title) is empty")
            return
        }
        play(song: firstSong, playlist: playlist)
    }
    
    // Simulate a “Shuffle Play” action.
    func shufflePlay(playlist: SpotifyRemake_Playlist) {
        guard !playlist.songs.isEmpty else {
            print("Playlist \(playlist.title) is empty")
            return
        }
        let randomSong = playlist.songs.randomElement()!
        play(song: randomSong, playlist: playlist)
        print("Shuffle play started on \(playlist.title)")
    }
    
    // Toggle play/pause (here, only presentation changes)
    func togglePlayback() {
        isPlaying.toggle()
        if let song = currentSong {
            print(isPlaying ? "Resumed playing \(song.title)" : "Paused \(song.title)")
        }
    }
}

// MARK: - Main Playlist View

struct SpotifyRemake_PlaylistView: View {
    let playlist: SpotifyRemake_Playlist
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
    @State private var isLiked: Bool = false
    @State private var isDownloaded: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Playlist Header – artwork and title overlay
                SpotifyRemake_PlaylistHeaderView(playlist: playlist)
                
                // Metadata – creator information, likes and total duration
                SpotifyRemake_PlaylistMetadataView(playlist: playlist)
                
                // Action Buttons – like, download, more options, play song and shuffle play
                SpotifyRemake_PlaylistActionButtonsView(
                    playlist: playlist,
                    isLiked: $isLiked,
                    isDownloaded: $isDownloaded
                )
                
                // Song List preview – show first few songs in the playlist
                SpotifyRemake_SongListViewPreview(songs: Array(playlist.songs.prefix(5)))
                
                // Full-width “Shuffle Play” button
                SpotifyRemake_FullWidthButton(title: "Shuffle Play") {
                    playerViewModel.shufflePlay(playlist: playlist)
                }
                .padding(.vertical)
                
                // Recent Advertisers – row of advertiser cards using mock data
                SpotifyRemake_RecentAdvertisersView(ads: MockDataStore.advertiserAds)
                
                Spacer(minLength: playerViewModel.currentSong != nil ? 80 : 0) // Adjust if mini player is present
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Navigation back button (custom styling)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Playlist Header View

struct SpotifyRemake_PlaylistHeaderView: View {
    let playlist: SpotifyRemake_Playlist

    var body: some View {
        VStack {
            // Artwork using a color block as a placeholder with an overlay for the title
            playlist.artworkColor
                .aspectRatio(1.0, contentMode: .fit)
                .cornerRadius(8)
                .padding(.top)
                .overlay(
                    VStack {
                        Spacer()
                        Text(playlist.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.5))
                    }
                )
            
            // Playlist description text
            Text(playlist.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 5)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Playlist Metadata View

struct SpotifyRemake_PlaylistMetadataView: View {
    let playlist: SpotifyRemake_Playlist

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "music.note.list") // Placeholder icon for creator/logo
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Circle().fill(Color.gray.opacity(0.3)))
                Text(playlist.creator)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            // Format the total playlist duration into hours and minutes
            let formatter: DateComponentsFormatter = {
                let f = DateComponentsFormatter()
                f.allowedUnits = [.hour, .minute]
                f.unitsStyle = .abbreviated
                return f
            }()
            let durationString = formatter.string(from: playlist.totalDuration) ?? "N/A"
            
            Text("\(playlist.likes) likes • \(durationString)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Playlist Action Buttons View

struct SpotifyRemake_PlaylistActionButtonsView: View {
    let playlist: SpotifyRemake_Playlist
    @Binding var isLiked: Bool
    @Binding var isDownloaded: Bool
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
    
    var body: some View {
        HStack(spacing: 25) {
            // Like button
            Button {
                isLiked.toggle()
                print("[ACTION] Playlist liked: \(isLiked)")
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .green : .gray)
                    .font(.title2)
            }
            
            // Download button
            Button {
                isDownloaded.toggle()
                print("[ACTION] Playlist download: \(isDownloaded)")
            } label: {
                Image(systemName: isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
                    .foregroundColor(isDownloaded ? .green : .gray)
                    .font(.title2)
            }
            
            // More options
            Button {
                print("[ACTION] More options tapped")
                // Present further options or an action sheet here if desired.
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
            
            Spacer()
            
            // Play button (plays the first song)
            Button {
                print("[ACTION] Play button tapped for playlist \(playlist.title)")
                if let firstSong = playlist.songs.first {
                    playerViewModel.play(song: firstSong, playlist: playlist)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 55, height: 55)
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Song List Preview View

struct SpotifyRemake_SongListViewPreview: View {
    let songs: [SpotifyRemake_Song]
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(songs) { song in
                HStack {
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        Text(song.artist)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        print("[ACTION] Options for song \(song.title)")
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 5)
                .contentShape(Rectangle())
                .onTapGesture {
                    print("[ACTION] Tapped song \(song.title)")
                    playerViewModel.play(song: song)
                }
                Divider().background(Color.gray.opacity(0.3))
            }
        }
    }
}

// MARK: - Fullwidth Button View

struct SpotifyRemake_FullWidthButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.5))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Recent Advertisers View

struct SpotifyRemake_RecentAdvertisersView: View {
    let ads: [SpotifyRemake_Ad]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent advertisers")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(ads) { ad in
                        SpotifyRemake_AdvertiserCardView(ad: ad)
                    }
                }
            }
        }
    }
}

// MARK: - Advertiser Card View

struct SpotifyRemake_AdvertiserCardView: View {
    let ad: SpotifyRemake_Ad
    
    var body: some View {
        HStack {
            if let icon = ad.iconName {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 8)
            }
            Text(ad.title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(ad.callToAction) {
                print("[ACTION] Advertiser tapped: \(ad.title)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(15)
            .font(.system(size: 12, weight: .bold))
        }
        .padding()
        .background(ad.backgroundColor)
        .cornerRadius(8)
        .frame(width: 300)
    }
}

// MARK: - Preview and Root View

struct CollectionItemView: View {
    var body: some View {
        NavigationView {
            // Use a grid or list for home screen preview
            VStack {
                NavigationLink {
                    SpotifyRemake_PlaylistView(playlist: MockDataStore.discoverWeekly)
                        .environmentObject(SpotifyRemake_PlayerViewModel())
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(MockDataStore.discoverWeekly.artworkColor)
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading) {
                            Text(MockDataStore.discoverWeekly.title)
                                .foregroundColor(.white)
                                .font(.headline)
                            Text("Discover Weekly")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionItemView()
            .preferredColorScheme(.dark)
    }
}
