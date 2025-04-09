//
//  V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import MusicKit // Import would be needed for real data

// --- Placeholder Data Structures ---
// Used to simulate the data described in diagrams

struct AlbumPlaceholder: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artistName: String
    var artworkURL: URL? = URL(string: "https://via.placeholder.com/100") // Placeholder image
}

struct TrackPlaceholder: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artistName: String // Tracks can have different artists on compilations
    var duration: TimeInterval? = 180 // Example duration
}

// --- Reusable UI Components ---

/// Displays artwork, handling optionals and providing a placeholder.
struct ArtworkImage: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                     .aspectRatio(contentMode: .fit)
            case .failure(_):
                Image(systemName: "music.note") // Placeholder on error
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.2)
                    .background(.thinMaterial)
            case .empty:
                ProgressView() // Loading indicator
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size, height: size)
        .cornerRadius(size * 0.1) // Consistent corner radius
        .shadow(radius: 3, y: 1)
    }
}

/// Basic structure for a list item with artwork and text.
struct MusicItemCell<Accessory: View>: View {
    let artworkURL: URL?
    let title: String
    let subtitle: String
    let accessoryView: Accessory // Generic view for trailing content

    init(artworkURL: URL?, title: String, subtitle: String, @ViewBuilder accessory: () -> Accessory) {
        self.artworkURL = artworkURL
        self.title = title
        self.subtitle = subtitle
        self.accessoryView = accessory()
    }

    var body: some View {
        HStack {
            ArtworkImage(url: artworkURL, size: 50)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            accessoryView // Display the provided accessory view
        }
        .padding(.vertical, 4)
    }
}

// Extension for optional accessory view
extension MusicItemCell where Accessory == EmptyView {
    init(artworkURL: URL?, title: String, subtitle: String) {
        self.init(artworkURL: artworkURL, title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}


/// Cell specifically for displaying an Album.
struct AlbumCell: View {
    let album: AlbumPlaceholder

    var body: some View {
        MusicItemCell(
            artworkURL: album.artworkURL,
            title: album.title,
            subtitle: album.artistName
        ) {
            // Accessory view (e.g., chevron for navigation)
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

/// Cell specifically for displaying a Track.
struct TrackCell: View {
    let track: TrackPlaceholder

    private var formattedDuration: String? {
        guard let duration = track.duration else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration)
    }

    var body: some View {
         // Tracks often don't show artwork in lists, adjust if designs differ
         HStack {
             VStack(alignment: .leading) {
                Text(track.title)
                    .lineLimit(1)
                Text(track.artistName) // Could be different from album artist
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
             }
             Spacer()
             if let duration = formattedDuration {
                 Text(duration)
                     .font(.caption)
                     .foregroundColor(.secondary)
             }
             // Potentially add play button or other indicator here
             Image(systemName: "play.circle") // Example accessory
                 .foregroundColor(.accentColor)
         }
         .padding(.vertical, 4)
    }
}

/// Custom Button Style for prominent actions like "Play".
struct ProminentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .font(.headline.weight(.semibold))
            .foregroundColor(isEnabled ? (colorScheme == .dark ? .black : .white) : .gray)
            .background(isEnabled ? Color.accentColor : Color.secondary.opacity(0.3))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isEnabled)
    }
}

// --- Main Views ---

struct ContentView: View {
    // State variables based on diagram analysis
    @State private var searchTerm: String = ""
    @State private var albums: [AlbumPlaceholder] = sampleAlbums // Placeholder Data
    @State private var recentAlbums: [AlbumPlaceholder] = sampleAlbums.suffix(3) // Simulating recent
    @State private var isBarcodeScanningViewPresented: Bool = false
    @State private var isDevelopmentSettingsViewPresented: Bool = false
    @State private var detectedBarcode: String? = nil // For simulation

    // Determines if barcode scanning is available (Placeholder)
    @State private var isBarcodeScanningAvailable: Bool = true

