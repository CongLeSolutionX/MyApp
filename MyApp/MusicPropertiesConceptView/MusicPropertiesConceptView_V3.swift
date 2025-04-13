//
//  MusicPropertiesConceptView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
// Assuming `MusicKit` types are available or placeholders are defined
// For demonstration, we'll use placeholder types if MusicKit isn't directly linkable here.

// --- Placeholder Types (Simulate MusicKit structures for UI purposes) ---

struct MusicItemID: Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
    init(rawValue: String) { self.rawValue = rawValue }
    init(stringLiteral value: String) { self.rawValue = value }
    var description: String { rawValue }
}

protocol MusicItem: Identifiable, Hashable, Sendable {
    var id: MusicItemID { get }
}

protocol MusicPropertyContainer {} // Marker protocol

struct Artwork: Hashable, Sendable {
    // Placeholder properties
    var description: String { "Artwork Description" }
}

struct Album: MusicItem, MusicPropertyContainer {
    let id: MusicItemID
    var title: String = "Placeholder Album"
    var artistName: String = "Placeholder Artist"
    // Add other properties as needed for demonstration
}
struct Artist: MusicItem {
    let id: MusicItemID
    var name: String = "Placeholder Artist"
}
struct Track: MusicItem {
    let id: MusicItemID
    var title: String = "Placeholder Track"
}
struct Genre: MusicItem {
    let id: MusicItemID
    var name: String = "Placeholder Genre"
}
struct URL: Hashable {
    let string: String // Simplified
}
enum AudioVariant: String, CaseIterable, Hashable {
    case lossless, highResolutionLossless, dolbyAtmos, dolbyAudio, lossyStereo, spatialAudio
}

// --- Property Type Placeholders (Simulate the type hierarchy) ---
//@unchecked Sendable
class AnyMusicProperty: Hashable, Equatable { // Base class concept
    let propertyName: String
    let rootType: String

    init(name: String, root: String) {
        self.propertyName = name
        self.rootType = root
    }

    static func == (lhs: AnyMusicProperty, rhs: AnyMusicProperty) -> Bool {
        lhs.propertyName == rhs.propertyName && lhs.rootType == rhs.rootType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(propertyName)
        hasher.combine(rootType)
    }
}

class PartialMusicProperty<Root>: AnyMusicProperty { // Intermediate concept
     init(name: String) {
        super.init(name: name, root: String(describing: Root.self))
    }
}

class PartialMusicAsyncProperty<Root>: PartialMusicProperty<Root> {} // Intermediate async concept

// Specific Property Type Concepts
class MusicAttributeProperty<Root, Value>: PartialMusicAsyncProperty<Root> {
    // Represents a simple attribute (like title, duration)
}
class MusicExtendedAttributeProperty<Root, Value>: PartialMusicAsyncProperty<Root> {
    // Represents an attribute that might need an extra lookup (like artistURL)
}
class MusicRelationshipProperty<Root, Relationship>: PartialMusicAsyncProperty<Root> {
    // Represents a relationship to another MusicItem or Collection (like artists, tracks)
}

// --- Static Property Placeholders on a MusicItem ---
// This simulates how MusicKit defines static properties for requesting data
extension Album {
    static let artists = MusicRelationshipProperty<Album, Artist>(name: "artists")
    static let tracks = MusicRelationshipProperty<Album, Track>(name: "tracks")
    static let genres = MusicRelationshipProperty<Album, Genre>(name: "genres")
    static let artistURL = MusicExtendedAttributeProperty<Album, URL>(name: "artistURL")
    static let audioVariants = MusicExtendedAttributeProperty<Album, [AudioVariant]>(name: "audioVariants")
    static let titleProp = MusicAttributeProperty<Album, String>(name: "title") // Assuming title is fetchable attribute too
    static let releaseDate = MusicAttributeProperty<Album, Date?>(name: "releaseDate") // Assuming it's an attribute
}

