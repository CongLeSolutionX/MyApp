//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import MusicKit

// --- 1. Corrected IdentifiableMusicItem Struct ---
// Make sure the 'artwork' property explicitly uses MusicKit.Artwork

struct IdentifiableMusicItem: Identifiable {
    let id: MusicItemID
    let underlyingItem: MusicItem
    let displayTitle: String
    let displaySubtitle: String
    let artwork: MusicKit.Artwork? // Specify MusicKit.Artwork here
}

// You'll also need these structs defined correctly:
struct MusicCatalogSearchResponse: Codable {
    let results: SearchResults?
}

struct SearchResults: Codable {
    let songs: MusicItemCollection<Song>?
    let albums: MusicItemCollection<Album>?
    let artists: MusicItemCollection<Artist>?
    // Add other types as needed
}


// Assume FetchAppleMusicAlbumView_V2 is your ContentView or similar SwiftUI View
struct FetchAppleMusicAlbumView_V2: View { // Renamed to reflect the file name context
    // ... (Your existing @State variables: authorizationStatus, isLoading, musicItems, errorMessage)

    @State private var authorizationStatus: MusicAuthorization.Status = .notDetermined // Example state
    @State private var isLoading: Bool = false // Example state
    @State private var musicItems: [IdentifiableMusicItem] = [] // Example state
    @State private var errorMessage: String? = nil // Example state


    var body: some View {
        // ... Your view body using the state variables ...
        List(musicItems) { item in // Example usage
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
        .onAppear {
            // Trigger fetch or authorization check
             Task {
                 await checkAndFetch() // Example function
             }
        }
        .navigationTitle("Music Search") // Example
    }

     // Example helper function
      func checkAndFetch() async {
          // ... check authorization status ...
         if MusicAuthorization.currentStatus == .authorized {
             await fetchMusicCatalogSearch()
         } else {
              // Handle requesting authorization if needed
             let status = await MusicAuthorization.request()
             if status == .authorized {
                 await fetchMusicCatalogSearch()
             }
         }
     }

    // --- 2. Corrected fetchMusicCatalogSearch Function ---
    private func fetchMusicCatalogSearch() async {
        // Ensure you are authorized before proceeding (add this check if missing)
        guard MusicAuthorization.currentStatus == .authorized else {
            await MainActor.run {
                errorMessage = "Not authorized to access Apple Music."
                isLoading = false
            }
            return
        }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
            musicItems = [] // Clear previous results
        }

        do {
            // Example search request
            var request = MusicCatalogSearchRequest(term: "rock", types: [Song.self, Album.self, Artist.self])
            request.limit = 25

            let response = try await request.response()

            // Process and flatten the results into our identifiable structure
            var items: [IdentifiableMusicItem] = []

            // --- Correction: Unwrap response.results first ---
//            if let results = response.results {
//
//                // --- Correction: Now use optional binding on results.songs ---
//                if let songs = results.songs {
//                    items.append(contentsOf: songs.map { songItem in // Use a more descriptive variable name
//                        IdentifiableMusicItem(
//                            id: songItem.id,
//                            underlyingItem: songItem,
//                            displayTitle: songItem.title,
//                            displaySubtitle: songItem.artistName,
//                            artwork: songItem.artwork // This now matches IdentifiableMusicItem's artwork type
//                        )
//                    })
//                }
//
//                // --- Correction: Use optional binding on results.albums ---
//                if let albums = results.albums {
//                    items.append(contentsOf: albums.map { albumItem in
//                        IdentifiableMusicItem(
//                            id: albumItem.id,
//                            underlyingItem: albumItem,
//                            displayTitle: albumItem.title,
//                            displaySubtitle: albumItem.artistName,
//                            artwork: albumItem.artwork // Matches
//                        )
//                    })
//                }
//
//                // --- Correction: Use optional binding on results.artists ---
//                if let artists = results.artists {
//                    items.append(contentsOf: artists.map { artistItem in
//                        IdentifiableMusicItem(
//                            id: artistItem.id,
//                            underlyingItem: artistItem,
//                            displayTitle: artistItem.name,
//                            displaySubtitle: "Artist", // Artists don't have an 'artistName'
//                            artwork: nil // Artists often don't have standard artwork in search results
//                        )
//                    })
//                }
//            } // End of 'if let results'

            await MainActor.run {
                self.musicItems = items
                self.isLoading = false
            }

        } catch {
            print("Music catalog search error: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to fetch music: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
