////
////  AppleMusicKitFramework.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import Combine // For ObservableObject, Publishers
//import SwiftUI // For UI elements and modifiers
//import MusicKit // The core framework
//
//// MARK: - Core Data Models (Placeholder for demonstration)
//
//// These are simplified representations. In a real app, you'd use the actual
//// MusicKit types returned from API calls. These are here primarily for
//// structuring the SwiftUI views before actual data fetching.
//
//struct DemoAlbum: Identifiable {
//    let id: MusicItemID
//    let title: String
//    let artistName: String
//    let artwork: Artwork?
//    // Add other relevant properties if needed for display
//}
//
//struct DemoTrack: Identifiable {
//    let id: MusicItemID
//    let title: String
//    let artistName: String
//    let artwork: Artwork?
//    // Add other relevant properties if needed for display
//}
//
//struct DemoArtist: Identifiable {
//    let id: MusicItemID
//    let name: String
//    let artwork: Artwork?
//    // Add other relevant properties if needed for display
//}
//
//struct DemoPlaylist: Identifiable {
//    let id: MusicItemID
//    let name: String
//    let curatorName: String?
//    let artwork: Artwork?
//    // Add other relevant properties if needed for display
//}
//
//// MARK: - View Models
//
//@MainActor
//class MusicManager: ObservableObject {
//    // --- Authorization & Subscription ---
//    @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
//    @Published var subscriptionStatus: MusicSubscription? = nil
//    @Published var canPlayCatalogContent: Bool = false
//    @Published var canBecomeSubscriber: Bool = false
//    @Published var hasCloudLibraryEnabled: Bool = false
//
//    // --- Data Fetching ---
//    @Published var searchResultsAlbums: [Album] = []
//    @Published var searchResultsArtists: [Artist] = []
//    @Published var searchResultsSongs: [Song] = []
//    @Published var searchResultsPlaylists: [Playlist] = []
//    @Published var searchSuggestions: [MusicCatalogSearchSuggestionsResponse.Suggestion] = []
//    @Published var topSearchResults: [MusicCatalogSearchResponse.TopResult] = []
//
//    @Published var fetchedAlbum: Album? = nil
//    @Published var albumTracks: [Track] = []
//    @Published var recentlyPlayedItems: [RecentlyPlayedMusicItem] = []
//    @Published var recommendations: [MusicPersonalRecommendation] = []
//    @Published var librarySongs: [Song] = []
//    @Published var libraryAlbums: [Album] = []
//    @Published var songCharts: [MusicCatalogChart<Song>] = []
//
//    // --- Library Management ---
//    @Published var libraryPlaylists: [Playlist] = []
//    @Published var createdPlaylist: Playlist? = nil
//    @Published var lastLibraryError: Error? = nil
//
//    // --- Playback ---
//    // Using ApplicationMusicPlayer for app-specific playback
//    let player = ApplicationMusicPlayer.shared
//    @Published var playerState = ApplicationMusicPlayer.shared.state
//    @Published var currentEntry: MusicPlayer.Queue.Entry? = nil
//    @Published var playbackStatus: MusicPlayer.PlaybackStatus = .stopped
//    @Published var repeatMode: MusicPlayer.RepeatMode? = nil
//    @Published var shuffleMode: MusicPlayer.ShuffleMode? = nil
//    @Published var currentTrackArtwork: Artwork? = nil
//    @Published var currentTrackTitle: String = "Nothing Playing"
//    @Published var currentTrackArtist: String = ""
//
//    private var cancellables = Set<AnyCancellable>()
//    private var authMonitorTask: Task<Void, Never>? = nil
//    private var subMonitorTask: Task<Void, Never>? = nil
//    private var playerStateMonitorTask: Task<Void, Never>? = nil
//
//    init() {
//        monitorAuthorization()
//        monitorSubscription()
//        monitorPlayerState()
//        Task {
//            await checkInitialAuthorization()
//            await checkInitialSubscription()
//        }
//    }
//
//    // --- Authorization Monitoring ---
//    func monitorAuthorization() {
//        authMonitorTask?.cancel() // Cancel previous task if any
//        authMonitorTask = Task { @MainActor in
//            // MusicAuthorization.updates is not directly available,
//            // developers usually check status when needed or app enters foreground.
//            // We'll just update it periodically or on demand.
//            print("Auth monitoring started (simulated - will check on demand)")
//        }
//    }
//
//    func checkInitialAuthorization() async {
//        let status = MusicAuthorization.currentStatus
//        await updateAuthStatus(status)
//    }
//
//    func requestAuthorization() async {
//        let status = await MusicAuthorization.request()
//        await updateAuthStatus(status)
//    }
//
//    @MainActor
//    private func updateAuthStatus(_ status: MusicAuthorization.Status) {
//        authorizationStatus = status
//        print("Authorization Status Updated: \(status)")
//    }
//
//    // --- Subscription Monitoring ---
//    func monitorSubscription() {
//        subMonitorTask?.cancel()
//        subMonitorTask = Task { @MainActor in
//            do {
//                for await subscription in MusicSubscription.subscriptionUpdates {
//                    await updateSubscriptionStatus(subscription)
//                }
//            } catch {
//                print("Error monitoring subscription updates: \(error)")
//                await updateSubscriptionStatus(nil) // Update UI on error
//            }
//        }
//    }
//
//    func checkInitialSubscription() async {
//        do {
//            let subscription = try await MusicSubscription.current
//            await updateSubscriptionStatus(subscription)
//        } catch {
//            print("Error fetching initial subscription status: \(error)")
//            await updateSubscriptionStatus(nil) // Update UI on error
//        }
//    }
//
//    @MainActor
//    private func updateSubscriptionStatus(_ subscription: MusicSubscription?) {
//        self.subscriptionStatus = subscription
//        self.canPlayCatalogContent = subscription?.canPlayCatalogContent ?? false
//        self.canBecomeSubscriber = subscription?.canBecomeSubscriber ?? false
//        // Note: hasCloudLibraryEnabled reflects iCloud Music Library status, often needed for library *modification*
//        self.hasCloudLibraryEnabled = subscription?.hasCloudLibraryEnabled ?? false
//        print("Subscription Status Updated: \(String(describing: subscription))")
//    }
//
//    // --- Player State Monitoring ---
//    func monitorPlayerState() {
//        playerStateMonitorTask?.cancel()
//        playerStateMonitorTask = Task { @MainActor in
//            // Monitor changes to the player's state
//            self.player.state.objectWillChange
//                .receive(on: RunLoop.main)
//                .sink { [weak self] _ in
//                    guard let self = self else { return }
//                    Task { await self.updatePlayerStateProperties() }
//                }
//                .store(in: &cancellables)
//
//            // Monitor changes to the player's queue current entry
//            self.player.queue.objectWillChange
//                .receive(on: RunLoop.main)
//                .sink { [weak self] _ in
//                    guard let self = self else { return }
//                     Task { await self.updatePlayerQueueProperties() }
//                }
//                .store(in: &cancellables)
//
//             // Initial update
//            await self.updatePlayerStateProperties()
//            await self.updatePlayerQueueProperties()
//        }
//    }
//
//    @MainActor
//    private func updatePlayerStateProperties() {
//        self.playbackStatus = player.state.playbackStatus
//        self.repeatMode = player.state.repeatMode
//        self.shuffleMode = player.state.shuffleMode
//        // print("Player State Updated: \(playbackStatus), Repeat: \(String(describing: repeatMode)), Shuffle: \(String(describing: shuffleMode))")
//    }
//
//     @MainActor
//     private func updatePlayerQueueProperties() {
//         self.currentEntry = player.queue.currentEntry
//         self.currentTrackArtwork = player.queue.currentEntry?.artwork
//         self.currentTrackTitle = player.queue.currentEntry?.title ?? "Nothing Playing"
//         self.currentTrackArtist = player.queue.currentEntry?.subtitle ?? ""
//         // print("Player Queue Updated: Current Entry - \(String(describing: currentEntry?.title))")
//     }
//
//
//    // --- Basic Playback Controls ---
//    func play() async {
//        do {
//            try await player.play()
//        } catch {
//            print("Error playing: \(error)")
//        }
//    }
//
//    func pause() {
//        player.pause()
//    }
//
//    func skipToNext() async {
//         do {
//             try await player.skipToNextEntry()
//         } catch {
//             print("Error skipping to next: \(error)")
//         }
//    }
//
//    func skipToPrevious() async {
//        // Restart if near beginning, otherwise skip back
//        if player.playbackTime < 5.0 {
//             do {
//                 try await player.skipToPreviousEntry()
//             } catch {
//                 print("Error skipping to previous: \(error)")
//             }
//         } else {
//             player.restartCurrentEntry()
//         }
//    }
//
//    func toggleShuffle() {
//        Task { @MainActor in
//            switch player.state.shuffleMode {
//            case .off, .none:
//                 player.state.shuffleMode = .songs
//             case .songs:
//                 player.state.shuffleMode = .off
//             default: // Handle potential future cases
//                 player.state.shuffleMode = .off
//            }
//            await updatePlayerStateProperties() // Manually trigger update after setting
//        }
//    }
//
//    func toggleRepeat() {
//       Task { @MainActor in
//            switch player.state.repeatMode {
//            case .none:
//                 player.state.repeatMode = .one
//             case .one:
//                 player.state.repeatMode = .all
//             case .all:
//                 player.state.repeatMode = .none
//             default: // Handle potential future cases
//                 player.state.repeatMode = .none
//            }
//             await updatePlayerStateProperties() // Manually trigger update after setting
//       }
//    }
//
//    // --- Catalog Searching ---
//    func performSearch(term: String, types: [any MusicCatalogSearchable.Type] = [Album.self, Artist.self, Song.self, Playlist.self]) async {
//        guard !term.isEmpty, !types.isEmpty else {
//            await clearSearchResults()
//            return
//        }
//
//        do {
//            var request = MusicCatalogSearchRequest(term: term, types: types)
//            request.limit = 25 // Set a reasonable limit
//            request.includeTopResults = true
//
//            let response = try await request.response()
//
//            // Assign results on the main thread
//            await MainActor.run {
//                self.searchResultsAlbums = response.albums.compactMap { $0 } // Ensure non-optional array
//                self.searchResultsArtists = response.artists.compactMap { $0 }
//                self.searchResultsSongs = response.songs.compactMap { $0 }
//                self.searchResultsPlaylists = response.playlists.compactMap { $0 }
//                self.topSearchResults = response.topResults.compactMap { $0 }
//                print("Search successful for '\(term)'")
//            }
//        } catch {
//            print("Error performing catalog search for '\(term)': \(error)")
//            await clearSearchResults()
//        }
//    }
//
//    func performSearchSuggestions(term: String) async {
//        guard !term.isEmpty else { return }
//        do {
//            var request = MusicCatalogSearchSuggestionsRequest(term: term, includingTopResultsOfTypes: [Song.self, Album.self])
//            request.limit = 10
//            let response = try await request.response()
//
//            await MainActor.run {
//                self.searchSuggestions = response.suggestions
//                // You could also update topSearchResults if needed from suggestions response
//                // self.topSearchResults = response.topResults.compactMap { $0 }
//                print("Fetched \(response.suggestions.count) suggestions for '\(term)'")
//            }
//        } catch {
//            print("Error fetching search suggestions for '\(term)': \(error)")
//             await MainActor.run {
//                 self.searchSuggestions = []
//             }
//        }
//    }
//
//    @MainActor
//    private func clearSearchResults() {
//        searchResultsAlbums = []
//        searchResultsArtists = []
//        searchResultsSongs = []
//        searchResultsPlaylists = []
//        topSearchResults = []
//        searchSuggestions = []
//    }
//
//    // --- Fetching Specific Items ---
//    func fetchAlbumDetails(album: Album) async {
//        do {
//            // Fetch the album again, this time requesting tracks and artists relationships
//            let detailedAlbum = try await album.with([.tracks, .artists])
//            await MainActor.run {
//                self.fetchedAlbum = detailedAlbum
//                self.albumTracks = detailedAlbum.tracks?.compactMap { $0 } ?? []
//                print("Fetched details for album: \(detailedAlbum.title)")
//            }
//        } catch {
//            print("Error fetching details for album \(album.id): \(error)")
//             await MainActor.run {
//                 self.fetchedAlbum = nil
//                 self.albumTracks = []
//             }
//        }
//    }
//
//    // --- Catalog Charts ---
//    func fetchTopCharts(genre: Genre? = nil, limit: Int = 20) async {
//        do {
//            var request = MusicCatalogChartsRequest(genre: genre, types: [Song.self])
//            request.limit = limit
//            let response = try await request.response()
//            await MainActor.run {
//                self.songCharts = response.songCharts
//                 print("Fetched \(response.songCharts.count) song charts.")
//            }
//        } catch {
//            print("Error fetching catalog charts: \(error)")
//             await MainActor.run {
//                 self.songCharts = []
//             }
//        }
//    }
//
//    // --- Recently Played & Recommendations ---
//    func fetchRecentlyPlayed(limit: Int = 20) async {
//        do {
//            var request = MusicRecentlyPlayedRequest<RecentlyPlayedMusicItem>() // Compound type
//            request.limit = limit
//            let response = try await request.response()
//            await MainActor.run {
//                self.recentlyPlayedItems = response.items.compactMap { $0 }
//                print("Fetched \(response.items.count) recently played items.")
//            }
//        } catch {
//            print("Error fetching recently played items: \(error)")
//            await MainActor.run {
//                 self.recentlyPlayedItems = []
//            }
//        }
//    }
//
//     func fetchRecommendations(limit: Int = 10) async {
//         do {
//             var request = MusicPersonalRecommendationsRequest()
//             request.limit = limit
//             let response = try await request.response()
//             await MainActor.run {
//                 self.recommendations = response.recommendations.compactMap { $0 }
//                 print("Fetched \(response.recommendations.count) recommendations.")
//             }
//         } catch {
//             print("Error fetching recommendations: \(error)")
//             await MainActor.run {
//                 self.recommendations = []
//             }
//         }
//     }
//
//    // --- Playback Actions ---
//    func playItem<T: PlayableMusicItem>(_ item: T) async {
//        do {
//            // Set the queue with the single item
//            player.queue = .init(for: [item])
//            try await player.prepareToPlay() // Prepare before playing is good practice
//            try await player.play()
//            print("Attempting to play item: \(item.id)")
//        } catch {
//            print("Error setting queue and playing item \(item.id): \(error)")
//        }
//    }
//
//    func playAlbum(_ album: Album, startTrack: Track? = nil) async {
//        do {
//             if let startTrack = startTrack {
//                 player.queue = .init(album: album, startingAt: startTrack)
//             } else {
//                 // Fetch tracks if needed to play the whole album from the start
//                 let detailedAlbum = try await album.with([.tracks])
//                 guard let albumTracks = detailedAlbum.tracks, !albumTracks.isEmpty else {
//                     print("Album has no tracks to play.")
//                     return
//                 }
//                 player.queue = .init(for: albumTracks) // Play all tracks
//             }
//
//            try await player.prepareToPlay()
//            try await player.play()
//            print("Attempting to play album: \(album.title)")
//        } catch {
//            print("Error setting queue and playing album \(album.id): \(error)")
//        }
//    }
//
//    func playPlaylist(_ playlist: Playlist, startEntry: Playlist.Entry? = nil) async {
//       do {
//           if let startEntry = startEntry, let entries = try? await playlist.with([.entries]).entries {
//               // Find the actual Entry object from the fetched entries using the ID
//               if let matchingEntry = entries.first(where: { $0.id == startEntry.id }) {
//                    player.queue = .init(playlist: playlist, startingAt: matchingEntry)
//               } else {
//                   print("Start entry not found in playlist entries, playing from beginning.")
//                   player.queue = .init(for: [playlist]) // Fallback: Play the playlist itself
//               }
//           } else {
//               player.queue = .init(for: [playlist]) // Play the playlist itself (might require fetching items)
//           }
//           try await player.prepareToPlay()
//           try await player.play()
//           print("Attempting to play playlist: \(playlist.name)")
//       } catch {
//           print("Error setting queue and playing playlist \(playlist.id): \(error)")
//       }
//   }
//
//    // --- Library Interaction ---
//     func fetchLibrarySongs(limit: Int = 50, filterTerm: String? = nil, sortBy: KeyPath<LibrarySongSortProperties, String>? = \.title, ascending: Bool = true) async {
//        do {
//            var request = MusicLibraryRequest<Song>()
//            request.limit = limit
//
//            if let term = filterTerm, !term.isEmpty {
//                // Example: Filter by title containing the term
//                 request.filter(matching: \.title, contains: term)
//                 // Could also add artistName filter: request.filter(matching: \.artistName, contains: term)
//            }
//
//            if let sortKeyPath = sortBy {
//                request.sort(by: sortKeyPath, ascending: ascending)
//            }
//
//            let response = try await request.response()
//            await MainActor.run {
//                self.librarySongs = response.items.compactMap { $0 }
//                 print("Fetched \(response.items.count) library songs.")
//            }
//        } catch {
//            print("Error fetching library songs: \(error)")
//            await MainActor.run {
//                self.librarySongs = []
//                self.lastLibraryError = error
//            }
//        }
//    }
//
//    func fetchLibraryAlbums(limit: Int = 50, sortBy: KeyPath<LibraryAlbumSortProperties, String>? = \.title, ascending: Bool = true) async {
//       do {
//           var request = MusicLibraryRequest<Album>()
//           request.limit = limit
//           request.sort(by: sortBy ?? \.title, ascending: ascending)
//
//           let response = try await request.response()
//           await MainActor.run {
//               self.libraryAlbums = response.items.compactMap { $0 }
//                print("Fetched \(response.items.count) library albums.")
//           }
//       } catch {
//           print("Error fetching library albums: \(error)")
//           await MainActor.run {
//               self.libraryAlbums = []
//               self.lastLibraryError = error
//           }
//       }
//   }
//
//    func addSongToLibrary(_ song: Song) async {
//        guard let addableSong = song as? MusicLibraryAddable else {
//            print("Error: Song type cannot be added to library (likely platform limitation).")
//            lastLibraryError = MusicLibrary.Error.unableToAddItem // Simulate error
//            return
//        }
//        #if canImport(UIKit) || os(macOS) // Check for platforms supporting library add
//        // Library modification requires specific platform availability
//         guard #available(iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, macOS 14.0, macCatalyst 17.0, *) else { return }
//         do {
//             try await MusicLibrary.shared.add(addableSong)
//             print("Successfully added song '\(song.title)' to library.")
//             lastLibraryError = nil
//             // Optionally refresh library view here
//             await fetchLibrarySongs()
//         } catch let error as MusicLibrary.Error where error == .itemAlreadyAdded {
//             print("Song '\(song.title)' is already in the library.")
//             lastLibraryError = error
//         } catch {
//             print("Error adding song '\(song.title)' to library: \(error)")
//              lastLibraryError = error
//         }
//         #else
//         print("Adding items to library is not supported on this platform.")
//         #endif
//    }
//
//    func addTrackToPlaylist(_ track: Track, playlist: Playlist) async {
//        guard let addableTrack = track as? MusicPlaylistAddable else {
//             print("Error: Track type cannot be added to playlist (likely platform limitation).")
//             lastLibraryError = MusicLibrary.Error.addToPlaylistFailed // Simulate error
//             return
//        }
//        #if canImport(UIKit) || os(macOS)
//         guard #available(iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, macOS 14.0, macCatalyst 17.0, *) else { return }
//         Task {
//             do {
//                let updatedPlaylist = try await MusicLibrary.shared.add(addableTrack, to: playlist)
//                 print("Successfully added track '\(track.title)' to playlist '\(playlist.name)'.")
//                 lastLibraryError = nil
//                 // Optionally update the playlist view or stored playlists
//                 await fetchLibraryPlaylists() // Example refresh
//             } catch {
//                 print("Error adding track '\(track.title)' to playlist '\(playlist.name)': \(error)")
//                 lastLibraryError = error
//             }
//         }
//         #else
//         print("Adding items to playlists is not supported on this platform.")
//         #endif
//    }
//
//     func createNewPlaylist(name: String, description: String? = nil, items: [any MusicPlaylistAddable]? = nil) async {
//        guard !name.isEmpty else {
//             print("Playlist name cannot be empty.")
//             lastLibraryError = MusicLibrary.Error.createPlaylistFailed
//             return
//         }
//        #if canImport(UIKit) || os(macOS)
//         guard #available(iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, macOS 14.0, macCatalyst 17.0, *) else { return }
//         Task {
//             do {
//                 let newPlaylist: Playlist
////                 if let itemsToAdd = items, !itemsToAdd.isEmpty {
////                     newPlaylist = try await MusicLibrary.shared.createPlaylist(name: name, description: description, items: itemsToAdd)
////                 } else {
//                     newPlaylist = try await MusicLibrary.shared.createPlaylist(name: name, description: description)
////                 }
//
//                 await MainActor.run {
//                      self.createdPlaylist = newPlaylist
//                      print("Successfully created playlist: \(newPlaylist.name)")
//                      self.lastLibraryError = nil
//                 }
//                 // Optionally refresh library playlists
//                 await fetchLibraryPlaylists()
//             } catch {
//                 print("Error creating playlist '\(name)': \(error)")
//                 await MainActor.run {
//                     self.createdPlaylist = nil
//                     self.lastLibraryError = error
//                 }
//             }
//         }
//         #else
//         print("Creating playlists is not supported on this platform.")
//         #endif
//    }
//
//    // Helper to fetch playlists (useful after creating one)
//    func fetchLibraryPlaylists() async {
//        // Similar implementation to fetchLibrarySongs/Albums but for Playlist
//        guard #available(iOS 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, macOS 14.0, macCatalyst 17.0, *) else { return }
//        do {
//            var request = MusicLibraryRequest<Playlist>()
//            request.limit = 100 // Fetch more playlists typically
//            request.sort(by: \.name, ascending: true)
//            let response = try await request.response()
//             await MainActor.run {
//                 self.libraryPlaylists = response.items.compactMap { $0 }
//                 print("Fetched \(response.items.count) library playlists.")
//            }
//        } catch {
//             print("Error fetching library playlists: \(error)")
//             await MainActor.run {
//                self.libraryPlaylists = []
//             }
//        }
//
//    }
//}
//
//// MARK: - SwiftUI Views
//
//// --- Reusable Components ---
//
//struct MusicListItem<Item: MusicItem & Identifiable>: View {
//    let item: Item
//    var artwork: Artwork? = nil
//    var title: String? = nil
//    var subtitle: String? = nil
//    var trailingText: String? = nil // e.g., duration
//
//    var body: some View {
//        HStack {
//            if let art = artwork {
//                ArtworkImage(art, width: 50, height: 50)
//                    .cornerRadius(4)
//                    .shadow(radius: 2)
//            } else {
//                Image(systemName: "music.note")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 50, height: 50)
//                    .padding(10)
//                    .background(Color.gray.opacity(0.3))
//                    .cornerRadius(4)
//            }
//
//            VStack(alignment: .leading) {
//                if let titleText = title {
//                    Text(titleText)
//                        .font(.headline)
//                        .lineLimit(1)
//                }
//                if let subtitleText = subtitle {
//                    Text(subtitleText)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                }
//            }
//
//            Spacer()
//
//            if let trail = trailingText {
//                 Text(trail)
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//struct PlayButtonItem<Item: PlayableMusicItem & Identifiable>: View {
//    let item: Item
//    @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        Button {
//            Task {
//                await musicManager.playItem(item)
//            }
//        } label: {
//            Image(systemName: "play.circle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 25, height: 25)
//        }
//        .buttonStyle(.plain) // Use plain style to avoid list row highlighting issues
//    }
//}
//
//struct AddToLibraryButton<Item: MusicItem & Identifiable>: View {
//    let item: Item
//    @EnvironmentObject var musicManager: MusicManager
//    @State private var feedbackText: String? = nil
//
//    var body: some View {
//        Button {
//             Task {
//                 if let song = item as? Song {
//                     await musicManager.addSongToLibrary(song)
//                    feedbackText = musicManager.lastLibraryError == nil ? "Added!" : "Error"
//                 } else if let album = item as? Album {
//                     // Similar logic for adding Album if MusicLibraryAddable
//                      print("Add Album To Library logic here")
//                      feedbackText = "Not Impl."
//                 } else if let playlist = item as? Playlist {
//                     // Similar logic for adding Playlist if MusicLibraryAddable
//                      print("Add Playlist To Library logic here")
//                      feedbackText = "Not Impl."
//                 } else {
//                     print("Item type cannot be added to library.")
//                     feedbackText = "Cannot Add"
//                 }
//                 // Clear feedback after a delay
//                 if feedbackText != nil {
//                     try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
//                     feedbackText = nil
//                 }
//             }
//        } label: {
//            HStack {
//                if let feedback = feedbackText {
//                    Text(feedback).font(.caption).transition(.opacity)
//                } else {
//                     Image(systemName: "plus.circle")
//                         .imageScale(.large)
//                         .foregroundColor(.accentColor)
//                }
//            }
//            .frame(minWidth: 50) // Ensure some width for feedback text
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//
//// --- Main Content View ---
//
//struct AppleMusicKitFrameworkCoreConceptsView: View {
//    @StateObject private var musicManager = MusicManager()
//    @State private var showSubscriptionOffer = false
//    @State private var subscriptionOfferOptions = MusicSubscriptionOffer.Options.default
//    @State private var searchTerm: String = ""
//
//    var body: some View {
//        NavigationView {
//            List {
//                // Authorization & Subscription Section
//                AuthSubscriptionSection(showSubscriptionOffer: $showSubscriptionOffer)
//
//                // Search Section
//                SearchSection(searchTerm: $searchTerm)
//
//                // Playback Controls Section (Basic)
//                NowPlayingSection()
//
//                 // Library Actions Section
//                 LibraryActionsSection()
//
//                // Display Sections (Results, Library, etc.)
//                if !searchTerm.isEmpty {
//                    SearchResultsSection(searchTerm: searchTerm)
//                } else {
//                    LibrarySection()
//                    ChartsAndRecommendationsSection()
//                }
//            }
//            .listStyle(SidebarListStyle()) // Use sidebar style for macOS/iPadOS look
//            .navigationTitle("MusicKit Demo")
////             #if os(macOS)
////             // Add a default detail view for macOS to avoid blank window
////             .frame(minWidth: 300)
////             Text("Select an item or perform a search.")
////                 .frame(maxWidth: .infinity, maxHeight: .infinity)
////            #endif
//        }
//        .environmentObject(musicManager)
//        // Subscription Offer Sheet Modifier
//        .musicSubscriptionOffer(
//            isPresented: $showSubscriptionOffer,
//            options: subscriptionOfferOptions
//        ) { error in
//             // Handle sheet load completion/error if needed
//             if let error = error {
//                 print("Error loading subscription offer: \(error.localizedDescription)")
//                 // Optionally show an alert to the user
//             } else {
//                 print("Subscription offer sheet loaded successfully.")
//             }
//         }
//       .onChange(of: searchTerm) { newValue in
//           // Basic debounce example
//            Task {
//                 try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
//                 if newValue == searchTerm { // Check if term hasn't changed again
//                     await musicManager.performSearch(term: newValue)
//                    await musicManager.performSearchSuggestions(term: newValue)
//                 }
//            }
//       }
//        .task { // Fetch initial data when view appears
//            await musicManager.fetchLibrarySongs(limit: 10) // Fetch some initial library data
//            await musicManager.fetchTopCharts(limit: 10)
//            await musicManager.fetchRecentlyPlayed(limit: 10)
//            await musicManager.fetchLibraryPlaylists()
//        }
//    }
//}
//
//// --- Sub-Sections for ContentView List ---
//
//struct AuthSubscriptionSection: View {
//    @EnvironmentObject var musicManager: MusicManager
//    @Binding var showSubscriptionOffer: Bool
//
//    var body: some View {
//        Section("Authorization & Subscription") {
//            // Authorization Status
//            HStack {
//                Text("Authorization:")
//                Spacer()
//                Text("\(musicManager.authorizationStatus.description)")
//                    .foregroundColor(authColor(musicManager.authorizationStatus))
//            }
//            // Request Button
//            if musicManager.authorizationStatus != .authorized {
//                Button("Request Authorization") {
//                    Task {
//                        await musicManager.requestAuthorization()
//                    }
//                }
//            }
//
//            Divider()
//
//            // Subscription Status
//             if musicManager.authorizationStatus == .authorized {
//                 HStack {
//                      Text("Can Play Catalog:")
//                      Spacer()
//                      Image(systemName: musicManager.canPlayCatalogContent ? "checkmark.circle.fill" : "xmark.circle.fill")
//                          .foregroundColor(musicManager.canPlayCatalogContent ? .green : .red)
//                 }
//                 HStack {
//                      Text("Can Become Subscriber:")
//                      Spacer()
//                      Image(systemName: musicManager.canBecomeSubscriber ? "checkmark.circle.fill" : "xmark.circle.fill")
//                           .foregroundColor(musicManager.canBecomeSubscriber ? .green : .red)
//                 }
//                 HStack {
//                     Text("Cloud Library Enabled:")
//                     Spacer()
//                     Image(systemName: musicManager.hasCloudLibraryEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
//                         .foregroundColor(musicManager.hasCloudLibraryEnabled ? .green : .red)
//                 }
//
//                // Show Offer Button
//                if musicManager.canBecomeSubscriber {
//                    Button("Show Subscription Offer") {
//                        showSubscriptionOffer = true
//                    }
//                }
//             } else {
//                 Text("Authorize first to check subscription.")
//                     .foregroundColor(.secondary)
//            }
//        }
//    }
//
//    func authColor(_ status: MusicAuthorization.Status) -> Color {
//        switch status {
//        case .authorized: return .green
//        case .denied, .restricted: return .red
//        case .notDetermined: return .orange
//        @unknown default: return .gray
//        }
//    }
//}
//
//struct SearchSection: View {
//     @Binding var searchTerm: String
//     @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        Section("Search Catalog") {
//             TextField("Search Albums, Artists, Songs...", text: $searchTerm)
//                #if os(macOS)
//                .textFieldStyle(.roundedBorder)
//                #endif
//
//            if !musicManager.searchSuggestions.isEmpty {
//                DisclosureGroup("Suggestions") {
//                    ForEach(musicManager.searchSuggestions) { suggestion in
//                        Button(suggestion.displayTerm) {
//                            searchTerm = suggestion.searchTerm // Trigger new search
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//           }
//        }
//    }
//}
//
//struct NowPlayingSection: View {
//    @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        Section("Now Playing (Application Player)") {
//            HStack {
//                 // Artwork
//                 if let artwork = musicManager.currentTrackArtwork {
//                      ArtworkImage(artwork, width: 60, height: 60)
//                         .cornerRadius(6)
//                 } else {
//                     Image(systemName: "music.note")
//                         .resizable().scaledToFit().frame(width: 60, height: 60)
//                         .padding(12).background(Color.secondary.opacity(0.3)).cornerRadius(6)
//                 }
//
//                // Track Info
//                 VStack(alignment: .leading) {
//                     Text(musicManager.currentTrackTitle).font(.headline).lineLimit(1)
//                     Text(musicManager.currentTrackArtist).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
//                     Text("Status: \(musicManager.playbackStatus.description)").font(.caption).foregroundColor(.orange)
//                 }
//                 Spacer()
//            }
//
//            // Controls
//             HStack {
//                 Spacer()
//                 Button { Task { await musicManager.skipToPrevious() } } label: { Image(systemName: "backward.fill") }
//                 Spacer()
//                 Button {
//                     if musicManager.playbackStatus == .playing { musicManager.pause() }
//                     else { Task { await musicManager.play() } }
//                 } label: { Image(systemName: musicManager.playbackStatus == .playing ? "pause.fill" : "play.fill") }.font(.largeTitle)
//                 Spacer()
//                 Button { Task { await musicManager.skipToNext() } } label: { Image(systemName: "forward.fill") }
//                 Spacer()
//            }.buttonStyle(.plain).imageScale(.large)
//
//            // Shuffle/Repeat
//            HStack {
//                Text("Shuffle:")
//                Spacer()
//                Button { musicManager.toggleShuffle() } label: {
//                     Image(systemName: musicManager.shuffleMode == .songs ? "shuffle.circle.fill" : "shuffle.circle")
//                        .foregroundColor(musicManager.shuffleMode == .songs ? .accentColor : .secondary)
//                }
//                Spacer()
//                 Text("Repeat:")
//                 Spacer()
//                 Button { musicManager.toggleRepeat() } label: {
//                     Image(systemName: repeatIcon(musicManager.repeatMode))
//                         .foregroundColor(musicManager.repeatMode != .none ? .accentColor : .secondary)
//                 }
//                 Spacer()
//            }.buttonStyle(.plain)
//
//        }
//    }
//    
//    func repeatIcon(_ mode: MusicPlayer.RepeatMode?) -> String {
//         switch mode {
//         case .one: return "repeat.1.circle.fill"
//         case .all: return "repeat.circle.fill"
//         default: return "repeat.circle"
//         }
//    }
//}
//
//struct LibraryActionsSection: View {
//     @EnvironmentObject var musicManager: MusicManager
//     @State private var newPlaylistName: String = ""
//     @State private var showingCreationStatus: String? = nil
//
//    var body: some View {
//        Section("Library Actions") {
//            VStack(alignment: .leading) {
//                Text("Create Playlist:")
//                 HStack {
//                     TextField("New Playlist Name", text: $newPlaylistName)
//                     Button("Create") {
//                          Task {
//                              await musicManager.createNewPlaylist(name: newPlaylistName)
//                              showingCreationStatus = musicManager.lastLibraryError == nil ? "Created!" : "Error"
//                               newPlaylistName = "" // Clear field
//                               try? await Task.sleep(nanoseconds: 2_000_000_000)
//                              showingCreationStatus = nil
//                          }
//                     }
//                     .disabled(newPlaylistName.isEmpty)
//                      if let status = showingCreationStatus {
//                          Text(status).font(.caption).foregroundColor(musicManager.lastLibraryError == nil ? .green : .red)
//                      }
//                 }
//            }
//            if let error = musicManager.lastLibraryError {
//                Text("Last Library Error: \(error.localizedDescription)")
//                    .font(.caption)
//                    .foregroundColor(.red)
//            }
//            
//            NavigationLink("View Library Playlists") {
//                 PlaylistListView(playlists: musicManager.libraryPlaylists, title: "Library Playlists")
//            }
//
//
//            // Button to Trigger Library Refresh
//             Button("Refresh Library Songs") {
//                 Task {
//                    await musicManager.fetchLibrarySongs(limit: 25)
//                 }
//            }
//             Button("Refresh Library Albums") {
//                  Task {
//                      await musicManager.fetchLibraryAlbums(limit: 25)
//                 }
//             }
//        }
//    }
//}
//
//struct SearchResultsSection: View {
//    let searchTerm: String
//    @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        // Using Group to potentially exceed 10 view limit in List
//        Group {
//            if !musicManager.topSearchResults.isEmpty {
//                 Section("Top Results for \"\(searchTerm)\"") {
//                     ForEach(musicManager.topSearchResults) { result in
//                         TopSearchResultRow(result: result)
//                    }
//                 }
//            }
//            if !musicManager.searchResultsSongs.isEmpty {
//                Section("Songs") {
//                    ForEach(musicManager.searchResultsSongs) { song in
//                        SongRow(song: song) // Specific row type for Songs
//                    }
//                }
//            }
//            if !musicManager.searchResultsAlbums.isEmpty {
//                 Section("Albums") {
//                     ForEach(musicManager.searchResultsAlbums) { album in
//                         NavigationLink(destination: AlbumDetailView(album: album)) {
//                             MusicListItem(item: album, artwork: album.artwork, title: album.title, subtitle: album.artistName)
//                         }
//                     }
//                 }
//            }
//            if !musicManager.searchResultsArtists.isEmpty {
//                 Section("Artists") {
//                     ForEach(musicManager.searchResultsArtists) { artist in
//                         // Make artist row navigable if you create an ArtistDetailView
//                         //NavigationLink(destination: ArtistDetailView(artist: artist)) {
//                             MusicListItem(item: artist, artwork: artist.artwork, title: artist.name)
//                         //}
//                     }
//                 }
//            }
//            if !musicManager.searchResultsPlaylists.isEmpty {
//                 Section("Playlists") {
//                    PlaylistListView(playlists: musicManager.searchResultsPlaylists, title: nil)
//                 }
//            }
//        }
//    }
//}
//
//struct LibrarySection: View {
//     @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        Section("My Library (Top 10)") {
//            if musicManager.librarySongs.isEmpty && musicManager.libraryAlbums.isEmpty {
//                Text("Library appears empty or not loaded yet.")
//                    .foregroundColor(.secondary)
//            }
//
//            if !musicManager.librarySongs.isEmpty {
//                DisclosureGroup("Songs") {
//                     ForEach(musicManager.librarySongs) { song in
//                         SongRow(song: song, showAddToLibrary: false) // Don't show add button for library items
//                    }
//                }
//            }
//            if !musicManager.libraryAlbums.isEmpty {
//                DisclosureGroup("Albums") {
//                     ForEach(musicManager.libraryAlbums) { album in
//                         NavigationLink(destination: AlbumDetailView(album: album)) {
//                             MusicListItem(item: album, artwork: album.artwork, title: album.title, subtitle: album.artistName)
//                         }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ChartsAndRecommendationsSection: View {
//     @EnvironmentObject var musicManager: MusicManager
//
//      var body: some View {
//          Group {
//               if !musicManager.songCharts.isEmpty {
//                   Section("Top Song Charts") {
//                       // Assuming only one chart type fetched for simplicity
//                       ForEach(musicManager.songCharts.first?.items ?? []) { song in
//                           SongRow(song: song)
//                       }
//                   }
//               }
//
//               if !musicManager.recentlyPlayedItems.isEmpty {
//                   Section("Recently Played") {
//                       ForEach(musicManager.recentlyPlayedItems) { item in
//                           RecentlyPlayedRow(item: item)
//                       }
//                   }
//               }
//
//               if !musicManager.recommendations.isEmpty {
//                   Section("Recommendations") {
//                       ForEach(musicManager.recommendations) { rec in
//                           DisclosureGroup(rec.title ?? "Recommended") {
//                               ForEach(rec.items) { item in
//                                   RecommendationItemRow(item: item)
//                               }
//                           }
//                       }
//                   }
//               }
//          }
//      }
//}
//
//
//// --- Detail Views and Specific Row Types ---
//
//struct SongRow: View {
//    let song: Song
//    var showAddToLibrary: Bool = true // Control visibility of add button
//    @EnvironmentObject var musicManager: MusicManager
//
//     var body: some View {
//         HStack {
//             MusicListItem(item: song, artwork: song.artwork, title: song.title, subtitle: song.artistName, trailingText: formatDuration(song.duration))
//             Spacer()
//             if showAddToLibrary {
//                 AddToLibraryButton(item: song)
//             }
//             PlayButtonItem(item: song)
//         }
//     }
//
//     func formatDuration(_ duration: TimeInterval?) -> String? {
//         guard let duration = duration, duration > 0 else { return nil }
//         let formatter = DateComponentsFormatter()
//         formatter.allowedUnits = [.minute, .second]
//         formatter.unitsStyle = .positional
//         formatter.zeroFormattingBehavior = .pad
//         return formatter.string(from: duration)
//     }
//}
//
//struct PlaylistListView: View {
//     let playlists: [Playlist]
//     let title: String? // Optional title for the view itself
//     @EnvironmentObject var musicManager: MusicManager
//
//     var body: some View {
//        #if os(macOS) // Conditional compilation for Title
//         let displayTitle = title ?? "Playlists"
//        #else
//         let displayTitle = title ?? "" // iOS title set via navigationTitle
//        #endif
//
//        List {
//            ForEach(playlists) { playlist in
//                 HStack {
//                     MusicListItem(item: playlist, artwork: playlist.artwork, title: playlist.name, subtitle: playlist.curatorName)
//                     Spacer()
//                     PlayButtonItem(item: playlist) // Play the whole playlist
//                 }
//            }
//        }
//        .navigationTitle(displayTitle)
//    }
//}
//
//
//struct AlbumDetailView: View {
//    @State var album: Album // Use @State if you modify it locally (e.g., fetch details)
//    @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//        List {
//            // Album Header (Artwork, Title, Artist)
//            VStack {
//                if let artwork = album.artwork {
//                    ArtworkImage(artwork, width: 200) // Larger artwork
//                         .cornerRadius(8)
//                         .shadow(radius: 5)
//                         .padding(.bottom)
//                }
//                Text(album.title).font(.title).bold()
//                Text(album.artistName).font(.title2).foregroundColor(.secondary)
//                Button {
//                     Task { await musicManager.playAlbum(album) }
//                } label: { Label("Play Album", systemImage: "play.fill") }
//                 .buttonStyle(.borderedProminent)
//                 .padding(.top, 5)
//                 
//                 AddToLibraryButton(item: album)
//                 .padding(.top, 5)
//
//
//            }.padding(.vertical)
//
//            // Track List
////            Section("Tracks (\(musicManager.albumTracks.count))") {
//                if musicManager.albumTracks.isEmpty {
//                     if musicManager.fetchedAlbum?.id == album.id {
//                         Text("No tracks found for this album.")
//                              .foregroundColor(.secondary)
//                    } else {
//                        ProgressView("Loading Tracks...")
//                    }
//                } else {
//                    ForEach(musicManager.albumTracks) { track in
//                         HStack {
//                              // Simplified track row for detail view
//                              VStack(alignment: .leading) {
//                                   Text("\(track.trackNumber ?? 0). \(track.title)")
//                                   Text(track.artistName)
//                                       .font(.caption)
//                                       .foregroundColor(.secondary)
//                              }
//                              Spacer()
////                             if let song = Track.song {
////                                   // Can only play songs/videos directly from Track enum
////                                   AddToLibraryButton(item: song)
////                                   PlayButtonItem(item: song)
////                              } else if let video = track.musicVideo {
////                                   PlayButtonItem(item: video)
////                                    // Add To Library for video if needed
////                              }
//                         }
//                    }
////                }
//            }
//
//            // Other Album Details (Optional)
//            Section("Details") {
//                 if let date = album.releaseDate {
//                      Text("Released: \(date, style: .date)")
//                 }
////                 if let count = album.trackCount {
////                      Text("Track Count: \(count)")
////                 }
//                 if album.isCompilation ?? false { Text("Compilation Album") }
//                 if album.isSingle ?? false { Text("Single") }
//                 if album.isComplete == false { Text("Incomplete Album Data") }
//                 if album.isAppleDigitalMaster ?? false { Label("Apple Digital Master", systemImage: "a.square.fill") }
//                 if let rating = album.contentRating { Text("Rating: \(rating == .explicit ? "Explicit" : "Clean")") }
//                 if let copyright = album.copyright { Text(copyright).font(.caption) }
//                 if let notes = album.editorialNotes?.standard { Text("Notes: \(notes)").font(.caption) }
//            }
//        }
//        .navigationTitle(album.title)
//        .task {
//            // Fetch tracks when the detail view appears
//            // Only fetch if the current fetchedAlbum isn't this one or if tracks are empty
//            if musicManager.fetchedAlbum?.id != album.id || musicManager.albumTracks.isEmpty {
//                 await musicManager.fetchAlbumDetails(album: album)
//            }
//        }
//        .onDisappear {
//             // Optional: Clear fetched details when view disappears to save memory
//            // Be careful if you want to keep the data cached
//            // musicManager.fetchedAlbum = nil
//            // musicManager.albumTracks = []
//        }
//    }
//}
//
//
//struct TopSearchResultRow: View {
//    let result: MusicCatalogSearchResponse.TopResult
//     @EnvironmentObject var musicManager: MusicManager
//
//    var body: some View {
//         HStack {
//             // Use generic MusicListItem structure
//             MusicListItem(item: result, artwork: result.artwork, title: result.title, subtitle: getSubtitle(for: result))
//             Spacer()
//             // Add play button if the item can be played
////              if let playableItem = getPlayableItem(from: result) {
////                  PlayButtonItem(item: playableItem)
////             }
//             // Potentially add AddToLibraryButton too, checking the inner type
//         }
//    }
//
//    func getSubtitle(for result: MusicCatalogSearchResponse.TopResult) -> String? {
//         switch result {
//         case .album(let album): return album.artistName
//         case .artist: return "Artist" // Artist name is in title
//         case .curator(let curator): return curator.kind == .editorial ? "Editorial Curator" : "Curator"
//         case .musicVideo(let video): return video.artistName
//         case .playlist(let playlist): return playlist.curatorName ?? "Playlist"
//         case .radioShow(let show): return show.hostName ?? "Radio Show"
//         case .recordLabel: return "Record Label" // Label name is in title
//         case .song(let song): return song.artistName
//         case .station: return "Station" // Station name is in title
//         @unknown default: return nil
//         }
//    }
//    
//    // Helper to extract a PlayableMusicItem if the TopResult case conforms
//    func getPlayableItem(from result: MusicCatalogSearchResponse.TopResult) -> (any PlayableMusicItem)? {
//        switch result {
//        case .album(let item): return item
//        case .artist: return nil // Artists themselves aren't directly playable via PlayableMusicItem
//        case .curator: return nil
//        case .musicVideo(let item): return nil
//        case .playlist(let item): return item
//        case .radioShow: return nil
//        case .recordLabel: return nil
//        case .song(let item): return item
//        case .station(let item): return item
//        @unknown default: return nil
//        }
//    }
//}
//
//struct RecentlyPlayedRow: View {
//     let item: RecentlyPlayedMusicItem
//     @EnvironmentObject var musicManager: MusicManager
//
//     var body: some View {
//          HStack {
//              MusicListItem(item: item, artwork: item.artwork, title: item.title, subtitle: item.subtitle)
//              Spacer()
////               if let playableItem = getPlayableItem(from: item) {
////                   PlayButtonItem(item: playableItem)
////               }
//          }
//     }
//
//    // Helper to extract PlayableMusicItem
//    func getPlayableItem(from recentItem: RecentlyPlayedMusicItem) -> (any PlayableMusicItem)? {
//        switch recentItem {
//        case .album(let album): return album
//        case .playlist(let playlist): return playlist
//        case .station(let station): return station
//         @unknown default: return nil
//        }
//    }
//}
//
//struct RecommendationItemRow: View {
//     let item: MusicPersonalRecommendation.Item
//     @EnvironmentObject var musicManager: MusicManager
//
//     var body: some View {
//          HStack {
//              MusicListItem(item: item, artwork: item.artwork, title: item.title, subtitle: item.subtitle)
//              Spacer()
////              if let playableItem = getPlayableItem(from: item) {
////                  PlayButtonItem(item: playableItem)
////              }
//          }
//     }
//
//    // Helper
//    func getPlayableItem(from recItem: MusicPersonalRecommendation.Item) -> (any PlayableMusicItem)? {
//         switch recItem {
//         case .album(let album): return album
//         case .playlist(let playlist): return playlist
//         case .station(let station): return station
//         @unknown default: return nil
//         }
//     }
//}
//
//// MARK: - Helper Extensions and Utilities
//
//extension MusicAuthorization.Status: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .notDetermined: return "Not Determined"
//        case .denied: return "Denied"
//        case .restricted: return "Restricted"
//        case .authorized: return "Authorized"
//        @unknown default: return "Unknown"
//        }
//    }
//}
//
//extension MusicPlayer.PlaybackStatus: CustomStringConvertible {
//     public var description: String {
//         switch self {
//         case .stopped: return "Stopped"
//         case .playing: return "Playing"
//         case .paused: return "Paused"
//         case .interrupted: return "Interrupted"
//         case .seekingForward: return "Seeking Fwd"
//         case .seekingBackward: return "Seeking Bwd"
//         @unknown default: return "Unknown"
//         }
//     }
//}
//
//// Preview Provider
//struct AppleMusicKitFrameworkCoreConceptsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppleMusicKitFrameworkCoreConceptsView()
//            // Add mock data to the musicManager for previewing if needed
//            .environmentObject(MusicManager()) // Provide a basic manager for preview
//    }
//}
////
////// Main App Structure
////@main
////struct MusicKitDemoApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