// --- SwiftUI Views ---

/// Visually represents the hierarchy of MusicKit property types.
struct MusicPropertyHierarchyView: View {
    var body: some View {
        GroupBox("Music Property Type Hierarchy") {
            VStack(alignment: .leading, spacing: 10) {
                PropertyTypeLabel(name: "AnyMusicProperty", color: .gray, systemImage: "puzzlepiece.extension")
                HStack(alignment: .top) {
                    Spacer().frame(width: 20) // Indentation
                    VStack(alignment: .leading, spacing: 10) {
                        PropertyTypeLabel(name: "PartialMusicProperty<Root>", color: .blue, systemImage: "puzzlepiece")
                        HStack(alignment: .top) {
                           Spacer().frame(width: 20) // Indentation
                            VStack(alignment: .leading, spacing: 10) {
                                PropertyTypeLabel(name: "PartialMusicAsyncProperty<Root>", color: .purple, systemImage: "bolt.fill")
                                HStack(alignment: .top) {
                                    Spacer().frame(width: 20) // Indentation
                                    VStack(alignment: .leading, spacing: 5) {
                                        PropertyTypeLabel(name: "MusicAttributeProperty<Root, Value>", color: .green, systemImage: "a.square.fill", description: "Simple value (e.g., title, duration)")
                                        PropertyTypeLabel(name: "MusicRelationshipProperty<Root, Related>", color: .orange, systemImage: "link", description: "Link to other items (e.g., artists, tracks)")
                                        PropertyTypeLabel(name: "MusicExtendedAttributeProperty<Root, Value>", color: .red, systemImage: "wand.and.stars", description: "Value needing extra lookup (e.g., artistURL)")

                                    }
                                    .padding(.leading, 5)
                                }
                            }
                             .padding(.leading, 5)
                        }
                    }
                    .padding(.leading, 5)
                }
            }
            .font(.system(.caption, design: .monospaced))
            .padding(.vertical, 5)
        }
        .padding()
    }
}

/// Helper view for displaying a property type label.
struct PropertyTypeLabel: View {
    let name: String
    let color: Color
    let systemImage: String
    var description: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
           Label {
               Text(name).fontWeight(.semibold)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundColor(color)
           }
            if let description {
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.leading, 25) // Align with text
            }
        }
    }
}

// --- Example Usage within MusicItemStaticPropertiesView ---
struct MusicItemStaticPropertiesView: View {
    let itemType = "Album"
    // Ensure these static properties actually exist on your placeholder Album type
    // and inherit from the correct base classes (MusicAttributeProperty, etc.)
    let properties: [AnyMusicProperty] = [
        Album.titleProp,
        Album.artists,
        Album.tracks,
        Album.genres,
        Album.artistURL,
        Album.audioVariants,
        Album.releaseDate
    ]

    var body: some View {
        GroupBox("Static Properties on \(itemType)") {
            VStack(alignment: .leading) {
                Text("Music items (like `\(itemType)`) define static properties representing fetchable data:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)

                ForEach(properties, id: \.self) { prop in
                    StaticPropertyRow(property: prop) // This should now work
                }
                 Text("... and others")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 2)

            }
            .padding(.vertical, 5)
        }
        .padding()
    }
}
/// Helper view for displaying a static property example.
struct StaticPropertyRow: View {
    let property: AnyMusicProperty // Correctly typed base class

    var propertyTypeName: String {
        switch property {
        // Corrected: Remove <_,_> from the 'is' checks
        case is MusicAttributeProperty<Any, Any>: break // Still need concrete types or Any here if using generic type parameters explicitly
            // Safer alternative is to rely on the base type check:
            // case property as? MusicAttributePropertyProtocol != nil // If you had protocols
            // Simplest Fix: Check the base generic type directly
        case is MusicAttributeProperty<Any, Any>:  // Check if it IS ANY kind of MusicAttributeProperty
            return "Attribute"
        case is MusicRelationshipProperty<Any, Any>: // Check if it IS ANY kind of MusicRelationshipProperty
            return "Relationship"
        case is MusicExtendedAttributeProperty<Any, Any>: // Check if it IS ANY kind of MusicExtendedAttributeProperty
            return "Extended Attribute"
        default:
            return "Property" // Fallback
        }
        return "No thing found"
    }

