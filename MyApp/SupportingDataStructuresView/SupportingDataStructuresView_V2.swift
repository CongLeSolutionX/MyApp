//
//  SupportingDataStructuresView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import MusicKit // Assuming MusicKit defines the base structures and ArtworkImage
import CoreGraphics // For CGColor

// --- Helper Struct to make Color Codable ---
struct CodableColor: Codable, Hashable, Equatable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    // Convenience initializer from CGColor
    init?(cgColor: CGColor?) {
        guard let cgColor = cgColor, let components = cgColor.components, components.count >= 3 else {
            // Handle cases like pattern colors or invalid component counts if necessary
             // For this mock, let's assume RGBA or Grayscale+Alpha
//             if let cgColor = cgColor, cgColor.numberOfComponents == 2 { // Grayscale + Alpha
//                 self.red = components[0]
//                 self.green = components[0]
//                 self.blue = components[0]
//                 self.alpha = components[1]
//                 return
//             }
            return nil // Cannot initialize from this CGColor
        }
        self.red = components[0]
        self.green = components[1]
        self.blue = components[2]
        self.alpha = components.count >= 4 ? components[3] : 1.0 // Assume alpha 1 if not present
    }

     // Computed property to get CGColor back
     var cgColor: CGColor? {
          // Note: Might need to specify a color space if default isn't desired
          return CGColor(red: red, green: green, blue: blue, alpha: alpha)
     }

    // Computed property for SwiftUI Color
     var swiftUIColor: Color? {
         guard let cg = cgColor else { return nil}
         return Color(cgColor: cg)
     }
}

// --- Mock Data Structures (Simulating MusicKit Types) ---
// NOTE: These are simplified versions for UI demonstration purposes ONLY.

// Represents MusicKit.MusicItemID (Unchanged)
struct MockMusicItemID: Equatable, Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral, Codable, CustomStringConvertible {
    var rawValue: String
    var description: String { rawValue }
    init(_ rawValue: String) { self.rawValue = rawValue }
    init(rawValue: String) { self.rawValue = rawValue }
    init(stringLiteral value: String) { self.rawValue = value }
}

// Represents MusicKit.Artwork (Corrected)
struct MockArtwork: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
    var maximumWidth: Int = 1000
    var maximumHeight: Int = 1000
    var alternateText: String? = "Sample Artwork"

    // Store colors using the Codable helper struct
    var backgroundColor: CodableColor? = CodableColor(cgColor: CGColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
    var primaryTextColor: CodableColor? = CodableColor(cgColor: CGColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    var secondaryTextColor: CodableColor? = CodableColor(cgColor: CGColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0))
    var tertiaryTextColor: CodableColor? = CodableColor(cgColor: CGColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0))
    var quaternaryTextColor: CodableColor? = CodableColor(cgColor: CGColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
   
//    var primaryTextColor: CodableColor? = CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//    var secondaryTextColor: CodableColor? = CodableColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
//    var tertiaryTextColor: CodableColor? = CodableColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
//    var quaternaryTextColor: CodableColor? = CodableColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)

    // Computed properties to easily get CGColor or SwiftUI Color (optional but convenient)
    var cgBackgroundColor: CGColor? { backgroundColor?.cgColor }
    var cgPrimaryTextColor: CGColor? { primaryTextColor?.cgColor }
    // ... add others if needed

    var swiftUIColorBackground: Color? { backgroundColor?.swiftUIColor }
    var swiftUIColorPrimaryText: Color? { primaryTextColor?.swiftUIColor }
      // ... add others if needed

    // Mock URL generation - in reality, this would use the actual sizing
    // This function remains unchanged as it doesn't depend on the CGColor properties directly
    func url(width: Int, height: Int) -> URL? {
        return URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/e1/f9/1a/e1f91aa8-78a4-8afa-67fa-a5548c7931d8/196589920424.jpg/\(width)x\(height)bb.jpg")
    }
    var description: String { "Artwork (\(maximumWidth)x\(maximumHeight))" }

    // No need to implement custom init(from:) or encode(to:) as Codable conformance
    // will now be synthesized automatically for MockArtwork because all its stored
    // properties (Int, String?, CodableColor?) are Codable.
}

// Represents MusicKit.EditorialNotes (Unchanged)
struct MockEditorialNotes: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
    var short: String? = "A brief note."
    var standard: String? = "A standard, slightly longer note about the content."
    var name: String? = "Editor's Choice"
    var tagline: String? = "Must Listen!"
    var description: String { "Notes: \(name ?? "N/A") - \(tagline ?? "N/A")" }
}

