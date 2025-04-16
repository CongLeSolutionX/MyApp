//
//  A.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import Foundation // Needed for UUID

// --- Artist Detail specific models ---

struct ArtistDetailData {
    let artistInfo: ArtistInfo
    let topTracks: [TrackInfo]
    let albums: [AlbumInfo]
    let relatedArtists: [ArtistInfo] // Re-use ArtistInfo for related artists
}

struct ArtistInfo: Identifiable {
    let id = UUID()
    let name: String
    let genre: String? // Optional genre
    // Use a larger image URL for banner/profile
    let imageUrl: String?
    let bio: String? // Optional biography
}

struct TrackInfo: Identifiable {
    let id = UUID()
    let name: String
    let albumName: String // Context: which album is this from?
    let imageUrl: String? // Small thumbnail URL
    let playCount: Int? // Mock popularity indicator
    // Add a mock URL for potential sharing or playback simulation later
    var mockTrackUrl: String { "https://open.spotify.com/track/artist-track-\(id.uuidString.prefix(8))" }
    let audioURL: String? // <<<< ADDED: URL for actual playback
}

struct AlbumInfo: Identifiable {
    let id = UUID()
    let name: String
    let releaseYear: String
    let imageUrl: String?
    let type: String // e.g., "album", "single"
    // Add a mock URL for potential navigation later
    var mockAlbumUrl: String { "https://open.spotify.com/album/artist-album-\(id.uuidString.prefix(8))" }
}

// --- Mock Data Factory ---

