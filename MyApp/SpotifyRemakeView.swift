//
//  SpotifyRemakeView.swift
//  MyApp
//
//  Created by Cong Le on 4/8/25.
//


import SwiftUI

// MARK: - Data Models

struct SpotifyRemake_Song: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let duration: TimeInterval // in seconds
}

struct SpotifyRemake_Playlist: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let creator: String // e.g., "Spotify", "John Doe"
    let artworkColor: Color // Use color as placeholder for artwork
    let songs: [SpotifyRemake_Song]
    var totalDuration: TimeInterval { songs.reduce(0) { $0 + $1.duration } }
    var likes: Int = Int.random(in: 1000...500000) // Mock likes
}

// Simplified Album model for horizontal scroll
struct SpotifyRemake_Album: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String // Can be derived or explicit
    let artworkColor: Color
}

// Grid item model (can represent playlists, albums, podcasts etc.)
struct SpotifyRemake_GridItemData: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: ItemType // To know what kind of content it links to
    let artworkColor: Color

    enum ItemType {
        case playlist(SpotifyRemake_Playlist) // Associated value holds the actual playlist
        case album(SpotifyRemake_Album)       // Can extend for other types
        case podcastEpisode
    }

    // Conformance for Hashable based on ID
    static func == (lhs: SpotifyRemake_GridItemData, rhs: SpotifyRemake_GridItemData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Ad model for clarity
struct SpotifyRemake_Ad: Identifiable {
    let id = UUID()
    let title: String
    let callToAction: String
    let backgroundColor: Color
    let iconName: String? // Optional icon for advertiser cards
}

// MARK: - Mock Data Store

struct MockDataStore {
    static let songs: [SpotifyRemake_Song] = [
        SpotifyRemake_Song(title: "Blinded By The LEDs", artist: "Lindstrøm", duration: 245),
        SpotifyRemake_Song(title: "Tiny Cities", artist: "Flume ft. Beck", duration: 210),
        SpotifyRemake_Song(title: "Baby Let Me Kiss You", artist: "Fern Kinney", duration: 190),
        SpotifyRemake_Song(title: "Closing Shot", artist: "Lindstrøm", duration: 320),
        SpotifyRemake_Song(title: "Midnight Girl", artist: "Lindstrøm", duration: 280),
        SpotifyRemake_Song(title: "Indestructable", artist: "Robyn", duration: 225),
        SpotifyRemake_Song(title: "Atmosphere", artist: "Joy Division", duration: 250),
        SpotifyRemake_Song(title: "Genesis", artist: "Grimes", duration: 255),
    ]

    static let discoverWeekly = SpotifyRemake_Playlist(
        title: "Discover Weekly",
        description: "Your weekly mixtape of fresh music. Enjoy! Updated every Monday.",
        creator: "Spotify",
        artworkColor: .pink,
        songs: Array(songs.shuffled().prefix(30)) // 30 random songs
    )

    static let dailyMix1 = SpotifyRemake_Playlist(
        title: "Daily Mix 1",
        description: "Based on your recent listening.",
        creator: "Spotify",
        artworkColor: .blue,
        songs: Array(songs.shuffled().prefix(25))
    )

    static let replyAllPlaylist = SpotifyRemake_Playlist(
        title: "Reply All Favs",
        description: "Podcast episodes you might like.",
        creator: "User Generated",
        artworkColor: .gray,
        songs: [] // Represents podcast playlist
    )

    static let gridItems: [SpotifyRemake_GridItemData] = [
        SpotifyRemake_GridItemData(title: "A Pandemic Update: The V...", type: .podcastEpisode, artworkColor: .blue), // Link to podcast?
        SpotifyRemake_GridItemData(title: "Discover Weekly", type: .playlist(discoverWeekly), artworkColor: .pink),
        SpotifyRemake_GridItemData(title: "Daily Mix 1", type: .playlist(dailyMix1), artworkColor: .blue),
        SpotifyRemake_GridItemData(title: "Reply All", type: .playlist(replyAllPlaylist) , artworkColor: .gray), // Representing podcast link
        SpotifyRemake_GridItemData(title: "Chill Vibes", type: .playlist(dailyMix1), artworkColor: .purple), // Reuse DM1 for demo
        SpotifyRemake_GridItemData(title: "Focus Flow", type: .playlist(discoverWeekly), artworkColor: .indigo), // Reuse DW for demo
    ]

    static let albums: [SpotifyRemake_Album] = [
        SpotifyRemake_Album(title: "Low-Key", artist: "Various Artists", artworkColor: .purple),
        SpotifyRemake_Album(title: "Wildfire", artist: "Sampha", artworkColor: .orange),
        SpotifyRemake_Album(title: "Process", artist: "Sampha", artworkColor: .teal),
        SpotifyRemake_Album(title: "Ambient Chill", artist: "Various Artists", artworkColor: .yellow),
    ]

    static let mainAd = SpotifyRemake_Ad(
        title: "Get 20% off your first bag. Start your next journey today.",
        callToAction: "Buy now",
        backgroundColor: .pink, iconName: nil
    )

    static let advertiserAds: [SpotifyRemake_Ad] = [
        SpotifyRemake_Ad(title: "Fresh beans delivered to you each week.", callToAction: "Learn more", backgroundColor: Color.gray.opacity(0.3), iconName: "cup.and.saucer.fill"),
        SpotifyRemake_Ad(title: "Level up your setup.", callToAction: "Shop", backgroundColor: Color.gray.opacity(0.3), iconName: "gamecontroller.fill"),
        SpotifyRemake_Ad(title: "Immerse yourself.", callToAction: "Explore", backgroundColor: Color.gray.opacity(0.3), iconName: "headphones"),
    ]
}

// MARK: - Player View Model (Shared State)

class SpotifyRemake_PlayerViewModel: ObservableObject {
    @Published var currentSong: SpotifyRemake_Song? = nil // Make it optional
    @Published var isPlaying: Bool = false
    @Published var currentPlaylist: SpotifyRemake_Playlist? = nil // Track context if needed

    func play(song: SpotifyRemake_Song, playlist: SpotifyRemake_Playlist? = nil) {
        print("Playing song: \(song.title) by \(song.artist)")
        currentSong = song
        currentPlaylist = playlist // Keep track of the playlist context
        isPlaying = true
    }

    func play(playlist: SpotifyRemake_Playlist) {
        guard let firstSong = playlist.songs.first else {
            print("Playlist \(playlist.title) is empty.")
            return
        }
        play(song: firstSong, playlist: playlist)
        print("Starting playlist: \(playlist.title)")
    }

    func togglePlayback() {
        guard currentSong != nil else { return } // Can't toggle if nothing is loaded

        isPlaying.toggle()
        if isPlaying {
            print("Resuming playback: \(currentSong!.title)")
        } else {
            print("Pausing playback: \(currentSong!.title)")
        }
    }

    func pause() {
         if isPlaying {
             isPlaying = false
             print("Pausing playback: \(currentSong?.title ?? "Unknown")")
         }
     }

     func resume() {
         if !isPlaying && currentSong != nil {
             isPlaying = true
             print("Resuming playback: \(currentSong?.title ?? "Unknown")")
         }
     }
}

// MARK: - Main Content View (Entry Point with Tab Bar)

struct SpotifyRemake_ContentView: View {
    // Use StateObject to initialize the ViewModel here, making it the source of truth
    @StateObject private var playerViewModel = SpotifyRemake_PlayerViewModel()
    @State private var selectedTab = 0 // Keep track of the selected tab

    init() {
        // Customize Tab Bar Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.9) // Semi-transparent black

        // Set colors for selected and unselected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SpotifyRemake_HomeView() // Already wrapped in NavView internally
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0) // Assign tag for selection binding

             // Example placeholder views for other tabs
             Text("Search Screen Content")
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(Color.black.edgesIgnoringSafeArea(.all))
                 .foregroundColor(.white)
                 .tabItem { Label("Search", systemImage: "magnifyingglass") }
                 .tag(1)

            Text("Your Library Screen Content")
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(Color.black.edgesIgnoringSafeArea(.all))
                 .foregroundColor(.white)
                 .tabItem { Label("Your Library", systemImage: "books.vertical.fill") }
                 .tag(2)

            Text("Premium Screen Content")
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(Color.black.edgesIgnoringSafeArea(.all))
                 .foregroundColor(.white)
                .tabItem { Label("Premium", systemImage: "spotify.logo") }
                 .tag(3)
        }
        // Provide the PlayerViewModel to all child views within the TabView
        .environmentObject(playerViewModel)
        // Set accent color for the selected tab icon/text (redundant if using appearance)
        // .accentColor(.white) // Use UITabBarAppearance for better control
        .preferredColorScheme(.dark) // Enforce dark mode for the whole app
    }
}