// Represents MusicKit.PlayParameters (Unchanged - still opaque)
struct MockPlayParameters: Equatable, Hashable, Sendable, Codable {
    private var internalData = UUID().uuidString
}

// Represents MusicKit.PreviewAsset (Corrected to use MockArtwork)
struct MockPreviewAsset: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
    // Use the corrected MockArtwork
    var artwork: MockArtwork? = MockArtwork() // Optional preview artwork
    var url: URL? = URL(string: "https://example.com/preview.mp3")
    var hlsURL: URL? = URL(string: "https://example.com/preview.m3u8")
    var description: String { "Preview (URL: \(url != nil), HLS: \(hlsURL != nil))" }
}

// Represents MusicKit.ContentRating (Unchanged)
enum MockContentRating: String, Codable, Equatable, Hashable, Sendable {
    case clean = "clean"
    case explicit = "explicit"
}

// Represents MusicKit.AudioVariant (Unchanged)
enum MockAudioVariant: String, CaseIterable, Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
    case dolbyAtmos = "Dolby Atmos"
    case dolbyAudio = "Dolby Audio"
    case lossless = "Lossless"
    case highResolutionLossless = "Hi-Res Lossless"
    case lossyStereo = "Stereo"
    case spatialAudio = "Spatial Audio"
    var description: String { self.rawValue }
}

// Represents a generic MusicItem for the collection (Unchanged)
protocol MockMusicItem: Identifiable {
    var id: MockMusicItemID { get }
}
struct MockSongItem: MockMusicItem, Equatable, Hashable, Sendable, Codable { // Added Codable conformance
    var id: MockMusicItemID
    var title: String
}

// Represents MusicKit.MusicItemCollection<T> (Unchanged structurally, but T needs to be Codable now)
struct MockMusicItemCollection<T: MockMusicItem>: RandomAccessCollection, Equatable, Hashable, Sendable, Codable, CustomStringConvertible, ExpressibleByArrayLiteral where T: Equatable, T: Hashable, T: Sendable, T: Codable { // Ensure T is Codable

    var items: [T]
    var title: String? = "Featured Collection"
    var hasNextBatch: Bool = true // Assume more can be loaded

    // --- Collection Conformance ---
    var startIndex: Int { items.startIndex }
    var endIndex: Int { items.endIndex }
    func index(after i: Int) -> Int { items.index(after: i) }
    subscript(position: Int) -> T { items[position] }

    // --- Init ---
    init(_ items: [T] = [], title: String? = nil, hasNextBatch: Bool = false) {
        self.items = items
        self.title = title
        self.hasNextBatch = hasNextBatch
    }

    init(arrayLiteral elements: T...) {
        self.items = elements
        self.title = nil
        self.hasNextBatch = false
    }

    // --- Mock Methods ---
    func nextBatch(limit: Int? = nil) async throws -> MockMusicItemCollection<T>? {
        print("Simulating fetch next batch...")
        return nil
    }

    var description: String { "\(title ?? "Collection"): \(items.count) items \(hasNextBatch ? "(more available)" : "")" }

    // --- Equatable & Hashable --- (Synthesized if T is Equatable/Hashable)
    // --- Codable --- (Synthesized if T is Codable)
}

// --- SwiftUI Views ---

struct MusicItemIDView: View { // Unchanged
    let itemID: MockMusicItemID
    // ... body as before ...
     var body: some View {
         Text("ID: \(itemID.rawValue)")
             .font(.caption)
             .foregroundColor(.secondary)
             .lineLimit(1)
             .truncationMode(.middle)
     }
}

struct ArtworkView: View { // Updated to use CodableColor/SwiftUIColor
    let artwork: MockArtwork
    let size: CGFloat = 60

    var body: some View {
        VStack(alignment: .leading) {
            // Assuming ArtworkImage exists and can handle the original MusicKit.Artwork
            // If using mocks, you might need to adapt ArtworkImage or use AsyncImage
            // ArtworkImage(artwork, width: size, height: size)

            // Fallback using AsyncImage with the URL function
            AsyncImage(url: artwork.url(width: Int(size * 2), height: Int(size * 2))) { phase in
                if let image = phase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } else if phase.error != nil {
                    Image(systemName: "photo.fill") // Error icon
                        .foregroundColor(.red)
                        .frame(width: size, height: size)
                        .background(Color.gray.opacity(0.2))

                } else {
                    Rectangle() // Placeholder uses the CodableColor
                        .fill(artwork.swiftUIColorBackground ?? Color.secondary.opacity(0.3))
                        .overlay(ProgressView())
                }
            }
            .frame(width: size, height: size)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )

