////
////  SupportingDataStructuresView.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import MusicKit // Assuming MusicKit defines the base structures and ArtworkImage
//import CoreGraphics // For CGColor
//
//// --- Mock Data Structures (Simulating MusicKit Types) ---
//// NOTE: These are simplified versions for UI demonstration purposes ONLY.
//// They do not contain the full logic or conformance of the actual MusicKit types.
//
//// Represents MusicKit.MusicItemID
//struct MockMusicItemID: Equatable, Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral, Codable, CustomStringConvertible {
//    var rawValue: String
//    var description: String { rawValue }
//    init(_ rawValue: String) { self.rawValue = rawValue }
//    init(rawValue: String) { self.rawValue = rawValue }
//    init(stringLiteral value: String) { self.rawValue = value }
//}
//
//// Represents MusicKit.Artwork
//struct MockArtwork: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
//    var maximumWidth: Int = 1000
//    var maximumHeight: Int = 1000
//    var alternateText: String? = "Sample Artwork"
//    var backgroundColor: CGColor? = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark grey example
//    var primaryTextColor: CGColor? = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // White example
//    var secondaryTextColor: CGColor? = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light grey
//    var tertiaryTextColor: CGColor? = CGColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Medium grey
//    var quaternaryTextColor: CGColor? = CGColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Darker grey
//
//    // Mock URL generation - in reality, this would use the actual sizing
//    func url(width: Int, height: Int) -> URL? {
//        // Placeholder URL - replace with actual logic if needed for image loading simulation
//        return URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/e1/f9/1a/e1f91aa8-78a4-8afa-67fa-a5548c7931d8/196589920424.jpg/\(width)x\(height)bb.jpg")
//    }
//    var description: String { "Artwork (\(maximumWidth)x\(maximumHeight))" }
//}
//
//// Represents MusicKit.EditorialNotes
//struct MockEditorialNotes: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
//    var short: String? = "A brief note."
//    var standard: String? = "A standard, slightly longer note about the content."
//    var name: String? = "Editor's Choice"
//    var tagline: String? = "Must Listen!"
//    var description: String { "Notes: \(name ?? "N/A") - \(tagline ?? "N/A")" }
//}
//
//// Represents MusicKit.PlayParameters (Opaque, so minimal representation)
//struct MockPlayParameters: Equatable, Hashable, Sendable, Codable {
//    // Opaque struct - no public members to display meaningfully
//    private var internalData = UUID().uuidString // Placeholder internal state
//}
//
//// Represents MusicKit.PreviewAsset
//struct MockPreviewAsset: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
//    var artwork: MockArtwork? = MockArtwork() // Optional preview artwork
//    var url: URL? = URL(string: "https://example.com/preview.mp3")
//    var hlsURL: URL? = URL(string: "https://example.com/preview.m3u8")
//    var description: String { "Preview (URL: \(url != nil), HLS: \(hlsURL != nil))" }
//}
//
//// Represents MusicKit.ContentRating
//enum MockContentRating: String, Codable, Equatable, Hashable, Sendable {
//    case clean = "clean"
//    case explicit = "explicit"
//}
//
//// Represents MusicKit.AudioVariant
//enum MockAudioVariant: String, CaseIterable, Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
//    case dolbyAtmos = "Dolby Atmos"
//    case dolbyAudio = "Dolby Audio"
//    case lossless = "Lossless"
//    case highResolutionLossless = "Hi-Res Lossless"
//    case lossyStereo = "Stereo"
//    case spatialAudio = "Spatial Audio"
//
//    var description: String { self.rawValue }
//}
//
//// Represents a generic MusicItem for the collection
//protocol MockMusicItem: Identifiable {
//    var id: MockMusicItemID { get }
//}
//struct MockSongItem: MockMusicItem { // Example concrete item
//    var id: MockMusicItemID
//    var title: String
//}
//
//// Represents MusicKit.MusicItemCollection<T>
//struct MockMusicItemCollection<T: MockMusicItem>: RandomAccessCollection, Equatable, Hashable, Sendable, Codable, CustomStringConvertible, ExpressibleByArrayLiteral where T: Equatable, T: Hashable, T: Sendable, T: Codable {
//
//    var items: [T]
//    var title: String? = "Featured Collection"
//    var hasNextBatch: Bool = true // Assume more can be loaded
//
//    // --- Collection Conformance ---
//    var startIndex: Int { items.startIndex }
//    var endIndex: Int { items.endIndex }
//    func index(after i: Int) -> Int { items.index(after: i) }
//    subscript(position: Int) -> T { items[position] }
//
//    // --- Init ---
//    init(_ items: [T] = [], title: String? = nil, hasNextBatch: Bool = false) {
//        self.items = items
//        self.title = title
//        self.hasNextBatch = hasNextBatch
//    }
//
//    init(arrayLiteral elements: T...) {
//        self.items = elements
//        self.title = nil
//        self.hasNextBatch = false
//    }
//
//    // --- Mock Methods ---
//    func nextBatch(limit: Int? = nil) async throws -> MockMusicItemCollection<T>? {
//        // Simulate fetching next batch - returns nil in this mock
//        print("Simulating fetch next batch...")
//        return nil
//    }
//
//    var description: String { "\(title ?? "Collection"): \(items.count) items \(hasNextBatch ? "(more available)" : "")" }
//
//    // --- Equatable & Hashable ---
//    static func == (lhs: MockMusicItemCollection<T>, rhs: MockMusicItemCollection<T>) -> Bool {
//        return lhs.items == rhs.items && lhs.title == rhs.title && lhs.hasNextBatch == rhs.hasNextBatch
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(items)
//        hasher.combine(title)
//        hasher.combine(hasNextBatch)
//    }
//}
//
//// --- SwiftUI Views ---
//
//struct MusicItemIDView: View {
//    let itemID: MockMusicItemID
//
//    var body: some View {
//        Text("ID: \(itemID.rawValue)")
//            .font(.caption)
//            .foregroundColor(.secondary)
//            .lineLimit(1)
//            .truncationMode(.middle)
//    }
//}
//
//struct ArtworkView: View {
//    let artwork: MockArtwork
//    let size: CGFloat = 60 // Example size
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            // Use the actual ArtworkImage if available and SwiftUI is imported
//             //ArtworkImage(artwork, width: size, height: size) // Assumes MusicKit provides this
////                .overlay(
////                    RoundedRectangle(cornerRadius: 4)
////                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
////                )
//
//            // Fallback / Alternative representation if ArtworkImage isn't available:
////            AsyncImage(url: artwork.url(width: Int(size * 2), height: Int(size * 2))) { phase in // Request higher res
////                if let image = phase.image {
////                    image.resizable()
////                         .aspectRatio(contentMode: .fit)
////                } else if phase.error != nil {
////                    Image(systemName: "photo") // Error icon
////                         .foregroundColor(.red)
////                } else {
////                    Rectangle() // Placeholder
////                        .fill(artwork.backgroundColor != nil ? Color(cgColor: artwork.backgroundColor!) : Color.secondary.opacity(0.3))
////                        .overlay(ProgressView())
////                }
////            }
////            .frame(width: size, height: size)
////            .cornerRadius(4)
////            .overlay(
////                RoundedRectangle(cornerRadius: 4)
////                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
////            )
//
//            Text("Max: \(artwork.maximumWidth)x\(artwork.maximumHeight)")
//                .font(.caption2)
//                .foregroundColor(.gray)
//            if let alt = artwork.alternateText {
//                Text("Alt: \(alt)")
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//                    .lineLimit(1)
//            }
//            if let bgColor = artwork.backgroundColor {
//                 HStack {
//                     Text("BG:")
//                     Rectangle()
//                         .fill(Color(cgColor: bgColor))
//                         .frame(width: 15, height: 15)
//                         .cornerRadius(3)
//                    if let primaryColor = artwork.primaryTextColor {
//                        Text("TXT:")
//                        Rectangle()
//                            .fill(Color(cgColor: primaryColor))
//                            .frame(width: 15, height: 15)
//                            .cornerRadius(3)
//                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray, lineWidth: 0.5))
//                    }
//                 }
//                 .font(.caption2)
//                 .foregroundColor(.gray)
//            }
//        }
//    }
//}
//
//struct EditorialNotesView: View {
//    let notes: MockEditorialNotes
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            if let name = notes.name {
//                Text(name).font(.headline).bold()
//            }
//            if let tagline = notes.tagline {
//                Text(tagline).font(.subheadline).italic().foregroundColor(.secondary)
//            }
//            if let standard = notes.standard {
//                Text(standard).font(.body)
//            } else if let short = notes.short {
//                Text(short).font(.body).foregroundColor(.gray)
//            }
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//struct PlayParametersView: View {
//    let playParams: MockPlayParameters? // It's usually optional
//
//    var body: some View {
//        if playParams != nil {
//            HStack {
//                Image(systemName: "play.circle.fill")
//                    .foregroundColor(.green)
//                Text("Playable")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        } else {
//            HStack {
//                Image(systemName: "play.slash")
//                    .foregroundColor(.red)
//                Text("Not Playable")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//    }
//}
//
//struct PreviewAssetView: View {
//    let asset: MockPreviewAsset
//
//    var body: some View {
//        HStack {
//            if let art = asset.artwork {
//               // ArtworkView(artwork: art, size: 40) // Smaller artwork for preview
//                ArtworkView(artwork: art)
//            } else {
//                Image(systemName: "film")
//                    .foregroundColor(.gray)
//                    .frame(width: 40, height: 40)
//            }
//            VStack(alignment: .leading) {
//                if asset.url != nil {
//                    HStack{
//                        Image(systemName: "link")
//                        Text("MP3 Preview")
//                    }
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                }
//                if asset.hlsURL != nil {
//                    HStack{
//                         Image(systemName: "play.tv")
//                         Text("HLS Preview")
//                    }
//                   .font(.caption)
//                   .foregroundColor(.purple)
//                }
//                if asset.url == nil && asset.hlsURL == nil {
//                    Text("No Preview Available")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//    }
//}
//
//struct ContentRatingView: View {
//    let rating: MockContentRating?
//
//    var body: some View {
//        if let rating = rating {
//            switch rating {
//            case .clean:
//                Text("Clean")
//                    .font(.caption)
//                    .padding(.horizontal, 5)
//                    .background(Color.green.opacity(0.2))
//                    .clipShape(Capsule())
//            case .explicit:
//                Text("Explicit")
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .padding(.horizontal, 5)
//                    .background(Color.red.opacity(0.2))
//                    .clipShape(Capsule())
//            }
//        } else {
//             Text("Unrated")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.horizontal, 5)
//                .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
//        }
//    }
//}
//
//struct AudioVariantView: View {
//    let variant: MockAudioVariant
//
//    var iconName: String {
//        switch variant {
//        case .dolbyAtmos: return "speaker.wave.3.fill"
//        case .dolbyAudio: return "speaker.surround.left.fill" // Example
//        case .lossless: return "headphones.circle"
//        case .highResolutionLossless: return "hifispeaker.and.homepodmini.fill" // Example
//        case .lossyStereo: return "speaker.fill"
//        case .spatialAudio: return "rotate.3d"
//        }
//    }
//
//    var color: Color {
//         switch variant {
//        case .dolbyAtmos, .spatialAudio: return .purple
//        case .dolbyAudio: return .blue
//        case .lossless, .highResolutionLossless: return .yellow
//        case .lossyStereo: return .gray
//        }
//    }
//
//    var body: some View {
//        HStack(spacing: 3) {
//            Image(systemName: iconName)
//                .foregroundColor(color)
//            Text(variant.description)
//        }
//        .font(.caption)
//        .padding(.horizontal, 6)
//        .padding(.vertical, 2)
//        .background(color.opacity(0.15))
//        .cornerRadius(8)
//    }
//}
//
//struct MusicItemCollectionView<T: MockMusicItem>: View where T: Equatable, T: Hashable, T: Sendable, T: Codable {
//    let collection: MockMusicItemCollection<T>
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            if let title = collection.title {
//                Text(title)
//                    .font(.headline)
//            } else {
//                 Text("Collection")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//            }
//            HStack {
//                Text("\(collection.items.count) items")
//                if collection.hasNextBatch {
//                    Image(systemName: "ellipsis.circle.fill")
//                        .foregroundColor(.blue)
//                    Text("(More available)")
//                        .foregroundColor(.blue)
//
//                }
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//
//            // Optionally display first few items if needed, keeping it simple here
//            // ForEach(collection.prefix(3)) { item in
//            //     Text(" - \(item.id.rawValue)") // Display basic info
//            // }
//        }
//        .padding()
//        .background(Color.secondary.opacity(0.1))
//        .cornerRadius(8)
//    }
//}
//
//// --- Main Demo View ---
//
//struct SupportingDataStructuresView: View {
//    // Mock Data Instances
//    let mockItemID = MockMusicItemID("song.123456789")
//    let mockArtwork = MockArtwork()
//    let mockNotes = MockEditorialNotes()
//    let mockPlayParams: MockPlayParameters? = MockPlayParameters() // Can be nil
//    let mockPreview = MockPreviewAsset()
//    let mockRatingExplicit: MockContentRating? = .explicit
//    let mockRatingClean: MockContentRating? = .clean
//    let mockRatingNil: MockContentRating? = nil
//    let mockVariants: [MockAudioVariant] = [.dolbyAtmos, .highResolutionLossless, .lossyStereo]
////    let mockCollection: MockMusicItemCollection<MockSongItem> = MockMusicItemCollection(
////        [MockSongItem(id: "s.1", title: "Song One"), MockSongItem(id: "s.2", title: "Song Two")],
////        title: "Recent Hits",
////        hasNextBatch: true
////    )
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Supporting Data Structures").font(.largeTitle).bold().padding(.bottom)
//
//                // MusicItemID
//                GroupBox("MusicItemID") {
//                  MusicItemIDView(itemID: mockItemID)
//                }
//
//                // Artwork
//                GroupBox("Artwork") {
//                    ArtworkView(artwork: mockArtwork)
//                }
//
//                // EditorialNotes
//                GroupBox("EditorialNotes") {
//                   EditorialNotesView(notes: mockNotes)
//                }
//
//                // PlayParameters
//                GroupBox("PlayParameters") {
//                    HStack{
//                      PlayParametersView(playParams: mockPlayParams)
//                      Spacer()
//                      PlayParametersView(playParams: nil) // Example of nil
//                    }
//                }
//
//                // PreviewAsset
//                 GroupBox("PreviewAsset") {
//                     PreviewAssetView(asset: mockPreview)
//                     Divider()
//                     PreviewAssetView(asset: MockPreviewAsset(artwork: nil, url: nil, hlsURL: URL(string:"hls://example.com"))) // Example HLS only
//                 }
//
//                // ContentRating
//                GroupBox("ContentRating") {
//                     HStack {
//                         ContentRatingView(rating: mockRatingExplicit)
//                         Spacer()
//                         ContentRatingView(rating: mockRatingClean)
//                         Spacer()
//                         ContentRatingView(rating: mockRatingNil)
//                     }
//                }
//
//                // AudioVariant
//                GroupBox("AudioVariant") {
//                     ScrollView(.horizontal, showsIndicators: false) {
//                         HStack {
//                             ForEach(MockAudioVariant.allCases.indices, id: \.self) { index in
//                                 AudioVariantView(variant: MockAudioVariant.allCases[index])
//                             }
//                         }
//                         .padding(.horizontal)
//                     }
//                    // .padding(.horizontal: -15)// Counteract inner padding for full scroll width
//                }
//
//                // MusicItemCollection
////                GroupBox("MusicItemCollection<MockSongItem>") {
////                    MusicItemCollectionView<T: MockMusicItem & Decodable & Encodable & Hashable & Sendable>(collection: mockCollection)
////                }
//
////                 GroupBox("MusicItemCollection<MockSongItem> (Empty)") {
////                     MusicItemCollectionView(collection: MockMusicItemCollection<MockSongItem>())
////                 }
//
//            }
//            .padding()
//        }
//    }
//}
//
//// --- Previews ---
//#Preview {
//    SupportingDataStructuresView()
//}