func createMockArtistDetailData(for artistName: String) -> ArtistDetailData {
    // Simulate fetching data based on artist name
    let placeholderImage = "https://via.placeholder.com/600x300/cccccc/888888?text=\(artistName.replacingOccurrences(of: " ", with: "+"))"
    let placeholderThumb = "https://via.placeholder.com/100x100/cccccc/888888?text=Track"
    let placeholderAlbum = "https://via.placeholder.com/150x150/cccccc/888888?text=Album"
    let placeholderArtist = "https://via.placeholder.com/100x100/cccccc/888888?text=Artist"
    
    // Example Data (customize more if needed)
    let artistData = ArtistDetailData(
        artistInfo: ArtistInfo(
            name: artistName,
            genre: artistName == "Pitbull" ? "Pop / Latin Hip Hop" : "Various",
            imageUrl: artistName == "Pitbull" ? "https://i.scdn.co/image/ab6761610000e5eb6058c2f84a4f6dff1dee78a8" : placeholderImage, // Larger Pitbull image
            bio: artistName == "Pitbull" ? "Armando Christian Pérez, known professionally as Pitbull, is an American rapper, singer, songwriter, and record producer. Pérez began his career in the early 2000s, recording reggaeton, Latin hip hop, and crunk music under a multitude of labels..." : "Information about this artist."
        ),
        topTracks: [
            TrackInfo(name: "Give Me Everything", albumName: "Planet Pit", imageUrl: placeholderThumb, playCount: 1_234_567, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
            TrackInfo(name: "Timber (feat. Ke$ha)", albumName: "Globalization", imageUrl: placeholderThumb, playCount: 1_111_222, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"),
            TrackInfo(name: "Hotel Room Service", albumName: "Rebelution", imageUrl: placeholderThumb, playCount: 987_654, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"),
            TrackInfo(name: "Feel This Moment (feat. Christina Aguilera)", albumName: "Global Warming", imageUrl: placeholderThumb, playCount: 876_543, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"), // From previous album
            TrackInfo(name: "Time of Our Lives", albumName: "Globalization", imageUrl: placeholderThumb, playCount: 765_432, audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3")
        ],
        albums: [
            AlbumInfo(name: "Global Warming", releaseYear: "2012", imageUrl: "https://i.scdn.co/image/ab67616d0000b2732c5b24ecfa39523a75c993c4", type: "album"), // From previous screen
            AlbumInfo(name: "Globalization", releaseYear: "2014", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Planet Pit", releaseYear: "2011", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Rebelution", releaseYear: "2009", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Climate Change", releaseYear: "2017", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Dale", releaseYear: "2015", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Armando", releaseYear: "2010", imageUrl: placeholderAlbum, type: "album"),
            AlbumInfo(name: "Don't Stop the Party (Single)", releaseYear: "2012", imageUrl: placeholderThumb, type: "single")
        ],
        relatedArtists: [
            ArtistInfo(name: "Jennifer Lopez", genre: "Pop / R&B", imageUrl: placeholderArtist, bio: nil),
            ArtistInfo(name: "Flo Rida", genre: "Hip Hop / Pop", imageUrl: placeholderArtist, bio: nil),
            ArtistInfo(name: "Enrique Iglesias", genre: "Latin Pop", imageUrl: placeholderArtist, bio: nil),
            ArtistInfo(name: "Ne-Yo", genre: "R&B / Pop", imageUrl: placeholderArtist, bio: nil),
            ArtistInfo(name: "Daddy Yankee", genre: "Reggaeton", imageUrl: placeholderArtist, bio: nil)
        ]
    )
    return artistData
}

// MARK: -

import SwiftUI

struct ArtistDetailView: View {
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    let artistName: String // Passed in from previous screen
    @State private var artistData: ArtistDetailData? = nil // Hold fetched/mocked data
    @State private var isFollowing: Bool = false // Mock follow state
    @State private var showingBio: Bool = false // Toggle for About section
    
    // Simulate loading / fetching data
    private func loadArtistData() {
        // In a real app, this would be an async network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate delay
            self.artistData = createMockArtistDetailData(for: artistName)
            // Maybe load follow status from user defaults/backend
            self.isFollowing = Bool.random() // Random initial follow state
        }
    }
    
    var body: some View {
        ScrollView {
            if let data = artistData {
                VStack(alignment: .leading, spacing: 25) { // Increased spacing between sections
                    ArtistHeaderView(artistInfo: data.artistInfo, isFollowing: $isFollowing)
                    
                    TopTracksSection(tracks: Array(data.topTracks.prefix(5))) // Show top 5
                    
                    AlbumsSection(albums: data.albums)
                    
                    RelatedArtistsSection(artists: data.relatedArtists)
                    
                    if let bio = data.artistInfo.bio, !bio.isEmpty {
                        AboutSection(bio: bio, isExpanded: $showingBio, artistInfo: ArtistInfo(name: "CongLe", genre: nil, imageUrl: nil, bio: nil))
                    }
                    
                    Spacer() // Push content up if short
                }
                .padding(.vertical) // Add padding top/bottom of scroll content
            } else {
                // --- Loading State ---
                ProgressView("Loading Artist...")
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.top, 100) // Push down from top
            }
        }
        .navigationTitle(artistName) // Use the name passed in for title immediately
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadArtistData)
        .alert("Action Simulated", isPresented: $showingInteractionAlert) { // Reusable alert
            Button("OK", role: .cancel) { }
        } message: {
            Text(interactionMessage)
        }
    }
    
    // --- State for interaction alerts ---
    @State private var showingInteractionAlert = false
    @State private var interactionMessage = ""
    
    private func simulateInteraction(message: String) {
        interactionMessage = message
        showingInteractionAlert = true
        print(message) // Log to console too
    }
}

// MARK: - Subviews for Artist Detail

struct ArtistHeaderView: View {
    let artistInfo: ArtistInfo
    @Binding var isFollowing: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Banner Image (optional)
            if let imageUrl = artistInfo.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Fill available space
                            .frame(height: 200) // Fixed height for banner
                            .clipped() // Clip overflow
                            .overlay( // Gradient overlay for text readability
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(8) // Optional corner radius
                    case .failure:
                        Rectangle() // Placeholder on failure
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 150)
                            .overlay(Text("Image unavailable").foregroundStyle(.secondary))
                            .cornerRadius(8)
                    case .empty:
                        Rectangle() // Placeholder while loading
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 150)
                            .overlay(ProgressView())
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal) // Add horizontal padding to the image frame
            }
            
            // Artist Name and Genre
            VStack {
                Text(artistInfo.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let genre = artistInfo.genre {
                    Text(genre)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Follow Button
            Button {
                isFollowing.toggle()
                // Add haptic feedback
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                // Here you'd call your backend/data layer to update follow status
                print("Follow status for \(artistInfo.name): \(isFollowing)")
            } label: {
                Label(isFollowing ? "Following" : "Follow", systemImage: isFollowing ? "checkmark.circle.fill" : "plus.circle")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(isFollowing ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundStyle(isFollowing ? .primary : .secondary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain) // Use plain style for custom background
            .animation(.easeInOut, value: isFollowing) // Animate button change
        }
    }
}

struct TopTracksSection: View {
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    let tracks: [TrackInfo]
    //@State private var showingTrackAlert = false
    //@State private var selectedTrackName = ""
    
    
    //    var body: some View {
    //            VStack(alignment: .leading) {
    //                Text("Top Tracks")
    //                    // ... title style ...
    //
    //                ForEach(tracks) { track in
    //                     // Determine if this track is playing/selected
    //                     let isPlaying = audioPlayerManager.currentlyPlayingTrackID == track.id && audioPlayerManager.isPlaying
    //                     let isCurrentlySelectedTrack = audioPlayerManager.currentlyPlayingTrackID == track.id
    //
    //                     HStack(spacing: 12) {
    //                         // --- Play/Pause/Number Icon ---
    //                         Group {
    //                              if isCurrentlySelectedTrack {
    //                                  Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    //                                      .foregroundStyle(.blue) // Different highlight color maybe?
    //                                      .frame(width: 20, alignment: .center)
    //                              } else {
    //                                  // Optional: Show rank number if available/meaningul
    //                                  Image(systemName:"music.note") // Default placeholder
    //                                      .foregroundStyle(.secondary)
    //                                      .frame(width: 20, alignment: .center)
    //                              }
    //                         }
    //                         .padding(.trailing, 5)
    //
    //                         AsyncImage(url: URL(string: track.imageUrl ?? "")) { /*...*/ } // Image remains same
    //                         .frame(width: 50, height: 50)
    //                         .clipShape(RoundedRectangle(cornerRadius: 4))
    //
    //                         VStack(alignment: .leading) {
    //                             Text(track.name)
    //                                 .font(.body)
    //                                 .foregroundStyle(isCurrentlySelectedTrack ? .blue : .primary) // Highlight selected
    //                                 .lineLimit(1)
    //                             Text(track.albumName)
    //                                 .font(.caption)
    //                                 .foregroundStyle(.secondary)
    //                                 .lineLimit(1)
    //                         }
    //
    //                         Spacer()
    //
    //                         if let plays = track.playCount { /* Play count */ }
    //                     }
    //                     .padding(.horizontal)
    //                     .padding(.vertical, 5)
    //                     .background(isCurrentlySelectedTrack ? Color.blue.opacity(0.1) : Color.clear) // Highlight
    //                     .contentShape(Rectangle())
    //                     .onTapGesture {
    //                          // Call the manager to toggle playback
    //                          audioPlayerManager.togglePlayPause(for: track.id, urlString: track.audioURL)
    //                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
    //                     }
    //                    Divider().padding(.leading, 85) // Adjust indent based on layout
    //                }
    //            }
    //              // Remove the specific track alert if it's just for playing
    //        }
    //
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Top Tracks")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            // Limited vertical list for top tracks
            ForEach(tracks) { track in
                // Determine if this track is playing/selected
                let isPlaying = audioPlayerManager.currentlyPlayingTrackID == track.id && audioPlayerManager.isPlaying
                let isCurrentlySelectedTrack = audioPlayerManager.currentlyPlayingTrackID == track.id
                
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: track.imageUrl ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    VStack(alignment: .leading) {
                        Text(track.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(track.albumName) // Show album context
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if let plays = track.playCount {
                        Text("\(plays / 1000)K") // Simple play count format
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(isCurrentlySelectedTrack ? Color.blue.opacity(0.1) : Color.clear) // Highlight
                .contentShape(Rectangle())
                .onTapGesture {
                    // Call the manager to toggle playback
                    audioPlayerManager.togglePlayPause(for: track.id, urlString: track.audioURL)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                Divider().padding(.leading, 85) // Adjust indent based on layout
            }
        }
    }
}
//         .alert("Track Tapped", isPresented: $showingTrackAlert) {
//              Button("OK", role: .cancel) { }
//         } message: {
//              Text("Simulated action for track: \(selectedTrackName)")
//         }


struct AlbumsSection: View {
    let albums: [AlbumInfo]
    @State private var showingAlbumAlert = false
    @State private var selectedAlbumName = ""
    
    // Use a grid layout for albums
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2) // 2 columns
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Albums & Singles")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(albums) { album in
                    Button {
                        // Simulate navigating to album detail
                        selectedAlbumName = album.name
                        showingAlbumAlert = true
                        print("Simulating tap on album: \(album.name)")
                    } label: {
                        AlbumGridItem(album: album)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .alert("Album Tapped", isPresented: $showingAlbumAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Simulated action for album: \(selectedAlbumName)")
        }
    }
}

struct AlbumGridItem: View {
    let album: AlbumInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: album.imageUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .overlay(Image(systemName:"music.note.list").font(.largeTitle).opacity(0.5))
            }
            .aspectRatio(1, contentMode: .fit) // Make it square
            .cornerRadius(6)
            
            Text(album.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundStyle(.primary)
            Text("\(album.type.capitalized) • \(album.releaseYear)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct RelatedArtistsSection: View {
    let artists: [ArtistInfo]
    @State private var showingArtistAlert = false
    @State private var selectedArtistName = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Artists")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(artists) { artist in
                        Button {
                            // Simulate navigating to this related artist's detail view
                            selectedArtistName = artist.name
                            showingArtistAlert = true
                            print("Simulating tap on related artist: \(artist.name)")
                        } label: {
                            RelatedArtistBubble(artist: artist)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5) // Padding for shadow visibility if needed
            }
        }
        .alert("Artist Tapped", isPresented: $showingArtistAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Simulated action for artist: \(selectedArtistName)")
        }
    }
}

struct RelatedArtistBubble: View {
    let artist: ArtistInfo
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: artist.imageUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                Rectangle()
                    .fill(Color.secondary.opacity(0.1))
                    .overlay(Image(systemName:"person.fill").font(.title).opacity(0.5))
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 100, height: 100) // Circular bubble size
            .clipShape(Circle())
            .shadow(radius: 3) // Add subtle shadow
            
            Text(artist.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(width: 100) // Limit text width
                .foregroundStyle(.primary)
        }
    }
}

