//
//  KeyProtocolDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

/// A view showcasing the key protocols defined in the MusicKit documentation.
struct ProtocolGalleryView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("MusicKit Key Protocols")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                // --- Core Protocols Section ---
                Section(header: Text("Core Protocols").font(.title2).fontWeight(.semibold)) {
                    GroupBox(label: Label("MusicItem", systemImage: "music.note")) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("The fundamental protocol adopted by all music items.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Divider()
                            LabelledText(label: "Key Property", text: "id: MusicItemID", systemImage: "tag.fill")
                            LabelledText(label: "Conforms to", text: "Sendable, Identifiable", systemImage: "puzzlepiece.extension.fill")
                        }
                    }

                    GroupBox(label: Label("Common Swift Protocols", systemImage: "swiftdata")) {
                         VStack(alignment: .leading, spacing: 10) {
                             ProtocolChip(name: "Equatable", description: "Supports equality comparison (==).", systemImage: "equal.circle")
                             ProtocolChip(name: "Hashable", description: "Can be hashed for use in Sets/Dictionaries. Conforms to Equatable.", systemImage: "number.circle")
                             ProtocolChip(name: "Codable", description: "Supports encoding and decoding (e.g., for JSON).", systemImage: "curlybraces")
                             ProtocolChip(name: "Sendable", description: "Type can be safely transferred across concurrency domains.", systemImage: "paperplane.circle")
                             ProtocolChip(name: "Identifiable", description: "Has a stable identity (via 'id').", systemImage: "person.text.rectangle")
                             ProtocolChip(name: "CustomStringConvertible", description: "Provides a custom textual representation ('description').", systemImage: "text.bubble")
                             ProtocolChip(name: "CustomDebugStringConvertible", description: "Provides a custom debug representation ('debugDescription').", systemImage: "ladybug")
                         }
                    }
                }
                .padding(.bottom)

                // --- Capability Protocols Section ---
                Section(header: Text("Capability Protocols").font(.title2).fontWeight(.semibold)) {
                     LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 15) {
                        ProtocolGroupBox(name: "MusicPropertyContainer", description: "Allows loading additional properties asynchronously.", systemImage: "arrow.down.circle.dotted")
                        ProtocolGroupBox(name: "PlayableMusicItem", description: "Indicates the item can be played by a MusicPlayer.", keyInfo: "`playParameters: PlayParameters?`", systemImage: "play.circle")
                        ProtocolGroupBox(name: "MusicCatalogChartRequestable", description: "Item can be fetched via a catalog charts request.", systemImage: "chart.bar.xaxis")
                        ProtocolGroupBox(name: "MusicCatalogSearchable", description: "Item can be searched in the Apple Music catalog.", systemImage: "magnifyingglass.circle")
                        ProtocolGroupBox(name: "FilterableMusicItem", description: "Item can be filtered in catalog requests.", keyInfo: "`associatedtype FilterType`", systemImage: "line.3.horizontal.decrease.circle")
                        ProtocolGroupBox(name: "MusicLibraryAddable", description: "Item can be added to the user's music library.", systemImage: "plus.rectangle.on.folder")
                        ProtocolGroupBox(name: "MusicPlaylistAddable", description: "Item can be added to a playlist.", systemImage: "text.badge.plus")
                        ProtocolGroupBox(name: "MusicLibraryRequestable", description: "Item can be fetched/filtered/sorted in library requests.", keyInfo: "`associatedtype LibraryFilter`, `associatedtype LibrarySortProperties`", systemImage: "books.vertical.fill")
                        ProtocolGroupBox(name: "MusicLibrarySectionRequestable", description: "Type can be used as a section in sectioned library requests.", systemImage: "list.bullet.indent")
                        ProtocolGroupBox(name: "MusicLibrarySearchable", description: "Item can be searched in the user's music library.", systemImage: "person.crop.rectangle.stack")
                        ProtocolGroupBox(name: "MusicPersonalRecommendationItem", description: "Item can appear in personal recommendations.", systemImage: "hand.thumbsup.circle")
                        ProtocolGroupBox(name: "MusicCatalogTopLevelResourceRequesting", description: "Represents a top-level catalog resource (e.g., Genres).", systemImage: "arrow.up.bin")
                        ProtocolGroupBox(name: "MusicRecentlyPlayedRequestable", description: "Item can appear in recently played lists.", systemImage: "clock.arrow.circlepath")
                     }
                }
                .padding(.bottom)

                // --- Filter & Sort Protocols Section ---
                Section(header: Text("Filter & Sort Protocols").font(.title2).fontWeight(.semibold)) {
                    DisclosureGroup("Catalog Filters") {
                        VStack(alignment: .leading) {
                            FilterSortChip(name: "AlbumFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "ArtistFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "CuratorFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "GenreFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "MusicVideoFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "PlaylistFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "RadioShowFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "RecordLabelFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "SongFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "StationFilter", icon: "line.3.horizontal.decrease.circle.fill")
                        }
                        .padding(.leading)
                    }

                    DisclosureGroup("Library Filters") {
                         VStack(alignment: .leading) {
                            FilterSortChip(name: "LibraryAlbumFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryArtistFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryGenreFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryMusicVideoFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryPlaylistEntryFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryPlaylistFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibrarySongFilter", icon: "line.3.horizontal.decrease.circle.fill")
                            FilterSortChip(name: "LibraryTrackFilter", icon: "line.3.horizontal.decrease.circle.fill")
                         }
                         .padding(.leading)
                    }

                     DisclosureGroup("Library Sort Properties") {
                         VStack(alignment: .leading) {
                             FilterSortChip(name: "LibraryAlbumSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryArtistSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryGenreSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryMusicVideoSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryPlaylistEntrySortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryPlaylistSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibrarySongSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                             FilterSortChip(name: "LibraryTrackSortProperties", icon: "arrow.up.arrow.down.circle.fill")
                         }
                         .padding(.leading)
                     }
                }
                .padding(.bottom)

                // --- Token Protocols Section ---
                Section(header: Text("Token Protocols").font(.title2).fontWeight(.semibold)) {
                    ProtocolGroupBox(name: "MusicTokenProvider", description: "Alias for MusicDeveloperTokenProvider & MusicUserTokenProvider.", systemImage: "key.icloud.fill")
                    ProtocolGroupBox(name: "MusicDeveloperTokenProvider", description: "Provides a developer token for API access.", keyInfo: "`developerToken(...) async throws -> String`", systemImage: "person.badge.key.fill")
                    ProtocolGroupBox(name: "MusicUserTokenProvider", description: "Provides a user-specific token for API access.", keyInfo: "`userToken(...) async throws -> String`", systemImage: "person.fill.badge.key.fill")
                }

            }
            .padding()
        }
        #if os(macOS)
        // On macOS, add some constraints for better window sizing
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        #endif
    }
}