    var propertyTypeColor: Color {
        switch property {
        // Corrected: Remove <_,_> from the 'is' checks
        case is MusicAttributeProperty<Any, Any>: // Check if it IS ANY kind of MusicAttributeProperty
            return .green
        case is MusicRelationshipProperty<Any, Any>: // Check if it IS ANY kind of MusicRelationshipProperty
            return .orange
        case is MusicExtendedAttributeProperty<Any, Any>: // Check if it IS ANY kind of MusicExtendedAttributeProperty
            return .red
        default:
            return .gray // Fallback
        }
    }

    // Assuming this body structure from the previous example
    var body: some View {
        HStack {
            Text(".`\(property.propertyName)`")
                .font(.system(.caption, design: .monospaced).weight(.medium))

            Spacer()

            Text(propertyTypeName)
                .font(.system(.caption2, design: .monospaced))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(propertyTypeColor.opacity(0.2))
                .foregroundColor(propertyTypeColor)
                .cornerRadius(4)
        }
        .padding(.vertical, 1)
    }
}

/// Demonstrates the concept of using `.with()` method.
struct WithMethodDemonstrationView: View {
    let album = Album(id: "alb.12345") // Example instance

    @State private var isLoading = false
    @State private var loadedInfo = ""

    var body: some View {
        GroupBox("Fetching Properties with `.with()`") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Use the static properties with the `.with()` instance method to load specific data:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Simulate the code structure
                Text("`let detailedAlbum = try await` ") +
                Text("album").foregroundColor(.blue) +
                Text("`.with(`") +
                Text("[.artists, .tracks]").foregroundColor(.orange) +
                Text("`)`")

                Text("Or using preferred source:")
                   .font(.caption)
                   .foregroundColor(.secondary)
                   .padding(.top, 5)

                Text("`let libraryAlbum = try await` ") +
                Text("album").foregroundColor(.blue) +
                Text("`.with(`") +
                Text("[.tracks]").foregroundColor(.orange) +
                Text("`, preferredSource: `") +
                Text(".library").foregroundColor(.purple) +
                Text("`)`")

                 Button {
                     simulateLoad()
                 } label: {
                      Label(isLoading ? "Loading..." : "Simulate Loading Artists & Tracks", systemImage: "arrow.down.circle.dotted")
                 }
                 .buttonStyle(.bordered)
                 .disabled(isLoading)
                 .padding(.top, 8)

                 if !loadedInfo.isEmpty {
                     Text(loadedInfo)
                         .font(.caption)
                         .foregroundColor(.green)
                         .padding(.top, 5)
                         .transition(.opacity)
                 }
            }
            .font(.system(.callout, design: .monospaced))
        }
        .padding()
    }

     func simulateLoad() {
        isLoading = true
        loadedInfo = ""
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulate successful loading
            loadedInfo = "✅ Successfully loaded 'artists' and 'tracks' relationships for \(album.title)."
            isLoading = false
        }
    }
}

// Main container view to display all components
struct MusicPropertiesConceptView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Understanding MusicKit Properties")
                    .font(.title)
                    .padding()

                MusicPropertyHierarchyView()
                Divider().padding(.horizontal)
                MusicItemStaticPropertiesView()
                 Divider().padding(.horizontal)
                WithMethodDemonstrationView()

                 Spacer() // Pushes content to the top
            }
        }
    }
}

// --- Preview ---
struct MusicPropertiesConceptView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPropertiesConceptView()
    }
}