// MARK: - Home Screen Structure

struct SpotifyRemake_HomeView: View {
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel // Access shared player state

    var body: some View {
        NavigationView { // Each tab should manage its own NavigationView if needed
            ZStack(alignment: .bottom) {
                // Main Scrolling Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SpotifyRemake_HomeHeaderView()
                        SpotifyRemake_GreetingGridView()
                        SpotifyRemake_MoreLikeSectionView(artistName: "Sampha", albums: MockDataStore.albums)
                        SpotifyRemake_AdBannerView(ad: MockDataStore.mainAd)
                        // Add another Album Section for variety
                        SpotifyRemake_MoreLikeSectionView(artistName: "Chill Beats", albums: MockDataStore.albums.shuffled())

                        // Spacer to push content up, leaving space for the player bar
                        Spacer(minLength: playerViewModel.currentSong != nil ? 80 : 0) // Only add space if player is visible
                    }
                    .padding(.horizontal)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true) // Use custom header

                // Mini Player Bar (Conditional Overlay)
                if playerViewModel.currentSong != nil {
                    SpotifyRemake_PlayerBarView()
                        // Add transition for smooth appearance/disappearance
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 49) // Standard TabBar height approx.
                        // Add tap gesture to potentially open full player later
                         .onTapGesture {
                             print("Mini player tapped! Should present full player.")
                             // Here you would set state to show a modal/full screen player
                         }

                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .animation(.easeInOut(duration: 0.3), value: playerViewModel.currentSong) // Animate player appearance
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Consistent navigation style
         // No need for .accentColor(.white) on NavigationView if TabView handles appearance
    }
}

