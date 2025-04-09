////
////  ComprehensiveView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import Combine
//import CryptoKit // For PKCE SHA256
//import AuthenticationServices // For ASWebAuthenticationSession
//
//// This file contains two distinct parts:
//// 1. Spotify UI Remake: A visual clone using mock data and a local player simulation.
//// 2. Spotify Auth & API: Implementation for authenticating with Spotify and fetching real data.
//// They are functionally separate but kept in one file as per the request.
//
//// MARK: - ================= Spotify UI Remake Start =================
//
//// MARK: - Data Models (UI Remake - Mock)
//
//struct SpotifyRemake_Song: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let artist: String
//    let duration: TimeInterval // in seconds
//}
//
//struct SpotifyRemake_Playlist: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let creator: String // e.g., "Spotify", "John Doe"
//    let artworkColor: Color // Use color as placeholder for artwork
//    let songs: [SpotifyRemake_Song]
//    var totalDuration: TimeInterval { songs.reduce(0) { $0 + $1.duration } }
//    var likes: Int = Int.random(in: 1000...500000) // Mock likes
//}
//
//// Simplified Album model for horizontal scroll (UI Remake - Mock)
//struct SpotifyRemake_Album: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let artist: String // Can be derived or explicit
//    let artworkColor: Color
//}
//
//// Grid item model (UI Remake - Mock)
//struct SpotifyRemake_GridItemData: Identifiable, Hashable {
//    let id = UUID()
//    let title: String
//    let type: ItemType // To know what kind of content it links to
//    let artworkColor: Color
//
//    enum ItemType {
//        case playlist(SpotifyRemake_Playlist) // Associated value holds the actual playlist
//        case album(SpotifyRemake_Album)       // Can extend for other types
//        case podcastEpisode
//    }
//
//    // Conformance for Hashable based on ID
//    static func == (lhs: SpotifyRemake_GridItemData, rhs: SpotifyRemake_GridItemData) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
//// Ad model for clarity (UI Remake - Mock)
//struct SpotifyRemake_Ad: Identifiable {
//    let id = UUID()
//    let title: String
//    let callToAction: String
//    let backgroundColor: Color
//    let iconName: String? // Optional icon for advertiser cards
//}
//
//// MARK: - Mock Data Store (UI Remake)
//
//struct MockDataStore {
//    static let songs: [SpotifyRemake_Song] = [
//        SpotifyRemake_Song(title: "Blinded By The LEDs", artist: "Lindstrøm", duration: 245),
//        SpotifyRemake_Song(title: "Tiny Cities", artist: "Flume ft. Beck", duration: 210),
//        SpotifyRemake_Song(title: "Baby Let Me Kiss You", artist: "Fern Kinney", duration: 190),
//        SpotifyRemake_Song(title: "Closing Shot", artist: "Lindstrøm", duration: 320),
//        SpotifyRemake_Song(title: "Midnight Girl", artist: "Lindstrøm", duration: 280),
//        SpotifyRemake_Song(title: "Indestructable", artist: "Robyn", duration: 225),
//        SpotifyRemake_Song(title: "Atmosphere", artist: "Joy Division", duration: 250),
//        SpotifyRemake_Song(title: "Genesis", artist: "Grimes", duration: 255),
//    ]
//
//    static let discoverWeekly = SpotifyRemake_Playlist(
//        title: "Discover Weekly",
//        description: "Your weekly mixtape of fresh music. Enjoy! Updated every Monday.",
//        creator: "Spotify",
//        artworkColor: .pink,
//        songs: Array(songs.shuffled().prefix(30)) // 30 random songs
//    )
//
//    static let dailyMix1 = SpotifyRemake_Playlist(
//        title: "Daily Mix 1",
//        description: "Based on your recent listening.",
//        creator: "Spotify",
//        artworkColor: .blue,
//        songs: Array(songs.shuffled().prefix(25))
//    )
//
//    static let replyAllPlaylist = SpotifyRemake_Playlist(
//        title: "Reply All Favs",
//        description: "Podcast episodes you might like.",
//        creator: "User Generated",
//        artworkColor: .gray,
//        songs: [] // Represents podcast playlist
//    )
//
//    static let gridItems: [SpotifyRemake_GridItemData] = [
//        SpotifyRemake_GridItemData(title: "A Pandemic Update: The V...", type: .podcastEpisode, artworkColor: .blue), // Link to podcast?
//        SpotifyRemake_GridItemData(title: "Discover Weekly", type: .playlist(discoverWeekly), artworkColor: .pink),
//        SpotifyRemake_GridItemData(title: "Daily Mix 1", type: .playlist(dailyMix1), artworkColor: .blue),
//        SpotifyRemake_GridItemData(title: "Reply All", type: .playlist(replyAllPlaylist) , artworkColor: .gray), // Representing podcast link
//        SpotifyRemake_GridItemData(title: "Chill Vibes", type: .playlist(dailyMix1), artworkColor: .purple), // Reuse DM1 for demo
//        SpotifyRemake_GridItemData(title: "Focus Flow", type: .playlist(discoverWeekly), artworkColor: .indigo), // Reuse DW for demo
//    ]
//
//    static let albums: [SpotifyRemake_Album] = [
//        SpotifyRemake_Album(title: "Low-Key", artist: "Various Artists", artworkColor: .purple),
//        SpotifyRemake_Album(title: "Wildfire", artist: "Sampha", artworkColor: .orange),
//        SpotifyRemake_Album(title: "Process", artist: "Sampha", artworkColor: .teal),
//        SpotifyRemake_Album(title: "Ambient Chill", artist: "Various Artists", artworkColor: .yellow),
//    ]
//
//    static let mainAd = SpotifyRemake_Ad(
//        title: "Get 20% off your first bag. Start your next journey today.",
//        callToAction: "Buy now",
//        backgroundColor: .pink, iconName: nil
//    )
//
//    static let advertiserAds: [SpotifyRemake_Ad] = [
//        SpotifyRemake_Ad(title: "Fresh beans delivered to you each week.", callToAction: "Learn more", backgroundColor: Color.gray.opacity(0.3), iconName: "cup.and.saucer.fill"),
//        SpotifyRemake_Ad(title: "Level up your setup.", callToAction: "Shop", backgroundColor: Color.gray.opacity(0.3), iconName: "gamecontroller.fill"),
//        SpotifyRemake_Ad(title: "Immerse yourself.", callToAction: "Explore", backgroundColor: Color.gray.opacity(0.3), iconName: "headphones"),
//    ]
//}
//
//// MARK: - Player View Model (UI Remake - Local State)
//
//class SpotifyRemake_PlayerViewModel: ObservableObject {
//    @Published var currentSong: SpotifyRemake_Song? = nil // Make it optional
//    @Published var isPlaying: Bool = false
//    @Published var currentPlaylist: SpotifyRemake_Playlist? = nil // Track context if needed
//
//    func play(song: SpotifyRemake_Song, playlist: SpotifyRemake_Playlist? = nil) {
//        print("[UI Remake] Playing song: \(song.title) by \(song.artist)")
//        currentSong = song
//        currentPlaylist = playlist // Keep track of the playlist context
//        isPlaying = true
//    }
//
//    func play(playlist: SpotifyRemake_Playlist) {
//        guard let firstSong = playlist.songs.first else {
//            print("[UI Remake] Playlist \(playlist.title) is empty.")
//            return
//        }
//        play(song: firstSong, playlist: playlist)
//        print("[UI Remake] Starting playlist: \(playlist.title)")
//    }
//
//    func togglePlayback() {
//        guard currentSong != nil else { return } // Can't toggle if nothing is loaded
//
//        isPlaying.toggle()
//        if isPlaying {
//            print("[UI Remake] Resuming playback: \(currentSong!.title)")
//        } else {
//            print("[UI Remake] Pausing playback: \(currentSong!.title)")
//        }
//    }
//
//    func pause() {
//         if isPlaying {
//             isPlaying = false
//             print("[UI Remake] Pausing playback: \(currentSong?.title ?? "Unknown")")
//         }
//     }
//
//     func resume() {
//         if !isPlaying && currentSong != nil {
//             isPlaying = true
//             print("[UI Remake] Resuming playback: \(currentSong?.title ?? "Unknown")")
//         }
//     }
//}
//
//// MARK: - Main Content View (UI Remake - Entry Point with Tab Bar)
//
//struct SpotifyRemake_ContentView: View {
//    // Use StateObject to initialize the ViewModel here, making it the source of truth
//    @StateObject private var playerViewModel = SpotifyRemake_PlayerViewModel()
//    @State private var selectedTab = 0 // Keep track of the selected tab
//
//    init() {
//        // Customize Tab Bar Appearance
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.9) // Semi-transparent black
//
//        // Set colors for selected and unselected items
//        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
//        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
//        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
//        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
//
//        UITabBar.appearance().standardAppearance = appearance
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
//    }
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            SpotifyRemake_HomeView() // Already wrapped in NavView internally
//                .tabItem { Label("Home", systemImage: "house.fill") }
//                .tag(0) // Assign tag for selection binding
//
//             // Example placeholder views for other tabs
//             Text("Search Screen Content")
//                 .frame(maxWidth: .infinity, maxHeight: .infinity)
//                 .background(Color.black.edgesIgnoringSafeArea(.all))
//                 .foregroundColor(.white)
//                 .tabItem { Label("Search", systemImage: "magnifyingglass") }
//                 .tag(1)
//
//            Text("Your Library Screen Content")
//                 .frame(maxWidth: .infinity, maxHeight: .infinity)
//                 .background(Color.black.edgesIgnoringSafeArea(.all))
//                 .foregroundColor(.white)
//                 .tabItem { Label("Your Library", systemImage: "books.vertical.fill") }
//                 .tag(2)
//
//            Text("Premium Screen Content")
//                 .frame(maxWidth: .infinity, maxHeight: .infinity)
//                 .background(Color.black.edgesIgnoringSafeArea(.all))
//                 .foregroundColor(.white)
//                .tabItem { Label("Premium", systemImage: "spotify.logo") } // Note: Requires custom asset or SF Symbol substitution
//                 .tag(3)
//        }
//        // Provide the PlayerViewModel to all child views within the TabView
//        .environmentObject(playerViewModel)
//        .preferredColorScheme(.dark) // Enforce dark mode for the whole app
//    }
//}
//
//// MARK: - Home Screen Structure (UI Remake)
//
//struct SpotifyRemake_HomeView: View {
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel // Access shared player state
//
//    var body: some View {
//        NavigationView { // Each tab should manage its own NavigationView if needed
//            ZStack(alignment: .bottom) {
//                // Main Scrolling Content
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        SpotifyRemake_HomeHeaderView()
//                        SpotifyRemake_GreetingGridView()
//                        SpotifyRemake_MoreLikeSectionView(artistName: "Sampha", albums: MockDataStore.albums)
//                        SpotifyRemake_AdBannerView(ad: MockDataStore.mainAd)
//                        // Add another Album Section for variety
//                        SpotifyRemake_MoreLikeSectionView(artistName: "Chill Beats", albums: MockDataStore.albums.shuffled())
//
//                        // Spacer to push content up, leaving space for the player bar
//                        Spacer(minLength: playerViewModel.currentSong != nil ? 80 : 0) // Only add space if player is visible
//                    }
//                    .padding(.horizontal)
//                }
//                .background(Color.black.edgesIgnoringSafeArea(.all))
//                .navigationBarHidden(true) // Use custom header
//
//                // Mini Player Bar (Conditional Overlay)
//                if playerViewModel.currentSong != nil {
//                    SpotifyRemake_PlayerBarView()
//                        // Add transition for smooth appearance/disappearance
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                        .padding(.bottom, 49) // Standard TabBar height approx.
//                        // Add tap gesture to potentially open full player later
//                         .onTapGesture {
//                             print("[UI Remake] Mini player tapped! Should present full player.")
//                             // Here you would set state to show a modal/full screen player
//                         }
//
//                }
//            }
//            .background(Color.black.edgesIgnoringSafeArea(.all))
//            .animation(.easeInOut(duration: 0.3), value: playerViewModel.currentSong) // Animate player appearance
//        }
//        .navigationViewStyle(StackNavigationViewStyle()) // Consistent navigation style
//    }
//}
//
//// MARK: - Home Screen Components (UI Remake)
//
//struct SpotifyRemake_HomeHeaderView: View {
//    var body: some View {
//        HStack {
//            Text("Good morning")
//                .font(.system(size: 24, weight: .bold))
//                .foregroundColor(.white)
//            Spacer()
//            Button {
//                print("[UI Remake] Settings button tapped!")
//            } label: {
//                Image(systemName: "gearshape")
//                    .font(.title2)
//                    .foregroundColor(.white)
//            }
//        }
//        .padding(.top)
//    }
//}
//
//struct SpotifyRemake_GreetingGridView: View {
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
//    let gridItemsData = MockDataStore.gridItems
//    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
//
//    var body: some View {
//        LazyVGrid(columns: columns, spacing: 10) {
//            ForEach(gridItemsData) { item in
//                // NavigationLink wraps the item view
//                NavigationLink(value: item) { // Use value-based navigation
//                    SpotifyRemake_GridItemView(title: item.title, color: item.artworkColor)
//                }
//            }
//        }
//         // Define navigation destination for GridItemData
//         .navigationDestination(for: SpotifyRemake_GridItemData.self) { item in
//             switch item.type {
//             case .playlist(let playlist):
//                 SpotifyRemake_PlaylistView(playlist: playlist) // Navigate to PlaylistView
//             case .album(let album):
//                 Text("[UI Remake] Album Detail Screen for \(album.title)") // Placeholder destination
//                     .foregroundColor(.white).background(Color.black.edgesIgnoringSafeArea(.all))
//             case .podcastEpisode:
//                 Text("[UI Remake] Podcast Episode Screen for \(item.title)") // Placeholder
//                     .foregroundColor(.white).background(Color.black.edgesIgnoringSafeArea(.all))
//             }
//         }
//    }
//}
//
//struct SpotifyRemake_GridItemView: View {
//    let title: String
//    let color: Color?
//
//    var body: some View {
//        HStack(spacing: 0) {
//            (color ?? Color.gray) // Use color as placeholder background
//                 .frame(width: 50, height: 50)
//                 .overlay( // Add a generic icon placeholder if needed
//                     Image(systemName: "music.note")
//                         .foregroundColor(.white.opacity(0.7))
//                 )
//
//            Text(title)
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.white)
//                .padding(.horizontal, 8)
//                .lineLimit(2)
//                .frame(maxWidth: .infinity, alignment: .leading) // Ensure text takes space
//        }
//        .background(Color.gray.opacity(0.3)) // Cell background
//        .cornerRadius(4)
//        .frame(height: 50)
//    }
//}
//
//struct SpotifyRemake_MoreLikeSectionView: View {
//    let artistName: String
//    let albums: [SpotifyRemake_Album] // Pass in the albums to display
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                // Placeholder for artist image
//                Circle()
//                    .fill(.gray)
//                    .frame(width: 40, height: 40)
//
//                VStack(alignment: .leading) {
//                    Text("MORE LIKE")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Text(artistName)
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 15) {
//                    ForEach(albums) { album in
//                        NavigationLink(value: album) { // Navigate on tap
//                            SpotifyRemake_AlbumCoverView(title: album.title, color: album.artworkColor)
//                        }
//                    }
//                }
//            }
//        }
//        // Define destination for Album type
//         .navigationDestination(for: SpotifyRemake_Album.self) { album in
//             // Placeholder: In a real app, navigate to an AlbumDetailView
//             Text("[UI Remake] Album Detail for \(album.title)")
//                 .foregroundColor(.white).background(Color.black.edgesIgnoringSafeArea(.all))
//                 .navigationTitle(album.title)
//         }
//    }
//}
//
//struct SpotifyRemake_AlbumCoverView: View {
//    let title: String
//    let color: Color?
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            (color ?? Color.gray)
//                .frame(width: 140, height: 140)
//                .cornerRadius(4)
//                .overlay(
//                    VStack { // Add overlay content if desired
//                       Spacer()
//                        Text(title)
//                             .font(.caption)
//                            .foregroundColor(.white)
//                             .lineLimit(1)
//                             .padding(5)
//                             .frame(maxWidth: .infinity)
//                             .background(Color.black.opacity(0.4))
//                     }
//                )
//        }
//    }
//}
//
//struct SpotifyRemake_AdBannerView: View {
//    let ad: SpotifyRemake_Ad
//    var body: some View {
//        HStack {
//            Text(ad.title)
//                 .font(.system(size: 14, weight: .semibold))
//                 .foregroundColor(.white)
//                 .frame(maxWidth: .infinity, alignment: .leading)
//
//            Button(ad.callToAction) {
//                 print("[UI Remake] Ad button tapped: \(ad.callToAction)")
//                 // Open URL, navigate, etc.
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)
//            .background(Color.white)
//            .foregroundColor(.black)
//            .cornerRadius(20)
//            .font(.system(size: 14, weight: .bold))
//        }
//        .padding()
//        .background(ad.backgroundColor)
//        .cornerRadius(8)
//    }
//}
//
//struct SpotifyRemake_PlayerBarView: View {
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
//
//    var body: some View {
//        HStack(spacing: 10) {
//            // Placeholder artwork
//             (playerViewModel.currentPlaylist?.artworkColor ?? .gray)
//                .frame(width: 40, height: 40)
//                .cornerRadius(4)
//                .overlay(Image(systemName: "music.note").foregroundColor(.white))
//
//            VStack(alignment: .leading) {
//                Text(playerViewModel.currentSong?.title ?? "No Song Playing")
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                    .lineLimit(1)
//                Text(playerViewModel.currentSong?.artist ?? "...")
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
//                     .lineLimit(1)
//            }
//              .frame(maxWidth: .infinity, alignment: .leading)
//
//            // Placeholder for device/cast icon
//            Button { print("[UI Remake] Device button tapped") } label: {
//                Image(systemName: "hifispeaker.and.appletv")
//                    .foregroundColor(.white)
//                    .font(.title3)
//            }
//
//            // Play/Pause Button
//            Button {
//                playerViewModel.togglePlayback()
//            } label: {
//                Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
//                    .foregroundColor(.white)
//                    .font(.title2) // Make slightly larger
//                     .frame(width: 30, height: 30) // Ensure consistent tap area
//            }
//        }
//        .padding(.horizontal)
//        .frame(height: 60)
//        .background(Color(UIColor.systemGray).opacity(0.8))
//         .cornerRadius(8)
//         .padding(.horizontal, 8)
//    }
//}
//
//// MARK: - Playlist/Detail Screen Structure (UI Remake)
//
//struct SpotifyRemake_PlaylistView: View {
//    let playlist: SpotifyRemake_Playlist // Receive the playlist data
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
//    @State private var isLiked: Bool = false // Local state for the heart icon
//    @State private var isDownloaded: Bool = false // Local state for download icon
//
//    @Environment(\.presentationMode) var presentationMode // To dismiss
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                SpotifyRemake_PlaylistHeaderView(playlist: playlist) // UI Remake Version
//                SpotifyRemake_PlaylistMetadataView(playlist: playlist)
//                SpotifyRemake_PlaylistActionButtonsView(
//                    playlist: playlist,
//                    isLiked: $isLiked,
//                    isDownloaded: $isDownloaded
//                )
//
//                 // Show first ~5 songs or info about them
//                SpotifyRemake_SongListViewPreview(songs: Array(playlist.songs.prefix(5)))
//
//                 SpotifyRemake_FullWidthButton(title: "Shuffle Play") {
//                     print("[UI Remake] Shuffle play playlist: \(playlist.title)")
//                     playerViewModel.play(playlist: playlist) // Start playing the playlist
//                 }
//                 .padding(.vertical)
//
//                SpotifyRemake_RecentAdvertisersView(ads: MockDataStore.advertiserAds)
//
//                 Spacer(minLength: playerViewModel.currentSong != nil ? 80 : 0) // Space for mini player
//            }
//            .padding(.horizontal)
//        }
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//        .preferredColorScheme(.dark)
//        .navigationTitle(playlist.title) // Use standard nav title
//         .navigationBarTitleDisplayMode(.inline) // Keep title small
//         .toolbar {
//             ToolbarItem(placement: .navigationBarLeading) {
//                 Button {
//                     presentationMode.wrappedValue.dismiss()
//                 } label: {
//                     Image(systemName: "chevron.backward")
//                         .foregroundColor(.white)
//                 }
//             }
//         }
//    }
//}
//
//// MARK: - Playlist Screen Components (UI Remake)
//
//// Uses SpotifyRemake_Playlist model
//struct SpotifyRemake_PlaylistHeaderView: View {
//    let playlist: SpotifyRemake_Playlist
//    var body: some View {
//        VStack {
//             playlist.artworkColor // Use playlist color as artwork
//                 .aspectRatio(1.0, contentMode: .fit)
//                .cornerRadius(8)
//                .padding(.top)
//                 .overlay( // Add title overlay at bottom
//                     VStack {
//                         Spacer()
//                         Text(playlist.title)
//                             .font(.system(size: 24, weight: .bold))
//                             .foregroundColor(.white)
//                             .padding()
//                             .frame(maxWidth: .infinity)
//                             .background(Color.black.opacity(0.4))
//                     }
//                 )
//
//            Text(playlist.description)
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//                .padding(.top, 5)
//                .frame(maxWidth: .infinity, alignment: .center)
//                 .multilineTextAlignment(.center)
//        }
//    }
//}
//
//struct SpotifyRemake_PlaylistMetadataView: View {
//    let playlist: SpotifyRemake_Playlist
//    var body: some View {
//        VStack(alignment: .leading) {
//             HStack {
//                 // Use a local image or system symbol if spotify.logo is not available
//                Image(systemName: "headphones.circle.fill") // Placeholder
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .foregroundColor(.white)
//                    .padding(5)
//                    .background(Circle().fill(.black))
//
//                Text(playlist.creator)
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                Spacer()
//            }
//
//            let durationFormatter: DateComponentsFormatter = {
//                let formatter = DateComponentsFormatter()
//                formatter.allowedUnits = [.hour, .minute]
//                formatter.unitsStyle = .abbreviated
//                return formatter
//            }()
//            let durationString = durationFormatter.string(from: playlist.totalDuration) ?? "N/A"
//
//            Text("\(playlist.likes) likes • \(durationString)")
//                .font(.system(size: 12))
//                .foregroundColor(.gray)
//         }
//    }
//}
//
//struct SpotifyRemake_PlaylistActionButtonsView: View {
//    let playlist: SpotifyRemake_Playlist
//    @Binding var isLiked: Bool
//    @Binding var isDownloaded: Bool
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
//
//    var body: some View {
//        HStack(spacing: 25) {
//            Button {
//                isLiked.toggle()
//                print("[UI Remake] Playlist liked status: \(isLiked)")
//            } label: {
//                Image(systemName: isLiked ? "heart.fill" : "heart")
//                    .foregroundColor(isLiked ? .green : .gray) // Change color when liked
//            }
//
//            Button {
//                isDownloaded.toggle()
//                print("[UI Remake] Playlist download status: \(isDownloaded)")
//            } label: {
//                 Image(systemName: isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
//                      .foregroundColor(isDownloaded ? .green : .gray)
//            }
//
//            Button { print("[UI Remake] More options tapped") } label: {
//                Image(systemName: "ellipsis").foregroundColor(.gray)
//            }
//
//            Spacer()
//
//            Button {
//                print("[UI Remake] Play button tapped for playlist: \(playlist.title)")
//                 if let firstSong = playlist.songs.first {
//                    playerViewModel.play(song: firstSong, playlist: playlist)
//                } else {
//                    print("[UI Remake] Playlist is empty, cannot play.")
//                }
//            } label: {
//                ZStack {
//                    Circle()
//                        .fill(Color.green) // Spotify Green
//                        .frame(width: 55, height: 55)
//                    Image(systemName: "play.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .font(.title2)
//    }
//}
//
//struct SpotifyRemake_SongListViewPreview: View {
//    let songs: [SpotifyRemake_Song] // Pass in the songs to display
//    @EnvironmentObject var playerViewModel: SpotifyRemake_PlayerViewModel
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(songs) { song in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(song.title)
//                            .font(.system(size: 16))
//                            .foregroundColor(.white)
//                        Text(song.artist)
//                            .font(.system(size: 13))
//                            .foregroundColor(.gray)
//                    }
//                    Spacer()
//                    Button { print("[UI Remake] More options for song: \(song.title)") } label: {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding(.vertical, 5)
//                 .contentShape(Rectangle()) // Make the whole HStack tappable
//                 .onTapGesture {
//                     print("[UI Remake] Tapped song row: \(song.title)")
//                     playerViewModel.play(song: song) // Play this specific song
//                 }
//            }
//        }
//    }
//}
//
//struct SpotifyRemake_RecentAdvertisersView: View {
//     let ads: [SpotifyRemake_Ad]
//     var body: some View {
//        VStack(alignment: .leading) {
//            Text("Recent advertisers")
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(.white)
//                .padding(.bottom, 5)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                 HStack(spacing: 15) {
//                    ForEach(ads) { ad in
//                        SpotifyRemake_AdvertiserCardView(ad: ad)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct SpotifyRemake_AdvertiserCardView: View {
//    let ad: SpotifyRemake_Ad
//    var body: some View {
//        HStack {
//            if let iconName = ad.iconName {
//                 Image(systemName: iconName)
//                    .font(.title2)
//                    .foregroundColor(.white)
//                    .frame(width: 30, height: 30)
//                    .padding(.trailing, 8)
//            }
//
//            Text(ad.title)
//                .font(.system(size: 13))
//                .foregroundColor(.gray)
//                 .lineLimit(2)
//                 .frame(maxWidth: .infinity, alignment: .leading)
//
//            Button(ad.callToAction) {
//                 print("[UI Remake] Advertiser CTA tapped: \(ad.callToAction)")
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(Color.white)
//            .foregroundColor(.black)
//            .cornerRadius(15)
//             .font(.system(size: 12, weight: .bold))
//        }
//        .padding()
//        .background(ad.backgroundColor) // Use ad's defined background
//        .cornerRadius(8)
//         .frame(width: 300) // Consistent width for horizontal scroll
//    }
//}
//
//// Helper for common button style (UI Remake)
//struct SpotifyRemake_FullWidthButton: View {
//    let title: String
//    let action: () -> Void
//
//    var body: some View {
//         Button(action: action) {
//             Text(title)
//                .font(.system(size: 14, weight: .bold))
//                .foregroundColor(.white)
//                .padding(.vertical, 12)
//                .frame(maxWidth: .infinity)
//                 .background(Color.gray.opacity(0.5)) // Button background
//                .clipShape(Capsule())
//        }
//    }
//}
//
//// MARK: - Preview Provider (UI Remake)
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            SpotifyRemake_ContentView()
//                .previewDisplayName("Remake Main Tab View")
//
//            NavigationView { // Wrap PlaylistView for nav bar preview
//                 SpotifyRemake_PlaylistView(playlist: MockDataStore.discoverWeekly)
//                     .environmentObject(SpotifyRemake_PlayerViewModel()) // Provide player for preview
//             }
//             .previewDisplayName("Remake Playlist Detail")
//
//
//             SpotifyRemake_HomeView()
//                 .environmentObject(SpotifyRemake_PlayerViewModel()) // Provide player for preview
//                 .previewDisplayName("Remake Home Screen")
//        }
//        .preferredColorScheme(.dark) // Ensure all previews are dark
//
//    }
//}
//
//// MARK: - Spotify Logo Placeholder Helper (UI Remake)
//extension Image {
//    // Using a system symbol is fine for demos
//    static let spotifyLogoPlaceholder = Image(systemName: "headphones.circle.fill")
//}
//
//// MARK: - ================= Spotify UI Remake End ===================
//
//// MARK: - ================= Spotify Auth & API Start ================
//
//// MARK: - Configuration (Auth & API)
//struct SpotifyConstants {
//    static let clientID = "adb2903676fc47b8aac6acf1d4a19df6" // <-- REPLACE THIS with your actual Client ID
//    static let redirectURI = "myapp://callback" // <-- REPLACE THIS with your configured URI (must match Spotify Dev Dashboard & Info.plist)
//    static let scopes = [
//        "user-read-private",
//        "user-read-email",
//        "playlist-read-private",
//        "playlist-read-collaborative",
//        "playlist-modify-public",
//        "playlist-modify-private",
//        "user-library-read",
//        "user-top-read"
//        // Add other scopes your app needs
//    ]
//    static let scopeString = scopes.joined(separator: " ")
//
//    static let authorizationEndpoint = URL(string: "https://accounts.spotify.com/authorize")!
//    static let tokenEndpoint = URL(string: "https://accounts.spotify.com/api/token")!
//    static let userProfileEndpoint = URL(string: "https://api.spotify.com/v1/me")!
//    static let userPlaylistsEndpoint = URL(string: "https://api.spotify.com/v1/me/playlists")!
//    static let playlistBaseEndpoint = "https://api.spotify.com/v1/playlists/" // Append /<playlist_id>/tracks
//
//    static let tokenUserDefaultsKey = "spotifyTokens" // Key for storing tokens (Insecure! Use Keychain in production)
//}
//
//// MARK: - Data Models (Auth & API)
//
//// Models for Token Handling
//struct TokenResponse: Codable {
//    let accessToken: String
//    let tokenType: String
//    let expiresIn: Int
//    let refreshToken: String?
//    let scope: String
//
//    var expiryDate: Date? {
//        Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case tokenType = "token_type"
//        case expiresIn = "expires_in"
//        case refreshToken = "refresh_token"
//        case scope
//    }
//}
//
//struct StoredTokens: Codable {
//    let accessToken: String
//    let refreshToken: String?
//    let expiryDate: Date?
//}
//
//// Models for User Profile
//struct SpotifyUserProfile: Codable, Identifiable {
//    let id: String
//    let displayName: String
//    let email: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case email
//        case images
//        case externalUrls = "external_urls"
//    }
//}
//
//// Shared Image Model
//struct SpotifyImage: Codable, Hashable {
//    let url: String
//    let height: Int?
//    let width: Int?
//    
//    func hash(into hasher: inout Hasher) { hasher.combine(url) }
//    static func == (lhs: SpotifyImage, rhs: SpotifyImage) -> Bool { lhs.url == rhs.url }
//}
//
//
//// Models for Playlists & Tracks (API Version - Renamed)
//
//// Generic Paging Object
//struct SpotifyPagingObject<T: Codable>: Codable {
//    let href: String
//    let items: [T]
//    let limit: Int
//    let next: String?
//    let offset: Int
//    let previous: String?
//    let total: Int
//}
//
//// Playlist Owner
//struct SpotifyPlaylistOwner: Codable, Identifiable, Hashable {
//    let id: String
//    let displayName: String?
//    let externalUrls: [String: String]?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyPlaylistOwner, rhs: SpotifyPlaylistOwner) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case displayName = "display_name"
//        case externalUrls = "external_urls"
//    }
//}
//
//// Playlist Tracks Info (Summary)
//struct PlaylistTracksInfo: Codable, Hashable {
//    let href: String
//    let total: Int
//
//    func hash(into hasher: inout Hasher) { hasher.combine(href); hasher.combine(total) }
//    static func == (lhs: PlaylistTracksInfo, rhs: PlaylistTracksInfo) -> Bool { lhs.href == rhs.href && lhs.total == rhs.total }
//}
//
//// *** Renamed Playlist Model for API Data ***
//struct SpotifyAPI_Playlist: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let description: String?
//    let owner: SpotifyPlaylistOwner
//    let collaborative: Bool
//    let tracks: PlaylistTracksInfo
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//    let publicPlaylist: Bool?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyAPI_Playlist, rhs: SpotifyAPI_Playlist) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, description, owner, collaborative, tracks, images
//        case externalUrls = "external_urls"
//        case publicPlaylist = "public"
//    }
//}
//
//// Type alias using the renamed Playlist model
//typealias SpotifyAPI_PlaylistList = SpotifyPagingObject<SpotifyAPI_Playlist>
//
//
//// Models for Tracks
//struct SpotifyArtistSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let externalUrls: [String: String]?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyArtistSimple, rhs: SpotifyArtistSimple) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyAlbumSimple: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let images: [SpotifyImage]?
//    let externalUrls: [String: String]?
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyAlbumSimple, rhs: SpotifyAlbumSimple) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, images, externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyTrack: Codable, Identifiable, Hashable {
//    let id: String
//    let name: String
//    let artists: [SpotifyArtistSimple]
//    let album: SpotifyAlbumSimple
//    let durationMs: Int
//    let trackNumber: Int?
//    let discNumber: Int?
//    let explicit: Bool?
//    let externalUrls: [String: String]?
//    let uri: String
//
//    var formattedDuration: String {
//        let totalSeconds = durationMs / 1000
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//
//    func hash(into hasher: inout Hasher) { hasher.combine(id) }
//    static func == (lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool { lhs.id == rhs.id }
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, artists, album, uri, explicit
//        case durationMs = "duration_ms"
//        case trackNumber = "track_number"
//        case discNumber = "disc_number"
//        case externalUrls = "external_urls"
//    }
//}
//
//struct SpotifyPlaylistTrack: Codable, Identifiable {
//    var id: String { track?.id ?? UUID().uuidString } // Use track ID if available
//    let addedAt: String?
//    let track: SpotifyTrack? // Can be null
//
//    enum CodingKeys: String, CodingKey {
//        case track
//        case addedAt = "added_at"
//    }
//}
//
//typealias SpotifyAPI_PlaylistTrackList = SpotifyPagingObject<SpotifyPlaylistTrack>
//
//
//// Models for Error Handling
//enum APIError: Error, LocalizedError {
//    case invalidRequest(message: String)
//    case networkError(Error)
//    case invalidResponse
//    case httpError(statusCode: Int, details: String)
//    case noData
//    case decodingError(Error?)
//    case notLoggedIn
//    case tokenRefreshFailed
//    case authenticationFailed // After refresh attempt fails
//    case maxRetriesReached
//    case unknown
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidRequest(let message): return "Invalid request: \(message)"
//        case .networkError(let error): return "Network error: \(error.localizedDescription)"
//        case .invalidResponse: return "Invalid response from server."
//        case .httpError(let statusCode, let details): return "HTTP Error \(statusCode): \(details)"
//        case .noData: return "No data received from server."
//        case .decodingError: return "Failed to decode server response."
//        case .notLoggedIn: return "User is not logged in."
//        case .tokenRefreshFailed: return "Could not refresh session token."
//        case .authenticationFailed: return "Authentication failed."
//        case .maxRetriesReached: return "Maximum retry attempts reached."
//        case .unknown: return "An unknown error occurred."
//        }
//    }
//
//    var isAuthError: Bool {
//        switch self {
//        case .httpError(let statusCode, _):
//            return statusCode == 401 || statusCode == 403
//        case .authenticationFailed, .tokenRefreshFailed, .notLoggedIn:
//            return true
//        default:
//            return false
//        }
//    }
//}
//
//struct SpotifyErrorResponse: Codable {
//    let error: SpotifyErrorDetail
//}
//struct SpotifyErrorDetail: Codable {
//    let status: Int
//    let message: String?
//}
//
//struct EmptyResponse: Codable {} // For 204 No Content responses
//
//// MARK: - Authentication Manager (Auth & API)
//class SpotifyAuthManager: ObservableObject {
//
//    // --- State Properties ---
//    @Published var isLoggedIn: Bool = false
//    @Published var currentTokens: StoredTokens? = nil
//    @Published var userProfile: SpotifyUserProfile? = nil
//    @Published var isLoading: Bool = false // General loading (auth, profile)
//    @Published var errorMessage: String? = nil // General errors
//
//    @Published var userPlaylists: [SpotifyAPI_Playlist] = [] // Use renamed API model
//    @Published var isLoadingPlaylists: Bool = false // Specific loading for playlist list
//    @Published var playlistErrorMessage: String? = nil // Specific error for playlist list
//    var playlistNextPageUrl: String? = nil
//
//    @Published var selectedPlaylist: SpotifyAPI_Playlist? = nil // Holds the playlist being viewed (API model)
//    @Published var currentPlaylistTracks: [SpotifyPlaylistTrack] = []
//    @Published var isLoadingPlaylistTracks: Bool = false // Specific loading for tracks
//    @Published var playlistTracksErrorMessage: String? = nil // Specific error for tracks
//    var playlistTracksNextPageUrl: String? = nil
//
//    private var currentPKCEVerifier: String?
//    private var currentWebAuthSession: ASWebAuthenticationSession?
//
//    // --- Initialization ---
//    init() {
//        loadTokens()
//        if let tokens = currentTokens, let expiry = tokens.expiryDate, expiry > Date() {
//            self.isLoggedIn = true
//            fetchUserProfile()
//            fetchUserPlaylists()
//        } else if currentTokens != nil {
//            refreshToken { [weak self] success in
//                DispatchQueue.main.async {
//                    if success {
//                        self?.fetchUserProfile()
//                        self?.fetchUserPlaylists()
//                    } else {
//                        self?.logout()
//                    }
//                }
//            }
//        }
//    }
//
//    // --- PKCE Helpers ---
//    private func generateCodeVerifier() -> String {
//        var buffer = [UInt8](repeating: 0, count: 32)
//        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
//        return Data(buffer).base64URLEncodedString()
//    }
//
//    private func generateCodeChallenge(from verifier: String) -> String? {
//        guard let data = verifier.data(using: .utf8) else { return nil }
//        let digest = SHA256.hash(data: data)
//        return Data(digest).base64URLEncodedString()
//    }
//
//    // --- Authentication Flow ---
//    func initiateAuthorization() {
//        guard !isLoading else { return }
//        prepareForNewAuth()
//
//        let verifier = generateCodeVerifier()
//        guard let challenge = generateCodeChallenge(from: verifier) else {
//            handleError("Could not start authentication (PKCE).")
//            isLoading = false
//            return
//        }
//        currentPKCEVerifier = verifier
//
//        var components = URLComponents(url: SpotifyConstants.authorizationEndpoint, resolvingAgainstBaseURL: true)
//        components?.queryItems = [
//            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//            URLQueryItem(name: "scope", value: SpotifyConstants.scopeString),
//            URLQueryItem(name: "code_challenge_method", value: "S256"),
//            URLQueryItem(name: "code_challenge", value: challenge),
//        ]
//
//        guard let authURL = components?.url else {
//            handleError("Could not construct authorization URL.")
//            isLoading = false
//            return
//        }
//
//        let scheme = URL(string: SpotifyConstants.redirectURI)?.scheme
//
//        currentWebAuthSession = ASWebAuthenticationSession(
//            url: authURL,
//            callbackURLScheme: scheme) { [weak self] callbackURL, error in
//                DispatchQueue.main.async {
//                    self?.isLoading = false
//                    self?.handleAuthCallback(callbackURL: callbackURL, error: error)
//                }
//            }
//
//        currentWebAuthSession?.presentationContextProvider = self
//        currentWebAuthSession?.prefersEphemeralWebBrowserSession = true
//
//        DispatchQueue.main.async {
//            self.currentWebAuthSession?.start()
//        }
//    }
//
//    private func prepareForNewAuth() {
//        isLoading = true
//        errorMessage = nil
//        userProfile = nil
//        userPlaylists = []
//        playlistErrorMessage = nil
//        playlistNextPageUrl = nil
//        clearPlaylistDetailState() // Clear specific detail state too
//    }
//
//    private func handleAuthCallback(callbackURL: URL?, error: Error?) {
//        if let error = error {
//            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
//                self.errorMessage = "Login cancelled."
//            } else {
//                self.errorMessage = "Authentication failed: \(error.localizedDescription)"
//            }
//            print("Auth Callback Error: \(error.localizedDescription)")
//            return
//        }
//
//        guard let successURL = callbackURL,
//              let components = URLComponents(string: successURL.absoluteString),
//              let code = components.queryItems?.first(where: { $0.name == "code" })?.value
//        else {
//            let spotifyError = URLComponents(string: callbackURL?.absoluteString ?? "")?.queryItems?.first(where: { $0.name == "error" })?.value
//            self.errorMessage = "Auth failed: \(spotifyError ?? "Could not get authorization code")"
//            print("Auth Callback Error: Missing or invalid URL/code. Spotify Error: \(spotifyError ?? "N/A")")
//            return
//        }
//
//        print("Successfully received authorization code.")
//        exchangeCodeForToken(code: code)
//    }
//
//
//    private func exchangeCodeForToken(code: String) {
//        guard let verifier = currentPKCEVerifier else {
//            handleError("Authentication failed (missing verifier).", clearVerifier: true)
//            return
//        }
//        guard !isLoading else { return }
//        isLoading = true
//        errorMessage = nil
//
//        makeTokenRequest(grantType: "authorization_code", code: code, verifier: verifier) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                self?.currentPKCEVerifier = nil // Clear verifier
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully exchanged code for tokens.")
//                    self?.processSuccessfulTokenResponse(tokenResponse)
//                    self?.fetchUserProfile()
//                    self?.fetchUserPlaylists()
//                case .failure(let error):
//                    self?.handleError("Failed to get tokens: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // --- Token Refresh ---
//    func refreshToken(completion: ((Bool) -> Void)? = nil) {
//        guard !isLoading else { completion?(false); return }
//        guard let refreshToken = currentTokens?.refreshToken else {
//            print("Error: No refresh token available. Logging out.")
//            logout()
//            completion?(false)
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        makeTokenRequest(grantType: "refresh_token", refreshToken: refreshToken) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let tokenResponse):
//                    print("Successfully refreshed tokens.")
//                    let updatedRefreshToken = tokenResponse.refreshToken ?? self?.currentTokens?.refreshToken
//                    self?.processSuccessfulTokenResponse(tokenResponse, explicitRefreshToken: updatedRefreshToken)
//                    completion?(true)
//                case .failure(let error):
//                    let errorDesc = (error as? APIError)?.errorDescription ?? error.localizedDescription
//                    print("Token Refresh Error: \(errorDesc)")
//                    // Only set error message if refresh fails; don't overwrite potential existing important messages
//                    if self?.errorMessage == nil {
//                        self?.errorMessage = "Session expired. Please log in again."
//                    }
//                    if let apiError = error as? APIError, apiError.isAuthError {
//                         self?.logout() // Force logout on auth errors during refresh
//                    }
//                    completion?(false)
//                }
//            }
//        }
//    }
//
//    // --- Centralized Token Request ---
//    private func makeTokenRequest(grantType: String, code: String? = nil, verifier: String? = nil, refreshToken: String? = nil, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
//        var request = URLRequest(url: SpotifyConstants.tokenEndpoint)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        var components = URLComponents()
//        var queryItems = [
//            URLQueryItem(name: "client_id", value: SpotifyConstants.clientID),
//            URLQueryItem(name: "grant_type", value: grantType)
//        ]
//
//        if let code = code, let verifier = verifier, grantType == "authorization_code" {
//            queryItems.append(contentsOf: [
//                URLQueryItem(name: "code", value: code),
//                URLQueryItem(name: "redirect_uri", value: SpotifyConstants.redirectURI),
//                URLQueryItem(name: "code_verifier", value: verifier)
//            ])
//        } else if let refreshToken = refreshToken, grantType == "refresh_token" {
//            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
//        } else {
//            completion(.failure(APIError.invalidRequest(message: "Invalid parameters for token request.")))
//            return
//        }
//
//        components.queryItems = queryItems
//        request.httpBody = components.query?.data(using: .utf8)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error { completion(.failure(APIError.networkError(error))); return }
//            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(APIError.invalidResponse)); return }
//            guard let data = data else { completion(.failure(APIError.noData)); return } // Ensure data exists even for errors
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//
//            do {
//                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
//                completion(.success(tokenResponse))
//            } catch {
//                print("Token JSON Decoding Error: \(error)")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    // Helper to process token response
//    private func processSuccessfulTokenResponse(_ tokenResponse: TokenResponse, explicitRefreshToken: String? = nil) {
//        let newRefreshToken = explicitRefreshToken ?? tokenResponse.refreshToken
//        let newStoredTokens = StoredTokens(
//            accessToken: tokenResponse.accessToken,
//            refreshToken: newRefreshToken,
//            expiryDate: tokenResponse.expiryDate
//        )
//        self.currentTokens = newStoredTokens
//        self.saveTokens(tokens: newStoredTokens)
//        self.isLoggedIn = true
//        self.errorMessage = nil
//    }
//
//    // --- API Data Fetching ---
//    func fetchUserProfile() {
//        makeAPIRequest(
//            url: SpotifyConstants.userProfileEndpoint,
//            responseType: SpotifyUserProfile.self
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                 // Assuming general isLoading might have been true, set it false
//                 // We don't need a separate isLoadingProfile flag for this simple case
//                 self?.isLoading = false
//                switch result {
//                case .success(let profile):
//                    self?.userProfile = profile
//                    print("Successfully fetched user profile for \(profile.displayName)")
//                case .failure(let error):
//                    self?.handleError("Could not fetch profile: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // Fetch User Playlists (Uses renamed API model)
//    func fetchUserPlaylists(loadNextPage: Bool = false) {
//        guard !isLoadingPlaylists else { return }
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistError("Cannot fetch playlists: Not logged in.")
//            return
//        }
//
//        var urlToFetch: URL?
//        if loadNextPage {
//            guard let nextUrlString = playlistNextPageUrl, let nextUrl = URL(string: nextUrlString) else {
//                print("Playlist Fetch: No next page URL.")
//                return
//            }
//            urlToFetch = nextUrl
//        } else {
//            urlToFetch = SpotifyConstants.userPlaylistsEndpoint
//            // Reset state only when fetching the first page
//            userPlaylists = []
//            playlistNextPageUrl = nil
//            playlistErrorMessage = nil
//        }
//
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistError("Invalid URL for fetching playlists.")
//            return
//        }
//
//        isLoadingPlaylists = true
//        playlistErrorMessage = nil // Clear previous errors on new fetch attempt
//
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyAPI_PlaylistList.self // Use renamed type alias
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoadingPlaylists = false
//                switch result {
//                case .success(let playlistResponse):
//                    if loadNextPage {
//                        self?.userPlaylists.append(contentsOf: playlistResponse.items)
//                    } else {
//                        self?.userPlaylists = playlistResponse.items
//                    }
//                    self?.playlistNextPageUrl = playlistResponse.next
//                    self?.playlistErrorMessage = nil // Clear error on success
//                    print("Fetched playlists page. Total: \(self?.userPlaylists.count ?? 0)")
//                case .failure(let error):
//                    self?.handlePlaylistError("Could not fetch playlists: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // Fetch Tracks for a specific Playlist
//    func fetchTracksForPlaylist(playlistID: String, loadNextPage: Bool = false) {
//        guard !isLoadingPlaylistTracks else { return }
//        guard isLoggedIn, currentTokens?.accessToken != nil else {
//            handlePlaylistTracksError("Cannot fetch tracks: Not logged in.")
//            return
//        }
//
//        var urlToFetch: URL?
//         if loadNextPage {
//             guard let nextUrlString = playlistTracksNextPageUrl, let nextUrl = URL(string: nextUrlString) else {
//                 print("Playlist Tracks Fetch: No next page URL.")
//                 return
//             }
//             urlToFetch = nextUrl
//         } else {
//             // Reset state when fetching the first page *for this playlist*
//             currentPlaylistTracks = []
//             playlistTracksNextPageUrl = nil
//             playlistTracksErrorMessage = nil
//             let tracksEndpointString = SpotifyConstants.playlistBaseEndpoint + "\(playlistID)/tracks"
//             // Optional: Add fields parameter, e.g., "?fields=items(track(id,name,artists(id,name),album(id,name,images),duration_ms,uri))"
//             urlToFetch = URL(string: tracksEndpointString)
//         }
//
//        guard let finalUrl = urlToFetch else {
//            handlePlaylistTracksError("Invalid URL for fetching tracks of playlist \(playlistID).")
//            return
//        }
//
//        isLoadingPlaylistTracks = true
//        playlistTracksErrorMessage = nil
//
//        print("Fetching tracks from: \(finalUrl.absoluteString)")
//
//        makeAPIRequest(
//            url: finalUrl,
//            responseType: SpotifyAPI_PlaylistTrackList.self // Use correct type alias
//        ) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoadingPlaylistTracks = false
//                switch result {
//                case .success(let trackResponse):
//                    // Filter out nil tracks *before* appending/assigning
//                    let validTracks = trackResponse.items.filter { $0.track != nil }
//
//                    if loadNextPage {
//                        self?.currentPlaylistTracks.append(contentsOf: validTracks)
//                    } else {
//                        self?.currentPlaylistTracks = validTracks
//                    }
//                    self?.playlistTracksNextPageUrl = trackResponse.next
//                    self?.playlistTracksErrorMessage = nil // Clear error on success
//                     print("Fetched tracks page for \(playlistID). Total valid tracks loaded: \(self?.currentPlaylistTracks.count ?? 0)")
//                case .failure(let error):
//                    let errorDesc = (error as? APIError)?.errorDescription ?? error.localizedDescription
//                    self?.handlePlaylistTracksError("Could not fetch tracks: \(errorDesc)")
//                }
//            }
//        }
//    }
//
//
//    // Generic API Request Handler (with Token Refresh Logic)
//    private func makeAPIRequest<T: Decodable>(
//        url: URL,
//        method: String = "GET",
//        body: Data? = nil,
//        responseType: T.Type,
//        currentAttempt: Int = 1, // Start attempt count at 1
//        maxAttempts: Int = 2,    // Allow one retry after refresh
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//         guard currentAttempt <= maxAttempts else {
//             completion(.failure(APIError.maxRetriesReached))
//             return
//         }
//
//         guard let accessToken = currentTokens?.accessToken else {
//             completion(.failure(APIError.notLoggedIn))
//             return
//         }
//
//         // --- Check for Token Expiry BEFORE making the call ---
//         if let expiryDate = currentTokens?.expiryDate, expiryDate <= Date().addingTimeInterval(-10) { // Add small buffer
//             print("Token likely expired, attempting refresh before API call to \(url.lastPathComponent)...")
//             refreshToken { [weak self] success in
//                 if success {
//                     print("Token refreshed successfully. Retrying API call to \(url.lastPathComponent)...")
//                     // Important: Rerun the same function, it will now use the new token
//                     self?.makeAPIRequest(
//                         url: url, method: method, body: body, responseType: responseType,
//                         currentAttempt: currentAttempt + 1, // Increment attempt count
//                         maxAttempts: maxAttempts, completion: completion
//                     )
//                 } else {
//                     print("Token refresh failed. Aborting API call to \(url.lastPathComponent).")
//                     completion(.failure(APIError.tokenRefreshFailed))
//                     DispatchQueue.main.async { self?.logout() } // Logout if refresh fails
//                 }
//             }
//             return // Don't proceed with the original request
//         }
//         // --- End Token Expiry Check ---
//
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        if let body = body, (method == "POST" || method == "PUT") {
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = body
//        }
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { completion(.failure(APIError.unknown)); return }
//
//            if let error = error { completion(.failure(APIError.networkError(error))); return }
//            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(APIError.invalidResponse)); return }
//            guard let data = data else { completion(.failure(APIError.noData)); return } // Need data for error parsing too
//
//            // --- Handle Auth Errors (401/403) by Refreshing Token ---
//            if (httpResponse.statusCode == 401 || httpResponse.statusCode == 403) {
//                 print("Received \(httpResponse.statusCode) for \(url.lastPathComponent). Attempting refresh...")
//                 refreshToken { [weak self] success in
//                     if success {
//                         print("Token refreshed. Retrying API call to \(url.lastPathComponent)...")
//                         // Retry the request - Increment attempt count
//                         self?.makeAPIRequest(
//                             url: url, method: method, body: body, responseType: responseType,
//                             currentAttempt: currentAttempt + 1,
//                             maxAttempts: maxAttempts, completion: completion
//                         )
//                     } else {
//                         print("Token refresh failed after \(httpResponse.statusCode). Aborting API call to \(url.lastPathComponent).")
//                         completion(.failure(APIError.authenticationFailed))
//                         DispatchQueue.main.async { self?.logout() } // Logout if refresh fails repeatedly
//                     }
//                 }
//                 return // Don't process the original error response yet
//            }
//            // --- End Auth Error Handling ---
//
//            guard (200...299).contains(httpResponse.statusCode) else {
//                let errorDetails = self.extractErrorDetails(from: data, statusCode: httpResponse.statusCode)
//                completion(.failure(APIError.httpError(statusCode: httpResponse.statusCode, details: errorDetails)))
//                return
//            }
//
//             // Handle Empty Response (e.g., 204 No Content)
//             if data.isEmpty && T.self == EmptyResponse.self {
//                 if let empty = EmptyResponse() as? T {
//                     completion(.success(empty))
//                 } else {
//                      completion(.failure(APIError.decodingError(nil))) // Should not happen
//                 }
//                 return
//             }
//
//            do {
//                let decodedObject = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedObject))
//            } catch {
//                print("API JSON Decoding Error for \(T.self) from \(url.lastPathComponent): \(error)")
//                print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
//                completion(.failure(APIError.decodingError(error)))
//            }
//        }.resume()
//    }
//
//    // --- State Management ---
//    func clearPlaylistDetailState() {
//        DispatchQueue.main.async {
//            print("Clearing playlist detail state.")
//            self.selectedPlaylist = nil
//            self.currentPlaylistTracks = []
//            self.playlistTracksErrorMessage = nil
//            self.playlistTracksNextPageUrl = nil
//            self.isLoadingPlaylistTracks = false
//        }
//    }
//
//    func logout() {
//        DispatchQueue.main.async {
//            self.isLoggedIn = false
//            self.currentTokens = nil
//            self.userProfile = nil
//            self.errorMessage = nil
//            self.userPlaylists = []
//            self.playlistErrorMessage = nil
//            self.isLoading = false
//            self.isLoadingPlaylists = false
//            self.playlistNextPageUrl = nil
//            self.clearTokens()
//            self.clearPlaylistDetailState() // Clear detail state on logout
//            self.currentWebAuthSession?.cancel()
//            self.currentWebAuthSession = nil
//            self.currentPKCEVerifier = nil
//            print("User logged out.")
//        }
//    }
//
//    // --- Token Persistence (UserDefaults - INSECURE!) ---
//    private func saveTokens(tokens: StoredTokens) {
//        // WARNING: Use Keychain for production apps!
//        if let encoded = try? JSONEncoder().encode(tokens) {
//            UserDefaults.standard.set(encoded, forKey: SpotifyConstants.tokenUserDefaultsKey)
//            print("Tokens saved to UserDefaults (Insecure).")
//        } else {
//            print("Error: Failed to encode tokens.")
//        }
//    }
//
//    private func loadTokens() {
//        if let savedTokens = UserDefaults.standard.data(forKey: SpotifyConstants.tokenUserDefaultsKey),
//           let decodedTokens = try? JSONDecoder().decode(StoredTokens.self, from: savedTokens) {
//            self.currentTokens = decodedTokens
//            print("Tokens loaded from UserDefaults.")
//        } else {
//            print("No valid tokens found in UserDefaults.")
//            self.currentTokens = nil
//        }
//    }
//
//    private func clearTokens() {
//        UserDefaults.standard.removeObject(forKey: SpotifyConstants.tokenUserDefaultsKey)
//        print("Tokens cleared from UserDefaults.")
//    }
//
//    // --- Error Handling Helpers ---
//    private func handleError(_ message: String, clearVerifier: Bool = false) {
//        DispatchQueue.main.async {
//            self.errorMessage = message
//            if clearVerifier { self.currentPKCEVerifier = nil }
//        }
//        print("Error: \(message)")
//    }
//
//    private func handlePlaylistError(_ message: String) {
//        DispatchQueue.main.async { self.playlistErrorMessage = message }
//        print("Playlist Error: \(message)")
//    }
//
//    private func handlePlaylistTracksError(_ message: String) {
//        DispatchQueue.main.async { self.playlistTracksErrorMessage = message }
//        print("Playlist Tracks Error: \(message)")
//    }
//
//    private func extractErrorDetails(from data: Data?, statusCode: Int) -> String {
//        guard let data = data else { return "Status code \(statusCode)" }
//        if let spotifyError = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: data), let msg = spotifyError.error.message {
//             return "\(msg) (Status: \(spotifyError.error.status))"
//        }
//        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//           let errorDesc = json["error_description"] as? String ?? json["error"] as? String {
//             return errorDesc
//        }
//        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
//            return text
//        }
//        return "HTTP status code \(statusCode)"
//    }
//}
//
//// MARK: - ASWebAuthenticationPresentationContextProviding
//// Needs to inherit from NSObject to conform
//extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
//    func isEqual(_ object: Any?) -> Bool {
//        return true
//    }
//    
//    var hash: Int {
//        return 0
//    }
//    
//    var superclass: AnyClass? {
//        return nil
//    }
//    
//    func `self`() -> Self {
//        return self
//    }
//    
//    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
//        return Unmanaged.passUnretained(self)
//    }
//    
//    func isProxy() -> Bool {
//        return true
//    }
//    
//    func isKind(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    func isMember(of aClass: AnyClass) -> Bool {
//        return true
//    }
//    
//    func conforms(to aProtocol: Protocol) -> Bool {
//        return true
//    }
//    
//    func responds(to aSelector: Selector!) -> Bool {
//        return true
//    }
//    
//    var description: String {
//        return ""
//    }
//    
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        // Find the key window
//        let keyWindow = UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .compactMap { $0 as? UIWindowScene }
//            .first?.windows
//            .first { $0.isKeyWindow }
//        return keyWindow ?? ASPresentationAnchor()
//    }
//}
//
//// MARK: - PKCE Helper Extension
//extension Data {
//    func base64URLEncodedString() -> String {
//        return self.base64EncodedString()
//            .replacingOccurrences(of: "+", with: "-")
//            .replacingOccurrences(of: "/", with: "_")
//            .replacingOccurrences(of: "=", with: "")
//    }
//}
//
//// MARK: - SwiftUI Views (Auth & API)
//
//struct AuthenticationFlowView: View {
//    @StateObject var authManager = SpotifyAuthManager()
//
//    var body: some View {
//        // Use NavigationStack for modern navigation
//        NavigationStack {
//            Group {
//                if !authManager.isLoggedIn {
//                    loggedOutView
//                        .navigationTitle("Spotify Login")
//                } else {
//                    loggedInContentView
//                        .navigationTitle("Your Spotify")
//                }
//            }
//            // Navigation Destination using the *renamed* API Playlist Model
//            .navigationDestination(for: SpotifyAPI_Playlist.self) { playlist in
//                SpotifyAPI_PlaylistDetailView(playlist: playlist) // Navigate to renamed detail view
//                   .environmentObject(authManager)
//            }
//            .overlay { // Loading Indicator
//                if authManager.isLoading {
//                    ProgressView("Authenticating...")
//                        .padding()
//                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
//                }
//            }
//            .alert("Error", isPresented: Binding(
//                get: { authManager.errorMessage != nil },
//                set: { if !$0 { authManager.errorMessage = nil } }
//            ), presenting: authManager.errorMessage) { message in
//                Button("OK") {} // Button action implicitly dismisses
//            } message: { message in
//                Text(message)
//            }
//        }
//         // Optional: Handle deep link URL if needed for post-auth actions
//         // .onOpenURL { url in ... }
//    }
//
//    // MARK: Logged Out View
//    private var loggedOutView: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            Image(systemName: "music.note.house.fill") // Example icon
//                .font(.system(size: 60))
//                .foregroundColor(Color(red: 30/255, green: 215/255, blue: 96/255)) // Spotify Green
//
//            Text("Connect your Spotify account to explore your music.")
//                .font(.headline)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Button {
//                authManager.initiateAuthorization()
//            } label: {
//                 Label("Log in with Spotify", systemImage: "lock.fill")
//                      .fontWeight(.semibold)
//                      .foregroundColor(.white)
//                      .padding(.vertical, 12)
//                      .frame(maxWidth: .infinity)
//                      .background(Color(red: 30/255, green: 215/255, blue: 96/255))
//                      .clipShape(Capsule())
//             }
//            .disabled(authManager.isLoading)
//            .padding(.horizontal, 40)
//
//            Spacer()
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground)) // Adapts to light/dark mode
//    }
//
//    // MARK: Logged In Content View
//    private var loggedInContentView: some View {
//        List {
//            Section("Profile") { profileSection }
//            Section("My Playlists") { playlistSection }
////             Section("Account") { actionSection }
//        }
//        .listStyle(InsetGroupedListStyle())
//        .refreshable {
//            print("Refreshing profile and playlists...")
//            authManager.fetchUserProfile()
//            authManager.fetchUserPlaylists(loadNextPage: false) // Reset playlists on refresh
//        }
//        .onAppear {
//             // Fetch only if needed
//            if authManager.userProfile == nil { authManager.fetchUserProfile() }
//            if authManager.userPlaylists.isEmpty { authManager.fetchUserPlaylists() }
//        }
//    }
//
//    // MARK: Profile Section View Builder
//    @ViewBuilder private var profileSection: some View {
//        if let profile = authManager.userProfile {
//            HStack {
//                AsyncImage(url: URL(string: profile.images?.first?.url ?? "")) { image in
//                    image.resizable().aspectRatio(contentMode: .fill).clipShape(Circle())
//                } placeholder: {
//                    Image(systemName: "person.circle.fill").resizable().aspectRatio(contentMode: .fit).foregroundColor(.secondary)
//                }
//                .frame(width: 50, height: 50)
//
//                VStack(alignment: .leading) {
//                    Text(profile.displayName).font(.headline)
//                    Text(profile.email).font(.subheadline).foregroundColor(.secondary)
//                }
//            }
//            .padding(.vertical, 4)
//        } else if authManager.isLoading && authManager.userProfile == nil {
//            HStack { Spacer(); ProgressView(); Text("Loading Profile..."); Spacer() }
//        } else if authManager.errorMessage != nil && authManager.userProfile == nil {
//            Text("Could not load profile.").foregroundColor(.red)
//        }
//    }
//
//    // MARK: Playlist Section View Builder
//    @ViewBuilder private var playlistSection: some View {
//        if authManager.isLoadingPlaylists && authManager.userPlaylists.isEmpty {
//            HStack { Spacer(); ProgressView(); Text("Loading Playlists..."); Spacer() }
//        } else if let errorMsg = authManager.playlistErrorMessage {
//            Text("Error: \(errorMsg)").foregroundColor(.red)
//        } else if authManager.userPlaylists.isEmpty && !authManager.isLoadingPlaylists {
//            Text("No playlists found.").foregroundColor(.secondary)
//        } else {
//            // Use the renamed API Playlist Model
//            ForEach(authManager.userPlaylists) { playlist in
//                // NavigationLink uses the *renamed* Playlist model value
//                 NavigationLink(value: playlist) {
//                    HStack(spacing: 12) {
//                        AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { img in
//                            img.resizable().aspectRatio(contentMode: .fill)
//                        } placeholder: {
//                             Image(systemName: "music.note.list").resizable().scaledToFit().padding(10)
//                                  .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                  .background(.quaternary).foregroundColor(.secondary)
//                           }
//                        .frame(width: 45, height: 45)
//                        .cornerRadius(4)
//
//                        VStack(alignment: .leading) {
//                            Text(playlist.name).lineLimit(1)
//                            Text("By \(playlist.owner.displayName ?? "Spotify") • \(playlist.tracks.total) tracks")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                        if playlist.collaborative {
//                             Image(systemName: "person.2.fill").foregroundColor(.accentColor)
//                         }
//                    }
//                }
//                // Pagination Trigger
//                 .onAppear {
//                     if playlist.id == authManager.userPlaylists.last?.id && authManager.playlistNextPageUrl != nil && !authManager.isLoadingPlaylists {
//                          print("Playlist trigger: Loading next page...")
//                          authManager.fetchUserPlaylists(loadNextPage: true)
//                     }
//                 }
//            }
//             // Loading indicator for *next page* load
//             if authManager.isLoadingPlaylists && !authManager.userPlaylists.isEmpty {
//                 ProgressView().frame(maxWidth: .infinity).padding(.vertical)
//             }
//        }
//    }
//
//
//    // MARK: Action Section View
////    private var actionSection: some View {
//////        Group { // Using Group to potentially add more actions later
////            Button("Refresh Token") {
////                authManager.refreshToken()
////            }
////            .disabled(authManager.currentTokens?.refreshToken == nil || authManager.isLoading)
////
////            // Logout Button
////            Button("Log Out", role: .destructive) {
////                authManager.logout()
////            }
////
////            // Debug Token Info
////            if let tokens = authManager.currentTokens {
////                DisclosureGroup("Token Details (Debug)") {
////                     VStack(alignment: .leading, spacing: 4) {
////                         Text("Access Token:") + Text(" \(tokens.accessToken)")
////                         if let expiry = tokens.expiryDate {
////                             Text("Expires: \(expiry, style: .time)")
////                                  .font(.caption)
////                                  .foregroundColor(expiry <= Date() ? .red : .green)
////                         }
////                         Text("Refresh Token:") .font(.caption.weight(.bold)) + Text(" \(tokens.refreshToken != nil ? "Present" : "Missing")")
////                              .font(.caption)
////                              .foregroundColor(tokens.refreshToken != nil ? .primary : .orange)
////                     }.padding(.top, 2)
////                 }
////                 .font(.callout)
////            }
////         }
////         .padding(.vertical, 2) // Add slight vertical padding to buttons/group
////    }
//}
//
//
//// MARK: - Playlist Detail View (Auth & API - Renamed)
//// Uses the Renamed API Playlist Model
//struct SpotifyAPI_PlaylistDetailView: View {
//    @EnvironmentObject var authManager: SpotifyAuthManager
//    let playlist: SpotifyAPI_Playlist // Use renamed model
//
//    var body: some View {
//        List {
//             Section { // Use header parameter for cleaner List look
//                 SpotifyAPI_PlaylistHeaderView(playlist: playlist) // Use renamed header view
//                      .padding(.bottom, 5) // Add padding below header within its Section
//             }
//             .listRowInsets(EdgeInsets()) // Remove default insets for header section
//             .listRowBackground(Color.clear) // Make header background clear
//
//             Section("Tracks (\(authManager.currentPlaylistTracks.filter { $0.track != nil }.count))") {
//                 if authManager.isLoadingPlaylistTracks && authManager.currentPlaylistTracks.isEmpty {
//                     HStack { Spacer(); ProgressView(); Text("Loading Tracks..."); Spacer() }
//                 } else if let errorMsg = authManager.playlistTracksErrorMessage {
//                     Text("Error: \(errorMsg)").foregroundColor(.red)
//                 } else if authManager.currentPlaylistTracks.filter({ $0.track != nil }).isEmpty && !authManager.isLoadingPlaylistTracks {
//                     Text("This playlist has no playable tracks.").foregroundColor(.secondary)
//                 } else {
//                     ForEach(authManager.currentPlaylistTracks) { playlistTrack in
//                         if let track = playlistTrack.track {
//                             SpotifyAPI_TrackRowView(track: track) // Use renamed row view
//                                 .onAppear {
//                                     // Pagination Trigger for Tracks
//                                      if playlistTrack.id == authManager.currentPlaylistTracks.last?.id && authManager.playlistTracksNextPageUrl != nil && !authManager.isLoadingPlaylistTracks {
//                                          print("Track trigger: Loading next page...")
//                                           authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: true)
//                                      }
//                                 }
//                         } else {
//                              // Optional: Indicate unavailable track if needed
//                              // Text("Track unavailable").foregroundColor(.gray).font(.caption)
//                          }
//                     }
//                     // Loading indicator for *next page* of tracks
//                      if authManager.isLoadingPlaylistTracks && !authManager.currentPlaylistTracks.isEmpty {
//                          ProgressView().frame(maxWidth: .infinity).padding(.vertical)
//                      }
//                 }
//             }
//         }
//         .listStyle(InsetGroupedListStyle()) // Use inset grouped for better section separation
//         .navigationTitle(playlist.name)
//         .navigationBarTitleDisplayMode(.inline)
//         .onAppear {
//             // Set the selected playlist and fetch tracks if this view is appearing for a *new* playlist
//             // or if tracks are empty for the *current* playlist.
//             if authManager.selectedPlaylist?.id != playlist.id || authManager.currentPlaylistTracks.isEmpty {
//                 authManager.selectedPlaylist = playlist
//                 authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//              }
//         }
//         .onDisappear {
//              // Only clear the state if we are navigating away from the *currently selected* playlist
//              if authManager.selectedPlaylist?.id == playlist.id {
//                    authManager.clearPlaylistDetailState()
//               }
//         }
//         .refreshable {
//              print("Refreshing tracks for playlist \(playlist.id)")
//              authManager.fetchTracksForPlaylist(playlistID: playlist.id, loadNextPage: false)
//          }
//    }
//}
//
//// MARK: - Helper Views for API Detail View
//
//// Playlist Header View (Auth & API - Renamed)
//// Uses the Renamed API Playlist Model
//struct SpotifyAPI_PlaylistHeaderView: View {
//    let playlist: SpotifyAPI_Playlist // Use renamed model
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//             AsyncImage(url: URL(string: playlist.images?.first?.url ?? "")) { image in
//                 image.resizable().aspectRatio(contentMode: .fit)
//             } placeholder: {
//                  Image(systemName: "music.note.list").resizable().scaledToFit().padding()
//                       .frame(maxWidth: .infinity, maxHeight: .infinity)
//                       .background(.quaternary).foregroundColor(.secondary)
//             }
//             .frame(width: 100, height: 100)
//             .cornerRadius(8)
//             .shadow(radius: 3)
//
//             VStack(alignment: .leading, spacing: 4) {
//                 Text(playlist.name).font(.headline).lineLimit(2)
//                 // Only show description if it exists and is not empty
//                 if let description = playlist.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                      Text(description).font(.caption).foregroundColor(.secondary).lineLimit(3)
//                 }
//                 Text("By \(playlist.owner.displayName ?? "Unknown")")
//                     .font(.caption2).foregroundColor(.secondary)
//                 Text("\(playlist.tracks.total) tracks")
//                       .font(.caption2).foregroundColor(.secondary)
//                 if playlist.collaborative {
//                      Label("Collaborative", systemImage: "person.2.fill")
//                           .font(.caption2).foregroundColor(.accentColor)
//                  }
//             }
//             Spacer() // Push content to left
//         }
//         .padding() // Add padding around the header content
//         .frame(maxWidth: .infinity) // Ensure HStack takes full width
//         .background(.ultraThinMaterial) // Give header a distinct background
//    }
//}
//
//
//// Track Row View (Auth & API - Renamed)
//struct SpotifyAPI_TrackRowView: View {
//    let track: SpotifyTrack
//
//    var body: some View {
//        HStack(spacing: 12) {
//             AsyncImage(url: URL(string: track.album.images?.last?.url ?? track.album.images?.first?.url ?? "")) { image in // Prefer smaller image
//                 image.resizable().aspectRatio(contentMode: .fill)
//             } placeholder: {
//                  Image(systemName: "music.mic")
//                       .resizable().scaledToFit().padding(10)
//                       .frame(maxWidth: .infinity, maxHeight: .infinity)
//                       .background(.quaternary).foregroundColor(.secondary)
//             }
//            .frame(width: 45, height: 45)
//            .cornerRadius(4)
//
//            VStack(alignment: .leading) {
//                Text(track.name)
//                   .lineLimit(1)
//                   .font(.body)
//                Text(track.artistNames)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//
//            Spacer() // Push duration to the right
//
//            Text(track.formattedDuration)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .monospacedDigit() // Keeps duration alignment consistent
//        }
//        .padding(.vertical, 4) // Slight padding within row
//    }
//}
//
//// MARK: - Previews (Auth & API)
//
//// Preview Structure for AuthenticationFlowView States
//struct AuthFlowPreviews: PreviewProvider {
//    static var previews: some View {
//         // --- Logged Out ---
//         AuthenticationFlowView()
//             .previewDisplayName("Auth: Logged Out")
//
//         // --- Logged In - Loading ---
//         let loadingManager = SpotifyAuthManager()
//         loadingManager.isLoggedIn = true
//         loadingManager.userProfile = nil // Simulate loading
//         loadingManager.currentTokens = StoredTokens(accessToken: "abc", refreshToken: "def", expiryDate: Date().addingTimeInterval(300)) // Need tokens to seem logged in
//         loadingManager.isLoadingPlaylists = true
//        AuthenticationFlowView(authManager: loadingManager)
//            .previewDisplayName("Auth: Logged In (Loading)")
//
//
//        // --- Logged In - List ---
//        let listManager = SpotifyAuthManager()
//        listManager.isLoggedIn = true
//        listManager.userProfile = SpotifyUserProfile(id: "p_list", displayName: "List User", email: "list@example.com", images: [], externalUrls: [:])
//        listManager.currentTokens = StoredTokens(accessToken: "abc", refreshToken: "def", expiryDate: Date().addingTimeInterval(300))
//        listManager.userPlaylists = [ // Use RENAMED model
//            SpotifyAPI_Playlist(id: "pl1", name: "Chill Vibes", description: "Music to relax to", owner: SpotifyPlaylistOwner(id: "user1", displayName: "Alice", externalUrls: nil), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 50), images: [], externalUrls: nil, publicPlaylist: true),
//            SpotifyAPI_Playlist(id: "pl2", name: "Workout Beats", description: nil, owner: SpotifyPlaylistOwner(id: "user2", displayName: "Bob", externalUrls: nil), collaborative: true, tracks: PlaylistTracksInfo(href: "", total: 100), images: nil, externalUrls: nil, publicPlaylist: false)
//        ]
//        listManager.isLoadingPlaylists = false
//       AuthenticationFlowView(authManager: listManager)
//           .previewDisplayName("Auth: Logged In (Playlist List)")
//
//
//       // --- Logged In - Error ---
//       let errorManager = SpotifyAuthManager()
//       errorManager.isLoggedIn = true
//       errorManager.userProfile = SpotifyUserProfile(id: "p_error", displayName: "Error User", email: "err@example.com", images: [], externalUrls: [:])
//       errorManager.currentTokens = StoredTokens(accessToken: "abc", refreshToken: "def", expiryDate: Date().addingTimeInterval(300))
//       errorManager.playlistErrorMessage = "Could not reach Spotify servers (Network Error)"
//       errorManager.isLoadingPlaylists = false
//       AuthenticationFlowView(authManager: errorManager)
//             .previewDisplayName("Auth: Logged In (Playlist Error)")
//    }
//}
//
//
//// Preview Structure for PlaylistDetailView States
////struct PlaylistDetailPreviews: PreviewProvider {
////    static var previews: some View {
////        // Sample Playlist Data (Using RENAMED model)
////        let samplePlaylist = SpotifyAPI_Playlist(id: "pl_detail_1", name: "Awesome Mix Vol. 1", description: "Legendary mixtape.", owner: SpotifyPlaylistOwner(id: "peter", displayName: "Peter Quill", externalUrls: nil), collaborative: false, tracks: PlaylistTracksInfo(href: "", total: 12), images: [], externalUrls: nil, publicPlaylist: true)
////        let sampleArtist = SpotifyArtistSimple(id: "art1", name: "Chill Hop", externalUrls: [:])
////        let sampleAlbum = SpotifyAlbumSimple(id: "alb1", name: "Study Vibes", images: [], externalUrls: [:])
////        let sampleTracks: [SpotifyPlaylistTrack] = [
////             SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk1", name: "Sunrise", artists: [sampleArtist], album: sampleAlbum, durationMs: 180000, trackNumber: 1, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk1")),
////             SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk2", name: "Rainy Day", artists: [sampleArtist], album: sampleAlbum, durationMs: 210000, trackNumber: 2, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk2")),
////             SpotifyPlaylistTrack(addedAt: nil, track: SpotifyTrack(id: "trk3", name: "Night Drive", artists: [sampleArtist], album: sampleAlbum, durationMs: 195000, trackNumber: 3, discNumber: 1, explicit: false, externalUrls: [:], uri: "spotify:track:trk3")),
////             SpotifyPlaylistTrack(addedAt: nil, track: nil) // Unavailable track
////         ]
////
////        // --- Detail - Loading Tracks ---
////        let loadingDetailManager = SpotifyAuthManager()
////        loadingDetailManager.isLoggedIn = true
////        loadingDetailManager.selectedPlaylist = samplePlaylist
////        loadingDetailManager.isLoadingPlaylistTracks = true
////        loadingDetailManager.currentPlaylistTracks = []
////        NavigationView { // Wrap in Nav for title
////            SpotifyAPI_PlaylistDetailView(playlist: samplePlaylist) // Use RENAMED view
////                .environmentObject(loadingDetailManager)
////        }.previewDisplayName("Detail: Loading Tracks")
////
////
////        // --- Detail - With Tracks ---
////        let tracksDetailManager = SpotifyAuthManager()
////        tracksDetailManager.isLoggedIn = true
////        tracksDetailManager.selectedPlaylist = samplePlaylist
////        tracksDetailManager.isLoadingPlaylistTracks = false
////        tracksDetailManager.currentPlaylistTracks = sampleTracks
////        // Optional: Simulate next page to test pagination UI
////        // tracksDetailManager.playlistTracksNextPageUrl = "https://api.spotify.com/v1/playlists/pl_detail_1/tracks?offset=3&limit=3"
////         NavigationView {
////             SpotifyAPI_PlaylistDetailView(playlist: samplePlaylist) // Use RENAMED view
////                .environmentObject(tracksDetailManager)
////         }.previewDisplayName("Detail: With Tracks")
////
////
////        // --- Detail - Error Loading Tracks ---
////        let errorDetailManager = SpotifyAuthManager()
////        errorDetailManager.isLoggedIn = true
////        errorDetailManager.selectedPlaylist = samplePlaylist
////        errorDetailManager.isLoadingPlaylistTracks = false
////        errorDetailManager.playlistTracksErrorMessage = "Failed to decode track data."
////        errorDetailManager.currentPlaylistTracks = []
////        NavigationView {
////            SpotifyAPI_PlaylistDetailView(playlist: samplePlaylist) // Use RENAMED view
////               .environmentObject(errorDetailManager)
////        }.previewDisplayName("Detail: Tracks Error")
////    }
////}
//
//
//// MARK: - ================= Spotify Auth & API End ==================
//
//// Note: There is no @main struct defined. You would need to add one
//// to make this runnable, choosing either SpotifyRemake_ContentView()
//// or AuthenticationFlowView() as the root view. Example:
///*
// @main
// struct MyApp: App {
//     var body: some Scene {
//         WindowGroup {
//             // Choose one:
//             // SpotifyRemake_ContentView()
//             AuthenticationFlowView()
//         }
//     }
// }
//*/