    var searchResults: [AlbumPlaceholder] {
        if searchTerm.isEmpty {
            return [] // Show recents or empty state if search is empty
        } else {
            // Simple local filtering for placeholder demo
            return albums.filter {
                $0.title.localizedCaseInsensitiveContains(searchTerm) ||
                $0.artistName.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                // Show search results or recent albums
                if searchTerm.isEmpty {
                    Section("Recently Viewed") {
                         if recentAlbums.isEmpty {
                             Text("No recently viewed albums.")
                                 .foregroundColor(.secondary)
                         } else {
                            ForEach(recentAlbums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumCell(album: album)
                                }
                            }
                         }
                    }
                } else {
                     Section("Search Results") {
                        if searchResults.isEmpty {
                            Text("No results for \"\(searchTerm)\".")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(searchResults) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumCell(album: album)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Music Albums")
            .searchable(text: $searchTerm, prompt: "Search Albums & Artists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Placeholder for potential filter/menu button
                     Button {
                        print("Menu Tapped")
                     } label: {
                        Image(systemName: "line.3.horizontal")
                     }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isBarcodeScanningAvailable {
                        Button {
                            isBarcodeScanningViewPresented = true
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                        }
                    }
                }
            }
            // Sheet for barcode scanning (placeholder content)
            .sheet(isPresented: $isBarcodeScanningViewPresented) {
                // BarcodeScanningView would go here
                VStack {
                    Text("Barcode Scanner Placeholder")
                    if let barcode = detectedBarcode {
                        Text("Detected: \(barcode)")
                    }
                    Button("Simulate Scan (12345)") {
                        detectedBarcode = "12345"
                        // In real app, handle detection: dismiss sheet, load album
                        isBarcodeScanningViewPresented = false
                        // Simulate finding and navigating if needed for testing
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Close") { isBarcodeScanningViewPresented = false }
                        .padding(.top)
                }
                .padding()
            }
             // Sheet for dev settings (placeholder content)
            .sheet(isPresented: $isDevelopmentSettingsViewPresented) {
                // DevelopmentSettingsView would go here
                 VStack {
                     Text("Development Settings")
                         .font(.title)
                    Toggle("Barcode Scanning Available", isOn: $isBarcodeScanningAvailable)
                    Button("Reset Recent Albums") {
                        recentAlbums = [] // Simulate reset
                        print("Recents Reset")
                    }
                    .padding(.top)
                    Button("Close") { isDevelopmentSettingsViewPresented = false }
                        .padding(.top)
                 }
                 .padding()
            }
            // Detect triple tap for dev settings (as per diagrams)
            .onTapGesture(count: 3) {
                 isDevelopmentSettingsViewPresented = true
            }
            // Could add .welcomeSheet() modifier here if implementing WelcomeView logic
        }
        // Apply navigation view style for iPad if needed
        // .navigationViewStyle(.stack)
    }
}

struct AlbumDetailView: View {
    let album: AlbumPlaceholder

    // State reflecting diagram's detail view logic
    @State private var tracks: [TrackPlaceholder] = sampleTracks // Placeholder
    @State private var relatedAlbums: [AlbumPlaceholder] = sampleAlbums // Placeholder
    @State private var isPlaying: Bool = false // Simulate player state
    @State private var isPlaybackQueueSet: Bool = false // Simulate player state
    @State private var musicSubscriptionAvailable: Bool = true // Simulate subscription status
    @State private var isShowingSubscriptionOffer: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // --- Header Section ---
                HStack(alignment: .bottom, spacing: 15) {
                    ArtworkImage(url: album.artworkURL, size: 120)

                    VStack(alignment: .leading) {
                        Text(album.title)
                            .font(.title2.weight(.bold))
                            .lineLimit(2)
                        Text(album.artistName)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                         Spacer() // Push button down
                        playButton // Extracted for clarity
                    }
                     Spacer() // Push content left
                }
                .padding(.horizontal)

                Divider()

                // --- Tracks Section ---
                Section {
                   ForEach(tracks) { track in
                         TrackCell(track: track)
                             .padding(.horizontal)
                             .onTapGesture {
                                 print("Selected track: \(track.title)")
                                 isPlaying = true // Simulate playing track
                                 isPlaybackQueueSet = true
                             }
                             Divider().padding(.leading) // Indented divider
                    }
                } header: {
                     Text("Tracks")
                         .font(.headline)
                         .padding(.horizontal)
                }

                // --- Related Albums Section ---
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(relatedAlbums) { relatedAlbum in
                                NavigationLink(destination: AlbumDetailView(album: relatedAlbum)) {
                                     VStack {
                                        ArtworkImage(url: relatedAlbum.artworkURL, size: 100)
                                        Text(relatedAlbum.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                        Text(relatedAlbum.artistName)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 100) // Ensure consistent width
                                }
                                .buttonStyle(.plain) // Prevents entire cell highlighting weirdly
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom) // Add padding below scroll view
                    }
                } header: {
                     Text("Related Albums")
                         .font(.headline)
                         .padding(.horizontal)
                }

            } // End Main VStack
            .padding(.top)
        }
        .navigationTitle(album.title) // Or keep it short like "Album"
        .navigationBarTitleDisplayMode(.inline)
        // Simulate loading data when view appears
        .task {
            await loadData()
        }
        // Sheet for subscription offer (placeholder)
        .sheet(isPresented: $isShowingSubscriptionOffer) {
            VStack {
                Text("Apple Music Subscription Offer")
                    .font(.title)
                Text("Join Apple Music to listen.")
                    .padding()
                Button("Learn More") {
                    // Open URL or handle subscription flow
                    print("Subscription Learn More tapped")
                    isShowingSubscriptionOffer = false
                }
                .buttonStyle(.borderedProminent)
                Button("Close") { isShowingSubscriptionOffer = false }
                    .padding(.top)
            }
            .padding()
        }
    }