// MARK: - Home Screen Components (Functionality Added)

struct SpotifyRemake_HomeHeaderView: View { // No changes needed for basic functionality
    var body: some View {
        HStack {
            Text("Good morning")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button {
                print("Settings button tapped!")
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.top)
    }
}

struct SpotifyRemake_GreetingGridView: View {
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
    let gridItemsData = MockDataStore.gridItems
    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(gridItemsData) { item in
                // NavigationLink wraps the item view
                NavigationLink(value: item) { // Use value-based navigation
                    SpotifyRemake_GridItemView(title: item.title, color: item.artworkColor)
                }
            }
        }
         // Define navigation destination for GridItemData
         .navigationDestination(for: SpotifyRemake_GridItemData.self) { item in
             switch item.type {
             case .playlist(let playlist):
                 SpotifyRemake_PlaylistView(playlist: playlist) // Navigate to PlaylistView
             case .album(let album):
                 Text("Album Detail Screen for \(album.title)") // Placeholder destination
                     .foregroundColor(.white)
             case .podcastEpisode:
                 Text("Podcast Episode Screen for \(item.title)") // Placeholder
                     .foregroundColor(.white)
             }
         }
    }
}

struct SpotifyRemake_GridItemView: View { // Primarily visual, action handled by NavigationLink wrapper
    let title: String
    let color: Color?

    var body: some View {
        HStack(spacing: 0) {
            (color ?? Color.gray) // Use color as placeholder background
                 .frame(width: 50, height: 50)
                 .overlay( // Add a generic icon placeholder if needed
                     Image(systemName: "music.note")
                         .foregroundColor(.white.opacity(0.7))
                 )

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure text takes space
        }
        .background(Color.gray.opacity(0.3)) // Cell background
        .cornerRadius(4)
        .frame(height: 50)
    }
}

struct SpotifyRemake_MoreLikeSectionView: View {
    let artistName: String
    let albums: [SpotifyRemake_Album] // Pass in the albums to display

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Placeholder for artist image
                Circle()
                    .fill(.gray)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading) {
                    Text("MORE LIKE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(artistName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(albums) { album in
                        NavigationLink(value: album) { // Navigate on tap
                            SpotifyRemake_AlbumCoverView(title: album.title, color: album.artworkColor)
                        }
                    }
                }
            }
        }
        // Define destination for Album type
         .navigationDestination(for: SpotifyRemake_Album.self) { album in
             // Placeholder: In a real app, navigate to an AlbumDetailView
             Text("Album Detail for \(album.title)")
                 .foregroundColor(.white)
                 .navigationTitle(album.title)
         }
    }
}

struct SpotifyRemake_AlbumCoverView: View { // Visual component
    let title: String
    let color: Color?