            Text("Max: \(artwork.maximumWidth)x\(artwork.maximumHeight)")
                .font(.caption2)
                .foregroundColor(.gray)
            if let alt = artwork.alternateText {
                Text("Alt: \(alt)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            // Use the computed SwiftUI Color property
             if let bgColor = artwork.swiftUIColorBackground {
                 HStack {
                     Text("BG:")
                     Rectangle()
                         .fill(bgColor) // Use SwiftUI Color
                         .frame(width: 15, height: 15)
                         .cornerRadius(3)
                     // Use the computed SwiftUI Color property
                     if let primaryColor = artwork.swiftUIColorPrimaryText {
                         Text("TXT:")
                         Rectangle()
                             .fill(primaryColor)
                             .frame(width: 15, height: 15)
                             .cornerRadius(3)
                             .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray, lineWidth: 0.5))
                    }
                 }
                 .font(.caption2)
                 .foregroundColor(.gray)
            }
        }
    }
}

struct EditorialNotesView: View { // Unchanged
    let notes: MockEditorialNotes
    // ... body as before ...
      var body: some View {
          VStack(alignment: .leading, spacing: 4) {
              if let name = notes.name {
                  Text(name).font(.headline).bold()
              }
              if let tagline = notes.tagline {
                  Text(tagline).font(.subheadline).italic().foregroundColor(.secondary)
              }
              if let standard = notes.standard {
                  Text(standard).font(.body)
              } else if let short = notes.short {
                  Text(short).font(.body).foregroundColor(.gray)
              }
          }
          .padding(.vertical, 5)
      }
}

struct PlayParametersView: View { // Unchanged
    let playParams: MockPlayParameters?
    // ... body as before ...
     var body: some View {
         if playParams != nil {
             HStack {
                 Image(systemName: "play.circle.fill")
                     .foregroundColor(.green)
                 Text("Playable")
                     .font(.caption)
                     .foregroundColor(.secondary)
             }
         } else {
             HStack {
                 Image(systemName: "play.slash")
                     .foregroundColor(.red)
                 Text("Not Playable")
                     .font(.caption)
                     .foregroundColor(.secondary)
             }
         }
     }
}

struct PreviewAssetView: View { // Updated to use corrected MockArtwork
    let asset: MockPreviewAsset
    // ... body as before, will use the updated ArtworkView ...
      var body: some View {
          HStack {
              if let art = asset.artwork {
                  // ArtworkView(artwork: art, size: 40) // Smaller artwork for preview
                  ArtworkView(artwork: art)
              } else {
                  Image(systemName: "film")
                      .foregroundColor(.gray)
                      .frame(width: 40, height: 40)
              }
              VStack(alignment: .leading) {
                  if asset.url != nil {
                      HStack{
                          Image(systemName: "link")
                          Text("MP3 Preview")
                      }
                      .font(.caption)
                      .foregroundColor(.blue)
                  }
                  if asset.hlsURL != nil {
                      HStack{
                           Image(systemName: "play.tv")
                           Text("HLS Preview")
                      }
                     .font(.caption)
                     .foregroundColor(.purple)
                  }
                  if asset.url == nil && asset.hlsURL == nil {
                      Text("No Preview Available")
                          .font(.caption)
                          .foregroundColor(.secondary)
                  }
              }
          }
      }
}

struct ContentRatingView: View { // Unchanged
    let rating: MockContentRating?
    // ... body as before ...
      var body: some View {
          if let rating = rating {
              switch rating {
              case .clean:
                  Text("Clean")
                      .font(.caption)
                      .padding(.horizontal, 5)
                      .background(Color.green.opacity(0.2))
                      .clipShape(Capsule())
              case .explicit:
                  Text("Explicit")
                      .font(.caption)
                      .fontWeight(.semibold)
                      .padding(.horizontal, 5)
                      .background(Color.red.opacity(0.2))
                      .clipShape(Capsule())
              }
          } else {
               Text("Unrated")
                  .font(.caption)
                  .foregroundColor(.gray)
                  .padding(.horizontal, 5)
                  .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
          }
      }
}

struct AudioVariantView: View {
    let variant: MockAudioVariant

    var iconName: String {
        switch variant {
        case .dolbyAtmos: return "speaker.wave.3.fill"
        case .dolbyAudio: return "speaker.surround.left.fill" // Example
        case .lossless: return "headphones.circle"
        case .highResolutionLossless: return "hifispeaker.and.homepodmini.fill" // Example
        case .lossyStereo: return "speaker.fill"
        case .spatialAudio: return "rotate.3d"
        }
    }

