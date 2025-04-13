//
//  CoreMusicItemTypesDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//


import SwiftUI
import MusicKit // Assuming MusicKit is imported in the project context

// --- Placeholder Data Structures (Matching MusicKit Types) ---
// NOTE: These are simplified representations for placeholder data.
// In a real app, you would use the actual MusicKit types.

struct PlaceholderArtwork {
    var bgColor: Color = .gray
    var primaryTextColor: Color = .white
}

struct PlaceholderMusicItemID: Hashable, CustomStringConvertible {
    let rawValue: String
    var description: String { rawValue }
}

struct PlaceholderAlbum {
    let id: PlaceholderMusicItemID
    let title: String
    let artistName: String
    let artwork: PlaceholderArtwork?
    let trackCount: Int
    let releaseDate: Date?
    let isCompilation: Bool?
    let isComplete: Bool?
    let isSingle: Bool?
    let genreNames: [String]
    let recordLabelName: String?
    let copyright: String?
    // Simplified relationships
    let hasArtists: Bool = true
    let hasTracks: Bool = true
    let hasGenres: Bool = true
}

struct PlaceholderArtist {
    let id: PlaceholderMusicItemID
    let name: String
    let artwork: PlaceholderArtwork?
    let genreNames: [String]?
    // Simplified relationships
    let hasAlbums: Bool = true
    let hasMusicVideos: Bool = true
    let hasPlaylists: Bool = true
    let hasStation: Bool = true
}

struct PlaceholderSong {
    let id: PlaceholderMusicItemID
    let title: String
    let artistName: String
    let albumTitle: String?
    let artwork: PlaceholderArtwork?
    let duration: TimeInterval?
    let genreNames: [String]
    let hasLyrics: Bool
    let composerName: String?
    // Simplified relationships
    let hasAlbums: Bool = true
    let hasArtists: Bool = true
    let hasGenres: Bool = true
    let hasComposers: Bool = true
    let hasMusicVideos: Bool = true
}

struct PlaceholderMusicVideo {
    let id: PlaceholderMusicItemID
    let title: String
    let artistName: String
    let artwork: PlaceholderArtwork?
    let duration: TimeInterval?
    let has4K: Bool?
    let hasHDR: Bool?
    let albumTitle: String?
    // Simplified relationships
    let hasAlbums: Bool = true
    let hasArtists: Bool = true
    let hasGenres: Bool = true
    let hasSongs: Bool = true
}

enum PlaceholderPlaylistKind {
    case editorial, external, personalMix, replay, userShared
}

struct PlaceholderPlaylist {
    let id: PlaceholderMusicItemID
    let name: String
    let curatorName: String?
    let artwork: PlaceholderArtwork?
    let kind: PlaceholderPlaylistKind?
    let isChart: Bool?
    let shortDescription: String?
    // Simplified relationships
    let hasEntries: Bool = true
    let hasTracks: Bool = true
    let hasCurator: Bool = true
    let hasRadioShow: Bool = true
}

enum PlaceholderTrack {
    case song(PlaceholderSong)
    case musicVideo(PlaceholderMusicVideo)

    var id: PlaceholderMusicItemID {
        switch self {
        case .song(let song): return song.id
        case .musicVideo(let mv): return mv.id
        }
    }
     var title: String {
        switch self {
        case .song(let song): return song.title
        case .musicVideo(let mv): return mv.title
        }
    }
    var artistName: String {
        switch self {
        case .song(let song): return song.artistName
        case .musicVideo(let mv): return mv.artistName
        }
    }
    var artwork: PlaceholderArtwork? {
        switch self {
        case .song(let song): return song.artwork
        case .musicVideo(let mv): return mv.artwork
        }
    }
    var duration: TimeInterval? {
         switch self {
        case .song(let song): return song.duration
        case .musicVideo(let mv): return mv.duration
        }
    }
     // Simplified relationships
    var hasAlbums: Bool {
        switch self {
        case .song(let song): return song.hasAlbums
        case .musicVideo(let mv): return mv.hasAlbums
        }
    }
     var hasArtists: Bool {
        switch self {
        case .song(let song): return song.hasArtists
        case .musicVideo(let mv): return mv.hasArtists
        }
    }
     var hasGenres: Bool {
         switch self {
        case .song(let song): return song.hasGenres
        case .musicVideo(let mv): return mv.hasGenres
        }
    }
}

