////
////  GetTop5TracksView.swift
////  MyApp
////
////  Created by Cong Le on 3/25/25.
////
//
//import SwiftUI
//
//// --- Data Models ---
//// Represents an artist (simplified from Spotify API)
//struct Artist: Identifiable, Hashable {
//    let id = UUID() // Local unique ID for SwiftUI lists
//    let name: String
//}
//
//// Represents a track (simplified from Spotify API)
//struct Track: Identifiable, Hashable {
//    let id = UUID() // Local unique ID for SwiftUI lists
//    let name: String
//    let artists: [Artist]
//
//    // Helper computed property to get a display string for artists
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// --- Local Data Store ---
//// Sample data simulating the response from the Spotify API fetch
//let sampleTopTracks: [Track] = [
//    Track(name: "Blinding Lights", artists: [Artist(name: "The Weeknd")]),
//    Track(name: "drivers license", artists: [Artist(name: "Olivia Rodrigo")]),
//    Track(name: "Levitating", artists: [Artist(name: "Dua Lipa"), Artist(name: "DaBaby")]),
//    Track(name: "Stay", artists: [Artist(name: "The Kid LAROI"), Artist(name: "Justin Bieber")]),
//    Track(name: "good 4 u", artists: [Artist(name: "Olivia Rodrigo")])
//]
//
//// --- SwiftUI View ---
//struct GetTop5TracksView: View {
//    // State variable to hold the tracks (using local sample data)
//    @State private var topTracks: [Track] = sampleTopTracks
//
//    var body: some View {
//        NavigationView {
//            List {
//                // Section header (optional, for better structure)
//                Section(header: Text("Your Top 5 Tracks (Long Term)")) {
//                    // Check if the tracks array is empty
//                    if topTracks.isEmpty {
//                        Text("No tracks available.")
//                            .foregroundColor(.secondary)
//                    } else {
//                        // Iterate over the tracks and display each one
//                        ForEach(topTracks) { track in
//                            GetTop5TracksView_TrackRow(track: track)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Top Tracks")
//             .refreshable {  // Add refresh functionality later if needed to replace local data
//                 // In a real app, you would call your API fetch function here
//                 print("Refresh action triggered (currently uses local data)")
//             }
//        }
//    }
//}
//
//// --- Row View for the List ---
//// Represents a single row in the track list
//struct GetTop5TracksView_TrackRow: View {
//    let track: Track
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(track.name)
//                .font(.headline) // Make track name more prominent
//            Text(track.artistNames)
//                .font(.subheadline) // Smaller font for artist names
//                .foregroundColor(.secondary) // Use a secondary color
//        }
//        .padding(.vertical, 4) // Add a little vertical padding within the row
//    }
//}
//
//
//// Allows you to see the UI in Xcode's preview canvas
//struct GetTop5TracksView_Previews: PreviewProvider {
//    static var previews: some View {
//        GetTop5TracksView()
//    }
//}
