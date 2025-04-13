//
//  MusicPlayerDemoView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import MusicKit // Import MusicKit for context, though we use mock data

// --- Mock Data Structures (Simulating MusicKit Items/State) ---

struct MockQueueEntry: Identifiable, Equatable, Hashable {
    let id = UUID().uuidString // Simulate MusicPlayer.Queue.Entry.id
    var title: String
    var subtitle: String?
    var artworkColor: Color // Simulate Artwork using a color placeholder
    var itemType: String // Simulate MusicPlayer.Queue.Entry.Item type

    static func == (lhs: MockQueueEntry, rhs: MockQueueEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Simulates the observable state of a MusicPlayer
class MockPlayerState: ObservableObject {
    @Published var playbackStatus: MusicPlayer.PlaybackStatus = .stopped
    @Published var playbackRate: Float = 1.0
    @Published var repeatMode: MusicPlayer.RepeatMode? = .none
    @Published var shuffleMode: MusicPlayer.ShuffleMode? = .off
   // @Published var audioVariant: AudioVariant? = .lossyStereo // Using actual MusicKit enum for type safety
    @Published var playbackTime: TimeInterval = 0.0
    @Published var currentEntryId: String?

    // Specific to ApplicationMusicPlayer conceptually
    @Published var transition: MusicPlayer.Transition = .none
}

// --- View Model (Holding Mock States and Queues) ---

@MainActor
class PlayerRepresentationViewModel: ObservableObject {
    @Published var appPlayerState = MockPlayerState()
    @Published var systemPlayerState = MockPlayerState()

    @Published var appQueue: [MockQueueEntry] = [
        MockQueueEntry(title: "App Track 1 (Song)", subtitle: "Artist A", artworkColor: .blue, itemType: "Song"),
        MockQueueEntry(title: "App Track 2 (Video)", subtitle: "Artist B", artworkColor: .green, itemType: "MusicVideo"),
        MockQueueEntry(title: "App Track 3 (Song)", subtitle: "Artist A", artworkColor: .orange, itemType: "Song")
    ]

    @Published var systemQueue: [MockQueueEntry] = [
        MockQueueEntry(title: "System Track 1 (Song)", subtitle: "Artist C", artworkColor: .purple, itemType: "Song"),
        MockQueueEntry(title: "System Track 2 (Song)", subtitle: "Artist D", artworkColor: .red, itemType: "Song")
    ]

    init() {
        // Set initial mock states
        appPlayerState.playbackStatus = .playing
        appPlayerState.repeatMode = .all
        appPlayerState.shuffleMode = .songs
        appPlayerState.playbackTime = 35.2
        appPlayerState.currentEntryId = appQueue.first?.id
        appPlayerState.transition = .crossfade(options: .init(duration: 5.0)) // Example transition

        systemPlayerState.playbackStatus = .paused
        systemPlayerState.repeatMode = .none
        systemPlayerState.shuffleMode = .off
        systemPlayerState.playbackTime = 120.5
        systemPlayerState.currentEntryId = systemQueue.first?.id
    }

    // --- Mock Actions (Simulating Player Control Methods) ---
    func togglePlayPause(for playerState: MockPlayerState) {
        if playerState.playbackStatus == .playing {
            playerState.playbackStatus = .paused
        } else {
            playerState.playbackStatus = .playing
        }
    }

    func skipToNext(for playerState: MockPlayerState, queue: [MockQueueEntry]) {
        guard let currentId = playerState.currentEntryId,
              let currentIndex = queue.firstIndex(where: { $0.id == currentId }),
              currentIndex + 1 < queue.count else {
            playerState.playbackStatus = .stopped // Reached end
            playerState.currentEntryId = nil
            playerState.playbackTime = 0
            return
        }
        playerState.currentEntryId = queue[currentIndex + 1].id
        playerState.playbackTime = 0
        playerState.playbackStatus = .playing // Assume play continues
    }

    func skipToPrevious(for playerState: MockPlayerState, queue: [MockQueueEntry]) {
         guard let currentId = playerState.currentEntryId,
               let currentIndex = queue.firstIndex(where: { $0.id == currentId }),
               currentIndex > 0 else {
             playerState.playbackTime = 0 // Restart first track if at beginning
             playerState.playbackStatus = .playing // Assume play continues
             return
         }
         playerState.currentEntryId = queue[currentIndex - 1].id
         playerState.playbackTime = 0
         playerState.playbackStatus = .playing // Assume play continues
     }

    func toggleRepeatMode(for playerState: MockPlayerState) {
        switch playerState.repeatMode {
        case .none: playerState.repeatMode = .one
        case .one: playerState.repeatMode = .all
        case .all: playerState.repeatMode = .none
        case .some(_): playerState.repeatMode = .none // Should not happen
        case nil: playerState.repeatMode = .one // Default if nil
        }
    }

     func toggleShuffleMode(for playerState: MockPlayerState) {
         switch playerState.shuffleMode {
         case .off: playerState.shuffleMode = .songs
         case .songs: playerState.shuffleMode = .off
         case .some(_): playerState.shuffleMode = .off // Should not happen
         case nil: playerState.shuffleMode = .songs // Default if nil
         }
     }

    func addMockEntry(to queueType: PlayerType) {
        let newEntry = MockQueueEntry(title: "New Track (\(Int.random(in: 1..<100)))", subtitle: "Some Artist", artworkColor: [.pink, .indigo, .teal].randomElement()!, itemType: "Song")
        switch queueType {
        case .application:
            appQueue.append(newEntry)
        case .system:
            systemQueue.append(newEntry)
        }
    }

    enum PlayerType { case application, system }
}

// --- UI Components ---

// Represents a single entry in the player queue UI
struct QueueEntryView: View {
    let entry: MockQueueEntry
    let isCurrent: Bool

    var body: some View {
        HStack {
            // Simulate Artwork
            RoundedRectangle(cornerRadius: 4)
                .fill(entry.artworkColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: entry.itemType == "Song" ? "music.note" : "video.fill")
                        .foregroundColor(.white.opacity(0.8))
                )

            VStack(alignment: .leading) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                if let subtitle = entry.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isCurrent {
                // Indicate current playing item
                Image(systemName: "waveform")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 4)
         // Highlight the current entry slightly
        .background(isCurrent ? Color.secondary.opacity(0.1) : Color.clear)
        .cornerRadius(isCurrent ? 5 : 0)
    }
}

// Displays the current state of the player (status, repeat, shuffle, etc.)
struct PlayerStateView: View {
    @ObservedObject var playerState: MockPlayerState
    var isApplicationPlayer: Bool = false // Flag for showing app-specific state

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Status:")
                Text(statusText(playerState.playbackStatus))
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: statusIcon(playerState.playbackStatus))
                    .foregroundColor(statusColor(playerState.playbackStatus))
            }