struct AboutSection: View {
    let bio: String
    @Binding var isExpanded: Bool // Allow collapsing/expanding
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("About \(artistInfo.name)") // Use the name here
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    withAnimation { // Animate expand/collapse
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            if isExpanded {
                Text(bio)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .slide)) // Add transition effect
            }
        }
    }
    
    // Need access to artistInfo - assuming it's passed or accessible
    // Simplification: For this example, let's assume `artistInfo` is available
    // In a real app, you might need to pass the name or the full ArtistInfo object
    let artistInfo: ArtistInfo // Placeholder - you need to pass this in
    
    // Initialize with the passed-in object
    init(bio: String, isExpanded: Binding<Bool>, artistInfo: ArtistInfo) {
        self.bio = bio
        self._isExpanded = isExpanded
        self.artistInfo = artistInfo
    }
    
}

// MARK: - Preview Provider

struct ArtistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArtistDetailView(artistName: "Pitbull") // Preview with a known mock artist
        }
        .preferredColorScheme(.dark)
        .environmentObject(AudioPlayerManager()) // Provide for preview
        
        NavigationView {
            ArtistDetailView(artistName: "Some Other Artist") // Preview with generic data
        }
        .preferredColorScheme(.light)
        .environmentObject(AudioPlayerManager()) // Provide for preview
    }
}
