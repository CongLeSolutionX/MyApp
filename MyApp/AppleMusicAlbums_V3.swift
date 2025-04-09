//
//  AppleMusicAlbums_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // Needed for ObservableObject

// --- Enhanced Placeholder Data Structures ---

struct AlbumPlaceholder: Identifiable, Hashable {
    let id = UUID() // Keep stable ID
    var apiId: String // Simulate an ID from an API (e.g., barcode)
    var title: String
    var artistName: String
    var artworkURL: URL? = URL(string: "https://picsum.photos/seed/\(Int.random(in: 1...1000))/100") // Random placeholder
    var releaseDate: Date? = Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...1000), to: Date()) // Example date
}

struct TrackPlaceholder: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artistName: String // Tracks can have different artists
    var albumTitle: String // Useful context
    var duration: TimeInterval? = TimeInterval(Int.random(in: 120...300)) // Random duration
    var trackNumber: Int?
}

// --- Central App State Management ---

@MainActor // Ensure UI updates happen on the main thread
class AppState: ObservableObject {
    @Published var allAlbums: [AlbumPlaceholder] = sampleAlbums // Master list
    @Published var recentAlbums: [AlbumPlaceholder] = [] // Tracks recently viewed
    @Published var musicSubscriptionAvailable: Bool = true // Simulate subscription
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil // For displaying errors

    // Simulate simple playback state
    @Published var nowPlayingInfo: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private let maxRecents = 10

    init() {
        // Load initial data or perform setup if needed
        print("AppState Initialized")
        // Could load saved recents here in a real app
    }

    // --- Actions ---

    func addToRecents(_ album: AlbumPlaceholder) {
        // Avoid duplicates and manage size
        recentAlbums.removeAll { $0.id == album.id }
        recentAlbums.insert(album, at: 0)
        if recentAlbums.count > maxRecents {
            recentAlbums.removeLast(recentAlbums.count - maxRecents)
        }
        print("Added '\(album.title)' to recents.")
        // Save recents in a real app (e.g., UserDefaults, CoreData)
    }

    func clearRecents() {
        recentAlbums.removeAll()
        print("Recents cleared.")
    }

    func findAlbum(byBarcode barcode: String) -> AlbumPlaceholder? {
        // Simulate finding an album based on its API/barcode ID
        print("Searching for album with barcode: \(barcode)")
        isLoading = true
        errorMessage = nil
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if let foundAlbum = self.allAlbums.first(where: { $0.apiId == barcode }) {
                 print("Found album: \(foundAlbum.title)")
                 return
            } else {
                 print("Album with barcode \(barcode) not found.")
                 self.errorMessage = "Album with barcode \(barcode) not found."
                 return
            }
        }
        // This immediate return is just for the placeholder sync function signature.
        // A real implementation would use async/await or completion handlers.
         return self.allAlbums.first(where: { $0.apiId == barcode }) // TEMP immediate return for sync demo
    }

    // Simulate fetching details for a specific album
    func fetchAlbumDetails(for albumId: UUID) async -> (tracks: [TrackPlaceholder], related: [AlbumPlaceholder]) {
        isLoading = true
        errorMessage = nil
        print("Fetching details for album ID: \(albumId)...")
        var fetchedTracks: [TrackPlaceholder] = []
        var fetchedRelated: [AlbumPlaceholder] = []

        do {
            // Simulate network delay
            try await Task.sleep(for: .seconds(1.5))

            // Simulate finding the album (should always exist if passed from list)
            guard let album = allAlbums.first(where: { $0.id == albumId }) else {
                throw URLError(.badServerResponse) // Simulate an error
            }

            // Simulate generating specific tracks for this album
            fetchedTracks = (1...Int.random(in: 8...15)).map { trackNum in
                TrackPlaceholder(
                    title: "Track \(trackNum) from \(album.title)",
                    artistName: album.artistName, // Usually same artist, but could vary
                    albumTitle: album.title,
                    trackNumber: trackNum
                )
            }

            // Simulate finding related albums (e.g., by same artist, genre - simple filter here)
            fetchedRelated = allAlbums.filter { $0.artistName == album.artistName && $0.id != album.id }
                                      .shuffled()
                                      .prefix(5)
                                      .map { $0 } // Ensure it's an array slice -> array

             print("Successfully fetched details for \(album.title)")

        } catch {
            print("Error fetching album details: \(error)")
            errorMessage = "Could not load album details. Please try again."
        }

        isLoading = false
        return (fetchedTracks, fetchedRelated)
    }

    // Simulate setting the player queue
    func playAlbum(_ album: AlbumPlaceholder) {
        if !musicSubscriptionAvailable {
             errorMessage = "Apple Music subscription required to play."
             print("Blocked playback attempt for \(album.title) - No subscription.")
             return
        }
        print("Simulating setting playback queue for album: \(album.title)")
        nowPlayingInfo = "Album: \(album.title) - \(album.artistName)"
        // In real app: Use MusicKit/AVPlayer to set queue and start playback
    }

    func playTrack(_ track: TrackPlaceholder) {
        if !musicSubscriptionAvailable {
             errorMessage = "Apple Music subscription required to play."
             print("Blocked playback attempt for track \(track.title) - No subscription.")
             return
        }
        print("Simulating playback for track: \(track.title)")
        nowPlayingInfo = "Track: \(track.title) - \(track.artistName) (\(track.albumTitle))"
        // In real app: Use MusicKit/AVPlayer to play specific track
    }

    func pausePlayback() {
        print("Simulating pause")
        // Update player state
        nowPlayingInfo = nil // Simple simulation: clear info on pause
    }
}