            HStack {
                Text("Time:")
                Text(formatTimeInterval(playerState.playbackTime))
                Spacer()
                Text("Rate: \(String(format: "%.1fx", playerState.playbackRate))")
            }

            HStack {
                Text("Repeat:")
                Text(repeatModeText(playerState.repeatMode))
                Image(systemName: repeatModeIcon(playerState.repeatMode))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Shuffle:")
                Text(shuffleModeText(playerState.shuffleMode))
                Image(systemName: shuffleModeIcon(playerState.shuffleMode))
                    .foregroundColor(.secondary)
            }

             HStack {
                Text("Audio Variant:")
//                 Text(audioVariantText($playerState.audioVariant))
//                    .font(.caption2) // Smaller for potentially longer text
//                    .lineLimit(1)
//                Image(systemName: audioVariantIcon(playerState.audioVariant))
//                    .foregroundColor(.secondary)
             }


            if isApplicationPlayer {
                HStack {
                    Text("Transition:")
                    Text(transitionText(playerState.transition))
                        .font(.caption2)
                        .lineLimit(1)
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.caption)
        .padding(.bottom, 5)
    }

    // Helper functions for display text and icons
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "0:00"
    }

    private func statusText(_ status: MusicPlayer.PlaybackStatus) -> String {
        switch status {
        case .stopped: return "Stopped"
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .interrupted: return "Interrupted"
        case .seekingForward: return "Seeking Fwd"
        case .seekingBackward: return "Seeking Bwd"
        @unknown default: return "Unknown"
        }
    }

     private func statusIcon(_ status: MusicPlayer.PlaybackStatus) -> String {
        switch status {
        case .stopped: return "stop.fill"
        case .playing: return "play.fill"
        case .paused: return "pause.fill"
        case .interrupted: return "exclamationmark.circle.fill"
        case .seekingForward: return "forward.fill"
        case .seekingBackward: return "backward.fill"
        @unknown default: return "questionmark.circle.fill"
        }
    }

     private func statusColor(_ status: MusicPlayer.PlaybackStatus) -> Color {
        switch status {
        case .playing: return .green
        case .paused: return .orange
        case .interrupted: return .red
        case .stopped: return .gray
        default: return .secondary
        }
    }

    private func repeatModeText(_ mode: MusicPlayer.RepeatMode?) -> String {
        switch mode {
        case .none: return "Off"
        case .one: return "One"
        case .all: return "All"
        default: return "N/A"
        }
    }

    private func repeatModeIcon(_ mode: MusicPlayer.RepeatMode?) -> String {
        switch mode {
        case .none: return "repeat"
        case .one: return "repeat.1"
        case .all: return "repeat.circle.fill" // Filled icon when active
        default: return "repeat"
        }
    }

    private func shuffleModeText(_ mode: MusicPlayer.ShuffleMode?) -> String {
        switch mode {
        case .off?: return "Off"
        case .songs?: return "Songs"
        default: return "N/A"
        }
    }

     private func shuffleModeIcon(_ mode: MusicPlayer.ShuffleMode?) -> String {
         return mode == .songs ? "shuffle.circle.fill" : "shuffle" // Filled icon when active
     }

     private func audioVariantText(_ variant: AudioVariant?) -> String {
        switch variant {
        case .dolbyAtmos: return "Dolby Atmos"
        case .dolbyAudio: return "Dolby Audio"
        case .lossless: return "Lossless"
        case .highResolutionLossless: return "Hi-Res Lossless"
        case .lossyStereo: return "Stereo"
        case .spatialAudio: return "Spatial"
        default: return "N/A"
        }
    }

    private func audioVariantIcon(_ variant: AudioVariant?) -> String {
        switch variant {
        case .dolbyAtmos, .dolbyAudio, .spatialAudio: return "speaker.wave.3.fill"
        case .lossless, .highResolutionLossless: return "waveform.path.ecg.rectangle.fill"
        default: return "hifispeaker.fill"
        }
    }

    private func transitionText(_ transition: MusicPlayer.Transition) -> String {
        switch transition {
        case .none:
            return "None"
        case .crossfade(let options):
            print(options)
//            if let duration = options.duration {
//                return "Crossfade (\(String(format: "%.1fs", duration)))"
//            } else {
//                return "Crossfade (Default)"
//            }
            return "Crossfade (Default)"
        @unknown default:
            return "Unknown"
        }
    }
}