    var body: some View {
        VStack(alignment: .leading) {
            (color ?? Color.gray)
                .frame(width: 140, height: 140)
                .cornerRadius(4)
                .overlay(
                    VStack { // Add overlay content if desired
                       Spacer()
                        Text(title)
                             .font(.caption)
                            .foregroundColor(.white)
                             .lineLimit(1)
                             .padding(5)
                             .frame(maxWidth: .infinity)
                             .background(Color.black.opacity(0.4))
                     }
                ) // Example: Title overlay

           // Optionally display title below if not overlaid
           // Text(title)
           //     .font(.caption)
           //     .foregroundColor(.white.opacity(0.8))
           //     .frame(width: 140, alignment: .leading)
           //     .lineLimit(1)
           //     .padding(.top, 4)
        }
    }
}

struct SpotifyRemake_AdBannerView: View {
    let ad: SpotifyRemake_Ad
    var body: some View {
        HStack {
            Text(ad.title)
                 .font(.system(size: 14, weight: .semibold))
                 .foregroundColor(.white)
                 .frame(maxWidth: .infinity, alignment: .leading)

            Button(ad.callToAction) {
                 print("Ad button tapped: \(ad.callToAction)")
                 // Open URL, navigate, etc.
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(20)
            .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(ad.backgroundColor)
        .cornerRadius(8)
    }
}

struct SpotifyRemake_PlayerBarView: View {
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel

    var body: some View {
         // Ensure view updates when playerViewModel changes
        HStack(spacing: 10) {
            // Placeholder artwork (could use currentSong's associated artwork later)
             (playerViewModel.currentPlaylist?.artworkColor ?? .gray)
                .frame(width: 40, height: 40)
                .cornerRadius(4)
                .overlay(Image(systemName: "music.note").foregroundColor(.white))

            VStack(alignment: .leading) {
                Text(playerViewModel.currentSong?.title ?? "No Song Playing")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(playerViewModel.currentSong?.artist ?? "...")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                     .lineLimit(1)
            }
              .frame(maxWidth: .infinity, alignment: .leading)

            // Placeholder for device/cast icon
            Button { print("Device button tapped") } label: {
                Image(systemName: "hifispeaker.and.appletv")
                    .foregroundColor(.white)
                    .font(.title3)
            }

            // Play/Pause Button
            Button {
                playerViewModel.togglePlayback()
            } label: {
                Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.title2) // Make slightly larger
                     .frame(width: 30, height: 30) // Ensure consistent tap area
            }
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background(Color(UIColor.systemGray).opacity(0.8)) // Use a system color for better dark/light mode adaptation
         .cornerRadius(8) // Add slight rounding
         .padding(.horizontal, 8) // Add padding so it doesn't touch edges
    }
}

// MARK: - Playlist/Detail Screen Structure

struct SpotifyRemake_PlaylistView: View {
    let playlist: SpotifyRemake_Playlist // Receive the playlist data
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
    @State private var isLiked: Bool = false // Local state for the heart icon
    @State private var isDownloaded: Bool = false // Local state for download icon

    @Environment(\.presentationMode) var presentationMode // To dismiss if presented modally

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SpotifyRemake_PlaylistHeaderView(playlist: playlist)
                SpotifyRemake_PlaylistMetadataView(playlist: playlist)
                SpotifyRemake_PlaylistActionButtonsView(
                    playlist: playlist,
                    isLiked: $isLiked,
                    isDownloaded: $isDownloaded
                )

                 // Show first ~5 songs or info about them
                SpotifyRemake_SongListViewPreview(songs: Array(playlist.songs.prefix(5)))

                // Optional: Add a button to play the whole playlist
                 SpotifyRemake_FullWidthButton(title: "Shuffle Play") {
                     print("Shuffle play playlist: \(playlist.title)")
                     playerViewModel.play(playlist: playlist) // Start playing the playlist
                 }
                 .padding(.vertical)

                SpotifyRemake_RecentAdvertisersView(ads: MockDataStore.advertiserAds)

                 Spacer(minLength: playerViewModel.currentSong != nil ? 80 : 0) // Space for mini player
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .navigationTitle(playlist.title) // Use standard nav title
         .navigationBarTitleDisplayMode(.inline) // Keep title small
         // Add back button color if needed (often handled by NavigationView accentColor)
         .toolbar { // Example of adding a custom back button or other items
             ToolbarItem(placement: .navigationBarLeading) {
                 Button {
                     presentationMode.wrappedValue.dismiss() // Basic back action
                 } label: {
                     Image(systemName: "chevron.backward")
                         .foregroundColor(.white)
                 }
             }
         }
    }
}

// MARK: - Playlist Screen Components (Functionality Added)

struct SpotifyRemake_PlaylistHeaderView: View {
    let playlist: SpotifyRemake_Playlist
    var body: some View {
        VStack {
             playlist.artworkColor // Use playlist color as artwork
                 .aspectRatio(1.0, contentMode: .fit)
                .cornerRadius(8)
                .padding(.top)
                 .overlay( // Add title overlay at bottom
                     VStack {
                         Spacer()
                         Text(playlist.title)
                             .font(.system(size: 24, weight: .bold))
                             .foregroundColor(.white)
                             .padding()
                             .frame(maxWidth: .infinity)
                             .background(Color.black.opacity(0.4))
                     }
                 )

            Text(playlist.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
                 .multilineTextAlignment(.center)
        }
    }
}

struct SpotifyRemake_PlaylistMetadataView: View {
    let playlist: SpotifyRemake_Playlist
    var body: some View {
        VStack(alignment: .leading) {
             HStack {
                Image(systemName: "spotify.logo") // Placeholder
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Circle().fill(.black)) // Background circle Optional

                Text(playlist.creator)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }

            // Format duration nicely
            let durationFormatter: DateComponentsFormatter = {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated
                return formatter
            }()
            let durationString = durationFormatter.string(from: playlist.totalDuration) ?? "N/A"

            Text("\(playlist.likes) likes • \(durationString)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
         }
    }
}

struct SpotifyRemake_PlaylistActionButtonsView: View {
    let playlist: SpotifyRemake_Playlist
    @Binding var isLiked: Bool
    @Binding var isDownloaded: Bool
    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel

