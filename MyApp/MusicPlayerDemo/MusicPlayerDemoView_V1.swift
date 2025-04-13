////
////  MusicPlayerDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import MusicKit // Import MusicKit for context, though we use mock data
//
//// --- Mock Data Structures (Simulating MusicKit Items/State) ---
//
//struct MockQueueEntry: Identifiable, Equatable, Hashable {
//    let id = UUID().uuidString // Simulate MusicPlayer.Queue.Entry.id
//    var title: String
//    var subtitle: String?
//    var artworkColor: Color // Simulate Artwork using a color placeholder
//    var itemType: String // Simulate MusicPlayer.Queue.Entry.Item type
//
//    static func == (lhs: MockQueueEntry, rhs: MockQueueEntry) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
//// Simulates the observable state of a MusicPlayer
//class MockPlayerState: ObservableObject {
//    @Published var playbackStatus: MusicPlayer.PlaybackStatus = .stopped
//    @Published var playbackRate: Float = 1.0
//    @Published var repeatMode: MusicPlayer.RepeatMode? = Optional.none
//    @Published var shuffleMode: MusicPlayer.ShuffleMode? = .off
//    @Published var audioVariant: AudioVariant? = .lossyStereo
//    @Published var playbackTime: TimeInterval = 0.0
//    @Published var currentEntryId: String?
//
//    // Specific to ApplicationMusicPlayer conceptually
//    //@Published var transition: MusicPlayer.Transition = .none
//}
//
//// --- View Model (Holding Mock States and Queues) ---
//
//@MainActor
//class PlayerRepresentationViewModel: ObservableObject {
//    @Published var appPlayerState = MockPlayerState()
//    @Published var systemPlayerState = MockPlayerState()
//
//    @Published var appQueue: [MockQueueEntry] = [
//        MockQueueEntry(title: "App Track 1 (Song)", subtitle: "Artist A", artworkColor: .blue, itemType: "Song"),
//        MockQueueEntry(title: "App Track 2 (Video)", subtitle: "Artist B", artworkColor: .green, itemType: "MusicVideo"),
//        MockQueueEntry(title: "App Track 3 (Song)", subtitle: "Artist A", artworkColor: .orange, itemType: "Song")
//    ]
//
//    @Published var systemQueue: [MockQueueEntry] = [
//        MockQueueEntry(title: "System Track 1 (Song)", subtitle: "Artist C", artworkColor: .purple, itemType: "Song"),
//        MockQueueEntry(title: "System Track 2 (Song)", subtitle: "Artist D", artworkColor: .red, itemType: "Song")
//    ]
//
//    init() {
//        // Set initial mock states
//        appPlayerState.playbackStatus = .playing
//        appPlayerState.repeatMode = .all
//        appPlayerState.shuffleMode = .songs
//        appPlayerState.playbackTime = 35.2
//        appPlayerState.currentEntryId = appQueue.first?.id
//      //  appPlayerState.transition = .crossfade(options: .init(duration: 5.0)) // Example transition
//
//        systemPlayerState.playbackStatus = .paused
//        systemPlayerState.repeatMode = MusicPlayer.RepeatMode.none
//        systemPlayerState.shuffleMode = .off
//        systemPlayerState.playbackTime = 120.5
//        systemPlayerState.currentEntryId = systemQueue.first?.id
//    }
//
//    // --- Mock Actions (Simulating Player Control Methods) ---
//    func togglePlayPause(for playerState: MockPlayerState) {
//        if playerState.playbackStatus == .playing {
//            playerState.playbackStatus = .paused
//        } else {
//            playerState.playbackStatus = .playing
//        }
//    }
//
//    func skipToNext(for playerState: MockPlayerState, queue: [MockQueueEntry]) {
//        guard let currentId = playerState.currentEntryId,
//              let currentIndex = queue.firstIndex(where: { $0.id == currentId }),
//              currentIndex + 1 < queue.count else {
//            playerState.playbackStatus = .stopped // Reached end
//            playerState.currentEntryId = nil
//            playerState.playbackTime = 0
//            return
//        }
//        playerState.currentEntryId = queue[currentIndex + 1].id
//        playerState.playbackTime = 0
//        playerState.playbackStatus = .playing // Assume play continues
//    }
//
//    func skipToPrevious(for playerState: MockPlayerState, queue: [MockQueueEntry]) {
//         guard let currentId = playerState.currentEntryId,
//               let currentIndex = queue.firstIndex(where: { $0.id == currentId }),
//               currentIndex > 0 else {
//             playerState.playbackTime = 0 // Restart first track if at beginning
//             playerState.playbackStatus = .playing // Assume play continues
//             return
//         }
//         playerState.currentEntryId = queue[currentIndex - 1].id
//         playerState.playbackTime = 0
//         playerState.playbackStatus = .playing // Assume play continues
//     }
//
//    func toggleRepeatMode(for playerState: MockPlayerState) {
//        switch playerState.repeatMode {
//        case .none?: playerState.repeatMode = .one
//        case .one: playerState.repeatMode = .all
//        case .all: playerState.repeatMode = MusicPlayer.RepeatMode.none
//        case .some(_): playerState.repeatMode = Optional.none // Should not happen
//        case nil: playerState.repeatMode = .one // Default if nil
//        }
//    }
//
//     func toggleShuffleMode(for playerState: MockPlayerState) {
//         switch playerState.shuffleMode {
//         case .off: playerState.shuffleMode = .songs
//         case .songs: playerState.shuffleMode = .off
//         case .some(_): playerState.shuffleMode = .off // Should not happen
//         case nil: playerState.shuffleMode = .songs // Default if nil
//         }
//     }
//
//    func addMockEntry(to queueType: PlayerType) {
//        let newEntry = MockQueueEntry(title: "New Track (\(Int.random(in: 1..<100)))", subtitle: "Some Artist", artworkColor: [.pink, .indigo, .teal].randomElement()!, itemType: "Song")
//        switch queueType {
//        case .application:
//            appQueue.append(newEntry)
//        case .system:
//            systemQueue.append(newEntry)
//        }
//    }
//
//    enum PlayerType { case application, system }
//}
//
//// --- UI Components ---
//
//// Represents a single entry in the player queue UI
//struct QueueEntryView: View {
//    let entry: MockQueueEntry
//    let isCurrent: Bool
//
//    var body: some View {
//        HStack {
//            // Simulate Artwork
//            RoundedRectangle(cornerRadius: 4)
//                .fill(entry.artworkColor)
//                .frame(width: 40, height: 40)
//                .overlay(
//                    Image(systemName: entry.itemType == "Song" ? "music.note" : "video.fill")
//                        .foregroundColor(.white.opacity(0.8))
//                )
//
//            VStack(alignment: .leading) {
//                Text(entry.title)
//                    .font(.headline)
//                    .lineLimit(1)
//                if let subtitle = entry.subtitle {
//                    Text(subtitle)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                }
//            }
//
//            Spacer()
//
//            if isCurrent {
//                // Indicate current playing item
//                Image(systemName: "waveform")
//                    .foregroundColor(.accentColor)
//            }
//        }
//        .padding(.vertical, 4)
//         // Highlight the current entry slightly
//        .background(isCurrent ? Color.secondary.opacity(0.1) : Color.clear)
//        .cornerRadius(isCurrent ? 5 : 0)
//    }
//}
//
//// Displays the current state of the player (status, repeat, shuffle, etc.)
//@available(iOS 18.0, *)
//struct PlayerStateView: View {
//    @ObservedObject var playerState: MockPlayerState
//    var isApplicationPlayer: Bool = false // Flag for showing app-specific state
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("Status:")
//                Text(statusText(playerState.playbackStatus))
//                    .fontWeight(.semibold)
//                Spacer()
//                Image(systemName: statusIcon(playerState.playbackStatus))
//                    .foregroundColor(statusColor(playerState.playbackStatus))
//            }
//
//            HStack {
//                Text("Time:")
//                Text(formatTimeInterval(playerState.playbackTime))
//                Spacer()
//                Text("Rate: \(String(format: "%.1fx", playerState.playbackRate))")
//            }
//
//            HStack {
//                Text("Repeat:")
//                Text(repeatModeText(playerState.repeatMode))
//                Image(systemName: repeatModeIcon(playerState.repeatMode))
//                    .foregroundColor(.secondary)
//                Spacer()
//                Text("Shuffle:")
//                Text(shuffleModeText(playerState.shuffleMode))
//                Image(systemName: shuffleModeIcon(playerState.shuffleMode))
//                    .foregroundColor(.secondary)
//            }
//
//             HStack {
//                Text("Audio Variant:")
//                Text(audioVariantText(playerState.audioVariant))
//                Image(systemName: audioVariantIcon(playerState.audioVariant))
//                    .foregroundColor(.secondary)
//             }
//
//
//            if isApplicationPlayer {
//                HStack {
//                    Text("Transition:")
////                    Text(transitionText(playerState.transition))
////                        .lineLimit(1)
//                    Image(systemName: "arrow.left.arrow.right")
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//        .font(.caption)
//        .padding(.bottom, 5)
//    }
//
//    // Helper functions for display text and icons
//    private func formatTimeInterval(_ interval: TimeInterval) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = .pad
//        return formatter.string(from: interval) ?? "0:00"
//    }
//
//    private func statusText(_ status: MusicPlayer.PlaybackStatus) -> String {
//        switch status {
//        case .stopped: return "Stopped"
//        case .playing: return "Playing"
//        case .paused: return "Paused"
//        case .interrupted: return "Interrupted"
//        case .seekingForward: return "Seeking Fwd"
//        case .seekingBackward: return "Seeking Bwd"
//        @unknown default: return "Unknown"
//        }
//    }
//
//     private func statusIcon(_ status: MusicPlayer.PlaybackStatus) -> String {
//        switch status {
//        case .stopped: return "stop.fill"
//        case .playing: return "play.fill"
//        case .paused: return "pause.fill"
//        case .interrupted: return "exclamationmark.circle.fill"
//        case .seekingForward: return "forward.fill"
//        case .seekingBackward: return "backward.fill"
//        @unknown default: return "questionmark.circle.fill"
//        }
//    }
//
//     private func statusColor(_ status: MusicPlayer.PlaybackStatus) -> Color {
//        switch status {
//        case .playing: return .green
//        case .paused: return .orange
//        case .interrupted: return .red
//        case .stopped: return .gray
//        default: return .secondary
//        }
//    }
//
//    private func repeatModeText(_ mode: MusicPlayer.RepeatMode?) -> String {
//        switch mode {
//        case nil: return "Off"
//        case .one: return "One"
//        case .all: return "All"
//        default: return "N/A"
//        }
//    }
//
//    private func repeatModeIcon(_ mode: MusicPlayer.RepeatMode?) -> String {
//        switch mode {
//        case nil: return "repeat"
//        case .one: return "repeat.1"
//        case .all: return "repeat"
//        default: return "repeat"
//        }
//    }
//
//    private func shuffleModeText(_ mode: MusicPlayer.ShuffleMode?) -> String {
//        switch mode {
//        case .off?: return "Off"
//        case .songs?: return "Songs"
//        default: return "N/A"
//        }
//    }
//
//     private func shuffleModeIcon(_ mode: MusicPlayer.ShuffleMode?) -> String {
//         return mode == .songs ? "shuffle.circle.fill" : "shuffle"
//     }
//
//     private func audioVariantText(_ variant: AudioVariant?) -> String {
//        switch variant {
//        case .dolbyAtmos: return "Dolby Atmos"
//        case .dolbyAudio: return "Dolby Audio"
//        case .lossless: return "Lossless"
//        case .highResolutionLossless: return "Hi-Res Lossless"
//        case .lossyStereo: return "Stereo"
//        case .spatialAudio: return "Spatial"
//        default: return "N/A"
//        }
//    }
//
//    private func audioVariantIcon(_ variant: AudioVariant?) -> String {
//        switch variant {
//        case .dolbyAtmos, .dolbyAudio, .spatialAudio: return "speaker.wave.3.fill"
//        case .lossless, .highResolutionLossless: return "waveform.path.ecg.rectangle.fill"
//        default: return "hifispeaker.fill"
//        }
//    }
//
//    private func transitionText(_ transition: MusicPlayer.Transition) -> String {
//        switch transition {
//        case .none:
//            return "None"
//        case .crossfade(let options):
//            print(options)
////            if let duration = options.duration {
////                return "Crossfade (\(String(format: "%.1fs", duration)))"
////            } else {
////                return "Crossfade (Default)"
////            }
//            return "Crossfade (Default)"
//        @unknown default:
//            return "Unknown"
//        }
//    }
//}
//
//// Represents the standard player controls
//struct PlayerControlsView: View {
//    @ObservedObject var playerState: MockPlayerState
//    var onPlayPause: () -> Void
//    var onSkipPrevious: () -> Void
//    var onSkipNext: () -> Void
//    var onToggleRepeat: () -> Void
//    var onToggleShuffle: () -> Void
//
//    var body: some View {
//        HStack(spacing: 20) {
//            Button(action: onToggleRepeat) {
//                Image(systemName: repeatModeIcon(playerState.repeatMode))
//                    .foregroundColor(playerState.repeatMode != Optional.none ? .accentColor : .secondary)
//            }
//
//            Spacer()
//
//            Button(action: onSkipPrevious) {
//                Image(systemName: "backward.fill")
//            }
//            .font(.title2)
//
//            Button(action: onPlayPause) {
//                Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
//                    .font(.largeTitle) // Make play/pause prominent
//            }
//
//            Button(action: onSkipNext) {
//                Image(systemName: "forward.fill")
//            }
//            .font(.title2)
//
//            Spacer()
//
//             Button(action: onToggleShuffle) {
//                 Image(systemName: shuffleModeIcon(playerState.shuffleMode))
//                     .foregroundColor(playerState.shuffleMode == .songs ? .accentColor : .secondary)
//             }
//        }
//        .buttonStyle(.plain) // Use plain style for better icon rendering control
//        .padding(.vertical)
//    }
//
//     // Duplicated icon helpers for local use within controls if needed, or use injected state
//     private func repeatModeIcon(_ mode: MusicPlayer.RepeatMode?) -> String {
//         switch mode {
//         case nil: return "repeat"
//         case .one: return "repeat.1"
//         case .all: return "repeat.circle.fill" // Fill when active?
//         default: return "repeat"
//         }
//     }
//
//     private func shuffleModeIcon(_ mode: MusicPlayer.ShuffleMode?) -> String {
//         return mode == .songs ? "shuffle.circle.fill" : "shuffle"
//     }
//}
//
//// --- Player Views (Application & System) ---
//
//struct PlayerView<QueueEntries: RandomAccessCollection>: View where QueueEntries.Element == MockQueueEntry {
//    let title: String
//    @ObservedObject var playerState: MockPlayerState
//    let queue: QueueEntries
//    let isApplicationPlayer: Bool // Differentiate for specific features if needed
//
//    var onPlayPause: () -> Void
//    var onSkipPrevious: () -> Void
//    var onSkipNext: () -> Void
//    var onToggleRepeat: () -> Void
//    var onToggleShuffle: () -> Void
//    var onAddEntry: () -> Void
//
//
//    var body: some View {
//        GroupBox {
//            VStack(alignment: .leading) {
//                // State Display
//                PlayerStateView(playerState: playerState, isApplicationPlayer: isApplicationPlayer)
//
//                Divider()
//
//                // Controls
//                 PlayerControlsView(
//                    playerState: playerState,
//                    onPlayPause: onPlayPause,
//                    onSkipPrevious: onSkipPrevious,
//                    onSkipNext: onSkipNext,
//                    onToggleRepeat: onToggleRepeat,
//                    onToggleShuffle: onToggleShuffle
//                 )
//
//                Divider()
//
//                // Queue Display
//                HStack {
//                   Text("Queue (\(queue.count))")
//                       .font(.headline)
//                   Spacer()
//                   // Add a button to simulate adding to the queue (conceptually insert)
//                   Button {
//                       onAddEntry()
//                   } label: {
//                       Image(systemName: "plus.circle")
//                   }
//                   .buttonStyle(.plain)
//                }
//
//                // Use ScrollView for potentially long queues
//                ScrollViewReader { proxy in
//                    ScrollView(.vertical) {
//                         LazyVStack { // Use LazyVStack for performance
//                            ForEach(queue) { entry in
//                                QueueEntryView(entry: entry, isCurrent: entry.id == playerState.currentEntryId)
//                                    .id(entry.id) // ID for ScrollViewReader
//                             }
//                         }
//                         .padding(.trailing, 1) // Prevent scroll indicator overlap minorly
//                    }
//                    .frame(maxHeight: 200) // Limit queue display height
//                    .onChange(of: playerState.currentEntryId) {
//                        let newId = playerState.currentEntryId
//                         // Scroll to the current item when it changes
//                         withAnimation {
//                             proxy.scrollTo(newId, anchor: .center)
//                         }
//                    }
//                    .onAppear {
//                        // Scroll initially if needed
//                        if let currentId = playerState.currentEntryId {
//                           proxy.scrollTo(currentId, anchor: .center)
//                        }
//                    }
//                }
//            }
//        } label: {
//            Label(title, systemImage: isApplicationPlayer ? "app.badge" : "music.note.tv")
//                .font(.title2)
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//
//// --- Main View Combining Player Representations ---
//
//struct MusicPlayerRepresentationView: View {
//    @StateObject private var viewModel = PlayerRepresentationViewModel()
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Application Music Player Representation
//                     PlayerView(
//                        title: "Application Music Player",
//                        playerState: viewModel.appPlayerState,
//                        queue: viewModel.appQueue,
//                        isApplicationPlayer: true,
//                        onPlayPause: { viewModel.togglePlayPause(for: viewModel.appPlayerState) },
//                        onSkipPrevious: { viewModel.skipToPrevious(for: viewModel.appPlayerState, queue: viewModel.appQueue) },
//                        onSkipNext: { viewModel.skipToNext(for: viewModel.appPlayerState, queue: viewModel.appQueue) },
//                        onToggleRepeat: { viewModel.toggleRepeatMode(for: viewModel.appPlayerState) },
//                        onToggleShuffle: { viewModel.toggleShuffleMode(for: viewModel.appPlayerState) },
//                        onAddEntry: { viewModel.addMockEntry(to: .application) }
//                     )
//
//                    // System Music Player Representation
//                    PlayerView(
//                       title: "System Music Player",
//                       playerState: viewModel.systemPlayerState,
//                       queue: viewModel.systemQueue,
//                       isApplicationPlayer: false,
//                       onPlayPause: { viewModel.togglePlayPause(for: viewModel.systemPlayerState) },
//                       onSkipPrevious: { viewModel.skipToPrevious(for: viewModel.systemPlayerState, queue: viewModel.systemQueue) },
//                       onSkipNext: { viewModel.skipToNext(for: viewModel.systemPlayerState, queue: viewModel.systemQueue) },
//                       onToggleRepeat: { viewModel.toggleRepeatMode(for: viewModel.systemPlayerState) },
//                       onToggleShuffle: { viewModel.toggleShuffleMode(for: viewModel.systemPlayerState) },
//                       onAddEntry: { viewModel.addMockEntry(to: .system) }
//                    )
//
//                    Spacer() // Push content up if ScrollView is not full
//                }
//                .padding()
//            }
//            .navigationTitle("Music Player Concepts")
//        }
//        // Apply a basic style for better presentation if used in an app
//        // .navigationViewStyle(.stack) // Example for iOS
//    }
//}
//
//// --- Preview Provider ---
//
//struct MusicPlayerRepresentationView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerRepresentationView()
//    }
//}
//
//// --- Extensions for related types (for completeness in representation) ---
//
//// Add minimal conformance representation based on documentation/diagram
//extension MusicPlayer.Queue.Entry.Item: MusicPropertyContainer {}
////extension MusicPlayer.Queue.Entry.Item: PlayableMusicItem {
////    // playParameters is already included conceptually via the enum definition
////}
//
//// Note: Codable conformance is complex for enums with associated values
//// and protocols. This representation focuses on UI aspects.
//
//// Similarly, represent protocol conformances mentioned in the docs, though
//// these don't directly impact the UI representation itself.
////@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
////@available(watchOS, unavailable)
////extension ApplicationMusicPlayer.Queue: Equatable {}
////@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
////@available(watchOS, unavailable)
////extension ApplicationMusicPlayer.Queue: Hashable {}
//
////// Add Transition & CrossfadeOptions struct definitions as per diagram/docs
////@available(iOS 18.0, *) // Use appropriate availability if needed
////@available(macOS, unavailable)
////@available(macCatalyst, unavailable)
////@available(tvOS, unavailable)
////@available(watchOS, unavailable)
////@available(visionOS, unavailable)
////extension MusicPlayer {
////    /// The transition applied between playing items.
////    public enum Transition : Equatable, Hashable, Sendable {
////        case none
////        case crossfade(options: MusicPlayer.Transition.CrossfadeOptions)
////
////        public static let crossfade: MusicPlayer.Transition = .crossfade(options: .init())
////
////        public static func crossfade(duration: TimeInterval?) -> MusicPlayer.Transition {
////            .crossfade(options: .init(duration: duration))
////        }
////
////        /// The options for the crossfade transition.
////        public struct CrossfadeOptions : Equatable, Hashable, Sendable {
////            public var duration: TimeInterval?
////
////            /// Creates options for a crossfade transition.
////            public init(duration: TimeInterval? = nil) {
////                self.duration = duration
////            }
////        }
////    }
////}
////
////// Add conceptual conformance for ApplicationMusicPlayer.Queue.Entries
////@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
////@available(watchOS, unavailable)
////extension ApplicationMusicPlayer.Queue {
////    // Conceptual representation of Entries struct as seen in docs
////    public struct Entries : Equatable, Hashable, RandomAccessCollection, MutableCollection, RangeReplaceableCollection, ExpressibleByArrayLiteral {
////       // This would typically wrap an Array<MusicPlayer.Queue.Entry>
////       // For this representation, we don't need the full implementation,
////       // knowing it behaves like a collection is sufficient.
////       public typealias Element = MusicPlayer.Queue.Entry
////       public typealias Index = Int // Simplification for representation
////       public typealias SubSequence = Slice<Entries>
////       public typealias Indices = Range<Int>
////
////       private var storage: [Element] = [] // Internal storage simulation
////
////       public var startIndex: Index { storage.startIndex }
////       public var endIndex: Index { storage.endIndex }
////
////       public subscript(position: Index) -> Element {
////           get { storage[position] }
////           set { storage[position] = newValue }
////       }
////
////       public func index(after i: Index) -> Index { storage.index(after: i) }
////       public func index(before i: Index) -> Index { storage.index(before: i) }
////
////       public init() { self.storage = [] }
////       public init(arrayLiteral elements: Element...) { self.storage = elements }
////        // Add required init/methods for RangeReplaceableCollection if needed for compilation
////       public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where