    var color: Color {
         switch variant {
        case .dolbyAtmos, .spatialAudio: return .purple
        case .dolbyAudio: return .blue
        case .lossless, .highResolutionLossless: return .yellow
        case .lossyStereo: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: iconName)
                .foregroundColor(color)
            Text(variant.description)
        }
        .font(.caption)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}


struct MusicItemCollectionView<T: MockMusicItem>: View where T: Equatable, T: Hashable, T: Sendable, T: Codable { // Ensure T: Codable
    let collection: MockMusicItemCollection<T>
    // ... body as before ...
      var body: some View {
          VStack(alignment: .leading) {
              if let title = collection.title {
                  Text(title)
                      .font(.headline)
              } else {
                   Text("Collection")
                      .font(.headline)
                      .foregroundColor(.gray)
              }
              HStack {
                  Text("\(collection.items.count) items")
                  if collection.hasNextBatch {
                      Image(systemName: "ellipsis.circle.fill")
                          .foregroundColor(.blue)
                      Text("(More available)")
                          .foregroundColor(.blue)

                  }
              }
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding()
          .background(Color.secondary.opacity(0.1))
          .cornerRadius(8)
      }
}

// --- Main Demo View ---

struct SupportingDataStructuresView: View {
    // Mock Data Instances (using corrected MockArtwork)
    let mockItemID = MockMusicItemID("song.123456789")
    let mockArtwork = MockArtwork() // Uses default CodableColor values
    let mockNotes = MockEditorialNotes()
    let mockPlayParams: MockPlayParameters? = MockPlayParameters()
    let mockPreview = MockPreviewAsset() // Uses default MockArtwork
    let mockRatingExplicit: MockContentRating? = .explicit
    let mockRatingClean: MockContentRating? = .clean
    let mockRatingNil: MockContentRating? = nil
    let mockVariants: [MockAudioVariant] = [.dolbyAtmos, .highResolutionLossless, .lossyStereo]
    let mockCollection: MockMusicItemCollection<MockSongItem> = MockMusicItemCollection(
        [MockSongItem(id: "s.1", title: "Song One"), MockSongItem(id: "s.2", title: "Song Two")],
        title: "Recent Hits",
        hasNextBatch: true
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                 Text("Supporting Data Structures").font(.largeTitle).bold().padding(.bottom)

                 GroupBox("MusicItemID") { // Use leading alignment
                     MusicItemIDView(itemID: mockItemID)
                 }

                 GroupBox("Artwork") {
                     ArtworkView(artwork: mockArtwork)
                 }

                 GroupBox("EditorialNotes") { // Use leading alignment
                    EditorialNotesView(notes: mockNotes)
                 }

                  GroupBox("PlayParameters") {
                      HStack{
                        PlayParametersView(playParams: mockPlayParams)
                        Spacer()
                        PlayParametersView(playParams: nil) // Example of nil
                      }
                  }

                  GroupBox("PreviewAsset") {
                      PreviewAssetView(asset: mockPreview)
                      Divider()
                      // Example HLS only requires MockArtwork to be Codable
                      PreviewAssetView(asset: MockPreviewAsset(artwork: MockArtwork(alternateText: "HLS Only Artwork"), url: nil, hlsURL: URL(string:"hls://example.com")))
                  }

                  GroupBox("ContentRating") {
                       HStack {
                           ContentRatingView(rating: mockRatingExplicit)
                           Spacer()
                           ContentRatingView(rating: mockRatingClean)
                           Spacer()
                           ContentRatingView(rating: mockRatingNil)
                       }
                  }

                  GroupBox("AudioVariant") {
                       ScrollView(.horizontal, showsIndicators: false) {
                           HStack {
                               ForEach(MockAudioVariant.allCases, id: \.self) { variant in
                                   AudioVariantView(variant: variant)
                               }
                           }
                           .padding(.horizontal) // Add padding inside ScrollView
                       }
                       .padding(.horizontal, -15) // Negative padding to counteract default ScrollView inset if needed
                  }

                  GroupBox("MusicItemCollection<MockSongItem>") {
                       MusicItemCollectionView(collection: mockCollection)
                  }

//                   GroupBox("MusicItemCollection<MockSongItem> (Empty)") {
//                       MusicItemCollectionView(collection: MockMusicItemCollection<MockSongItem>())
//                   }

            }
            .padding()
        }
    }
}

// --- Previews ---
#Preview {
    SupportingDataStructuresView()
}