// Represents the standard player controls
struct PlayerControlsView: View {
    @ObservedObject var playerState: MockPlayerState
    var onPlayPause: () -> Void
    var onSkipPrevious: () -> Void
    var onSkipNext: () -> Void
    var onToggleRepeat: () -> Void
    var onToggleShuffle: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onToggleRepeat) {
                Image(systemName: repeatModeIcon(playerState.repeatMode))
                    .foregroundColor(playerState.repeatMode != .none ? .accentColor : .secondary)
            }

            Spacer()

            Button(action: onSkipPrevious) {
                Image(systemName: "backward.fill")
            }
            .font(.title2)

            Button(action: onPlayPause) {
                Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                    .font(.largeTitle) // Make play/pause prominent
            }

            Button(action: onSkipNext) {
                Image(systemName: "forward.fill")
            }
            .font(.title2)

            Spacer()

             Button(action: onToggleShuffle) {
                 Image(systemName: shuffleModeIcon(playerState.shuffleMode))
                     .foregroundColor(playerState.shuffleMode == .songs ? .accentColor : .secondary)
             }
        }
        .buttonStyle(.plain) // Use plain style for better icon rendering control
        .padding(.vertical)
    }

     // Duplicated icon helpers for local use within controls if needed, or use injected state
     private func repeatModeIcon(_ mode: MusicPlayer.RepeatMode?) -> String {
         switch mode {
         case .none: return "repeat"
         case .one: return "repeat.1"
         case .all: return "repeat.circle.fill" // Use filled icon when active
         default: return "repeat"
         }
     }

     private func shuffleModeIcon(_ mode: MusicPlayer.ShuffleMode?) -> String {
         return mode == .songs ? "shuffle.circle.fill" : "shuffle" // Use filled icon when active
     }
}

// --- Player Views (Application & System) ---

struct PlayerView<QueueEntries: RandomAccessCollection>: View where QueueEntries.Element == MockQueueEntry {
    let title: String
    @ObservedObject var playerState: MockPlayerState
    let queue: QueueEntries
    let isApplicationPlayer: Bool // Differentiate for specific features if needed

    var onPlayPause: () -> Void
    var onSkipPrevious: () -> Void
    var onSkipNext: () -> Void
    var onToggleRepeat: () -> Void
    var onToggleShuffle: () -> Void
    var onAddEntry: () -> Void


    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                // State Display
                PlayerStateView(playerState: playerState, isApplicationPlayer: isApplicationPlayer)

                Divider()