    // Extracted Play/Join Button Logic
    @ViewBuilder
    private var playButton: some View {
        if musicSubscriptionAvailable {
            Button {
                 isPlaying.toggle()
                 isPlaybackQueueSet = true // Assume setting queue on first play
                 print("Play/Pause Tapped. isPlaying: \(isPlaying)")
             } label: {
                 Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
             }
             .buttonStyle(ProminentButtonStyle())
        } else {
             Button("Join") { // Show join if no subscription
                 isShowingSubscriptionOffer = true
                 print("Join Tapped")
             }
             .buttonStyle(ProminentButtonStyle())
        }
    }


    // Simulate loading tracks and related albums
    func loadData() async {
        // Replace with actual MusicKit calls
        print("AlbumDetailView: Simulating data load for \(album.title)")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        // Assume data is fetched and assigned to @State vars here
         tracks = sampleTracks.shuffled() // Simulate loading different tracks
         relatedAlbums = sampleAlbums.shuffled() // Simulate loading different related albums
        print("AlbumDetailView: Data load complete.")
    }
}

// --- App Structure (Minimal) ---

// @main // Uncomment @main if this is the entry point
struct MusicAlbumsApp: App {
    // Could initialize RecentAlbumsStorage, PresentationCoordinator here as @StateObjects
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Apply .welcomeSheet() modifier here using PresentationCoordinator
             // .environmentObject(PresentationCoordinator.shared) // Example
             // .welcomeSheet() // Custom modifier assumed
        }
    }
}

// --- Preview Provider ---

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // Add environment objects if needed for preview (e.g., for coordinator)
            // .environmentObject(PresentationCoordinator.shared)
    }
}

// --- Sample Data ---

let sampleAlbums: [AlbumPlaceholder] = [
    AlbumPlaceholder(title: "Abbey Road", artistName: "The Beatles"),
    AlbumPlaceholder(title: "The Dark Side of the Moon", artistName: "Pink Floyd"),
    AlbumPlaceholder(title: "Rumours", artistName: "Fleetwood Mac"),
    AlbumPlaceholder(title: "Led Zeppelin IV", artistName: "Led Zeppelin"),
    AlbumPlaceholder(title: "Kind of Blue", artistName: "Miles Davis", artworkURL: URL(string: "https://via.placeholder.com/100/aabbcc")),
    AlbumPlaceholder(title: "Thriller", artistName: "Michael Jackson"),
    AlbumPlaceholder(title: "Back in Black", artistName: "AC/DC"),
]

let sampleTracks: [TrackPlaceholder] = [
    TrackPlaceholder(title: "Come Together", artistName: "The Beatles"),
    TrackPlaceholder(title: "Something", artistName: "The Beatles", duration: 210),
    TrackPlaceholder(title: "Maxwell's Silver Hammer", artistName: "The Beatles"),
    TrackPlaceholder(title: "Oh! Darling", artistName: "The Beatles"),
    TrackPlaceholder(title: "Octopus's Garden", artistName: "The Beatles", duration: 150),
    TrackPlaceholder(title: "I Want You (She's So Heavy)", artistName: "The Beatles"),
]