// --- Reusable UI Components (Mostly Unchanged, Ensure Data Passed) ---

struct ArtworkImage: View { /* ... same as before ... */
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
                    .overlay {
                         Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    }
            case .empty:
                 // Added overlay for structure during load
                 Rectangle().fill(.thinMaterial)
                    .overlay(ProgressView())
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.1))
        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
    }
}

struct MusicItemCell<Accessory: View>: View { /* ... same as before ... */
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
        HStack(spacing: 12) {
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


/// Cell specifically for displaying an Album in a list.
struct AlbumListCell: View {
    let album: AlbumPlaceholder

    var body: some View {
        MusicItemCell(
            artworkURL: album.artworkURL,
            title: album.title,
            subtitle: album.artistName
        ) {
            // Accessory view (chevron for navigation indication)
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary) // Use tertiaryLabel for less emphasis
                .font(.caption.weight(.bold))
                .imageScale(.small)
        }
    }
}

/// Cell specifically for displaying a Track inside AlbumDetailView.
struct TrackListCell: View {
    @EnvironmentObject var appState: AppState // To trigger play actions
    let track: TrackPlaceholder
    let trackNumber: Int? // Pass track number for display

    private var formattedDuration: String? {
        guard let duration = track.duration else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration)
    }

    var body: some View {
         HStack {
             if let number = trackNumber {
                 Text("\(number)")
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .frame(minWidth: 20, alignment: .trailing) // Align track numbers
             } else {
                 Spacer().frame(width: 20) // Placeholder if no number
             }

             VStack(alignment: .leading) {
                Text(track.title)
                    .lineLimit(1)
                // Potentially show contributing artists if different
                 Text(track.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
             }
             Spacer()
             if let duration = formattedDuration {
                 Text(duration)
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .padding(.trailing, 8)
             }
             // Simple visual cue for current simulated track
             if appState.nowPlayingInfo?.contains(track.title) == true {
                  Image(systemName: "speaker.wave.2.fill")
                      .foregroundColor(.accentColor)
                      .imageScale(.small)
             } else {
                 // Provide a tappable area without a visible button
                 Image(systemName: "play.circle")
                    .foregroundColor(.accentColor)
                     .imageScale(.large)
                     .opacity(0) // Make invisible but keep layout space for tap area
             }
         }
         .padding(.vertical, 6)
         .contentShape(Rectangle()) // Make entire Hstack tappable
         .onTapGesture {
             appState.playTrack(track)
         }
    }
}

/// Custom Button Style for prominent actions
struct ProminentButtonStyle: ButtonStyle { /* ... same as before ... */
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
    @EnvironmentObject var appState: AppState
    @State private var searchTerm: String = ""
    @State private var isBarcodeScanningViewPresented: Bool = false
    @State private var isDevelopmentSettingsViewPresented: Bool = false
    @State private var scannedBarcode: String = "" // Holds barcode from scanner sheet

    // State for programmatic navigation after barcode scan
    @State private var scannedAlbum: AlbumPlaceholder? = nil
    @State private var activateNavigationToScannedAlbum: Bool = false