                // Controls
                 PlayerControlsView(
                    playerState: playerState,
                    onPlayPause: onPlayPause,
                    onSkipPrevious: onSkipPrevious,
                    onSkipNext: onSkipNext,
                    onToggleRepeat: onToggleRepeat,
                    onToggleShuffle: onToggleShuffle
                 )

                Divider()

                // Queue Display
                HStack {
                   Text("Queue (\(queue.count))")
                       .font(.headline)
                   Spacer()
                   // Add a button to simulate adding to the queue (conceptually insert)
                   Button {
                       onAddEntry()
                   } label: {
                       Image(systemName: "plus.circle")
                   }
                   .buttonStyle(.plain)
                }

                // Use ScrollView for potentially long queues
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                         LazyVStack { // Use LazyVStack for performance
                            ForEach(queue) { entry in
                                QueueEntryView(entry: entry, isCurrent: entry.id == playerState.currentEntryId)
                                    .id(entry.id) // ID for ScrollViewReader
                             }
                         }
                         .padding(.trailing, 1) // Prevent scroll indicator overlap minorly
                    }
                    .frame(maxHeight: 200) // Limit queue display height
                    .onChange(of: playerState.currentEntryId) { _, newId in // Updated for iOS 17+ style
                         // Scroll to the current item when it changes
                         withAnimation {
                             proxy.scrollTo(newId, anchor: .center)
                         }
                    }
                    .onAppear {
                        // Scroll initially if needed
                        if let currentId = playerState.currentEntryId {
                           proxy.scrollTo(currentId, anchor: .center)
                        }
                    }
                }
            }
        } label: {
            Label(title, systemImage: isApplicationPlayer ? "app.badge" : "music.note.tv")
                .font(.title2)
        }
        .padding(.vertical, 5)
    }
}


// --- Main View Combining Player Representations ---

struct MusicPlayerRepresentationView: View {
    @StateObject private var viewModel = PlayerRepresentationViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Application Music Player Representation
                     PlayerView(
                        title: "Application Music Player",
                        playerState: viewModel.appPlayerState,
                        queue: viewModel.appQueue,
                        isApplicationPlayer: true,
                        onPlayPause: { viewModel.togglePlayPause(for: viewModel.appPlayerState) },
                        onSkipPrevious: { viewModel.skipToPrevious(for: viewModel.appPlayerState, queue: viewModel.appQueue) },
                        onSkipNext: { viewModel.skipToNext(for: viewModel.appPlayerState, queue: viewModel.appQueue) },
                        onToggleRepeat: { viewModel.toggleRepeatMode(for: viewModel.appPlayerState) },
                        onToggleShuffle: { viewModel.toggleShuffleMode(for: viewModel.appPlayerState) },
                        onAddEntry: { viewModel.addMockEntry(to: .application) }
                     )

                    // System Music Player Representation
                    PlayerView(
                       title: "System Music Player",
                       playerState: viewModel.systemPlayerState,
                       queue: viewModel.systemQueue,
                       isApplicationPlayer: false,
                       onPlayPause: { viewModel.togglePlayPause(for: viewModel.systemPlayerState) },
                       onSkipPrevious: { viewModel.skipToPrevious(for: viewModel.systemPlayerState, queue: viewModel.systemQueue) },
                       onSkipNext: { viewModel.skipToNext(for: viewModel.systemPlayerState, queue: viewModel.systemQueue) },
                       onToggleRepeat: { viewModel.toggleRepeatMode(for: viewModel.systemPlayerState) },
                       onToggleShuffle: { viewModel.toggleShuffleMode(for: viewModel.systemPlayerState) },
                       onAddEntry: { viewModel.addMockEntry(to: .system) }
                    )

                    Spacer() // Push content up if ScrollView is not full
                }
                .padding()
            }
            .navigationTitle("Music Player Concepts")
        }
        // Apply a basic style for better presentation if used in an app
         // .navigationViewStyle(.stack) // Example for iOS
         #if os(macOS)
         .frame(minWidth: 400, minHeight: 600) // Example for macOS window size
         #endif
    }
}

// --- Preview Provider ---

struct MusicPlayerRepresentationView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerRepresentationView()
    }
}

