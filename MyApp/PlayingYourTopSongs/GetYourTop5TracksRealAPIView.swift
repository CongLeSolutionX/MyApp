////
////  GetYourTop5TracksRealAPIView.swift
////  MyApp
////
////  Created by Cong Le on 3/25/25.
////
//
//import SwiftUI
//
//// --- Constants and Configuration ---
//// WARNING: Hardcoding tokens is insecure and bad practice for production apps.
//// Obtain a token via Spotify's authorization flows for a real application.
//// See: https://developer.spotify.com/documentation/web-api/concepts/authorization
////let spotifyApiToken = "YOUR_SPOTIFY_API_TOKEN" // <--- REPLACE WITH YOUR ACTUAL TOKEN
//
//// --- Data Models (Matching Spotify API Response) ---
//
//// Represents the overall structure of the top tracks endpoint response
//struct GetYourTop5Tracks_SpotifyTopTracksResponse: Decodable {
//    let items: [GetYourTop5Tracks_SpotifyTrack]
//}
//
//// Represents a track object from the Spotify API
//struct GetYourTop5Tracks_SpotifyTrack: Decodable, Identifiable {
//    let id: String // Spotify's unique ID for the track
//    let name: String
//    let artists: [GetYourTop5Tracks_SpotifyArtist]
//    // Add other properties if needed, e.g., album, duration_ms, external_urls
//}
//
//// Represents an artist object from the Spotify API
//struct GetYourTop5Tracks_SpotifyArtist: Decodable, Identifiable {
//    let id: String // Spotify's unique ID for the artist
//    let name: String
//    // Add other properties if needed, e.g., external_urls
//}
//
//// --- UI Data Models (Simplified for the View) ---
//// These remain the same as before, providing a layer between API data and UI display
//struct GetYourTop5Tracks_Artist: Identifiable, Hashable {
//    let id = UUID() // Local unique ID for SwiftUI lists
//    let name: String
//}
//
//struct GetYourTop5Tracks_Track: Identifiable, Hashable {
//    let id = UUID() // Local unique ID for SwiftUI lists
//    let name: String
//    let artists: [GetYourTop5Tracks_Artist]
//
//    var artistNames: String {
//        artists.map { $0.name }.joined(separator: ", ")
//    }
//}
//
//// --- API Service ---
//enum GetYourTop5Tracks_ApiError: Error {
//    case invalidURL
//    case requestFailed(Error)
//    case invalidResponse
//    case decodingError(Error)
//    case httpError(statusCode: Int)
//}
//
//class GetYourTop5Tracks_SpotifyService {
//    private let apiBaseUrl = "https://api.spotify.com/v1"
//
//    // Fetches the user's top tracks from the Spotify API
//    func fetchTopTracks(token: String) async throws -> [GetYourTop5Tracks_Track] {
//        let endpoint = "/me/top/tracks?time_range=long_term&limit=5"
//        guard let url = URL(string: apiBaseUrl + endpoint) else {
//            throw GetYourTop5Tracks_ApiError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        // Add the crucial Authorization header
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        let data: Data
//        let response: URLResponse
//
//        do {
//            // Perform the async network request
//            (data, response) = try await URLSession.shared.data(for: request)
//        } catch {
//            throw GetYourTop5Tracks_ApiError.requestFailed(error)
//        }
//
//        // Check if the response is a valid HTTP response and the status code is OK
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw GetYourTop5Tracks_ApiError.invalidResponse
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//             // You could try decoding error details from `data` here if Spotify provides them
//            print("HTTP Error: \(httpResponse.statusCode)")
//            print("Response Data: \(String(data: data, encoding: .utf8) ?? "Undecodable data")")
//            throw GetYourTop5Tracks_ApiError.httpError(statusCode: httpResponse.statusCode)
//        }
//
//
//        do {
//            // Decode the JSON response into our Spotify-specific models
//            let decoder = JSONDecoder()
//            let spotifyResponse = try decoder.decode(GetYourTop5Tracks_SpotifyTopTracksResponse.self, from: data)
//
//            // Map the Spotify API models to our simpler UI models
//            let uiTracks = spotifyResponse.items.map { spotifyTrack -> GetYourTop5Tracks_Track in
//                let uiArtists = spotifyTrack.artists.map { GetYourTop5Tracks_Artist(name: $0.name) }
//                return GetYourTop5Tracks_Track(name: spotifyTrack.name, artists: uiArtists)
//            }
//            return uiTracks
//        } catch {
//            print("Decoding failed: \(error)")
//            if let decodingError = error as? DecodingError {
//                 // Print more detailed decoding errors
//                 print("Decoding Error Details: \(decodingError)")
//             }
//            throw GetYourTop5Tracks_ApiError.decodingError(error)
//        }
//    }
//}
//
//// --- SwiftUI View ---
//struct GetYourTop5TracksRealAPIView: View {
//    @State private var tracks: [GetYourTop5Tracks_Track] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String? = nil // To display errors in the UI
//
//    private let spotifyService = GetYourTop5Tracks_SpotifyService()
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section(header: Text("Your Top 5 Tracks (Long Term)")) {
//                    if isLoading {
//                        ProgressView("Loading tracks...") // Show loading indicator
//                            .frame(maxWidth: .infinity, alignment: .center)
//                    } else if let errorMsg = errorMessage {
//                        Text("Error: \(errorMsg)") // Show error message
//                            .foregroundColor(.red)
//                    } else if tracks.isEmpty {
//                        Text("No tracks found or unable to load.")
//                            .foregroundColor(.secondary)
//                    } else {
//                        ForEach(tracks) { track in
//                            GetYourTop5Tracks_TrackRow(track: track)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Top Tracks")
//            .task { // Use .task for async operations tied to the view's lifecycle
//                await loadTopTracks()
//            }
//            .refreshable { // Allow pull-to-refresh
//                 await loadTopTracks()
//            }
//        }
//    }
//
//    // Function to load data from the API
//    private func loadTopTracks() async {
//        // Basic check for token placeholder
//        guard spotifyApiToken != "YOUR_SPOTIFY_API_TOKEN", !spotifyApiToken.isEmpty else {
//            errorMessage = "Spotify API Token is not set. Please replace 'YOUR_SPOTIFY_API_TOKEN' in the code."
//            isLoading = false
//            tracks = [] // Clear existing tracks if token is invalid
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil // Clear previous errors
//
//        do {
//            let fetchedTracks = try await spotifyService.fetchTopTracks(token: spotifyApiToken)
//            // Update the state on the main thread
//             await MainActor.run {
//                 self.tracks = fetchedTracks
//             }
//        } catch let apiError as GetYourTop5Tracks_ApiError {
//             // Handle specific API errors
//             await MainActor.run {
//                switch apiError {
//                case .invalidURL:
//                    self.errorMessage = "Internal error: Invalid API URL."
//                case .requestFailed(let error):
//                    self.errorMessage = "Network request failed: \(error.localizedDescription)"
//                case .invalidResponse:
//                    self.errorMessage = "Received an invalid response from the server."
//                case .decodingError(let error):
//                     self.errorMessage = "Failed to decode server response. Check console for details."
//                    print("Decoding Error: \(error)")
//                 case .httpError(let statusCode):
//                     self.errorMessage = "API request failed with status code \(statusCode). This could be due to an invalid or expired token."
//                }
//                 self.tracks = [] // Clear tracks on error
//             }
//         } catch {
//             // Handle unexpected errors
//             await MainActor.run {
//                 self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
//                 self.tracks = [] // Clear tracks on error
//            }
//        }
//
//        // Ensure isLoading is set to false after completion, regardless of success or failure
//         await MainActor.run {
//             isLoading = false
//         }
//    }
//}
//
//// --- Row View for the List ---
//// (Remains unchanged from the previous version)
//struct GetYourTop5Tracks_TrackRow: View {
//    let track: GetYourTop5Tracks_Track
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(track.name)
//                .font(.headline)
//            Text(track.artistNames)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//// --- App Entry Point ---
//// @main
//// struct TopTracksApp: App {
////     var body: some Scene {
////         WindowGroup {
////             ContentView()
////         }
////     }
//// }
//
//// --- Preview Provider ---
//struct GetYourTop5TracksRealAPIView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview with sample data as API won't work in previews without complex setup
//        GetYourTop5TracksRealAPIView(tracks: [
//            GetYourTop5Tracks_Track(name: "Preview Song 1", artists: [GetYourTop5Tracks_Artist(name: "Preview Artist A")]),
//            GetYourTop5Tracks_Track(name: "Another Track (Preview)", artists: [GetYourTop5Tracks_Artist(name: "Artist B"), GetYourTop5Tracks_Artist(name: "Artist C")])
//        ])
//         .preferredColorScheme(.dark) // Example: Preview in dark mode
//
//        // Preview showing loading state
//        GetYourTop5TracksRealAPIView(isLoading: true)
//            .previewDisplayName("Loading State")
//
//         // Preview showing error state
//        GetYourTop5TracksRealAPIView(errorMessage: "Network connection failed.")
//             .previewDisplayName("Error State")
//    }
//}
//
//// Helper extension for preview initialization
//extension GetYourTop5TracksRealAPIView {
//     init(tracks: [GetYourTop5Tracks_Track]) {
//         _tracks = State(initialValue: tracks)
//         _isLoading = State(initialValue: false)
//         _errorMessage = State(initialValue: nil)
//     }
//
//    init(isLoading: Bool) {
//         _tracks = State(initialValue: [])
//         _isLoading = State(initialValue: isLoading)
//         _errorMessage = State(initialValue: nil)
//     }
//
//    init(errorMessage: String) {
//         _tracks = State(initialValue: [])
//         _isLoading = State(initialValue: false)
//         _errorMessage = State(initialValue: errorMessage)
//     }
//}
