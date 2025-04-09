//
//  FetchAppleMusicAlbumView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import MusicKit // Import the framework

// ----- 1. Data Structures for API Response (Example: Catalog Search) -----
// Define Codable structs matching the Apple Music API response structure.
// This will vary based on the specific endpoint you call.
// This example is for a catalog search response.

struct MusicCatalogSearchResponse: Codable {
    let results: SearchResults? // Results might be optional if the search yields nothing
}

struct SearchResults: Codable {
    let songs: MusicItemCollection<Song>?
    let albums: MusicItemCollection<Album>?
    let artists: MusicItemCollection<Artist>?
    // Add other types like playlists, stations as needed
}

// Generic structure to hold items and provide Identifiable conformance for SwiftUI Lists
struct IdentifiableMusicItem: Identifiable {
    let id: MusicItemID
    let underlyingItem: MusicItem // Store the original item (Song, Album, Artist, etc.)
    let displayTitle: String
    let displaySubtitle: String
    let artwork: Artwork?
}

// ----- 2. Main ContentView -----

struct FetchAppleMusicAlbumView: View {

    // State variables to manage UI and data
    @State private var authorizationStatus: MusicAuthorization.Status = .notDetermined
    @State private var isLoading: Bool = false
    @State private var musicItems: [IdentifiableMusicItem] = []
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Display content based on authorization status
                switch authorizationStatus {
                case .notDetermined:
                    // Initial state or if user hasn't been asked yet
                    Text("Music access not determined.")
                    Button("Request Music Access") {
                        Task {
                            await requestMusicAuthorization()
                        }
                    }
                    .padding()

                case .denied:
                    // User explicitly denied access
                    Text("Music Access Denied")
                        .foregroundColor(.red)
                    Text("Please enable access in Settings > Privacy > Media & Apple Music.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                case .restricted:
                    // Access is restricted (e.g., parental controls)
                    Text("Music Access Restricted")
                        .foregroundColor(.orange)
                    Text("Access to Apple Music is restricted on this device.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                case .authorized:
                    // User granted access - show music content or loading/error state
                    authorizedView

                @unknown default:
                    Text("Unknown authorization status.")
                }
            }
            .navigationTitle("Apple Music Demo")
            .onAppear {
                // Check status when the view appears
                checkMusicAuthorization()
            }
        }
    }

    // ----- 3. View for Authorized State -----
    @ViewBuilder
    private var authorizedView: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching Music...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                Button("Retry") {
                    Task {
                         await fetchMusicCatalogSearch() // Retry fetching
                    }
                }
            } else if musicItems.isEmpty {
                 Text("No music items found. Tap fetch to search.")
                 Button("Fetch Music") {
                     Task {
                          await fetchMusicCatalogSearch()
                     }
                 }
                 .padding(.top)
            } else {
                // Display fetched music items in a list
                List(musicItems) { item in
                    HStack {
                        if let artwork = item.artwork {
                            ArtworkImage(artwork, width: 50, height: 50)
                                .cornerRadius(4)
                        } else {
                            Rectangle() // Placeholder
                                .fill(.secondary.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                                .overlay(Image(systemName: "music.note").foregroundColor(.secondary))
                        }
                        VStack(alignment: .leading) {
                            Text(item.displayTitle).font(.headline)
                            Text(item.displaySubtitle).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }


    // ----- 4. Permission Handling Logic -----

    /// Checks the current authorization status without prompting the user.
    private func checkMusicAuthorization() {
        authorizationStatus = MusicAuthorization.currentStatus
        // If already authorized when view appears, fetch music immediately
        if authorizationStatus == .authorized {
            Task {
                await fetchMusicCatalogSearch()
            }
        }
    }

    /// Requests authorization from the user. Handles all possible outcomes.
    private func requestMusicAuthorization() async {
        let status = await MusicAuthorization.request()
        // Update the state variable on the main thread
        await MainActor.run {
             self.authorizationStatus = status
        }

        // If authorization was successful, fetch music
        if status == .authorized {
             await fetchMusicCatalogSearch()
        }
    }


    // ----- 5. API Data Fetching Logic -----

    /// Fetches data from the Apple Music API (Catalog Search Example).
    private func fetchMusicCatalogSearch() async {
        guard authorizationStatus == .authorized else {
            await MainActor.run {
                errorMessage = "Not authorized to fetch music."
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil // Clear previous errors
            musicItems = [] // Clear previous results
        }

        do {
            // Example: Search the catalog for "rock" songs and albums
            var request = MusicCatalogSearchRequest(term: "rock", types: [Song.self, Album.self, Artist.self])
            request.limit = 25 // Limit the number of results

            let response = try await request.response()

            // Process and flatten the results into our identifiable structure
             var items: [IdentifiableMusicItem] = []

            if let songs = response.songs {
                items.append(contentsOf: songs.map {
                    IdentifiableMusicItem(
                        id: $0.id,
                        underlyingItem: $0,
                        displayTitle: $0.title,
                        displaySubtitle: $0.artistName,
                       artwork: $0.artwork
                    )
                 })
             }
            if let albums = response.albums {
                 items.append(contentsOf: albums.map {
                    IdentifiableMusicItem(
                        id: $0.id,
                        underlyingItem: $0,
                        displayTitle: $0.title,
                        displaySubtitle: $0.artistName,
                        artwork: $0.artwork
                     )
                 })
             }
            if let artists = response.artists {
                items.append(contentsOf: artists.map {
                    IdentifiableMusicItem(
                         id: $0.id,
                         underlyingItem: $0,
                         displayTitle: $0.name,
                         displaySubtitle: "Artist", // Artists don't have an 'artistName'
                         artwork: nil // Artists often don't have standard artwork in search results
                    )
                 })
             }

            await MainActor.run {
                self.musicItems = items
                self.isLoading = false
            }

        } catch {
             print("Music catalog search error: \(error)")
            await MainActor.run {
                 if let musicError = error as? MusicDataRequest.Error {
                     // More specific MusicKit errors
                     self.errorMessage = "MusicKit Error: \(musicError.localizedDescription). Code: \(musicError.description)"
                 } else {
                     self.errorMessage = "Failed to fetch music: \(error.localizedDescription)"
                 }
                self.isLoading = false
            }
        }
    }
}
//
//// ----- App Entry Point -----
//@main
//struct MusicKitDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            FetchAppleMusicAlbumView()
//        }
//    }
//}