struct PlaceholderGenre {
    let id: PlaceholderMusicItemID
    let name: String
    let parentName: String? // Simulate parent relationship
}

enum PlaceholderCuratorKind {
    case editorial, external
}

struct PlaceholderCurator {
    let id: PlaceholderMusicItemID
    let name: String
    let artwork: PlaceholderArtwork?
    let kind: PlaceholderCuratorKind
    // Simplified relationships
    let hasPlaylists: Bool = true
}

struct PlaceholderRadioShow {
    let id: PlaceholderMusicItemID
    let name: String
    let hostName: String?
    let artwork: PlaceholderArtwork?
    // Simplified relationships
    let hasPlaylists: Bool = true
}

struct PlaceholderRecordLabel {
    let id: PlaceholderMusicItemID
    let name: String
    let artwork: PlaceholderArtwork?
    let shortDescription: String?
    // Simplified relationships
    let hasLatestReleases: Bool = true
    let hasTopReleases: Bool = true
}

struct PlaceholderStation {
    let id: PlaceholderMusicItemID
    let name: String
    let artwork: PlaceholderArtwork?
    let isLive: Bool
    let stationProviderName: String?
}


// MARK: - SwiftUI Views

// --- Helper Views ---

/// A view to display artwork using placeholders.
/// In a real app, this would use MusicKit's `ArtworkImage`.
struct PlaceholderArtworkView: View {
    let artwork: PlaceholderArtwork?
    let size: CGFloat

    var body: some View {
        Group {
            if let art = artwork {
                art.bgColor
            } else {
                Color.secondary
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.1))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.1)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .overlay {
             if artwork == nil {
                 Image(systemName: "music.note")
                     .foregroundColor(.white.opacity(0.8))
                     .font(.system(size: size * 0.5))
             }
        }

    }
}

/// Simple view to display a key-value pair.
struct InfoRow: View {
    let label: String
    let value: String?

    var body: some View {
        if let value = value, !value.isEmpty {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.caption2)
                    .multilineTextAlignment(.trailing)
            }
        } else {
            EmptyView()
        }
    }
}

/// Formats TimeInterval (seconds) into MM:SS or HH:MM:SS
func formatDuration(_ interval: TimeInterval?) -> String? {
    guard let interval = interval, interval > 0 else { return nil }
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = interval >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: interval)
}

func formatDate(_ date: Date?) -> String? {
     guard let date = date else { return nil }
     let formatter = DateFormatter()
     formatter.dateStyle = .medium
     formatter.timeStyle = .none
     return formatter.string(from: date)
}

// --- Core Music Item Views ---

struct AlbumView: View {
    let album: PlaceholderAlbum

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: album.artwork, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(album.title).font(.headline)
                Text(album.artistName).font(.subheadline).foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         if album.isCompilation == true {
                             Text("Compilation").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.secondary.opacity(0.2)))
                         }
                         if album.isSingle == true {
                             Text("Single").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.secondary.opacity(0.2)))
                         }
                         if album.isComplete == false {
                             Text("Incomplete").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.yellow.opacity(0.3)))
                         }
                          ForEach(album.genreNames, id: \.self) { genre in
                            Text(genre).font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.blue.opacity(0.2)))
                          }
                      }
                 }
                 .frame(height: 16) // Constrain height

                Divider().padding(.vertical, 2)

                InfoRow(label: "ID:", value: album.id.rawValue)
                InfoRow(label: "Tracks:", value: "\(album.trackCount)")
                InfoRow(label: "Released:", value: formatDate(album.releaseDate))
                InfoRow(label: "Label:", value: album.recordLabelName)
                InfoRow(label: "Copyright:", value: album.copyright)

                // Indicate relationships exist
                 HStack(spacing: 4) {
                    if album.hasArtists { Image(systemName: "person.2.fill").imageScale(.small) }
                    if album.hasTracks { Image(systemName: "music.note.list").imageScale(.small) }
                    if album.hasGenres { Image(systemName: "tag.fill").imageScale(.small) }
                 }.foregroundColor(.gray)
            }
            Spacer() // Push content to the left
        }
        .padding()
    }
}