    var body: some View {
        HStack(spacing: 25) {
            Button {
                isLiked.toggle()
                print("Playlist liked status: \(isLiked)")
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .green : .gray) // Change color when liked
            }

            Button {
                isDownloaded.toggle()
                print("Playlist download status: \(isDownloaded)")
            } label: {
                 // More complex state might be needed (downloading, downloaded, error)
                 Image(systemName: isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
                      .foregroundColor(isDownloaded ? .green : .gray)
            }

            Button { print("More options tapped") } label: {
                Image(systemName: "ellipsis").foregroundColor(.gray)
            }

            Spacer()

            Button {
                print("Play button tapped for playlist: \(playlist.title)")
                 if let firstSong = playlist.songs.first {
                    playerViewModel.play(song: firstSong, playlist: playlist)
                } else {
                    print("Playlist is empty, cannot play.")
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.green) // Spotify Green
                        .frame(width: 55, height: 55)
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
        }
        .font(.title2)
    }
}

struct SpotifyRemake_SongListViewPreview: View {
    let songs: [SpotifyRemake_Song] // Pass in the songs to display
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
                    Button { print("More options for song: \(song.title)") } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 5)
                // Allow tapping on a song row to play it
                 .contentShape(Rectangle()) // Make the whole HStack tappable
                 .onTapGesture {
                     print("Tapped song row: \(song.title)")
                     playerViewModel.play(song: song) // Play this specific song
                 }
            }
        }
    }
}

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

struct SpotifyRemake_AdvertiserCardView: View {
    let ad: SpotifyRemake_Ad
    var body: some View {
        HStack {
            if let iconName = ad.iconName {
                 Image(systemName: iconName)
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
                 print("Advertiser CTA tapped: \(ad.callToAction)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(15)
             .font(.system(size: 12, weight: .bold))
        }
        .padding()
        .background(ad.backgroundColor) // Use ad's defined background
        .cornerRadius(8)
         .frame(width: 300) // Consistent width for horizontal scroll
    }
}

// Helper for common button style
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
                 .background(Color.gray.opacity(0.5)) // Button background
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyRemake_ContentView()
            .preferredColorScheme(.dark) // Ensure preview is dark

        // You can also preview individual screens with mock data and environment objects
         NavigationView { // Wrap PlaylistView for nav bar preview
             SpotifyRemake_PlaylistView(playlist: MockDataStore.discoverWeekly)
                 .environmentObject(SpotifyRemake_PlayerViewModel()) // Provide player for preview
         }
         .preferredColorScheme(.dark)

         SpotifyRemake_HomeView()
             .environmentObject(SpotifyRemake_PlayerViewModel()) // Provide player for preview
             .preferredColorScheme(.dark)
    }
}

// MARK: - Spotify Logo Placeholder (if needed)

extension Image {
    // Using a system symbol as a placeholder is generally fine for demos
    static let spotifyLogo = Image(systemName: "headphones.circle.fill")
}