    // Determines if barcode scanning is available (Placeholder)
    // private var isBarcodeScanningAvailable: Bool {
    //     // In real app, check camera availability etc.
    //     return true
    // }

    var searchResults: [AlbumPlaceholder] {
        if searchTerm.isEmpty {
            return [] // Return empty, recents are shown separately
        } else {
            // Simple local filtering for placeholder demo
            return appState.allAlbums.filter {
                $0.title.localizedCaseInsensitiveContains(searchTerm) ||
                $0.artistName.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                 // Display error message if any
                 if let error = appState.errorMessage {
                     Text(error)
                         .foregroundColor(.red)
                         .padding()
                         .frame(maxWidth: .infinity)
                         .background(Color.red.opacity(0.1))
                         .onTapGesture { appState.errorMessage = nil } // Allow dismissal
                 }

                List {
                    // Show search results or recent albums
                    if searchTerm.isEmpty {
                        Section("Recently Viewed") {
                             if appState.recentAlbums.isEmpty {
                                 Text("Albums you view will appear here.")
                                     .foregroundColor(.secondary)
                             } else {
                                ForEach(appState.recentAlbums) { album in
                                    // NavigationLink to AlbumDetailView
                                    NavigationLink(destination: AlbumDetailView(albumId: album.id)) {
                                        AlbumListCell(album: album)
                                    }
                                }
                             }
                        }
                    } else {
                         Section("Search Results (\(searchResults.count))") {
                            if appState.isLoading {
                                ProgressView("Searching...") // Show loading during simulated search
                            } else if searchResults.isEmpty {
                                Text("No results for \"\(searchTerm)\".")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(searchResults) { album in
                                     NavigationLink(destination: AlbumDetailView(albumId: album.id)) {
                                         AlbumListCell(album: album)
                                     }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped) // Use insetGrouped for better section look
                .navigationTitle("Music Albums")
                .searchable(text: $searchTerm, prompt: "Search Albums & Artists")
                 .overlay {
                      // Invisible NavigationLink for barcode scanning result
                      if let scannedAlbum = scannedAlbum {
                          NavigationLink(
                              destination: AlbumDetailView(albumId: scannedAlbum.id),
                              isActive: $activateNavigationToScannedAlbum
                          ) { EmptyView() }
                           .hidden() // Make sure it doesn't affect layout
                      }
                 }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                         Button {
                            print("Menu Tapped - Not Implemented")
                            // Add action like showing a filter menu
                         } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle") // More specific icon
                         }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // if isBarcodeScanningAvailable { // Rely on AppState or device check
                            Button {
                                scannedBarcode = "" // Reset before showing sheet
                                isBarcodeScanningViewPresented = true
                            } label: {
                                Label("Scan Barcode", systemImage: "barcode.viewfinder")
                            }
                        // }
                    }
                }
                // --- Now Playing Footer ---
                 if let nowPlaying = appState.nowPlayingInfo {
                      HStack {
                         Image(systemName: "music.note")
                         Text(nowPlaying)
                              .font(.footnote)
                              .lineLimit(1)
                          Spacer()
                          Button { appState.pausePlayback() } label: { Image(systemName: "pause.fill") }
                      }
                      .padding()
                      .background(.regularMaterial)
                      .transition(.move(edge: .bottom).combined(with: .opacity))
                 }

            } // End VStack
             .animation(.default, value: appState.nowPlayingInfo) // Animate footer in/out
             .animation(.default, value: appState.errorMessage) // Animate error
            // --- Sheets ---
            .sheet(isPresented: $isBarcodeScanningViewPresented) {
                // BarcodeScanningView would go here
                barcodeScanningSheetContent
            }
            .sheet(isPresented: $isDevelopmentSettingsViewPresented) {
                // DevelopmentSettingsView would go here
                developmentSettingsSheetContent
            }
            // Detect triple tap for dev settings
            .onTapGesture(count: 3) {
                 isDevelopmentSettingsViewPresented = true
            }
        }
        // Use stack style on iPad for better layout
        .navigationViewStyle(.stack)
    }


    // --- Sheet Content Views ---
    private var barcodeScanningSheetContent: some View {
         NavigationView { // Embed in NavigationView for Title/Buttons
             VStack(spacing: 20) {
                Text("Scan Album Barcode")
                     .font(.title2)

                // Placeholder for Camera View Finder would go here

                 TextField("Enter Barcode Manually", text: $scannedBarcode)
                     .keyboardType(.numberPad)
                     .textFieldStyle(.roundedBorder)
                     .padding(.horizontal)

                if appState.isLoading {
                    ProgressView("Searching...")
                 } else if let error = appState.errorMessage {
                     Text(error).foregroundColor(.red).font(.caption)
                 }

                 Button("Find Album") {
                     // Basic validation
                     if !scannedBarcode.isEmpty {
                          // Simulate finding
                           Task {
                               // Use the async version in AppState if it were truly async
                               if let found = appState.findAlbum(byBarcode: scannedBarcode) {
                                   self.scannedAlbum = found
                                   isBarcodeScanningViewPresented = false // Dismiss sheet
                                   // Trigger navigation AFTER sheet dismissal animation completes?
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.activateNavigationToScannedAlbum = true
                                   }
                               }
                               // Error message is handled by AppState's @Published var
                          }
                     }
                 }
                 .buttonStyle(.borderedProminent)
                 .disabled(scannedBarcode.isEmpty || appState.isLoading)


                Spacer()
            }
            .padding()
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Cancel") { isBarcodeScanningViewPresented = false }
                 }
            }
         }
    }

     private var developmentSettingsSheetContent: some View {
         NavigationView {
             Form { // Use Form for typical settings layout
                 Section("App State Simulation") {
                    Toggle("Music Subscription Active", isOn: $appState.musicSubscriptionAvailable)
                    Button("Clear Recent Albums") {
                        appState.clearRecents()
                    }
                    .foregroundColor(.red) // Indicate destructive action
                 }

                 Section("Simulate Error") {
                     Button("Trigger Generic Error Message") {
                         appState.errorMessage = "This is a simulated error message."
                         isDevelopmentSettingsViewPresented = false
                     }
                 }
             }
             .navigationTitle("Dev Settings")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") { isDevelopmentSettingsViewPresented = false }
                 }
             }
         }
    }
}