struct ArtistView: View {
    let artist: PlaceholderArtist

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: artist.artwork, size: 50)
                .clipShape(Circle()) // Artists often shown with circular images

            VStack(alignment: .leading, spacing: 4) {
                Text(artist.name).font(.headline)

                 if let genres = artist.genreNames, !genres.isEmpty {
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack {
                              ForEach(genres, id: \.self) { genre in
                                Text(genre).font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.blue.opacity(0.2)))
                              }
                          }
                     }
                     .frame(height: 16)
                }


                InfoRow(label: "ID:", value: artist.id.rawValue)

                 // Indicate relationships exist
                  HStack(spacing: 4) {
                     if artist.hasAlbums { Image(systemName: "opticaldisc").imageScale(.small) }
                     if artist.hasMusicVideos { Image(systemName: "video.fill").imageScale(.small) }
                     if artist.hasPlaylists { Image(systemName: "music.note.list").imageScale(.small) }
                     if artist.hasStation { Image(systemName: "antenna.radiowaves.left.and.right").imageScale(.small) }
                  }.foregroundColor(.gray).padding(.top, 2)
            }
             Spacer()
        }
        .padding()
    }
}

struct SongView: View {
     let song: PlaceholderSong

     var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: song.artwork, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title).font(.headline)
                Text(song.artistName).font(.subheadline).foregroundColor(.secondary)
                if let albumTitle = song.albumTitle {
                     Text("Album: \(albumTitle)").font(.caption).foregroundColor(.gray)
                }

                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         if song.hasLyrics {
                             Text("Lyrics").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.green.opacity(0.2)))
                         }
                          ForEach(song.genreNames, id: \.self) { genre in
                            Text(genre).font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.blue.opacity(0.2)))
                          }
                      }
                 }
                 .frame(height: 16)

                InfoRow(label: "ID:", value: song.id.rawValue)
                InfoRow(label: "Duration:", value: formatDuration(song.duration))
                InfoRow(label: "Composer:", value: song.composerName)

                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if song.hasAlbums { Image(systemName: "opticaldisc").imageScale(.small) }
                    if song.hasArtists { Image(systemName: "person.2.fill").imageScale(.small) }
                    if song.hasGenres { Image(systemName: "tag.fill").imageScale(.small) }
                    if song.hasComposers { Image(systemName: "music.quarternote.3").imageScale(.small)}
                    if song.hasMusicVideos { Image(systemName: "video.fill").imageScale(.small) }
                 }.foregroundColor(.gray).padding(.top, 2)
            }
            Spacer()
        }
        .padding()
     }
}

struct MusicVideoView: View {
     let musicVideo: PlaceholderMusicVideo

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: musicVideo.artwork, size: 50)
                .overlay(Image(systemName: "play.fill").foregroundColor(.white.opacity(0.7))) // Indicate video

            VStack(alignment: .leading, spacing: 4) {
                Text(musicVideo.title).font(.headline)
                Text(musicVideo.artistName).font(.subheadline).foregroundColor(.secondary)
                 if let albumTitle = musicVideo.albumTitle {
                     Text("Album: \(albumTitle)").font(.caption).foregroundColor(.gray)
                }

                 HStack {
                     if musicVideo.has4K == true {
                         Text("4K").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.purple.opacity(0.2)))
                     }
                     if musicVideo.hasHDR == true {
                         Text("HDR").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.orange.opacity(0.3)))
                     }
                 }

                InfoRow(label: "ID:", value: musicVideo.id.rawValue)
                InfoRow(label: "Duration:", value: formatDuration(musicVideo.duration))

                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if musicVideo.hasAlbums { Image(systemName: "opticaldisc").imageScale(.small) }
                    if musicVideo.hasArtists { Image(systemName: "person.2.fill").imageScale(.small) }
                    if musicVideo.hasGenres { Image(systemName: "tag.fill").imageScale(.small) }
                    if musicVideo.hasSongs { Image(systemName: "music.note") }
                 }.foregroundColor(.gray).padding(.top, 2)
            }
             Spacer()
        }
        .padding()
    }
}

