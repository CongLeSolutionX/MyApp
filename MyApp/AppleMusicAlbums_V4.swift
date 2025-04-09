////
////  V4.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import Combine
//import MusicKit // Import the framework
//
//// --- Remove Placeholder Data Structures ---
//// We will now use MusicKit.Album and MusicKit.Track
//
//// --- Central App State Management (Updated for MusicKit) ---
//
//@MainActor
//class AppState: ObservableObject {
//    // Use MusicKit types
//    @Published var searchResults: MusicCatalogSearchResponse? // Holds entire search response
//    @Published var recentAlbumIDs: [MusicItemID] = [] // Store IDs for recents
//    @Published var recentAlbumsDetails: [Album] = [] // Store fetched details for display
//    @Published var musicSubscription: MusicSubscription? // Holds subscription status
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
//
//    // Playback State (Simplified - Using SystemMusicPlayer)
//    @Published var nowPlayingTitle: String? = nil
//    @Published var isPlaying: Bool = false
//
//    private var searchTask: Task<Void, Never>? // To cancel previous searches
//    private var subscriptionTask: Task<Void, Never>? // To monitor subscription
//    private var recentsUpdateTask: Task<Void, Never>? // To fetch recent details
//    private var playbackStateMonitor: AnyCancellable? // Monitor player state
//    private var cancellables = Set<AnyCancellable>()
//
//
//    private let maxRecents = 10
//    private let recentsStorageKey = "recentAlbumIDs" // Key for UserDefaults
//
//    init() {
//        print("AppState Initialized - MusicKit Integration")
//        loadRecents() // Load saved IDs
//        monitorPlaybackState() // Start monitoring player
//
//        // Assign the subscription monitoring task
//        self.subscriptionTask = Task { [weak self] in
//            await self?.monitorSubscriptionUpdates()
//        }
//        // Fetch details for loaded recent IDs
//         Task { await fetchRecentAlbumsDetails() }
//    }
//
//    deinit {
//        subscriptionTask?.cancel()
//        recentsUpdateTask?.cancel()
//        playbackStateMonitor?.cancel()
//    }
//
//    // MARK: - Authorization
//    func requestMusicAuthorization() async {
//        guard authorizationStatus == .notDetermined else { return } // Only request if not determined
//
//        isLoading = true
//        let status = await MusicAuthorization.request()
//        self.authorizationStatus = status
//        isLoading = false
//        print("Music Authorization Status: \(status)")
//        if status != .authorized {
//            errorMessage = "Music access is required. Please authorize in Settings."
//        }
//    }
//
//    // MARK: - Subscription Monitoring
//    private func monitorSubscriptionUpdates() async {
//         print("Starting Music Subscription monitoring...")
//         // Using AsyncStream to monitor updates
//         for await subscription in MusicSubscription.subscriptionUpdates {
//             Task { @MainActor [weak self] in // Ensure updates are on main thread
//                 print("Subscription status updated: \(subscription.canPlayCatalogContent)")
//                 self?.musicSubscription = subscription
//             }
//         }
//         print("Music Subscription monitoring finished.") // Should ideally run indefinitely
//    }
//
//    var canPlayCatalogContent: Bool {
//        musicSubscription?.canPlayCatalogContent ?? false
//    }
//
//    // MARK: - Catalog Search
//    func performSearch(term: String) {
//        guard authorizationStatus == .authorized else {
//             errorMessage = "Cannot search without Music authorization."
//             print("Search aborted: Not authorized")
//             // Optionally trigger auth request again here
//             return
//        }
//        guard !term.trimmingCharacters(in: .whitespaces).isEmpty else {
//             print("Search aborted: Empty search term")
//            self.searchResults = nil // Clear results for empty search
//            return
//        }
//
//        print("Performing search for: \(term)")
//        isLoading = true
//        errorMessage = nil
//        searchTask?.cancel() // Cancel the previous search task
//
//        searchTask = Task {
//            do {
//                var searchRequest = MusicCatalogSearchRequest(term: term, types: [Album.self]) // Search only for Albums
//                searchRequest.limit = 20 // Limit results
//                let searchResponse = try await searchRequest.response()
//
//                 // Check if task was cancelled before updating state
//                 try Task.checkCancellation()
//
//                // Update state on the main thread
//                Task { @MainActor [weak self] in
//                    self?.searchResults = searchResponse
//                    self?.isLoading = false
//                    print("Search completed. Found \(searchResponse.albums.count) albums.")
//                    if searchResponse.albums.isEmpty {
//                        self?.errorMessage = "No results found for \"\(term)\"."
//                    }
//                }
//            } catch is CancellationError {
//               print("Search task cancelled.")
//                // Don't clear isLoading here as a new search might have started
//            } catch {
//                 // Check if it's the specific error for cancelled URL task KERN_ABORTED
//               let nsError = error as NSError
//               if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
//                    print("Search network request cancelled.")
//               } else {
//                    print("Error during music search: \(error)")
//                    Task { @MainActor [weak self] in
//                        self?.errorMessage = "Search failed. Check connection or try again."
//                        self?.isLoading = false
//                         self?.searchResults = nil // Clear results on error
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Fetching Details
//    func fetchAlbumDetails(for albumID: MusicItemID) async -> (album: Album?, tracks: [Track]?, related: [Album]?) {
//        guard authorizationStatus == .authorized else {
//             print("Cannot fetch details: Not authorized.")
//             errorMessage = "Music access authorization needed."
//             return (nil, nil, nil)
//         }
//
//        print("Fetching details for Album ID: \(albumID.rawValue)...")
//        isLoading = true
//        errorMessage = nil
//        var fetchedAlbum: Album?
//        var fetchedTracks: [Track]?
//        var fetchedRelated: [Album]?
//
//        do {
//            // Request album and include 'tracks' and 'artists' relationships
//            var request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: albumID)
//            request.properties = [.tracks, .artists] // Specify relationships to fetch
//
//            let response = try await request.response()
//            fetchedAlbum = response.items.first
//
//            if let album = fetchedAlbum {
//                print("Successfully fetched primary album: \(album.title)")
//                // Tracks are included in the response if the relationship was fetched
//                fetchedTracks = album.tracks?.compactMap { $0 } // CompactMap to handle potential nil tracks if relationship fetching fails partially
//
//                // Fetch related albums (e.g., by the first artist)
//                if let artistID = album.artists?.first?.id {
//                    print("Fetching related albums by artist ID: \(artistID.rawValue)")
//                    var artistAlbumsRequest = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: artistID)
//                    artistAlbumsRequest.properties = [.albums] // Fetch the artist's albums relationship
//
//                    let artistResponse = try await artistAlbumsRequest.response()
//                    if let artist = artistResponse.items.first, let related = artist.albums {
//                          // Filter out the current album itself from related list
//                        fetchedRelated = related.filter { $0.id != album.id }.compactMap { $0 }
//                        print("Fetched \(fetchedRelated?.count ?? 0) related albums for artist \(artist.name).")
//                    } else {
//                        print("Could not fetch related albums (artist or albums relationship missing).")
//                    }
//                } else {
//                     print("Could not fetch related albums (album artist missing).")
//                }
//
//            } else {
//                print("Failed to fetch album with ID: \(albumID.rawValue)")
//                errorMessage = "Could not load album details."
//            }
//
//        } catch {
//            print("Error fetching album details/related: \(error)")
//            errorMessage = "Failed to load album details. Check connection."
//        }
//
//        isLoading = false
//         print("Finished fetching details for Album ID: \(albumID.rawValue). Tracks: \(fetchedTracks?.count ?? 0), Related: \(fetchedRelated?.count ?? 0)")
//        return (fetchedAlbum, fetchedTracks, fetchedRelated)
//    }
//
//
//    // MARK: - Recents Management
//    func addToRecents(_ album: Album) {
//        let id = album.id
//        recentAlbumIDs.removeAll { $0 == id }
//        recentAlbumIDs.insert(id, at: 0)
//        if recentAlbumIDs.count > maxRecents {
//            recentAlbumIDs.removeLast(recentAlbumIDs.count - maxRecents)
//        }
//        print("Added '\(album.title)' (ID: \(id.rawValue)) to recent IDs.")
//        saveRecents() // Persist IDs
//         // Immediately update the details array for instant UI feedback
//         recentAlbumsDetails.removeAll { $0.id == album.id }
//        recentAlbumsDetails.insert(album, at: 0)
//        if recentAlbumsDetails.count > maxRecents {
//            recentAlbumsDetails.removeLast(recentAlbumsDetails.count - maxRecents)
//        }
//    }
//
//    private func loadRecents() {
//        if let data = UserDefaults.standard.data(forKey: recentsStorageKey) {
//            do {
//                let decoder = JSONDecoder()
//                recentAlbumIDs = try decoder.decode([MusicItemID].self, from: data)
//                print("Loaded \(recentAlbumIDs.count) recent album IDs.")
//            } catch {
//                print("Error decoding recent album IDs: \(error)")
//            }
//        }
//    }
//
//    private func saveRecents() {
//        do {
//            let encoder = JSONEncoder()
//            let data = try encoder.encode(recentAlbumIDs)
//            UserDefaults.standard.set(data, forKey: recentsStorageKey)
//            print("Saved \(recentAlbumIDs.count) recent album IDs.")
//        } catch {
//            print("Error encoding recent album IDs: \(error)")
//        }
//    }
//
//    func fetchRecentAlbumsDetails() async {
//         guard authorizationStatus == .authorized else {
//             print("Cannot fetch recent details: Not authorized.")
//             // Don't show error, just wait for authorization
//             return
//         }
//        guard !recentAlbumIDs.isEmpty else {
//            print("No recent IDs to fetch details for.")
//             self.recentAlbumsDetails = [] // Ensure it's empty if IDs are empty
//            return
//        }
//
//        print("Fetching details for \(recentAlbumIDs.count) recent albums...")
//        isLoading = true // Consider a separate loading indicator for recents if desired
//
//         // Cancel previous task if it's still running
//         recentsUpdateTask?.cancel()
//
//         recentsUpdateTask = Task {
//             var fetchedDetails: [Album] = []
//             let idsToFetch = recentAlbumIDs // Capture current IDs
//
//             do {
//                 // Fetch albums in batches or individually. Individual is simpler for smaller lists.
//                 // MusicCatalogResourceRequest can take multiple IDs.
//                  var request = MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: idsToFetch)
//                  // request.limit = idsToFetch.count // Ensure all are fetched if limit applies
//
//                 let response = try await request.response()
//                  let albumsById = Dictionary(response.items.map { ($0.id, $0) }, uniquingKeysWith: { $1 })
//
//                 // Reconstruct the array in the original order of IDs
//                  fetchedDetails = idsToFetch.compactMap { albumsById[$0] }
//
//                 try Task.checkCancellation() // Check if task was cancelled
//
//                 print("Successfully fetched details for \(fetchedDetails.count) of \(idsToFetch.count) recent albums.")
//                 self.recentAlbumsDetails = fetchedDetails // Update the published array
//
//             } catch is CancellationError {
//                print("Fetching recent album details cancelled.")
//             } catch {
//                 print("Error fetching recent album details: \(error)")
//                 // Decide if an error message is appropriate here
//                  self.errorMessage = "Could not load some recent albums."
//             }
//              self.isLoading = false
//         }
//          await recentsUpdateTask?.value // Wait for the task to complete if needed elsewhere
//    }
//
//
//    func clearRecents() {
//        recentAlbumIDs.removeAll()
//        recentAlbumsDetails.removeAll()
//        UserDefaults.standard.removeObject(forKey: recentsStorageKey)
//        print("Recents cleared.")
//    }
//
//      // MARK: - Playback (Using SystemMusicPlayer)
//     private func monitorPlaybackState() {
//         playbackStateMonitor = SystemMusicPlayer.shared.state.objectWillChange.sink { [weak self] _ in
//             Task { @MainActor in // Ensure UI updates are on main actor
//                  self?.updatePlaybackState()
//             }
//         }
//          // Initial state check
//          updatePlaybackState()
//     }
//
//     private func updatePlaybackState() {
//          let newState = SystemMusicPlayer.shared.state.playbackStatus == .playing
//          if self.isPlaying != newState {
//              self.isPlaying = newState
//              print("Playback state updated: \(self.isPlaying ? "Playing" : "Paused/Stopped")")
//          }
//
//         self.nowPlayingTitle = SystemMusicPlayer.shared.queue.currentEntry?.title
//          // Could also get artist, artwork etc. from currentEntry.item
//     }
//
//
//    func playAlbum(_ album: Album) {
//        guard canPlayCatalogContent else {
//             errorMessage = "Apple Music subscription required to play."
//             print("Blocked playback for \(album.title) - No subscription.")
//             return
//        }
//        print("Requesting playback for album: \(album.title)")
//        Task {
//            do {
//                // Set the queue to the single album
//                SystemMusicPlayer.shared.queue = [album]
//                try await SystemMusicPlayer.shared.play()
//                print("Playback started for album \(album.title)")
//            } catch {
//                print("Error starting album playback for \(album.title): \(error)")
//                 errorMessage = "Could not start playback."
//            }
//        }
//    }
//
//     func playTrack(_ track: Track) {
//         guard canPlayCatalogContent else {
//             errorMessage = "Apple Music subscription required to play."
//             print("Blocked playback for track \(track.title) - No subscription.")
//             return
//         }
//          guard track.playParameters != nil else {
//               print("Cannot play track \(track.title) - Missing play parameters.")
//                errorMessage = "This track cannot be played directly."
//               return
//          }
//
//         print("Requesting playback for track: \(track.title)")
//         Task {
//            do {
//                 // Set the queue starting with this track.
//                 // You might fetch the album first to get the full track list for a better queue.
//                 // Simple approach: queue with just this track.
//                SystemMusicPlayer.shared.queue = [track]
//                try await SystemMusicPlayer.shared.play()
//                print("Playback started for track \(track.title)")
//            } catch {
//                print("Error starting track playback for \(track.title): \(error)")
//                 errorMessage = "Could not start playback."
//            }
//        }
//    }
//
//    func pausePlayback() {
//        print("Requesting pause")
//        SystemMusicPlayer.shared.pause()
//         // State update will happen via the monitor
//    }
//
//     func resumePlayback() {
//          print("Requesting resume")
//          Task {
//              do {
//                  try await SystemMusicPlayer.shared.play()
//              } catch {
//                   print("Error resuming playback: \(error)")
//                   errorMessage = "Could not resume playback."
//              }
//          }
//     }
//}
//
//// --- Reusable UI Components (Updated for MusicKit Types) ---
//
//struct ArtworkImage: View {
//    // Accept MusicKit.Artwork
//    let artwork: Artwork?
//    let size: CGFloat
//
//    var body: some View {
//         // Use AsyncImage with the URL from artwork
//         AsyncImage(url: artwork?.url(width: Int(size * 2), height: Int(size * 2))) { phase in // Request @2x
//            switch phase {
//            case .success(let image):
//                image.resizable()
//                     .aspectRatio(contentMode: .fit)
//            case .failure(_):
//                Image(systemName: "music.note") // Placeholder on error/no artwork
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .padding(size * 0.2)
//                    .background(.secondary) // Use system background
//                    .overlay {
//                         RoundedRectangle(cornerRadius: size * 0.1).stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
//                    }
//            case .empty:
//                 // Consistent placeholder during load
//                RoundedRectangle(cornerRadius: size * 0.1).fill(.secondary)
//                    .overlay(ProgressView())
//            @unknown default:
//                EmptyView()
//            }
//        }
//        .frame(width: size, height: size)
//        .clipShape(RoundedRectangle(cornerRadius: size * 0.1))
//        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
//    }
//}
//
//// Generic Cell - Updated to use Artwork directly
//struct MusicItemCell<Accessory: View>: View {
//    let artwork: Artwork? // Use MusicKit Artwork
//    let title: String
//    let subtitle: String
//    let accessoryView: Accessory
//
//    init(artwork: Artwork?, title: String, subtitle: String, @ViewBuilder accessory: () -> Accessory) {
//        self.artwork = artwork
//        self.title = title
//        self.subtitle = subtitle
//        self.accessoryView = accessory()
//    }
//
//    var body: some View {
//        HStack(spacing: 12) {
//            ArtworkImage(artwork: artwork, size: 50) // Pass Artwork
//
//            VStack(alignment: .leading) {
//                Text(title)
//                    .font(.headline)
//                    .lineLimit(1)
//                Text(subtitle)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//            Spacer()
//            accessoryView
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//extension MusicItemCell where Accessory == EmptyView {
//     init(artwork: Artwork?, title: String, subtitle: String) {
//        self.init(artwork: artwork, title: title, subtitle: subtitle) { EmptyView() }
//    }
//}
//
//// Album Cell - Updated for MusicKit.Album
//struct AlbumListCell: View {
//    let album: Album
//
//    var body: some View {
//        MusicItemCell(
//            artwork: album.artwork, // Use album.artwork
//            title: album.title,
//            subtitle: album.artistName
//        ) {
//            Image(systemName: "chevron.right")
//                .foregroundColor(.secondary)
//                .font(.caption.weight(.bold))
//                .imageScale(.small)
//        }
//    }
//}
//
//// Track Cell - Updated for MusicKit.Track
//struct TrackListCell: View {
//    @EnvironmentObject var appState: AppState
//    let track: Track
//    let trackNumber: Int? // Use track.trackNumber if available
//
//    private var formattedDuration: String? {
//        guard let duration = track.duration else { return nil }
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad
//        return formatter.string(from: duration)
//    }
//
//    // Check if this track is the one currently playing (basic check by title/id)
//    var isCurrentlyPlaying: Bool {
//         // Compare IDs for more accuracy if possible, else title
//        SystemMusicPlayer.shared.queue.currentEntry?.item?.id == track.id
//        // Fallback to title check if ID isn't readily available/matchable
//        // appState.nowPlayingTitle == track.title
//    }
//
//
//    var body: some View {
//         HStack {
//             Text("\(track.trackNumber ?? trackNumber ?? 0)") // Use MusicKit track number or passed index
//                 .font(.caption)
//                 .foregroundColor(.secondary)
//                 .frame(minWidth: 20, alignment: .trailing)
//                 // .padding(.leading, 5) // Add padding if needed
//
//             VStack(alignment: .leading) {
//                Text(track.title)
//                     .lineLimit(1)
//                     .foregroundStyle(track.playParameters != nil ? .primary : .secondary) // Dim unplayable tracks
//
//                 // Optionally show artist if different from album artist (requires fetching relationships)
//                 Text(track.artistName) // Display track's primary artist
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//             }
//             Spacer()
//             if let duration = formattedDuration {
//                 Text(duration)
//                     .font(.body) // Make duration slightly more prominent than before
//                     .monospacedDigit()
//                     .foregroundColor(.secondary)
//                     .padding(.trailing, 8)
//             }
//
//             // Show play indicator or nothing (tap action handles play)
//             if isCurrentlyPlaying && appState.isPlaying {
//                  Image(systemName: "speaker.wave.2.fill")
//                      .foregroundColor(.accentColor)
//                      .imageScale(.small)
//                      .frame(width: 20, height: 20) // Reserve space
//             } else {
//                  // Reserve space but keep invisible unless interacting
//                  Image(systemName: "play.circle")
//                     .foregroundColor(.accentColor)
//                     .imageScale(.large)
//                     .opacity(0)
//                     .frame(width: 20, height: 20) // Reserve space
//             }
//         }
//         .padding(.vertical, 6)
//         .contentShape(Rectangle())
//         .onTapGesture {
//             if track.playParameters != nil {
//                 appState.playTrack(track)
//             } else {
//                 print("Track \(track.title) is not playable.")
//                  appState.errorMessage = "This track may not be available in your region or requires purchase."
//             }
//         }
//          // Add context menu for actions?
//          .contextMenu {
//               Button { appState.playTrack(track) } label: { Label("Play", systemImage: "play.fill") }
//                   .disabled(track.playParameters == nil || !appState.canPlayCatalogContent)
//               // Add more actions: Add to queue, Add to Playlist, Show Artist, etc.
//          }
//    }
//}
//
//struct ProminentButtonStyle: ButtonStyle { /* ... same as before ... */
//    @Environment(\.isEnabled) private var isEnabled
//    @Environment(\.colorScheme) private var colorScheme
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .font(.headline.weight(.semibold))
//            .foregroundColor(isEnabled ? (colorScheme == .dark ? .black : .white) : .gray)
//            .background(isEnabled ? Color.accentColor : Color.secondary.opacity(0.3))
//            .clipShape(Capsule())
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .opacity(isEnabled ? 1.0 : 0.6)
//            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
//            .animation(.easeOut(duration: 0.15), value: isEnabled)
//    }
//}
//
//
//// --- Main Views (Updated for MusicKit) ---
//
//struct ContentView: View {
//    @EnvironmentObject var appState: AppState
//    @State private var searchTerm: String = ""
//    // Barcode scanning needs rethink - MusicKit doesn't directly map barcodes.
//    // Keep UI for now but functional part needs specific API or different approach.
//    @State private var isBarcodeScanningViewPresented: Bool = false
//    @State private var isDevelopmentSettingsViewPresented: Bool = false
//    @State private var scannedBarcode: String = "" // For manual entry simulation
//
//    // Computed property for search results from AppState
//    var albumsFound: MusicItemCollection<Album>? {
//        if let albumsFound = appState.searchResults?.albums {
//            return albumsFound
//        }
//        return nil
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                 // Display error message or loading indicator
//                 statusOverlay
//
//                 // Main Content List
//                List {
//                     if searchTerm.isEmpty {
//                         // Show Recents
//                         recentSection
//                     } else {
//                         // Show Search Results
//                         searchSection
//                     }
//                }
//                .listStyle(.insetGrouped)
//                 // Use searchable modifier correctly with async search
//                 .searchable(text: $searchTerm, prompt: "Search Albums & Artists")
//                 .onChange(of: searchTerm) {
//                      // Trigger search via AppState - Debounce if needed in complex app
//                      appState.performSearch(term: searchTerm)
//                 }
//                .navigationTitle("Music Albums")
//                .toolbar { navigationToolbar }
//
//                 // --- Now Playing Footer ---
//                 nowPlayingFooter
//            }
//             .animation(.default, value: appState.isPlaying) // Animate footer
//             .animation(.default, value: appState.errorMessage) // Animate error bar
//             // Request authorization when the view appears
//             .task { // Use .task for initial async setup
//                  await appState.requestMusicAuthorization()
//                  // Fetch recents if needed after authorization
//                  if appState.authorizationStatus == .authorized {
//                       await appState.fetchRecentAlbumsDetails()
//                  }
//             }
//            // --- Sheets ---
//            .sheet(isPresented: $isBarcodeScanningViewPresented) { barcodeScanningSheetContent }
//            .sheet(isPresented: $isDevelopmentSettingsViewPresented) { developmentSettingsSheetContent }
//            // Detect triple tap for dev settings
//            .onTapGesture(count: 3) { isDevelopmentSettingsViewPresented = true }
//        }
//        .navigationViewStyle(.stack)
//    }
//
//    // --- Subviews for ContentView ---
//
//    @ViewBuilder
//    private var statusOverlay: some View {
//         if let error = appState.errorMessage {
//             Text(error)
//                 .foregroundColor(.white)
//                 .padding(.vertical, 8).padding(.horizontal)
//                 .frame(maxWidth: .infinity)
//                 .background(Color.red)
//                 .cornerRadius(8)
//                 .padding(.horizontal)
//                 .transition(.move(edge: .top).combined(with: .opacity))
//                 .onTapGesture { appState.errorMessage = nil } // Allow dismissal
//         }
//        // No general loading indicator for ContentView itself, only during search/recents fetch shown in sections
//        if appState.authorizationStatus != .authorized && appState.authorizationStatus != .notDetermined {
//             VStack {
//                 Text("Music Access Required")
//                     .font(.headline)
//                 Text("Please authorize Apple Music access in Settings.")
//                      .font(.subheadline)
//                      .foregroundColor(.secondary)
//                 Button("Open Settings") {
//                      // Link to app settings
//                      if let url = URL(string: UIApplication.openSettingsURLString) {
//                           UIApplication.shared.open(url)
//                      }
//                 }
//                 .buttonStyle(.bordered)
//                 .padding(.top, 5)
//             }
//             .padding()
//             .background(.regularMaterial)
//             .cornerRadius(10)
//             .padding()
//        }
//    }
//
//
//     @ViewBuilder
//     private var recentSection: some View {
//          Section("Recently Viewed") {
//              if appState.isLoading && appState.recentAlbumsDetails.isEmpty { // Show loading only if recents aren't loaded yet
//                   ProgressView("Loading Recents...")
//              } else if appState.recentAlbumsDetails.isEmpty {
//                  Text("Albums you view will appear here.")
//                      .foregroundColor(.secondary)
//              } else {
//                  ForEach(appState.recentAlbumsDetails) { album in
////                       NavigationLink(destination: AlbumDetailView(albumId: album.id)) {
////                           AlbumListCell(album: album)
////                       }
//                  }
//                   // Add "Clear Recents" option?
//                    Button("Clear Recents", role: .destructive) {
//                         appState.clearRecents()
//                    }
//                   .frame(maxWidth: .infinity, alignment: .center) // Center the button
//              }
//          }
//     }
//
//    @ViewBuilder
//    private var searchSection: some View {
////        Section("Search Results (\(albumsFound?.count))") {
//             if appState.isLoading {
//                 ProgressView("Searching...")
//             } else if albumsFound?.isEmpty ?? false && appState.errorMessage == nil {
//                   // Don't show 'No Results' if an error message is already shown
//                  Text("No results found for \"\(searchTerm)\".")
//                         .foregroundColor(.secondary)
//             } else {
//                 ForEach(albumsFound! ) { album in
////                     NavigationLink(destination: AlbumDetailView(albumId: album.id)) {
////                         AlbumListCell(album: album)
////                     }
//                 }
//             }
////         }
//    }
//
//     @ToolbarContentBuilder
//     private var navigationToolbar: some ToolbarContent {
//         ToolbarItem(placement: .navigationBarLeading) {
//              Button { print("Menu Tapped - Not Implemented") } label: {
//                 Image(systemName: "line.3.horizontal.decrease.circle")
//              }
//         }
//         ToolbarItem(placement: .navigationBarTrailing) {
//             // Barcode scanning is complex with MusicKit IDs. Keep UI, but non-functional for now.
//             Button {
//                  scannedBarcode = ""
//                  isBarcodeScanningViewPresented = true
//                  appState.errorMessage = "Barcode search not directly supported by MusicKit. Use catalog search." // Inform user
//             } label: {
//                 Label("Scan Code", systemImage: "barcode.viewfinder")
//             }
//             // .disabled(true) // Can disable if decided
//         }
//    }
//
//     @ViewBuilder
//     private var nowPlayingFooter: some View {
//          // Using the state from AppState updated by the monitor
//          if appState.isPlaying || appState.nowPlayingTitle != nil {
//               HStack {
//                    // Mini artwork simulation (replace with actual if possible)
//                    Image(systemName: "music.note")
//                         .padding(8)
//                         .background(.secondary)
//                         .cornerRadius(4)
//
//                    Text(appState.nowPlayingTitle ?? "Playing Music")
//                         .font(.footnote.weight(.semibold))
//                         .lineLimit(1)
//                    Spacer()
//                    Button {
//                         if appState.isPlaying {
//                              appState.pausePlayback()
//                         } else if appState.nowPlayingTitle != nil { // Allow resume only if something was playing
//                              appState.resumePlayback()
//                         }
//                    } label: {
//                         Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
//                              .imageScale(.large)
//                              .contentTransition(.symbolEffect(.replace)) // Nice transition effect
//                    }
//                     .buttonStyle(.plain) // Remove button background/border
//               }
//               .padding()
//               .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10)) // Use material background
//               .padding(.horizontal)
//               .padding(.bottom, 5)
//               .shadow(radius: 3, y: 2)
//               .transition(.move(edge: .bottom).combined(with: .opacity))
//               .onTapGesture {
//                    // Tap footer to navigate to full player? (Not implemented)
//                    print("Now Playing Footer tapped")
//               }
//          }
//     }
//
//    // --- Sheet Content Views (Keep Dev Settings, Barcode is limited) ---
//    private var barcodeScanningSheetContent: some View {
//         NavigationView {
//             VStack(spacing: 20) {
//                Text("Manual Barcode Entry (Simulated)") // Title reflects limitation
//                     .font(.title2)
//
//                Text("Note: Finding albums by barcode is not directly supported via MusicKit. This simulates entering a term to search.")
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//                     .padding(.horizontal)
//
//                TextField("Enter Code/Term to Search", text: $scannedBarcode)
//                     .textFieldStyle(.roundedBorder)
//                     .padding(.horizontal)
//
//                 if appState.isLoading { ProgressView() }
//
//                 Button("Search Catalog") {
//                     if !scannedBarcode.isEmpty {
//                         searchTerm = scannedBarcode // Use the entry as a search term
//                         isBarcodeScanningViewPresented = false // Dismiss sheet
//                          // Search will be triggered by the .onChange modifier on searchTerm
//                     }
//                 }
//                 .buttonStyle(.borderedProminent)
//                 .disabled(scannedBarcode.isEmpty || appState.isLoading)
//
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Simulated Scan")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                 ToolbarItem(placement: .navigationBarLeading) {
//                     Button("Cancel") { isBarcodeScanningViewPresented = false }
//                 }
//            }
//         }
//    }
//
//    private var developmentSettingsSheetContent: some View { /* ... same as before, uses AppState ... */
//         NavigationView {
//             Form {
//                 Section("App State Simulation") {
//                    // Subscription toggle doesn't make sense now, show actual status
//                     HStack {
//                          Text("Music Subscription Active")
//                          Spacer()
//                          Text(appState.canPlayCatalogContent ? "Yes" : "No")
//                               .foregroundColor(appState.canPlayCatalogContent ? .green : .red)
//                     }
//
//                    Button("Clear Recent Albums") {
//                        appState.clearRecents()
//                    }
//                    .foregroundColor(.red)
//                 }
//                  Section("Authorization") {
//                       Text("Status: \(appState.authorizationStatus.description)")
//                       if appState.authorizationStatus != .authorized {
//                            Button("Request Authorization Again") {
//                                 Task { await appState.requestMusicAuthorization() }
//                            }
//                       }
//                  }
//
//                 Section("Simulate Error") {
//                     Button("Trigger Generic Error Message") {
//                         appState.errorMessage = "This is a simulated error message."
//                         isDevelopmentSettingsViewPresented = false
//                     }
//                 }
//             }
//             .navigationTitle("Dev Settings")
//             .navigationBarTitleDisplayMode(.inline)
//             .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                     Button("Done") { isDevelopmentSettingsViewPresented = false }
//                 }
//             }
//         }
//    }
//}
//
////#Preview("ContentView") {
////    ContentView()
////        
////}
//// --- Detail View (Updated for MusicKit) ---
////
////struct AlbumDetailView: View {
////    @EnvironmentObject var appState: AppState
////    @Environment(\.dismiss) var dismiss
////
////    let albumId: MusicItemID // Pass ID
////
////    // State for fetched data
////    @State private var album: Album? = nil
////    @State private var tracks: [Track]? = nil // Use optional array
////    @State private var relatedAlbums: [Album]? = nil // Use optional array
////
////    @State private var isLoadingDetails: Bool = true
////    @State private var isShowingSubscriptionOffer: Bool = false
////
////    // Check if the current *loaded* album is playing
////    var isCurrentlyPlayingAlbum: Bool {
////         guard let currentAlbum = album else { return false }
////         // More robust check: is the player's queue set to this album?
////         // Or is the currently playing item from this album?
////         return SystemMusicPlayer.shared.queue.currentEntry?.item?.album?.id == currentAlbum.id && appState.isPlaying
////    }
////
////
////    var body: some View {
////         ScrollView {
////             // Conditional content based on loading state and success
////             content
////         }
////         .navigationTitle(album?.title ?? "") // Empty title while loading
////         .navigationBarTitleDisplayMode(.inline)
////         .task { // Use .task for async work tied to view lifecycle
////              await loadAlbumDetails()
////         }
////         .sheet(isPresented: $isShowingSubscriptionOffer) { // Identical sheet logic
////              subscriptionOfferSheet
////         }
////          .alert("Subscription Required", isPresented: Binding(get: { appState.errorMessage?.contains("subscription required") ?? false }, set: { _,_ in appState.errorMessage = nil } )
////
//
//// --- Detail View (Updated for MusicKit) ---
////
////struct AlbumDetailView: View {
////    @EnvironmentObject var appState: AppState
////    @Environment(\.dismiss) var dismiss
////
////    let albumId: MusicItemID // Pass ID
////
////    // State for fetched data
////    @State private var album: Album? = nil
////    @State private var tracks: [Track]? = nil // Use optional array
////    @State private var relatedAlbums: [Album]? = nil // Use optional array
////
////    @State private var isLoadingDetails: Bool = true
////    @State private var isShowingSubscriptionOffer: Bool = false
////
////    // Check if the current *loaded* album is playing
//////    var isCurrentlyPlayingThisAlbum: Bool {
//////        guard let currentAlbum = album else { return false }
//////        // Check if the system player's queue is currently playing AND the current item belongs to this album
//////        return SystemMusicPlayer.shared.queue.currentEntry?.item == currentAlbum.id && appState.isPlaying
//////    }
////
////    var body: some View {
////         ScrollView {
////             // Conditional content based on loading state and success
////             content
////                  .padding(.bottom, 80) // Add padding at the bottom to avoid now playing footer overlap
////         }
////         .navigationTitle(album?.title ?? "") // Empty title while loading
////         .navigationBarTitleDisplayMode(.inline)
////         .toolbar { detailToolbar } // Add toolbar items
////         .task { // Use .task for async work tied to view lifecycle
////              await loadAlbumDetails()
////         }
////         .sheet(isPresented: $isShowingSubscriptionOffer) { // Subscription Offer Sheet
////              subscriptionOfferSheet
////         }
////          .alert("Subscription Required", isPresented: Binding( // Alert for subscription errors
////                get: { appState.errorMessage?.contains("subscription required") ?? false },
////                set: { _,_ in if appState.errorMessage?.contains("subscription required") ?? false { appState.errorMessage = nil } } // Clear only subscription error
////          )) {
////               Button("Join Now") { isShowingSubscriptionOffer = true }
////               Button("Cancel", role: .cancel) {}
////           } message: {
////              Text("An Apple Music subscription is required to play this content.")
////           }
////         // Display general errors from AppState as well
////         .overlay(alignment: .top) { // Use overlay for transient error message
////              if let error = appState.errorMessage, !error.contains("subscription required") {
////                   Text(error)
////                       .foregroundColor(.white)
////                       .font(.caption)
////                       .padding(8)
////                       .frame(maxWidth: .infinity)
////                       .background(Color.red.opacity(0.9))
////                       .cornerRadius(8)
////                       .padding(.horizontal)
////                       .transition(.move(edge: .top).combined(with: .opacity))
////                       .onTapGesture { appState.errorMessage = nil }
////                       .animation(.default, value: appState.errorMessage)
////              }
////         }
////         // Add background material?
////          // .background(.systemGroupedBackground) // Match list background style if needed
////     }
////
////     // --- Detail View Content ---
////     @ViewBuilder
////     private var content: some View {
////         if isLoadingDetails {
////              VStack { // Wrap ProgressView for centering/padding
////                   Spacer(minLength: 50)
////                   ProgressView("Loading Album...")
////                   Spacer()
////              }
////               .frame(maxWidth: .infinity)
////         } else if let currentAlbum = album {
////              VStack(alignment: .leading, spacing: 20) {
////                   // --- Header Section ---
////                   albumHeader(album: currentAlbum)
////                       .padding(.horizontal)
////
////                   Divider()
////
////                   // --- Tracks Section ---
////                   // Pass the optional tracks array
////                   trackSection(tracks: tracks)
////
////                   // --- Related Albums Section ---
////                   if let related = relatedAlbums, !related.isEmpty {
////                        relatedSection(related: related)
////                   } else if !isLoadingDetails { // Only show if not loading and empty
////                        // Optionally hide the "No related" message or style differently
////                        // Text("No related albums found.")
////                        //    .font(.caption)
////                        //    .foregroundColor(.secondary)
////                        //    .padding()
////                   }
////                   // Add extra spacer at the bottom? Already added padding to ScrollView content.
////               }
////               .padding(.top) // Add top padding for content within ScrollView
////          } else {
////               // Error state if album is nil after loading attempt
////               VStack {
////                    Spacer(minLength: 50)
////                    Image(systemName: "exclamationmark.triangle.fill")
////                         .font(.largeTitle)
////                         .foregroundColor(.orange)
////                    Text("Failed to load album details.")
////                         .padding(.top)
////                         .foregroundColor(.secondary)
////                         .multilineTextAlignment(.center)
////                    Button("Go Back") { dismiss() }
////                         .buttonStyle(.bordered)
////                         .padding(.top)
////                    Spacer()
////               }
////                .padding() // Add padding to the error VStack
////               .frame(maxWidth: .infinity)
////          }
////     }
////
////
////     // --- Toolbar ---
////    @ToolbarContentBuilder
////    private var detailToolbar: some ToolbarContent {
////        ToolbarItem(placement: .navigationBarTrailing) {
////            HStack(spacing: 15) { // Added spacing
////                if isLoadingDetails {
////                    ProgressView().controlSize(.small)
////                } else if album != nil { // Only show buttons if album loaded
////                    // Add to Library / Remove from Library Button (requires library management)
////                    // LibraryButton(item: album) // Example custom button
////
////                    // Share Button
////                    ShareLink(item: album?.url ?? URL(string:"https://music.apple.com")!) { // Provide fallback URL
////                            Label("Share", systemImage: "square.and.arrow.up")
////                    }
////                    .disabled(album?.url == nil)
////                }
////            }
////        }
////    }
////
////
////     // --- Subviews for Detail Sections (Using MusicKit Types) ---
////
////     @ViewBuilder
////     private func albumHeader(album: Album) -> some View {
////          HStack(alignment: .bottom, spacing: 15) {
////              ArtworkImage(artwork: album.artwork, size: 120)
////
////              VStack(alignment: .leading, spacing: 5) { // Added spacing
////                  Text(album.title)
////                      .font(UIDevice.current.userInterfaceIdiom == .pad ? .largeTitle : .title2).fontWeight(.bold)
////                      .lineLimit(3) // Allow more lines
////
////                   // Check if artistURL is available for linking
////                   if let artistURL = album.artistURL {
////                       Link(destination: artistURL) { // Link to Music app artist page
////                           Text(album.artistName)
////                       }
////                       .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .title3)
////                       .foregroundColor(.secondary) // Style as secondary, but link color will apply
////                   } else {
////                       Text(album.artistName)
////                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .title3)
////                           .foregroundColor(.secondary)
////                   }
////
////
////                  // Optional details: Genre, Release Date, Record Label
////                  HStack(spacing: 4) { // Use HStack for inline details
////                       if let firstGenre = album.genres?.first?.name { // Safely unwrap genre
////                             Text(firstGenre)
////                       }
////                       if let release = album.releaseDate {
////                            Text("• \(release, style: .year)") // Use bullet separator
////                       }
////                       // Add record label if available and desired
////                       // if let label = album.recordLabelName { Text("• \(label)") }
////                   }
////                   .font(.caption)
////                   .foregroundColor(.secondary)
////                   .lineLimit(1) // Ensure details stay on one line
////
////                  // Show editorial notes if available
////                   if let editorial = album.editorialNotes?.standard ?? album.editorialNotes?.short {
////                       // Add a "More" button or expander here if desired
////                       Text(editorial)
////                           .font(.caption)
////                           .foregroundColor(.secondary)
////                           .lineLimit(3) // Show a snippet
////                           .padding(.top, 2)
////                  }
////
////                  Spacer(minLength: 10) // Ensure some space before button
////                  playButton(for: album) // Pass album for play action
////              }
////               Spacer(minLength: 0) // Allow VStack to shrink if needed, push content left
////          }
////     }
////
////    @ViewBuilder
////    private func trackSection(tracks: [Track]?) -> some View {
////        // Check if tracks array is available (even if empty)
////        guard let trackList = tracks else {
////             // Optionally show a placeholder or message if tracks relationship wasn't loaded
////             if !isLoadingDetails { // Only show if not loading
////                  Text("Track list unavailable.")
////                        .font(.caption)
////                        .foregroundColor(.secondary)
////                        .padding()
////             }
////              return // Exit the builder
////         }
////
////        Section {
////            // Use LazyVStack for potentially long track lists
////            LazyVStack(alignment: .leading, spacing: 0) { // Remove default spacing
////                 ForEach(Array(trackList.enumerated()), id: \.element.id) { index, track in
////                     // Pass track number from MusicKit if available, else use index
////                     TrackListCell(track: track, trackNumber: track.trackNumber ?? (index + 1))
////                          .padding(.leading) // Add leading padding to cell content itself
////
////                           // Add divider conditionally, e.g., not after the last track
////                          if index < trackList.count - 1 {
////                               Divider().padding(.leading, 55) // Indent divider past number+spacing area
////                          }
////                 }
////            }
////         } header: {
////              HStack {
////                   Text("Tracks (\(trackList.count))")
////                   Spacer()
////                    // Display total album duration if meaningful
////                   if let totalDuration = trackList.compactMap(\.duration).reduce(0, +), totalDuration > 0 {
////                        Text(formattedDuration(totalDuration))
////                             .font(.caption)
////                             .foregroundColor(.secondary)
////                   }
////              }
////              .font(.headline)
////              .padding(.horizontal)
////              .padding(.bottom, 5) // Add spacing below header
////         }
////    }
////
////    // Helper to format duration for the section header
////     private func formattedDuration(_ duration: TimeInterval) -> String {
////         let formatter = DateComponentsFormatter()
////         formatter.allowedUnits = [.hour, .minute] // Generally only hours/minutes needed for total time
////         formatter.unitsStyle = .abbreviated // Use brief style like 1h 15m
////         formatter.zeroFormattingBehavior = .dropLeading // Don't show 0h
////         return formatter.string(from: duration) ?? ""
////     }
////
////    @ViewBuilder
////    private func relatedSection(related: [Album]) -> some View {
////        Section {
////             ScrollView(.horizontal, showsIndicators: false) {
////                  LazyHStack(spacing: 15) { // Use LazyHStack
////                      ForEach(related) { relatedAlbum in
////                          // Navigate to ANOTHER detail view
////                          NavigationLink(value: relatedAlbum.id) { // Use NavigationLink(value:) for potential deeplinking
////                               VStack(alignment: .center) { // Center align content
////                                  ArtworkImage(artwork: relatedAlbum.artwork, size: 100)
////                                  Text(relatedAlbum.title)
////                                      .font(.caption)
////                                      .lineLimit(2)
////                                      .multilineTextAlignment(.center)
////                                      .frame(height: 35, alignment: .top) // Fixed height, align top
////
////                                   // Only show artist if different from the main album's artist
////                                   // if relatedAlbum.artistName != album?.artistName {
////                                   //      Text(relatedAlbum.artistName)
////                                   //          .font(.caption2)
////                                   //          .foregroundColor(.secondary)
////                                   //          .lineLimit(1)
////                                   // }
////                                }
////                                .frame(width: 100) // Ensure consistent width
////                          }
////                          .buttonStyle(.plain) // Improve appearance inside ScrollView
////                      }
////                  }
////                  .padding(.horizontal) // Add horizontal padding to the HStack content
////                  .padding(.bottom) // Add padding below scroll view items
////             }
////         } header: {
////              Text("More by \(album?.artistName ?? "Artist")") // Use artist name in header
////                  .font(.headline)
////                  .padding(.horizontal)
////                  .padding(.bottom, 5)
////         }
////         // Handle navigation destination for the value-based NavigationLink
////         .navigationDestination(for: MusicItemID.self) { albumID in
////              AlbumDetailView(albumId: albumID)
////         }
////    }
////
////    // Extracted Play/Join Button Logic for the Album
////    @ViewBuilder
////    private func playButton(for album: Album) -> some View {
////         // Use AppState's subscription status directly
////        if appState.canPlayCatalogContent {
////            Button {
////                 // Toggle playback for this specific album
////                  if isCurrentlyPlayingThisAlbum {
////                       appState.pausePlayback()
////                  } else {
////                       appState.playAlbum(album)
////                  }
////             } label: {
////                  // Dynamic label based on playing state
////                  Label(isCurrentlyPlayingThisAlbum ? "Pause" : "Play", systemImage: isCurrentlyPlayingThisAlbum ? "pause.fill" : "play.fill")
////             }
////             .buttonStyle(ProminentButtonStyle())
////             .disabled(album.tracks == nil && !isCurrentlyPlayingThisAlbum) // Disable if tracks aren't loaded yet (needed for queue), unless already playing it
////             .id("play_\(isCurrentlyPlayingThisAlbum)") // Helps animation/state updates
////        } else {
////             // Join Button if no subscription
////             Button("Join") {
////                 isShowingSubscriptionOffer = true
////             }
////             .buttonStyle(ProminentButtonStyle())
////        }
////    }
////
////    // Extracted Subscription Offer Sheet Content
////    private var subscriptionOfferSheet: some View {
////         // Standard Apple Music upsell sheet look
////         VStack(spacing: 15) { // Added spacing
////             Image(systemName: "applemusic.fill") // Official SF Symbol
////                 .font(.system(size: 60))
////                 .padding(.bottom)
////                 .foregroundColor(.pink) // Apple Music Pink
////
////             Text("Unlock with Apple Music") // Clearer Title
////                 .font(.title2.bold())
////
////             Text("Get access to millions of songs, exclusive content, and skip tracks anytime.")
////                 .font(.subheadline) // Slightly larger text
////                 .multilineTextAlignment(.center)
////                 .padding(.horizontal, 30) // More horizontal padding
////                 .foregroundColor(.secondary)
////
////             Button("Try it Free*") { // Standard CTA
////                 print("Subscription Learn More tapped - Open URL/Subscription Flow")
////                 isShowingSubscriptionOffer = false
////                 // In real app: open App Store subscription sheet or specific URL
////                  if let url = URL(string: "https://music.apple.com/subscribe?itscg=10000&itsct=musicsub_m1_buy_web"), UIApplication.shared.canOpenURL(url) {
////                      UIApplication.shared.open(url)
////                  }
////             }
////             .buttonStyle(ProminentButtonStyle())
////             .padding(.top)
////
////             Text("*Plan auto-renews until cancelled. Terms apply.") // Footer text
////                 .font(.caption2).foregroundColor(.secondary)
////
////             Button("Not Now") { isShowingSubscriptionOffer = false }
////                 .padding(.top, 5)
////                 .tint(.secondary) // Less prominent style
////                 .font(.callout) // Slightly larger than caption
////         }
////         .padding(.vertical, 30).padding(.horizontal) // Add more padding
////         // Adapt for presentation detents if desired (iOS 16+)
////          // .presentationDetents([.medium])
////     }
////
////     // --- Data Loading Function ---
////     func loadAlbumDetails() async {
////          // Avoid reloading if already loaded and ID matches
////         guard self.album?.id != albumId || self.album == nil else {
////              print("AlbumDetailView: Details for \(albumId.rawValue) already loaded.")
////               isLoadingDetails = false // Ensure loading is off
////               // Re-add to recents on re-appear? Optional.
////               if let currentAlbum = self.album { appState.addToRecents(currentAlbum) }
////              return
////          }
////
////         print("AlbumDetailView: Loading details for ID \(albumId)")
////          isLoadingDetails = true
////          appState.errorMessage = nil // Clear previous errors
////
////          let details = await appState.fetchAlbumDetails(for: albumId)
////
////         // Update state on the main actor
////         await MainActor.run {
////             self.album = details.album
////             self.tracks = details.tracks
////             self.relatedAlbums = details.related
////              self.isLoadingDetails = false
////
////              // Add to recents only *after* successfully fetching the album data
////              if let loadedAlbum = details.album {
////                   appState.addToRecents(loadedAlbum)
////              }
////              print("AlbumDetailView: Finished Loading UI update for \(details.album?.title ?? "Unknown Album").")
////
////             // If the album fetch completely failed (details.album is nil), AppState might have set an error.
////             // Or we can handle it explicitly here.
////              if details.album == nil && appState.errorMessage == nil {
////                  // Set a generic error if AppState didn't provide one
////                   appState.errorMessage = "Could not load album details. Please try again later."
////              }
////         }
////     }
////}
////
////
////// --- App Structure (With State Management) ---
////
////@main
////struct MusicAlbumsApp: App {
////    // Create the single source of truth for the app state
////    @StateObject private var appState = AppState()
////
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////                // Inject the app state into the environment
////                .environmentObject(appState)
////             // Could apply welcome sheet modifier here if needed
////        }
////    }
////}
////
////// --- Preview Provider Helper ---
////// Create a helper to provide a configured AppState for previews
//////struct PreviewAppState {
//////    static var configured: AppState = {
//////        let state = AppState()
//////        // Simulate authorized state for previews
//////        state.authorizationStatus = .authorized
//////        state.musicSubscription = MusicSubscription() // Assume subscribed for previews
//////        // Add some dummy recent details for preview
//////        // Note: MusicKit items can be complex to mock fully
//////        // state.recentAlbumsDetails = [/* Mocked Album objects here if possible */]
//////        return state
//////    }()
//////}
////
////
////// --- Preview Providers ---
////
////#Preview { // New #Preview macro (Xcode 15+)
////     ContentView()
////         .environmentObject(PreviewAppState.configured) // Use configured state
////}
////
////
////#Preview { // New #Preview macro (Xcode 15+)
////     NavigationView {
////         // Need a valid ID from MusicKit. This might fail if catalog changes.
////         // Better to mock data or use a known static ID if available for testing.
////          // For now, use a placeholder/potentially invalid ID for structure preview.
////          AlbumDetailView(albumId: MusicItemID("1579384638")) // Example ID (Check if valid)
////     }
////     .environmentObject(PreviewAppState.configured) // Use configured state
////}
////
////// Add MusicAuthorization.Status description extension for Dev Settings
////extension MusicAuthorization.Status: CustomStringConvertible {
////    public var description: String {
////        switch self {
////        case .notDetermined: return "Not Determined"
////        case .denied: return "Denied"
////        case .restricted: return "Restricted"
////        case .authorized: return "Authorized"
////        @unknown default: return "Unknown"
////        }
////    }
////}
////
////// Add MusicPlayer.PlaybackStatus description extension for AppState logging
////extension MusicPlayer.PlaybackStatus: CustomStringConvertible {
////    public var description: String {
////        switch self {
////        case .stopped: return "Stopped"
////        case .playing: return "Playing"
////        case .paused: return "Paused"
////        case .interrupted: return "Interrupted"
////        case .seekingForward: return "Seeking Forward"
////        case .seekingBackward: return "Seeking Backward"
////        @unknown default: return "Unknown Status"
////        }
////    }
////}