struct AlbumDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss // To potentially dismiss if album load fails badly

    let albumId: UUID // Pass ID instead of the whole object initially

    @State private var album: AlbumPlaceholder? = nil // Loaded album details
    @State private var tracks: [TrackPlaceholder] = []
    @State private var relatedAlbums: [AlbumPlaceholder] = []
    @State private var isLoadingDetails: Bool = true
    @State private var isShowingSubscriptionOffer: Bool = false

    // Check if the current album/track is playing (simplified)
    var isCurrentlyPlayingAlbum: Bool {
        appState.nowPlayingInfo?.contains(album?.title ?? "___") ?? false
    }

    var body: some View {
         ScrollView {
             if isLoadingDetails {
                  ProgressView("Loading Album...")
                      .padding(.top, 50)
             } else if let currentAlbum = album {
                  VStack(alignment: .leading, spacing: 20) {
                      // --- Header Section ---
                      albumHeader(album: currentAlbum)
                          .padding(.horizontal)

                      Divider()

                      // --- Tracks Section ---
                      trackSection(tracks: tracks)

                      // --- Related Albums Section ---
                      if !relatedAlbums.isEmpty {
                           relatedSection(related: relatedAlbums)
                      } else {
                           Text("No related albums found.")
                               .font(.caption)
                               .foregroundColor(.secondary)
                               .padding()
                      }

                  } // End Main VStack
                  .padding(.top)
             } else {
                  // Error state if album is nil after loading
                  Text("Failed to load album details.")
                      .foregroundColor(.red)
                      .padding()
                  Button("Go Back") { dismiss() }
                      .buttonStyle(.bordered)
             }
        }
        .navigationTitle(album?.title ?? "Album") // Show title once loaded
        .navigationBarTitleDisplayMode(.inline)
        .task { // Use .task for async work tied to view lifecycle
             await loadAlbumDetails()
        }
        .sheet(isPresented: $isShowingSubscriptionOffer) {
             // Subscription Offer Sheet Content
             subscriptionOfferSheet
        }
        .alert("Subscription Required", isPresented: Binding(get: { appState.errorMessage?.contains("subscription required") ?? false }, set: { _,_ in appState.errorMessage = nil } ) ) {
             // Show alert if playback fails due to subscription
              Button("Join Now") {
                  isShowingSubscriptionOffer = true
              }
              Button("Cancel", role: .cancel) {}
          } message: {
             Text("An Apple Music subscription is required to play this content.")
          }

    }

    // --- Subviews for Detail Sections ---

    @ViewBuilder
    private func albumHeader(album: AlbumPlaceholder) -> some View {
         HStack(alignment: .bottom, spacing: 15) {
             ArtworkImage(url: album.artworkURL, size: 120)

             VStack(alignment: .leading) {
                 Text(album.title)
                     .font(UIDevice.current.userInterfaceIdiom == .pad ? .largeTitle : .title2).fontWeight(.bold) // Larger on iPad
                     .lineLimit(3) // Allow more lines for longer titles
                 Text(album.artistName)
                      .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .title3)
                      .foregroundColor(.secondary)
                     .lineLimit(1)

                 // Optional: Display Release Date
                 if let date = album.releaseDate {
                      Text("Released: \(date, style: .date)")
                           .font(.caption)
                           .foregroundColor(.secondary)
                 }

                 Spacer() // Push button down
                 playButton(for: album) // Pass album for play action
             }
              Spacer() // Push content left
         }
    }

    @ViewBuilder
    private func trackSection(tracks: [TrackPlaceholder])-> some View {
         Section {
            // Use LazyVStack for potentially long track lists
            LazyVStack(alignment: .leading, spacing: 0) { // Remove default spacing
                 ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                     // Pass index+1 for track number display
                     TrackListCell(track: track, trackNumber: track.trackNumber ?? (index + 1))
                         .padding(.horizontal)
                         .background(index % 2 == 0 ? Color.clear : Color.secondary.opacity(0.05)) // Subtle row banding
                     Divider().padding(.leading, 50) // Indent divider past number/artwork space
                 }
            }
         } header: {
              Text("Tracks (\(tracks.count))")
                  .font(.headline)
                  .padding(.horizontal)
                  .padding(.bottom, 5) // Add spacing below header
         }
    }

    @ViewBuilder
    private func relatedSection(related: [AlbumPlaceholder]) -> some View {
        Section {
             ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) { // Use LazyHStack
                     ForEach(related) { relatedAlbum in
                         // Navigate to ANOTHER detail view
                         NavigationLink(destination: AlbumDetailView(albumId: relatedAlbum.id)) {
                              VStack {
                                 ArtworkImage(url: relatedAlbum.artworkURL, size: 100)
                                 Text(relatedAlbum.title)
                                     .font(.caption)
                                     .lineLimit(2) // Allow two lines for title
                                     .multilineTextAlignment(.center)
                                     .frame(height: 35) // Fixed height for text block
                                 Text(relatedAlbum.artistName)
                                     .font(.caption2)
                                     .foregroundColor(.secondary)
                                     .lineLimit(1)
                                     .truncationMode(.tail)
                             }
                             .frame(width: 100) // Ensure consistent width
                         }
                         .buttonStyle(.plain) // Improve appearance inside ScrollView
                     }
                 }
                 .padding(.horizontal)
                 .padding(.bottom) // Add padding below scroll view
             }
         } header: {
              Text("Related Albums")
                  .font(.headline)
                  .padding(.horizontal)
                  .padding(.bottom, 5)
         }
    }

    // Extracted Play/Join Button Logic
    @ViewBuilder
    private func playButton(for album: AlbumPlaceholder) -> some View {
        if appState.musicSubscriptionAvailable {
            Button {
                  if isCurrentlyPlayingAlbum {
                       appState.pausePlayback()
                  } else {
                       appState.playAlbum(album)
                  }
             } label: {
                  Label(isCurrentlyPlayingAlbum ? "Pause" : "Play", systemImage: isCurrentlyPlayingAlbum ? "pause.fill" : "play.fill")
             }
             .buttonStyle(ProminentButtonStyle())
             .id(isCurrentlyPlayingAlbum) // Helps animation when state changes
        } else {
             Button("Join") { // Show join if no subscription
                 isShowingSubscriptionOffer = true
             }
             .buttonStyle(ProminentButtonStyle())
        }
    }

    // Extracted Subscription Offer Sheet Content
    private var subscriptionOfferSheet: some View {
         VStack {
             Image(systemName: "music.note.tv.fill") // Example Icon
                 .font(.system(size: 50))
                 .padding(.bottom)
                 .foregroundColor(.pink) // Apple Music Pink
             Text("Apple Music")
                 .font(.title.bold())
             Text("Unlock millions of songs and your entire music library.")
                 .multilineTextAlignment(.center)
                 .padding(.horizontal)
                 .foregroundColor(.secondary)
             Button("Try it Free*") { // More appealing CTA
                 print("Subscription Learn More tapped - Open URL/Subscription Flow")
                 isShowingSubscriptionOffer = false
                 // In real app: open App Store subscription sheet or URL
                 // UIApplication.shared.open(URL(string: "applemusic://subscribe")!)
             }
             .buttonStyle(ProminentButtonStyle())
             .padding(.top)
             Text("*Subscription terms apply.")
                 .font(.caption2).foregroundColor(.secondary)
             Button("Not Now") { isShowingSubscriptionOffer = false }
                 .padding(.top)
                 .tint(.secondary) // Less prominent close button
         }
         .padding()
    }


     // Function to load data when view appears
     func loadAlbumDetails() async {
         // Only load if album is not already loaded or ID changed
         guard self.album == nil else {
              // If album already exists, ensure it's added to recents
              if let currentAlbum = self.album {
                    appState.addToRecents(currentAlbum)
              }
               isLoadingDetails = false
              return
          }

         print("AlbumDetailView: Loading details for ID \(albumId)")
         isLoadingDetails = true

          // Fetch the core album info first (if needed, though passed by ID means AppState has it)
          // In this version, we assume AppState has the basic AlbumPlaceholder object
          self.album = appState.allAlbums.first { $0.id == albumId }

          // Ensure the basic album was found
          guard let loadedAlbum = self.album else {
               print("FATAL Error: Album with ID \(albumId) not found in AppState.")
                appState.errorMessage = "Could not find album information."
               isLoadingDetails = false
                // Consider dismissing the view here if the album is truly gone
                // dismiss()
               return
          }

         // Fetch tracks and related from AppState's async function
         let details = await appState.fetchAlbumDetails(for: albumId)
         self.tracks = details.tracks
         self.relatedAlbums = details.related

         // Add to recents *after* successfully loading
         appState.addToRecents(loadedAlbum)

         isLoadingDetails = false
         print("AlbumDetailView: Finished Loading for \(loadedAlbum.title)")
     }
}