struct PlaylistView: View {
     let playlist: PlaceholderPlaylist

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: playlist.artwork, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name).font(.headline)
                if let curator = playlist.curatorName {
                    Text("Curated by \(curator)").font(.subheadline).foregroundColor(.secondary)
                }

                HStack {
                     if let kind = playlist.kind {
                         Text(String(describing: kind)).font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.teal.opacity(0.2)))
                         }
                     if playlist.isChart == true {
                         Text("Chart").font(.caption2).padding(.horizontal, 4).background(Capsule().fill(.red.opacity(0.2)))
                     }
                 }

                if let description = playlist.shortDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                InfoRow(label: "ID:", value: playlist.id.rawValue)

                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if playlist.hasEntries { Image(systemName: "list.bullet").imageScale(.small) }
                    if playlist.hasTracks { Image(systemName: "music.note.list").imageScale(.small) }
                    if playlist.hasCurator { Image(systemName: "person.crop.circle.fill").imageScale(.small) }
                    if playlist.hasRadioShow { Image(systemName: "radio.fill").imageScale(.small) }
                 }.foregroundColor(.gray).padding(.top, 2)
            }
            Spacer()
        }
        .padding()
    }
}

struct TrackView: View {
    let track: PlaceholderTrack

    var body: some View {
         // This view acts as a wrapper, displaying either Song or MusicVideo view
         // based on the enum case. A real implementation might share more UI
         // elements between the two cases.
         VStack(alignment: .leading) {
             switch track {
             case .song(let song):
                 SongView(song: song) // Reuse the specific Song view
             case .musicVideo(let musicVideo):
                 MusicVideoView(musicVideo: musicVideo) // Reuse the specific MusicVideo view
             }
            // Common track info could go here if needed, but most relevant info
            // is already in the specific Song/MusicVideo views.
            // Example: InfoRow(label: "Track ID:", value: track.id.rawValue)
         }
    }
}

struct GenreView: View {
    let genre: PlaceholderGenre

    var body: some View {
         HStack {
             Image(systemName: "tag.fill")
                 .foregroundColor(.blue)
                 .frame(width: 50, height: 50)


             VStack(alignment: .leading, spacing: 4) {
                 Text(genre.name).font(.headline)
                 if let parent = genre.parentName {
                      Text("Parent: \(parent)").font(.caption).foregroundColor(.gray)
                 }
                 InfoRow(label: "ID:", value: genre.id.rawValue)
            }
             Spacer()
         }
         .padding()
    }
}

struct CuratorView: View {
    let curator: PlaceholderCurator

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: curator.artwork, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(curator.name).font(.headline)
                Text("Kind: \(String(describing: curator.kind))")
                     .font(.caption)
                     .padding(.horizontal, 5)
                     .background(Capsule().fill(Color.orange.opacity(0.2)))

                InfoRow(label: "ID:", value: curator.id.rawValue)

                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if curator.hasPlaylists { Image(systemName: "music.note.list").imageScale(.small) }
                 }.foregroundColor(.gray).padding(.top, 2)
            }
             Spacer()
        }
        .padding()
    }
}