// --- Helper Views ---

/// Displays text with a label and an optional system image.
struct LabelledText: View {
    let label: String
    let text: String
    let systemImage: String?

    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: 20) // Align icons
            } else {
                 Spacer().frame(width: 20) // Keep alignment if no icon
            }
            Text("\(label):")
                .fontWeight(.medium)
                 .foregroundColor(.gray)
            Text(text)
            Spacer() // Push content to the left
        }
        .font(.callout)
    }
}

/// A simple capsule shape displaying a protocol name.
struct ProtocolChip: View {
    let name: String
    let description: String?
    let systemImage: String

    var body: some View {
        HStack {
             Label(name, systemImage: systemImage)
                .font(.caption.weight(.medium))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())

            if let description = description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
             Spacer()
        }
    }
}

/// A standardized GroupBox for displaying protocol information.
struct ProtocolGroupBox: View {
    let name: String
    let description: String
    var keyInfo: String? = nil
    let systemImage: String

    var body: some View {
        GroupBox(label: Label(name, systemImage: systemImage).font(.headline)) {
            VStack(alignment: .leading, spacing: 5) {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let keyInfo = keyInfo {
                     Divider()
                    Text(keyInfo)
                        .font(.caption.monospaced())
                        .foregroundColor(.blue)
                        .padding(.top, 3)
                }
                Spacer() // Ensure GroupBox takes available space if needed in grid
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure text area uses width
        }
    }
}

/// Chip specifically for Filter/Sort protocols.
struct FilterSortChip: View {
    let name: String
    let icon: String

    var body: some View {
        Label(name, systemImage: icon)
            .font(.caption)
            .padding(.vertical, 3)
            .padding(.horizontal, 6)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

// --- Preview ---
#Preview {
    ProtocolGalleryView()
        .preferredColorScheme(.dark) // Example: Dark mode preview
}

// Note: MusicItemID is defined elsewhere in the MusicKit framework.
// For this preview to compile standalone, you might need a stub, e.g.:
// struct MusicItemID: Hashable, ExpressibleByStringLiteral {
//     let rawValue: String
//     init(rawValue: String) { self.rawValue = rawValue }
//     init(stringLiteral value: String) { self.rawValue = value }
// }
// typealias MusicItem = Identifiable & Sendable // Basic stub
// struct Artwork: Hashable {} // Basic stub
// struct PlayParameters: Hashable {} // Basic stub
// struct MusicItemCollection<T>: RandomAccessCollection, Hashable where T: Hashable{ /* Stub impl */ } // Basic stub
// protocol MusicLibrarySectionRequestable: Identifiable where ID == MusicItemID {} // Stub