// --- App Structure (With State Management) ---

@main
struct MusicAlbumsApp: App {
    // Create the single source of truth for the app state
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the app state into the environment
                .environmentObject(appState)
             // Could apply welcome sheet modifier here if needed
             // .welcomeSheet() // Using presentation coordinator from AppState if required
        }
    }
}

// --- Preview Provider ---

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // Provide a mock AppState for the preview
            .environmentObject(AppState())
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
         NavigationView { // Embed in NavigationView for preview context
             AlbumDetailView(albumId: sampleAlbums[0].id) // Preview with the first sample album ID
         }
         .environmentObject(AppState()) // Provide mock AppState
    }
}


// --- Sample Data (More Diverse) ---

let sampleAlbums: [AlbumPlaceholder] = [
    AlbumPlaceholder(apiId: "190295643270", title: "Abbey Road", artistName: "The Beatles"), // Example Barcode
    AlbumPlaceholder(apiId: "724382975220", title: "The Dark Side of the Moon", artistName: "Pink Floyd"),
    AlbumPlaceholder(apiId: "075992731327", title: "Rumours", artistName: "Fleetwood Mac"),
    AlbumPlaceholder(apiId: "075678263827", title: "Led Zeppelin IV", artistName: "Led Zeppelin"),
    AlbumPlaceholder(apiId: "093624924525", title: "Kind of Blue", artistName: "Miles Davis", artworkURL: URL(string: "https://picsum.photos/seed/miles/100")),
    AlbumPlaceholder(apiId: "074643811226", title: "Thriller", artistName: "Michael Jackson"),
    AlbumPlaceholder(apiId: "075678146123", title: "Back in Black", artistName: "AC/DC"),
    AlbumPlaceholder(apiId: "886979308028", title: "Random Access Memories", artistName: "Daft Punk"),
    AlbumPlaceholder(apiId: "602537542403", title: "1989", artistName: "Taylor Swift"),
    AlbumPlaceholder(apiId: "050087317232", title: "OK Computer", artistName: "Radiohead"),
]

// Note: SampleTracks are now generated dynamically inside AppState.fetchAlbumDetails
// let sampleTracks: [TrackPlaceholder] = [ ... ] // Removed, as they are generated per album load