struct RadioShowView: View {
    let radioShow: PlaceholderRadioShow

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: radioShow.artwork, size: 50)
                 .overlay(Image(systemName: "radio.fill").foregroundColor(.white.opacity(0.7)))

            VStack(alignment: .leading, spacing: 4) {
                Text(radioShow.name).font(.headline)
                 if let host = radioShow.hostName {
                     Text("Host: \(host)").font(.subheadline).foregroundColor(.secondary)
                 }
                InfoRow(label: "ID:", value: radioShow.id.rawValue)
                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if radioShow.hasPlaylists { Image(systemName: "music.note.list").imageScale(.small) }
                 }.foregroundColor(.gray).padding(.top, 2)
            }
            Spacer()
        }
        .padding()
    }
}

struct RecordLabelView: View {
    let recordLabel: PlaceholderRecordLabel

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: recordLabel.artwork, size: 50)
                .overlay(Image(systemName: "record.circle.fill").foregroundColor(.white.opacity(0.7)))


            VStack(alignment: .leading, spacing: 4) {
                Text(recordLabel.name).font(.headline)
                if let description = recordLabel.shortDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                InfoRow(label: "ID:", value: recordLabel.id.rawValue)

                 // Indicate relationships exist
                 HStack(spacing: 4) {
                    if recordLabel.hasLatestReleases { Label("Latest", systemImage: "sparkles").labelStyle(.iconOnly).imageScale(.small) }
                    if recordLabel.hasTopReleases { Label("Top", systemImage: "star.fill").labelStyle(.iconOnly).imageScale(.small) }
                 }.foregroundColor(.gray).padding(.top, 2)

            }
             Spacer()
        }
        .padding()
    }
}

struct StationView: View {
    let station: PlaceholderStation

    var body: some View {
        HStack(spacing: 15) {
            PlaceholderArtworkView(artwork: station.artwork, size: 50)
                .overlay(Image(systemName: "antenna.radiowaves.left.and.right").foregroundColor(.white.opacity(0.7)))


            VStack(alignment: .leading, spacing: 4) {
                Text(station.name).font(.headline)
                if let provider = station.stationProviderName {
                    Text("Provider: \(provider)").font(.caption).foregroundColor(.secondary)
                }
                 if station.isLive {
                    Text("LIVE")
                         .font(.caption.weight(.bold))
                         .padding(.horizontal, 4)
                         .foregroundColor(.red)
                         .background(Capsule().fill(.red.opacity(0.15)))
                 }
                InfoRow(label: "ID:", value: station.id.rawValue)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview() {
    Section("Album") {
        AlbumView(album: PlaceholderAlbum(id: .init(rawValue: "asd"), title: "asdasd", artistName: "asdasdsad", artwork: nil, trackCount: 2, releaseDate: nil, isCompilation: true, isComplete: true, isSingle: true, genreNames: ["ssdsd", "asdasdsd"], recordLabelName: nil, copyright: nil))
    }
}

// --- Example Usage & Previews ---
//
//struct CoreMusicItemViews_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            Section("Album") {
//                AlbumView(album: sampleAlbum)
//            }
//            Section("Artist") {
//                ArtistView(artist: sampleArtist)
//            }
//            Section("Song") {
//                SongView(song: sampleSong)
//            }
//            Section("Music Video") {
//                MusicVideoView(musicVideo: sampleMusicVideo)
//            }
//            Section("Playlist") {
//                PlaylistView(playlist: samplePlaylist)
//            }
//            Section("Track (Song)") {
//                TrackView(track: .song(sampleSong))
//            }
//            Section("Track (Music Video)") {
//                TrackView(track: .musicVideo(sampleMusicVideo))
//            }
//            Section("Genre") {
//                GenreView(genre: sampleGenre)
//            }
//            Section("Curator") {
//                CuratorView(curator: sampleCurator)
//            }
//            Section("Radio Show") {
//                RadioShowView(radioShow: sampleRadioShow)
//            }
//            Section("Record Label") {
//                RecordLabelView(recordLabel: sampleRecordLabel)
//            }
//        }
//    }