// --- Extensions for related types (for completeness in representation) ---
//
//// Add minimal conformance representation based on documentation/diagram
//extension MusicPlayer.Queue.Entry.Item: MusicPropertyContainer {}
//extension MusicPlayer.Queue.Entry.Item: PlayableMusicItem {}
//
//// Note: Codable conformance is complex for enums with associated values
//// and protocols. This representation focuses on UI aspects.
//
//// Similarly, represent protocol conformances mentioned in the docs, though
//// these don't directly impact the UI representation itself.
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//extension ApplicationMusicPlayer.Queue: Equatable {}
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//extension ApplicationMusicPlayer.Queue: Hashable {}
//
//// Add Transition & CrossfadeOptions struct definitions as per diagram/docs
//@available(iOS 18.0, *) // Use appropriate availability if needed
//@available(macOS, unavailable)
//@available(macCatalyst, unavailable)
//@available(tvOS, unavailable)
//@available(watchOS, unavailable)
//@available(visionOS, unavailable)
//extension MusicPlayer {
//    /// The transition applied between playing items.
//    public enum Transition : Equatable, Hashable, Sendable {
//        case none
//        case crossfade(options: MusicPlayer.Transition.CrossfadeOptions)
//
//        public static let crossfade: MusicPlayer.Transition = .crossfade(options: .init())
//
//        public static func crossfade(duration: TimeInterval?) -> MusicPlayer.Transition {
//            .crossfade(options: .init(duration: duration))
//        }
//
//        /// The options for the crossfade transition.
//        public struct CrossfadeOptions : Equatable, Hashable, Sendable {
//            public var duration: TimeInterval?
//
//            /// Creates options for a crossfade transition.
//            public init(duration: TimeInterval? = nil) {
//                self.duration = duration
//            }
//        }
//    }
//}
//
//// Add conceptual conformance for ApplicationMusicPlayer.Queue.Entries
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//extension ApplicationMusicPlayer.Queue {
//    // Conceptual representation of Entries struct as seen in docs
//    // Conforming to relevant collection protocols shown in the docs.
//    public struct Entries : Equatable, Hashable, Sequence, Collection, BidirectionalCollection, RandomAccessCollection, MutableCollection, RangeReplaceableCollection, ExpressibleByArrayLiteral {
//
//        // --- Type Aliases (as per Documentation) ---
//        public typealias Element = MusicPlayer.Queue.Entry
//        public typealias Iterator = Array<MusicPlayer.Queue.Entry>.Iterator // Matching docs
//        public typealias Index = Array<MusicPlayer.Queue.Entry>.Index
//        public typealias SubSequence = Array<MusicPlayer.Queue.Entry>.SubSequence // Matching docs
//        public typealias Indices = Array<MusicPlayer.Queue.Entry>.Indices
//
//        // --- Storage (Internal Implementation Detail) ---
//        private var storage: [Element] = []
//
//        // --- Initializers ---
//        public init() {
//            self.storage = []
//        }
//
//        public init<S>(_ sequence: S) where S: Sequence, S.Element == Element {
//             self.storage = Array(sequence)
//         }
//
//        public init(arrayLiteral elements: Element...) {
//            self.storage = elements
//        }
//
//        // --- Collection Conformance ---
//        public var startIndex: Index { storage.startIndex }
//        public var endIndex: Index { storage.endIndex }
//        public var indices: Indices { storage.indices }
//
//        public subscript(position: Index) -> Element {
//            get { storage[position] }
//            set { storage[position] = newValue }
//        }
//
//         public subscript(bounds: Range<Index>) -> SubSequence {
//             get { storage[bounds] }
//             // Set is more complex if SubSequence isn't MutableCollection
//             // For simulation, get is often sufficient. Let's assume it matches Array's Slice behavior.
//         }
//
//        public func makeIterator() -> Iterator { storage.makeIterator() }
//        public func index(after i: Index) -> Index { storage.index(after: i) }
//        public func formIndex(after i: inout Index) { storage.formIndex(after: &i) }
//        public func index(_ i: Index, offsetBy distance: Int) -> Index { storage.index(i, offsetBy: distance) }
//        public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? { storage.index(i, offsetBy: distance, limitedBy: limit) }
//        public func distance(from start: Index, to end: Index) -> Int { storage.distance(from: start, to: end) }
//
//
//        // --- BidirectionalCollection Conformance ---
//        public func index(before i: Index) -> Index { storage.index(before: i) }
//        public func formIndex(before i: inout Index) { storage.formIndex(before: &i) }
//
//        // --- MutableCollection Conformance ---
//        // Subscript setter is already implemented above.
//
//        // --- RangeReplaceableCollection Conformance ---
//        public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, C.Element == Element {
//            storage.replaceSubrange(subrange, with: newElements)
//        }
//
//        // Required public init() is already provided.
//
//        // Optional but good practice for RangeReplaceableCollection:
//        public mutating func append(_ newElement: Element) {
//             storage.append(newElement)
//         }
//
//         public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
//             storage.append(contentsOf: newElements)
//         }
//
//         public mutating func insert(_ newElement: Element, at i: Index) {
//             storage.insert(newElement, at: i)
//         }
//
//         public mutating func insert<C>(contentsOf newElements: C, at i: Index) where C : Collection, Element == C.Element {
//             storage.insert(contentsOf: newElements, at: i)
//         }
//
//         public mutating func remove(at i: Index) -> Element {
//             return storage.remove(at: i)
//         }
//
//         public mutating func removeSubrange(_ bounds: Range<Index>) {
//             storage.removeSubrange(bounds)
//         }
//
//         public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
//             storage.removeAll(keepingCapacity: keepCapacity)
//         }
//
//        // --- Equatable Conformance ---
//        public static func == (lhs: Entries, rhs: Entries) -> Bool {
//            lhs.storage == rhs.storage
//        }
//
//        // --- Hashable Conformance ---
//        public func hash(into hasher: inout Hasher) {
//            hasher.combine(storage)
//        }
//    }
//}
//
//// Add other necessary MusicKit types/enums for compilation if not already present
//// These are minimal stubs based on usage in the UI/ViewModel
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public enum AudioVariant: CaseIterable, Equatable, Hashable, Sendable {
//    case dolbyAtmos, dolbyAudio, lossless, highResolutionLossless, lossyStereo, spatialAudio
//}
//
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//extension MusicPlayer {
//    public enum PlaybackStatus : Equatable, Hashable, Sendable {
//        case stopped, playing, paused, interrupted, seekingForward, seekingBackward
//    }
//
//    public enum RepeatMode : Sendable, Equatable, Hashable {
//        case none, one, all
//    }
//
//    public enum ShuffleMode : Sendable, Equatable, Hashable {
//        case off, songs
//    }
//
//    // Define Queue, Entry, and Item nested types if not already defined globally
//    // For this example, they are defined globally based on the previous structure.
//}
//
//// Example Placeholder Artwork struct if needed for compilation
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct Artwork: Equatable, Hashable, Sendable {
//    // Add minimal properties needed if any, e.g., backgroundColor
//     public var backgroundColor: CGColor? // Requires CoreGraphics import
//
//     // Make it equatable/hashable if needed by container types
//     public static func == (lhs: Artwork, rhs: Artwork) -> Bool { lhs.backgroundColor == rhs.backgroundColor } // Simplistic
//     public func hash(into hasher: inout Hasher) { hasher.combine(backgroundColor) } // Simplistic
//}
//
//// Example Placeholder PlayableMusicItem protocol
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//public protocol PlayableMusicItem : MusicItem { // Assuming MusicItem exists
//     var playParameters: PlayParameters? { get }
//}
//
//// Example Placeholder MusicItem protocol
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public protocol MusicItem : Identifiable where ID == MusicItemID {} // Simplified
//
//// Example Placeholder MusicItemID struct
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//@frozen public struct MusicItemID : Equatable, Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral {
//     public let rawValue: String
//     public init(rawValue: String) { self.rawValue = rawValue }
//     public init(stringLiteral value: String) { self.rawValue = value }
//     public typealias RawValue = String
//     public typealias ExtendedGraphemeClusterLiteralType = String
//     public typealias StringLiteralType = String
//     public typealias UnicodeScalarLiteralType = String
// }
//
//// Example Placeholder PlayParameters struct
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct PlayParameters : Equatable, Hashable, Sendable {
//     // Opaque representation
//}
//
//// Example Placeholder structs for Song/MusicVideo if needed by Item enum
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct Song: MusicItem, Equatable, Hashable, Identifiable, Sendable {
//     public let id: MusicItemID
//     // Other properties...
//}
//
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct MusicVideo: MusicItem, Equatable, Hashable, Identifiable, Sendable {
//     public let id: MusicItemID
//      // Other properties...
//}
//

// ----- Required MusicKit Protocol Mocks -----
// These are necessary because Swift needs concrete types for protocol conformance
// even if we are only simulating the behavior.
//
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//open class MusicPlayer: ObservableObject { // Make it ObservableObject for state binding
//    @Published public var state: MusicPlayer.State = State() // Use @Published for UI updates
//
//    open var isPreparedToPlay: Bool { false } // Mock implementation
//    open func prepareToPlay() async throws {} // Mock implementation
//    open func play() async throws {} // Mock implementation
//    open func pause() {} // Mock implementation
//    open func stop() {} // Mock implementation
//
//    @Published open var playbackTime: TimeInterval = 0.0 // Make it @Published
//
//    open func beginSeekingForward() {} // Mock implementation
//    open func beginSeekingBackward() {} // Mock implementation
//    open func endSeeking() {} // Mock implementation
//    open func skipToNextEntry() async throws {} // Mock implementation
//    open func restartCurrentEntry() {} // Mock implementation
//    open func skipToPreviousEntry() async throws {} // Mock implementation
//
//     // --- Nested Types (Essential Stubs) ---
//     // These nested types need to be defined within MusicPlayer context
//     // if they are not available globally through MusicKit import.
//
//     // Make State ObservableObject as well
//     open class State : ObservableObject {
//         @Published open var playbackStatus: MusicPlayer.PlaybackStatus = .stopped
//         @Published open var playbackRate: Float = 1.0
//         @Published open var repeatMode: MusicPlayer.RepeatMode? = .none
//         @Published open var shuffleMode: MusicPlayer.ShuffleMode? = .off
//         //@Published open var audioVariant: AudioVariant? = .lossyStereo // Use actual enum
//
//         // Required by ObservableObject
//         // public var objectWillChange = ObservableObjectPublisher()
//     }
//
//     open class Queue : ObservableObject, ExpressibleByArrayLiteral {
//         @Published open var currentEntry: MusicPlayer.Queue.Entry? // Make observable
//
//          // --- Nested Types for Queue ---
//         public struct Entry : Equatable, Hashable, Identifiable, CustomStringConvertible {
//             public let id: String = UUID().uuidString // Simulate ID
//             public var item: MusicPlayer.Queue.Entry.Item?
//             public var transientItem: (any PlayableMusicItem)? // Keep as protocol
//             public var isTransient: Bool { transientItem != nil }
//             public var startTime: TimeInterval?
//             public var endTime: TimeInterval?
//
//             // Simplified Initializer for mock
//             public init(item: Item?, startTime: TimeInterval? = nil, endTime: TimeInterval? = nil) {
//                 self.item = item
//                 self.startTime = startTime
//                 self.endTime = endTime
//             }
//             // Conformance details omitted for brevity in this mock stub
//
//             public var description: String { "Entry \(id)" } // Simplified description
//
//             // --- Nested Item Enum for Entry ---
//             public enum Item : MusicItem, Equatable, Hashable, Identifiable, Sendable {
//                 case song(Song)
//                 case musicVideo(MusicVideo)
//                 public var id: MusicItemID {
//                     switch self { case .song(let s): s.id; case .musicVideo(let mv): mv.id }
//                 }
//                 public var playParameters: PlayParameters? { nil } // Mock
//                 // Conformance details omitted for brevity
//             }
//         }
//
//         public enum EntryInsertionPosition : Sendable, Equatable, Hashable {
//             case afterCurrentEntry, tail
//         }
//
//         // Required initializers (mock implementations)
//         required public init<S, PI>(for playableItems: S, startingAt startPlayableItem: S.Element? = nil) where S : Sequence, PI : PlayableMusicItem, PI == S.Element {}
//         required public init<S>(_ entries: S, startingAt startEntry: S.Element? = nil) where S : Sequence, S.Element == MusicPlayer.Queue.Entry {}
//
//         // Specific initializers (mock)
//         @available(iOS 16.4, tvOS 16.4, visionOS 1.0, macOS 14.0, *)
//         required public init(album: Album, startingAt startTrack: Track) {}
//         @available(iOS 16.4, tvOS 16.4, visionOS 1.0, macOS 14.0, *)
//         required public init(playlist: Playlist, startingAt startPlaylistEntry: Playlist.Entry) {}
//
//         // ExpressibleByArrayLiteral conformance (mock)
//         required public init(arrayLiteral elements: any PlayableMusicItem...) {}
//         public typealias ArrayLiteralElement = any PlayableMusicItem
//
//         // Mock insertion methods
//         open func insert<S, PI>(_ playableItems: S, position: MusicPlayer.Queue.EntryInsertionPosition) async throws where S : Sequence, PI : PlayableMusicItem, PI == S.Element {}
//         open func insert<S>(_ entries: S, position: MusicPlayer.Queue.EntryInsertionPosition) async throws where S : Sequence, S.Element == MusicPlayer.Queue.Entry {}
//         open func insert<PI>(_ playableItem: PI, position: MusicPlayer.Queue.EntryInsertionPosition) async throws where PI : PlayableMusicItem {}
//         open func insert(_ entry: MusicPlayer.Queue.Entry, position: MusicPlayer.Queue.EntryInsertionPosition) async throws {}
//     }
//}

// Define concrete subclasses ApplicationMusicPlayer and SystemMusicPlayer
//
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, macOS 14.0, *)
//@available(watchOS, unavailable)
//public final class ApplicationMusicPlayer : MusicPlayer { // Make final for singleton pattern
//    public static let shared = ApplicationMusicPlayer()
//
//    // Shadow the queue property with the more specific type
//    // Use @Published or ensure the base class handles observation correctly
//    @Published public var queue: ApplicationMusicPlayer.Queue = .init() // Initialize specific queue type
//
//    // Add the transition property
//    @available(iOS 18.0, *) // Mark with correct availability
//    @available(macOS, unavailable)
//    @available(macCatalyst, unavailable)
//    @available(tvOS, unavailable)
//    @available(watchOS, unavailable)
//    @available(visionOS, unavailable)
//    @Published public var transition: MusicPlayer.Transition = .none // Add transition property
//
//    private override init() { // Make init private for singleton
//        super.init()
//        // Specific ApplicationMusicPlayer initial setup if needed
//    }
//
//    // Define the nested ApplicationMusicPlayer.Queue if it hasn't been lifted globally
//    public final class Queue: MusicPlayer.Queue { // Make final if appropriate
//         @Published public var entries: ApplicationMusicPlayer.Queue.Entries = .init()
//
//        // Required initializers must call super or be convenience
//        required public init<S, PI>(for playableItems: S, startingAt startPlayableItem: S.Element?) where S : Sequence, PI : PlayableMusicItem, PI == S.Element {
//            super.init(for: playableItems, startingAt: startPlayableItem)
//        }
//        required public init<S>(_ entries: S, startingAt startEntry: S.Element?) where S : Sequence, S.Element == MusicPlayer.Queue.Entry {
//             super.init(entries, startingAt: startEntry)
//         }
//        @available(iOS 16.4, tvOS 16.4, visionOS 1.0, macOS 14.0, *)
//         required public init(album: Album, startingAt startTrack: Track) {
//             super.init(album: album, startingAt: startTrack)
//         }
//        @available(iOS 16.4, tvOS 16.4, visionOS 1.0, macOS 14.0, *)
//         required public init(playlist: Playlist, startingAt startPlaylistEntry: Playlist.Entry) {
//             super.init(playlist: playlist, startingAt: startPlaylistEntry)
//         }
//         required public init(arrayLiteral elements: any PlayableMusicItem...) {
//             super.init(arrayLiteral: elements)
//         }
//
//        // Default init for observation
//         override init() {
//             super.init()
//         }
//     }
//}
//
//
//@available(iOS 15.0, tvOS 15.0, visionOS 1.0, *)
//@available(watchOS, unavailable)
//@available(macOS, unavailable)
//public final class SystemMusicPlayer : MusicPlayer {
//    public static let shared = SystemMusicPlayer()
//
//    // Shadow the queue property with the base type
//    @Published public var queue: MusicPlayer.Queue = .init()
//
//     private override init() { // Make init private for singleton
//         super.init()
//         // Specific SystemMusicPlayer initial setup if needed
//    }
//}
//
//// Minimal Stubs for other types if needed for compilation
//protocol MusicPropertyContainer {}
//
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct Album: MusicItem, Equatable, Hashable, Identifiable, Sendable, PlayableMusicItem { // Add Playable conformance
//    public let id: MusicItemID
//    public var playParameters: PlayParameters? { nil } // Mock
//}
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public enum Track: MusicItem, Equatable, Hashable, Identifiable, Sendable, PlayableMusicItem { // Add Playable conformance
//   case song(Song)
//   case musicVideo(MusicVideo)
//    public var id: MusicItemID {
//         switch self { case .song(let s): s.id; case .musicVideo(let mv): mv.id }
//    }
//    public var playParameters: PlayParameters? { nil } // Mock
//}
//
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//public struct Playlist: MusicItem, Equatable, Hashable, Identifiable, Sendable, PlayableMusicItem { // Add Playable conformance
//    public let id: MusicItemID
//    public var playParameters: PlayParameters? { nil } // Mock
//
//    // Nested Entry struct stub
//    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
//    public struct Entry : MusicItem, Equatable, Hashable, Identifiable, Sendable, PlayableMusicItem { // Add Playable conformance
//         public let id: MusicItemID
//         public var item: Playlist.Entry.Item? // Assuming Item exists
//         public var playParameters: PlayParameters? { nil } // Mock
//
//        // Nested Item enum stub
//        public enum Item : MusicItem, Equatable, Hashable, Identifiable, Sendable {
//            case musicVideo(MusicVideo)
//            case song(Song)
//            public var id: MusicItemID {
//                  switch self { case .song(let s): s.id; case .musicVideo(let mv): mv.id }
//            }
//        }
//    }
//}
