////
////  AppleMusicAlbums.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//The entry point for the app.
//*/
//
//import MusicKit
//import SwiftUI
//
///// `MusicAlbumsApp` conforms to the SwiftUI `App` protocol, and configures the overall appearance of the app.
//@main
//struct MusicAlbumsApp: App {
//    
//    // MARK: - Object lifecycle
//    
//    /// Configures the app when it launches.
//    init() {
//        adjustVisualAppearance()
//    }
//    
//    // MARK: - App
//    
//    /// The app’s root view.
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .frame(minWidth: 400.0, minHeight: 200.0)
//        }
//    }
//    
//    // MARK: - Methods
//    
//    /// Configures the UI appearance of the app.
//    private func adjustVisualAppearance() {
//        var navigationBarLayoutMargins: UIEdgeInsets = .zero
//        navigationBarLayoutMargins.left = 26.0
//        navigationBarLayoutMargins.right = navigationBarLayoutMargins.left
//        UINavigationBar.appearance().layoutMargins = navigationBarLayoutMargins
//        
//        var tableViewLayoutMargins: UIEdgeInsets = .zero
//        tableViewLayoutMargins.left = 28.0
//        tableViewLayoutMargins.right = tableViewLayoutMargins.left
//        UITableView.appearance().layoutMargins = tableViewLayoutMargins
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//A view that introduces the purpose of the app to users.
//*/
//
//import MusicKit
//import SwiftUI
//
//// MARK: - Welcome view
//
///// `WelcomeView` is a view that introduces to users the purpose of the MusicAlbums app,
///// and demonstrates best practices for requesting user consent for an app to get access to
///// Apple Music data.
/////
///// Present this view as a sheet using the convenience `.welcomeSheet()` modifier.
//struct WelcomeView: View {
//    
//    // MARK: - Properties
//    
//    /// The current authorization status of MusicKit.
//    @Binding var musicAuthorizationStatus: MusicAuthorization.Status
//    
//    /// Opens a URL using the appropriate system service.
//    @Environment(\.openURL) private var openURL
//    
//    // MARK: - View
//    
//    /// A declaration of the UI that this view presents.
//    var body: some View {
//        ZStack {
//            gradient
//            VStack {
//                Text("CongLeSolutionX Entertainment")
//                    .foregroundColor(.primary)
//                    .font(.largeTitle.weight(.semibold))
//                    .shadow(radius: 2)
//                    .padding(.bottom, 1)
//                
//                Image("My-meme-orange-microphone")
//                    .resizable(resizingMode: .stretch)
//                    .frame(width: 320, height: 240)
//                    .shadow(radius: 3)
//                    .padding(.bottom, 16)
//                Text("Rediscover your old music.")
//                    .foregroundColor(.primary)
//                    .font(.title2.weight(.medium))
//                    .multilineTextAlignment(.center)
//                    .shadow(radius: 1)
//                    .padding(.bottom, 16)
//                explanatoryText
//                    .foregroundColor(.primary)
//                    .font(.title3.weight(.medium))
//                    .multilineTextAlignment(.center)
//                    .shadow(radius: 1)
//                    .padding([.leading, .trailing], 32)
//                    .padding(.bottom, 16)
//                if let secondaryExplanatoryText = self.secondaryExplanatoryText {
//                    secondaryExplanatoryText
//                        .foregroundColor(.primary)
//                        .font(.title3.weight(.medium))
//                        .multilineTextAlignment(.center)
//                        .shadow(radius: 1)
//                        .padding([.leading, .trailing], 32)
//                        .padding(.bottom, 16)
//                }
//                if musicAuthorizationStatus == .notDetermined || musicAuthorizationStatus == .denied {
//                    Button(action: handleButtonPressed) {
//                        buttonText
//                            .padding([.leading, .trailing], 10)
//                    }
//                    .buttonStyle(.prominent)
//                    .colorScheme(.light)
//                }
//            }
//            .colorScheme(.dark)
//        }
//    }
//    
//    /// Constructs a gradient to use as the view background.
//    private var gradient: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [
//                            // Lighter Gold/Orange
//                            Color(red: 240.0 / 255.0, green: 190.0 / 255.0, blue: 70.0 / 255.0), // Lighter Goldenrod tone
//                            // Medium Gold/Orange
//                            Color(red: 218.0 / 255.0, green: 165.0 / 255.0, blue: 32.0 / 255.0),  // Goldenrod (Hex: #DAA520)
//                            // Dark Gold/Brownish
//                            Color(red: 180.0 / 255.0, green: 120.0 / 255.0, blue: 20.0 / 255.0)  // Darker orange/brown gold
//                        ]),
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//        .flipsForRightToLeftLayoutDirection(false)
//        .ignoresSafeArea()
//    }
//    
//    /// Provides text that explains how to use the app according to the authorization status.
//    private var explanatoryText: Text {
//        let explanatoryText: Text
//        switch musicAuthorizationStatus {
//            case .restricted:
//                explanatoryText = Text("Music Albums cannot be used on this iPhone because usage of ")
//                    + Text(Image(systemName: "applelogo")) + Text(" Music is restricted.")
//            default:
//                explanatoryText = Text("This app uses ")
//                    + Text(Image(systemName: "applelogo")) + Text(" Music\nto help you rediscover your music.")
//        }
//        return explanatoryText
//    }
//    
//    /// Provides additional text that explains how to get access to Apple Music
//    /// after previously denying authorization.
//    private var secondaryExplanatoryText: Text? {
//        var secondaryExplanatoryText: Text?
//        switch musicAuthorizationStatus {
//            case .denied:
//                secondaryExplanatoryText = Text("Please grant Music Albums access to ")
//                    + Text(Image(systemName: "applelogo")) + Text(" Music in Settings.")
//            default:
//                break
//        }
//        return secondaryExplanatoryText
//    }
//    
//    /// A button that the user taps to continue using the app according to the current
//    /// authorization status.
//    private var buttonText: Text {
//        let buttonText: Text
//        switch musicAuthorizationStatus {
//            case .notDetermined:
//                buttonText = Text("Continue")
//            case .denied:
//                buttonText = Text("Open Settings")
//            default:
//                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
//        }
//        return buttonText
//    }
//    
//    // MARK: - Methods
//    
//    /// Allows the user to authorize Apple Music usage when tapping the Continue/Open Setting button.
//    private func handleButtonPressed() {
//        switch musicAuthorizationStatus {
//            case .notDetermined:
//                Task {
//                    let musicAuthorizationStatus = await MusicAuthorization.request()
//                    update(with: musicAuthorizationStatus)
//                }
//            case .denied:
//                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                    openURL(settingsURL)
//                }
//            default:
//                fatalError("No button should be displayed for current authorization status: \(musicAuthorizationStatus).")
//        }
//    }
//    
//    /// Safely updates the `musicAuthorizationStatus` property on the main thread.
//    @MainActor
//    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
//        withAnimation {
//            self.musicAuthorizationStatus = musicAuthorizationStatus
//        }
//    }
//    
//    // MARK: - Presentation coordinator
//    
//    /// A presentation coordinator to use in conjuction with `SheetPresentationModifier`.
//    class PresentationCoordinator: ObservableObject {
//        static let shared = PresentationCoordinator()
//        
//        private init() {
//            let authorizationStatus = MusicAuthorization.currentStatus
//            musicAuthorizationStatus = authorizationStatus
//            isWelcomeViewPresented = (authorizationStatus != .authorized)
//        }
//        
//        @Published var musicAuthorizationStatus: MusicAuthorization.Status {
//            didSet {
//                isWelcomeViewPresented = (musicAuthorizationStatus != .authorized)
//            }
//        }
//        
//        @Published var isWelcomeViewPresented: Bool
//    }
//    
//    // MARK: - Sheet presentation modifier
//    
//    /// A view modifier that changes the presentation and dismissal behavior of the welcome view.
//    fileprivate struct SheetPresentationModifier: ViewModifier {
//        @StateObject private var presentationCoordinator = PresentationCoordinator.shared
//        
//        func body(content: Content) -> some View {
//            content
//                .sheet(isPresented: $presentationCoordinator.isWelcomeViewPresented) {
//                    WelcomeView(musicAuthorizationStatus: $presentationCoordinator.musicAuthorizationStatus)
//                        .interactiveDismissDisabled()
//                }
//        }
//    }
//}
//
//// MARK: - View extension
//
///// Allows the addition of the`welcomeSheet` view modifier to the top-level view.
//extension View {
//    func welcomeSheet() -> some View {
//        modifier(WelcomeView.SheetPresentationModifier())
//    }
//}
//
//// MARK: - Previews
//
//struct WelcomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        WelcomeView(musicAuthorizationStatus: .constant(.notDetermined))
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//The app's top-level view that allows users to find music they want to rediscover.
//*/
//
//import MusicKit
//import SwiftUI
//
//struct ContentView: View {
//    
//    // MARK: - View
//    
//    var body: some View {
//        
//        rootView
//            .onAppear(perform: recentAlbumsStorage.beginObservingMusicAuthorizationStatus)
//            .onChange(of: searchTerm) {
//                requestUpdatedSearchResults(for: searchTerm)
//            }
//            .onChange(of: detectedBarcode) {
//                handleDetectedBarcode(detectedBarcode)
//            }
//            .onChange(of: isDetectedAlbumDetailViewActive) {
//                handleDetectedAlbumDetailViewActiveChange(isDetectedAlbumDetailViewActive)
//            }
//        
//            // Display the barcode scanning view when appropriate.
//            .sheet(isPresented: $isBarcodeScanningViewPresented) {
//                BarcodeScanningView($detectedBarcode)
//            }
//        
//            // Display the development settings view when appropriate.
//            .sheet(isPresented: $isDevelopmentSettingsViewPresented) {
//                DevelopmentSettingsView()
//            }
//        
//            // Display the welcome view when appropriate.
//            .welcomeSheet()
//    }
//    
//    /// The various components of the main navigation view.
//    private var navigationViewContents: some View {
//        VStack {
//            gradient
//            searchResultsList
//                .animation(.default, value: albums)
//            if isBarcodeScanningAvailable {
//                if albums.isEmpty {
//                    Button(action: { isBarcodeScanningViewPresented = true }) {
//                        Image(systemName: "barcode.viewfinder")
//                            .font(.system(size: 60, weight: .semibold))
//                    }
//                }
//                if let albumMatchingDetectedBarcode = detectedAlbum {
//                    NavigationLink(destination: AlbumDetailView(albumMatchingDetectedBarcode), isActive: $isDetectedAlbumDetailViewActive) {
//                        EmptyView()
//                    }
//                }
//            }
//        }
//    }
//    
//    /// The top-level content view.
//    private var rootView: some View {
//        NavigationView {
//            navigationViewContents
//                .navigationTitle("CongLeSolutionX Entertainment")
//        }
//        .searchable(text: $searchTerm, prompt: "Albums")
//        .gesture(hiddenDevelopmentSettingsGesture)
//    }
//    
//    // MARK: - Search results requesting
//    
//    /// The current search term the user enters.
//    @State private var searchTerm = ""
//    
//    /// The albums the app loads using MusicKit that match the current search term.
//    @State private var albums: MusicItemCollection<Album> = []
//    
//    /// A reference to the storage object for recent albums the user previously viewed in the app.
//    @StateObject private var recentAlbumsStorage = RecentAlbumsStorage.shared
//    
//    /// A list of albums to display below the search bar.
//    private var searchResultsList: some View {
//        List(albums.isEmpty ? recentAlbumsStorage.recentlyViewedAlbums : albums) { album in
//            AlbumCell(album)
//        }
//    }
//    
//    /// Makes a new search request to MusicKit when the current search term changes.
//    private func requestUpdatedSearchResults(for searchTerm: String) {
//        Task {
//            if searchTerm.isEmpty {
//                self.reset()
//            } else {
//                do {
//                    // Issue a catalog search request for albums matching the search term.
//                    var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
//                    searchRequest.limit = 5
//                    let searchResponse = try await searchRequest.response()
//                    
//                    // Update the user interface with the search response.
//                    self.apply(searchResponse, for: searchTerm)
//                } catch {
//                    print("Search request failed with error: \(error).")
//                    self.reset()
//                }
//            }
//        }
//    }
//    
//    /// Safely updates the `albums` property on the main thread.
//    @MainActor
//    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
//        if self.searchTerm == searchTerm {
//            self.albums = searchResponse.albums
//        }
//    }
//    
//    /// Safely resets the `albums` property on the main thread.
//    @MainActor
//    private func reset() {
//        self.albums = []
//    }
//    
//    // MARK: - Barcode detection handling
//    
//    /// `true` if the barcode scanning functionality is available to the user.
//    @AppStorage("barcode-scanning-available") private var isBarcodeScanningAvailable = true
//    
//    /// `true` if the content view needs to display the barcode scanning view.
//    @State private var isBarcodeScanningViewPresented = false
//    
//    /// A barcode that the barcode scanning view detects.
//    @State private var detectedBarcode = ""
//    
//    /// The album that matches the detected barcode, if any.
//    @State private var detectedAlbum: Album?
//    
//    /// `true` if the content view needs to display the album detail view.
//    @State private var isDetectedAlbumDetailViewActive = false
//    
//    /// Searches for an album that matches a barcode that the barcode scanning view detects.
//    private func handleDetectedBarcode(_ detectedBarcode: String) {
//        if detectedBarcode.isEmpty {
//            self.detectedAlbum = nil
//        } else {
//            Task {
//                do {
//                    let albumsRequest = MusicCatalogResourceRequest<Album>(matching: \.upc, equalTo: detectedBarcode)
//                    let albumsResponse = try await albumsRequest.response()
//                    if let firstAlbum = albumsResponse.items.first {
//                        self.handleDetectedAlbum(firstAlbum)
//                    }
//                } catch {
//                    print("Encountered error while trying to find albums with upc = \"\(detectedBarcode)\".")
//                }
//            }
//        }
//    }
//    
//    /// Safely updates state properties on the main thread.
//    @MainActor
//    private func handleDetectedAlbum(_ detectedAlbum: Album) {
//        
//        // Dismiss the barcode scanning view.
//        self.isBarcodeScanningViewPresented = false
//        
//        // Push the album detail view for the detected album.
//        self.detectedAlbum = detectedAlbum
//        withAnimation {
//            self.isDetectedAlbumDetailViewActive = true
//        }
//        
//    }
//    
//    /// Clears the scanned barcode when hiding or showing the album detail view.
//    private func handleDetectedAlbumDetailViewActiveChange(_ isDetectedAlbumDetailViewActive: Bool) {
//        if !isDetectedAlbumDetailViewActive {
//            self.detectedBarcode = ""
//        }
//    }
//    
//    // MARK: - Development settings
//    
//    /// `true` if the content view needs to display the development settings view.
//    @State var isDevelopmentSettingsViewPresented = false
//    
//    /// A custom gesture that initiates the presentation of the development settings view.
//    private var hiddenDevelopmentSettingsGesture: some Gesture {
//        TapGesture(count: 3).onEnded {
//            isDevelopmentSettingsViewPresented = true
//        }
//    }
//}
//
//// MARK: - Previews
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//Detailed information about an album.
//*/
//
//import MusicKit
//import SwiftUI
//
///// `AlbumDetailView` is a view that presents detailed information about a specific `Album`.
//struct AlbumDetailView: View {
//    
//    // MARK: - Object lifecycle
//    
//    init(_ album: Album) {
//        self.album = album
//    }
//    
//    // MARK: - Properties
//    
//    /// The album that this view represents.
//    let album: Album
//    
//    /// The tracks that belong to this album.
//    @State var tracks: MusicItemCollection<Track>?
//    
//    /// A collection of related albums.
//    @State var relatedAlbums: MusicItemCollection<Album>?
//    
//    // MARK: - View
//    
//    var body: some View {
//        List {
//            Section(header: header, content: {})
//                .textCase(nil)
//                .foregroundColor(Color.primary)
//            
//            // Add a list of tracks on the album.
//            if let loadedTracks = tracks, !loadedTracks.isEmpty {
//                Section(header: Text("Tracks")) {
//                    ForEach(loadedTracks) { track in
//                        TrackCell(track, from: album) {
//                            handleTrackSelected(track, loadedTracks: loadedTracks)
//                        }
//                    }
//                }
//            }
//            
//            // Add a list of related albums.
//            if let loadedRelatedAlbums = relatedAlbums, !loadedRelatedAlbums.isEmpty {
//                Section(header: Text("Related Albums")) {
//                    ForEach(loadedRelatedAlbums) { album in
//                        AlbumCell(album)
//                    }
//                }
//            }
//        }
//        .navigationTitle(album.title)
//        
//        // When the view appears, load tracks and related albums asynchronously.
//        .task {
//            RecentAlbumsStorage.shared.update(with: album)
//            try? await loadTracksAndRelatedAlbums()
//        }
//        
//        // Start observing changes to the music subscription.
//        .task {
//            for await subscription in MusicSubscription.subscriptionUpdates {
//                musicSubscription = subscription
//            }
//        }
//        
//        // Display the subscription offer when appropriate.
//        .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
//    }
//    
//    // The fixed part of this view’s UI.
//    private var header: some View {
//        VStack {
//            if let artwork = album.artwork {
//                ArtworkImage(artwork, width: 320)
//                    .cornerRadius(8)
//            }
//            Text(album.artistName)
//                .font(.title2.bold())
//            playButtonRow
//        }
//    }
//    
//    // MARK: - Loading tracks and related albums
//    
//    /// Loads tracks and related albums asynchronously.
//    private func loadTracksAndRelatedAlbums() async throws {
//        let detailedAlbum = try await album.with([.artists, .tracks])
//        let artist = try await detailedAlbum.artists?.first?.with([.albums])
//        update(tracks: detailedAlbum.tracks, relatedAlbums: artist?.albums)
//    }
//    
//    /// Safely updates `tracks` and `relatedAlbums` properties on the main thread.
//    @MainActor
//    private func update(tracks: MusicItemCollection<Track>?, relatedAlbums: MusicItemCollection<Album>?) {
//        withAnimation {
//            self.tracks = tracks
//            self.relatedAlbums = relatedAlbums
//        }
//    }
//    
//    // MARK: - Playback
//    
//    /// The MusicKit player to use for Apple Music playback.
//    private let player = ApplicationMusicPlayer.shared
//    
//    /// The state of the MusicKit player to use for Apple Music playback.
//    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
//    
//    /// `true` when the album detail view sets a playback queue on the player.
//    @State private var isPlaybackQueueSet = false
//    
//    /// `true` when the player is playing.
//    private var isPlaying: Bool {
//        return (playerState.playbackStatus == .playing)
//    }
//    
//    /// The Apple Music subscription of the current user.
//    @State private var musicSubscription: MusicSubscription?
//    
//    /// The localized label of the Play/Pause button when in the play state.
//    private let playButtonTitle: LocalizedStringKey = "Play"
//    
//    /// The localized label of the Play/Pause button when in the paused state.
//    private let pauseButtonTitle: LocalizedStringKey = "Pause"
//    
//    /// `true` when the album detail view needs to disable the Play/Pause button.
//    private var isPlayButtonDisabled: Bool {
//        let canPlayCatalogContent = musicSubscription?.canPlayCatalogContent ?? false
//        return !canPlayCatalogContent
//    }
//    
//    /// `true` when the album detail view needs to offer an Apple Music subscription to the user.
//    private var shouldOfferSubscription: Bool {
//        let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
//        return canBecomeSubscriber
//    }
//    
//    /// A declaration of the Play/Pause button, and (if appropriate) the Join button, side by side.
//    private var playButtonRow: some View {
//        HStack {
//            Button(action: handlePlayButtonSelected) {
//                HStack {
//                    Image(systemName: (isPlaying ? "pause.fill" : "play.fill"))
//                    Text((isPlaying ? pauseButtonTitle : playButtonTitle))
//                }
//                .frame(maxWidth: 200)
//            }
//            .buttonStyle(.prominent)
//            .disabled(isPlayButtonDisabled)
//            .animation(.easeInOut(duration: 0.1), value: isPlaying)
//            
//            if shouldOfferSubscription {
//                subscriptionOfferButton
//            }
//        }
//    }
//    
//    /// The action to perform when the user taps the Play/Pause button.
//    private func handlePlayButtonSelected() {
//        if !isPlaying {
//            if !isPlaybackQueueSet {
//                player.queue = [album]
//                isPlaybackQueueSet = true
//                beginPlaying()
//            } else {
//                Task {
//                    do {
//                        try await player.play()
//                    } catch {
//                        print("Failed to resume playing with error: \(error).")
//                    }
//                }
//            }
//        } else {
//            player.pause()
//        }
//    }
//    
//    /// The action to perform when the user taps a track in the list of tracks.
//    private func handleTrackSelected(_ track: Track, loadedTracks: MusicItemCollection<Track>) {
//        player.queue = ApplicationMusicPlayer.Queue(for: loadedTracks, startingAt: track)
//        isPlaybackQueueSet = true
//        beginPlaying()
//    }
//    
//    /// A convenience method for beginning music playback.
//    ///
//    /// Call this instead of `MusicPlayer`’s `play()`
//    /// method whenever the playback queue is reset.
//    private func beginPlaying() {
//        Task {
//            do {
//                try await player.play()
//            } catch {
//                print("Failed to prepare to play with error: \(error).")
//            }
//        }
//    }
//    
//    // MARK: - Subscription offer
//    
//    private var subscriptionOfferButton: some View {
//        Button(action: handleSubscriptionOfferButtonSelected) {
//            HStack {
//                Image(systemName: "applelogo")
//                Text("Join")
//            }
//            .frame(maxWidth: 200)
//        }
//        .buttonStyle(.prominent)
//    }
//    
//    /// The state that controls whether the album detail view displays a subscription offer for Apple Music.
//    @State private var isShowingSubscriptionOffer = false
//    
//    /// The options for the Apple Music subscription offer.
//    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default
//    
//    /// Computes the presentation state for a subscription offer.
//    private func handleSubscriptionOfferButtonSelected() {
//        subscriptionOfferOptions.messageIdentifier = .playMusic
//        subscriptionOfferOptions.itemID = album.id
//        isShowingSubscriptionOffer = true
//    }
//}
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//Controls for functionality that the app might hide temporarily.
//*/
//
//import SwiftUI
//
///// DevelopmentSettingsView is a view that offers controls for hidden settings.
///// This is a developer-only tool to temporarily hide certain key features of the app.
//struct DevelopmentSettingsView: View {
//    
//    // MARK: - Properties
//    
//    /// `true` if the app needs to display a button that presents the barcode scanning view.
//    ///
//    /// The view persists this Boolean value in `UserDefaults`.
//    @AppStorage("barcode-scanning-available") var isBarcodeScanningAvailable = true
//    
//    // MARK: - View
//    
//    var body: some View {
//        NavigationView {
//            settingsList
//                .navigationBarTitle("Development Settings", displayMode: .inline)
//        }
//    }
//    
//    private var settingsList: some View {
//        List {
//            Section(header: Text("Features")) {
//                Toggle("Barcode Scanning", isOn: $isBarcodeScanningAvailable)
//            }
//            Section(header: Text("Reset")) {
//                Button("Reset Recent Albums") {
//                    RecentAlbumsStorage.shared.reset()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Previews
//
//struct DevelopmentSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DevelopmentSettingsView()
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//The view for recognizing barcodes.
//*/
//
//import SwiftUI
//
///// `BarcodeScanningView` presents the UI for recognizing regular one-dimensional barcodes.
//struct BarcodeScanningView: UIViewControllerRepresentable {
//    
//    // MARK: - Object lifecycle
//    
//    init(_ detectedBarcode: Binding<String>) {
//        self._detectedBarcode = detectedBarcode
//    }
//    
//    // MARK: - Properties
//    
//    @Binding var detectedBarcode: String
//    
//    // MARK: - View controller representable
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        return BarcodeScanningViewController($detectedBarcode)
//    }
//    
//    func updateUIViewController(_ viewController: UIViewController, context: Context) {
//        // The underlying view controller doesn’t need to be updated in any way.
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//The view controller for recognizing barcodes.
//*/
//
//import AVFoundation
//import SwiftUI
//import UIKit
//
///// `BarcodeScanningViewController` is a view controller for recognizing regular one-dimensional barcodes.
///// This view controller accomplishes this using `AVCaptureSession` and `AVCaptureVideoPreviewLayer`.
//class BarcodeScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
//    
//    // MARK: - Object lifecycle
//    
//    init(_ detectedBarcode: Binding<String>) {
//        self._detectedBarcode = detectedBarcode
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Properties
//    
//    /// A barcode string that the barcode scanning view detects.
//    @Binding var detectedBarcode: String
//    
//    /// A capture session for enabling the camera.
//    private var captureSession: AVCaptureSession?
//    
//    /// The capture session’s preview content.
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//    
//    // MARK: - View lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        
//        // Set up the capture device.
//        let captureSession = AVCaptureSession()
//        let metadataOutput = AVCaptureMetadataOutput()
//        if
//            let videoCaptureDevice = AVCaptureDevice.default(for: .video),
//            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
//            captureSession.canAddInput(videoInput),
//            captureSession.canAddOutput(metadataOutput) {
//            
//            // Configure the capture session.
//            self.captureSession = captureSession
//            captureSession.addInput(videoInput)
//            captureSession.addOutput(metadataOutput)
//            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
//            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
//            
//            // Configure the preview layer.
//            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            self.previewLayer = previewLayer
//            
//            previewLayer.frame = view.layer.bounds
//            previewLayer.videoGravity = .resizeAspectFill
//            view.layer.addSublayer(previewLayer)
//            
//            // Start the capture session.
//            captureSession.startRunning()
//        } else {
//            let scanningUnsupportedAlertController = UIAlertController(
//                title: "Scanning not supported",
//                message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
//                preferredStyle: .alert
//            )
//            let okAlertAction = UIAlertAction(title: "OK", style: .default)
//            scanningUnsupportedAlertController.addAction(okAlertAction)
//            present(scanningUnsupportedAlertController, animated: true)
//        }
//    }
//    
//    /// Resumes the current capture session, if any, when the view appears.
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if let captureSession = self.captureSession, !captureSession.isRunning {
//            captureSession.startRunning()
//        }
//    }
//    
//    /// Suspends the current capture session, if any, when the view disappears.
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if let captureSession = self.captureSession, captureSession.isRunning {
//            captureSession.stopRunning()
//        }
//    }
//    
//    /// Hides the status bar when a capture is running.
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//    
//    /// Forces this view into portrait orientation.
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
//    
//    // MARK: - Capture metadata output objects delegate
//    
//    /// Captures a barcode string, if there is one in the current capture session.
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        self.captureSession?.stopRunning()
//        
//        // Check that a barcode is available.
//        if
//            let previewLayer = self.previewLayer,
//            let metadataObject = metadataObjects.first,
//            let readableObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
//            let detectedBarcode = readableObject.stringValue {
//            
//            // Provide haptic feedback when the barcode scanning view controller detects a barcode.
//            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            
//            // Display the recognized barcode string as UI feedback.
//            var barcodeBounds = CGRect(origin: previewLayer.position, size: .zero)
//            var barcodeCorners = readableObject.corners
//            if !barcodeCorners.isEmpty {
//                let barcodePath = UIBezierPath()
//                let firstCorner = barcodeCorners.removeFirst()
//                barcodePath.move(to: firstCorner)
//                for corner in barcodeCorners {
//                    barcodePath.addLine(to: corner)
//                }
//                barcodePath.close()
//                barcodeBounds = barcodePath.bounds
//                
//                addAnimatedBarcodeShape(with: barcodePath, to: previewLayer)
//            }
//            showLabel(for: detectedBarcode, avoiding: barcodeBounds)
//            
//            // Remember the recognized barcode string.
//            self.detectedBarcode = detectedBarcode
//        }
//    }
//    
//    // MARK: - Display detected barcode
//    
//    /// Highlights the recognized barcode.
//    private func addAnimatedBarcodeShape(with barcodePath: UIBezierPath, to parentLayer: CALayer) {
//        let barcodeShapeLayer = CAShapeLayer()
//        barcodeShapeLayer.path = barcodePath.cgPath
//        barcodeShapeLayer.strokeColor = view.tintColor.cgColor
//        barcodeShapeLayer.lineWidth = 3.0
//        barcodeShapeLayer.lineJoin = .round
//        barcodeShapeLayer.lineCap = .round
//        
//        let barcodeBounds = barcodePath.bounds
//        barcodeShapeLayer.bounds = barcodeBounds
//        barcodeShapeLayer.position = CGPoint(x: barcodeBounds.midX, y: barcodeBounds.midY)
//        barcodeShapeLayer.masksToBounds = true
//        parentLayer.addSublayer(barcodeShapeLayer)
//        
//        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
//        opacityAnimation.autoreverses = true
//        opacityAnimation.duration = 0.3
//        opacityAnimation.repeatCount = 5
//        opacityAnimation.toValue = 0.0
//        barcodeShapeLayer.add(opacityAnimation, forKey: opacityAnimation.keyPath)
//    }
//    
//    /// Shows the recognized barcode string.
//    private func showLabel(for detectedBarcode: String, avoiding barcodeBounds: CGRect) {
//        let fontSize = 32.0
//        let cornerRadius = 8.0
//        
//        let label = UILabel()
//        label.text = detectedBarcode
//        label.font = .systemFont(ofSize: fontSize, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .label
//        label.sizeToFit()
//        
//        let labelContainer = UIView()
//        labelContainer.backgroundColor = .systemBackground.withAlphaComponent(0.6)
//        labelContainer.layer.cornerRadius = cornerRadius
//        labelContainer.bounds = CGRect(origin: .zero, size: label.bounds.insetBy(dx: -cornerRadius, dy: -cornerRadius).size)
//        label.center = CGPoint(x: labelContainer.bounds.midX, y: labelContainer.bounds.midY)
//        labelContainer.addSubview(label)
//        
//        let parentViewBounds = view.bounds
//        let normalizedVerticalOffset = (barcodeBounds.midY < parentViewBounds.midY) ? 0.80 : 0.20
//        let verticalOffset = parentViewBounds.minY + ((parentViewBounds.maxY - parentViewBounds.minY) * normalizedVerticalOffset)
//        labelContainer.center = CGPoint(x: parentViewBounds.midX, y: verticalOffset)
//        
//        let scale = 0.01
//        labelContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
//        view.addSubview(labelContainer)
//        
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: []) {
//            labelContainer.transform = .identity
//        }
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//A cell view for lists of `Album` items.
//*/
//
//import MusicKit
//import SwiftUI
//
///// `AlbumCell` is a view to use in a SwiftUI `List` to represent an `Album`.
//struct AlbumCell: View {
//    
//    // MARK: - Object lifecycle
//    
//    init(_ album: Album) {
//        self.album = album
//    }
//    
//    // MARK: - Properties
//    
//    let album: Album
//    
//    // MARK: - View
//    
//    var body: some View {
//        NavigationLink(destination: AlbumDetailView(album)) {
//            MusicItemCell(
//                artwork: album.artwork,
//                title: album.title,
//                subtitle: album.artistName
//            )
//        }
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//A cell view for lists of `Track` items.
//*/
//
//import MusicKit
//import SwiftUI
//
///// `TrackCell` is a view to use in a SwiftUI `List` to represent a `Track`.
//struct TrackCell: View {
//    
//    // MARK: - Object lifecycle
//    
//    init(_ track: Track, from album: Album, action: @escaping () -> Void) {
//        self.track = track
//        self.album = album
//        self.action = action
//    }
//    
//    // MARK: - Properties
//    
//    let track: Track
//    let album: Album
//    let action: () -> Void
//    
//    private var subtitle: String {
//        var subtitle = ""
//        if track.artistName != album.artistName {
//            subtitle = track.artistName
//        }
//        return subtitle
//    }
//    
//    // MARK: - View
//    
//    var body: some View {
//        Button(action: action) {
//            MusicItemCell(
//                artwork: nil,
//                title: track.title,
//                subtitle: subtitle
//            )
//            .frame(minHeight: 50)
//        }
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//A cell view for lists of music items.
//*/
//
//import MusicKit
//import SwiftUI
//
///// `MusicItemCell` is a view to use in a SwiftUI `List` to represent a `MusicItem`.
//struct MusicItemCell: View {
//    
//    // MARK: - Properties
//    
//    let artwork: Artwork?
//    let title: String
//    let subtitle: String
//    
//    // MARK: - View
//    
//    var body: some View {
//        HStack {
//            if let existingArtwork = artwork {
//                VStack {
//                    Spacer()
//                    ArtworkImage(existingArtwork, width: 56)
//                        .cornerRadius(6)
//                    Spacer()
//                }
//            }
//            VStack(alignment: .leading) {
//                Text(title)
//                    .lineLimit(1)
//                    .foregroundColor(.primary)
//                if !subtitle.isEmpty {
//                    Text(subtitle)
//                        .lineLimit(1)
//                        .foregroundColor(.secondary)
//                        .padding(.top, -4.0)
//                }
//            }
//        }
//    }
//}
//
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//A custom button style for prominent buttons that the app displays.
//*/
//
//import SwiftUI
//
///// `ProminentButtonStyle` is a custom button style that encapsulates
///// all the common modifiers for prominent buttons that the app displays.
//struct ProminentButtonStyle: ButtonStyle {
//    
//    /// The color scheme of the environment.
//    @Environment(\.colorScheme) private var colorScheme: ColorScheme
//    
//    /// Applies relevant modifiers for this button style.
//    func makeBody(configuration: Self.Configuration) -> some View {
//        configuration.label
//            .font(.title3.bold())
//            .foregroundColor(.accentColor)
//            .padding()
//            .background(backgroundColor.cornerRadius(8))
//    }
//    
//    /// The background color appropriate for the current color scheme.
//    private var backgroundColor: Color {
//        return Color(uiColor: (colorScheme == .dark) ? .secondarySystemBackground : .systemBackground)
//    }
//}
//
//// MARK: - Button style extension
//
///// An extension that offers more convenient and idiomatic syntax to apply
///// the prominent button style to a button.
//extension ButtonStyle where Self == ProminentButtonStyle {
//    
//    /// A button style that encapsulates all the common modifiers
//    /// for prominent buttons shown in the UI.
//    static var prominent: ProminentButtonStyle {
//        ProminentButtonStyle()
//    }
//}
//
//
///*
//See LICENSE folder for this sample’s licensing information.
//
//Abstract:
//Persistent information about recently viewed albums.
//*/
//
//import Combine
//import Foundation
//import MusicKit
//
///// `RecentAlbumsStorage` allows storing persistent information about recently viewed albums.
///// It also offers a convenient way to observe those recently viewed albums.
//class RecentAlbumsStorage: ObservableObject {
//    
//    // MARK: - Object lifecycle
//    
//    /// The shared instance of `RecentAlbumsStorage`.
//    static let shared = RecentAlbumsStorage()
//    
//    // MARK: - Properties
//    
//    /// A collection of recently viewed albums.
//    @Published var recentlyViewedAlbums: MusicItemCollection<Album> = []
//    
//    /// The `UserDefaults` key for persisting recently viewed album identifiers.
//    private let recentlyViewedAlbumIdentifiersKey = "recently-viewed-albums-identifiers"
//    
//    /// The maximum number of recently viewed albums that the storage object can persist to `UserDefaults`.
//    private let maximumNumberOfRecentlyViewedAlbums = 10
//    
//    /// Retrieves recently viewed album identifiers from `UserDefaults`.
//    private var recentlyViewedAlbumIDs: [MusicItemID] {
//        get {
//            let rawRecentlyViewedAlbumIdentifiers = UserDefaults.standard.array(forKey: recentlyViewedAlbumIdentifiersKey) ?? []
//            let recentlyViewedAlbumIDs = rawRecentlyViewedAlbumIdentifiers.compactMap { identifier -> MusicItemID? in
//                var itemID: MusicItemID?
//                if let stringIdentifier = identifier as? String {
//                    itemID = MusicItemID(stringIdentifier)
//                }
//                return itemID
//            }
//            return recentlyViewedAlbumIDs
//        }
//        set {
//            UserDefaults.standard.set(newValue.map(\.rawValue), forKey: recentlyViewedAlbumIdentifiersKey)
//            loadRecentlyViewedAlbums()
//        }
//    }
//    
//    /// Observer of changes to the current MusicKit authorization status.
//    private var musicAuthorizationStatusObserver: AnyCancellable?
//    
//    // MARK: - Methods
//    
//    /// Begins observing MusicKit authorization status.
//    func beginObservingMusicAuthorizationStatus() {
//        musicAuthorizationStatusObserver = WelcomeView.PresentationCoordinator.shared.$musicAuthorizationStatus
//            .filter { authorizationStatus in
//                return (authorizationStatus == .authorized)
//            }
//            .sink { [weak self] _ in
//                self?.loadRecentlyViewedAlbums()
//            }
//    }
//    
//    /// Clears recently viewed album identifiers from `UserDefaults`.
//    func reset() {
//        self.recentlyViewedAlbumIDs = []
//    }
//    
//    /// Adds an album to the viewed album identifiers in `UserDefaults`.
//    func update(with recentlyViewedAlbum: Album) {
//        var recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
//        if let index = recentlyViewedAlbumIDs.firstIndex(of: recentlyViewedAlbum.id) {
//            recentlyViewedAlbumIDs.remove(at: index)
//        }
//        recentlyViewedAlbumIDs.insert(recentlyViewedAlbum.id, at: 0)
//        while recentlyViewedAlbumIDs.count > maximumNumberOfRecentlyViewedAlbums {
//            recentlyViewedAlbumIDs.removeLast()
//        }
//        self.recentlyViewedAlbumIDs = recentlyViewedAlbumIDs
//    }
//    
//    /// Updates the recently viewed albums when MusicKit authorization status changes.
//    private func loadRecentlyViewedAlbums() {
//        let recentlyViewedAlbumIDs = self.recentlyViewedAlbumIDs
//        if recentlyViewedAlbumIDs.isEmpty {
//            self.recentlyViewedAlbums = []
//        } else {
//            Task {
//                do {
//                    let albumsRequest = MusicCatalogResourceRequest<Album>(matching: \.id, memberOf: recentlyViewedAlbumIDs)
//                    let albumsResponse = try await albumsRequest.response()
//                    await self.updateRecentlyViewedAlbums(albumsResponse.items)
//                } catch {
//                    print("Failed to load albums for recently viewed album IDs: \(recentlyViewedAlbumIDs)")
//                }
//            }
//        }
//        
//    }
//    
//    /// Safely changes `recentlyViewedAlbums` on the main thread.
//    @MainActor
//    private func updateRecentlyViewedAlbums(_ recentlyViewedAlbums: MusicItemCollection<Album>) {
//        self.recentlyViewedAlbums = recentlyViewedAlbums
//    }
//}
//
///// Constructs a gradient to use as the view background.
//var gradient: some View {
//    LinearGradient(
//        gradient: Gradient(colors: [
//                        // Lighter Gold/Orange
//                        Color(red: 240.0 / 255.0, green: 190.0 / 255.0, blue: 70.0 / 255.0), // Lighter Goldenrod tone
//                        // Medium Gold/Orange
//                        Color(red: 218.0 / 255.0, green: 165.0 / 255.0, blue: 32.0 / 255.0),  // Goldenrod (Hex: #DAA520)
//                        // Dark Gold/Brownish
//                        Color(red: 180.0 / 255.0, green: 120.0 / 255.0, blue: 20.0 / 255.0)  // Darker orange/brown gold
//                    ]),
//        startPoint: .leading,
//        endPoint: .trailing
//    )
//    .flipsForRightToLeftLayoutDirection(false)
//    .ignoresSafeArea()
//}
