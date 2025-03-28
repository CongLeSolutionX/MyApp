//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}
import SwiftUI
import CoreSpotlight
import UniformTypeIdentifiers

// --- Mock Data Structures ---

struct MockAppItem: Identifiable, Hashable { // Now conforms correctly
    let id = UUID()
    var uniqueIdentifier: String
    var title: String
    var contentDescription: String
    var keywords: [String] = ["example", "mock", "data"]
    var contentType: UTType = .plainText // Example type
    // --- MODIFIED --- Store the system name (String), which IS Hashable
    var thumbnailSystemName: String? = "doc.text.fill"
    // --- REMOVED --- var thumbnail: Image? = Image(systemName: "doc.text.fill")
    var contentURL: URL? = URL(string: "myapp://item/\(UUID().uuidString)")
    var supportsPhoneCall: Bool = false
    var phoneNumber: String? = nil
    var supportsNavigation: Bool = false
    var latitude: Double? = nil
    var longitude: Double? = nil
    var expirationDate: Date? = nil
    var creationDate: Date = Date()
    var authorNames: [String]? = ["Demo Author"]

    // For AI Features
    var isEligibleForAI: Bool {
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
        let isRecent = creationDate >= twentyFourHoursAgo
        let hasContent = !contentDescription.isEmpty // Simplification
        let minLength = 200 // For summary
        let meetsLength = contentDescription.count >= minLength
        // Use contains check for UTI conformance comparison as direct equality can be tricky with dynamic UTIs
        let validContentType = contentType.conforms(to: .message) || contentType.conforms(to: .emailMessage) || contentType.conforms(to: .audiovisualContent) // More general example

        return isRecent && hasContent && validContentType // Length check applied later based on flag
    }

    // --- ADDED --- Manually implement Equatable as UTType might not be auto-equatable depending on context
    // Often needed when Hashable conformance is manual or includes complex types.
    // Let's implement it explicitly to be safe.
    static func == (lhs: MockAppItem, rhs: MockAppItem) -> Bool {
        return lhs.id == rhs.id // Identity is usually sufficient for Identifiable items
        // If you require value equality, compare all relevant properties:
        // return lhs.uniqueIdentifier == rhs.uniqueIdentifier &&
        //        lhs.title == rhs.title // ... and so on for all properties except Image
    }

    // --- ADDED --- Manual Hashable conformance (hashes based on relevant properties)
    // We base hashability primarily on ID, but can include other stable identifiers.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        // Optionally combine other unique and hashable properties:
        // hasher.combine(uniqueIdentifier)
        // hasher.combine(contentType) // UTType is Hashable
    }
}

// MockSearchResult and MockSuggestion remain the same as before
struct MockSearchResult: Identifiable {
    let id = UUID()
    let item: MockAppItem
    var relevance: Double = Double.random(in: 0.5...1.0) // Simulate relevance
}

struct MockSuggestion: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var displayIcon: String? = nil
}

// --- SwiftUI Views ---
// (ContentView, SearchResultView, AIIntegrationView remain largely the same,
//  but ItemIndexingView needs updating where the thumbnail was used)

struct ItemIndexingView: View {
    let item: MockAppItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // --- MODIFIED --- Create the Image from the system name here
                Group {
                    if let systemName = item.thumbnailSystemName {
                        Image(systemName: systemName)
                    } else {
                        Image(systemName: "doc") // Default fallback
                    }
                }
                .foregroundStyle(.secondary) // Example styling

                Text(item.title).font(.headline)
                Spacer()
                Image(systemName: "lock.fill").foregroundColor(.blue).opacity(item.contentType == .contact ? 1 : 0)
                 Image(systemName: "tray.and.arrow.up.fill")
                     .foregroundColor(.green)

            }
            Text("ID: \(item.uniqueIdentifier)").font(.caption).foregroundColor(.secondary)
            // Use conforms(to:) for safer UTI comparisons
            Text("Type: \(item.contentType.preferredFilenameExtension ?? item.contentType.identifier)")
                 .font(.caption)
                 .foregroundColor(.secondary)

            DisclosureGroup("Attributes (CSSearchableItemAttributeSet)") {
                 VStack(alignment: .leading, spacing: 3){
                     Text("Desc: \(item.contentDescription)").lineLimit(2)
                     Text("Keywords: \(item.keywords.joined(separator: ", "))")
                     if let url = item.contentURL { Text("URL: \(url.absoluteString)").lineLimit(1) }
                     if let date = item.expirationDate { Text("Expires: \(date, style: .date)")}

                     if item.supportsPhoneCall, let phone = item.phoneNumber {
                         Label(phone, systemImage: "phone.fill").foregroundColor(.blue)
                     }
                     if item.supportsNavigation, let lat = item.latitude, let lon = item.longitude {
                         Label("\(lat, specifier: "%.4f"), \(lon, specifier: "%.4f")", systemImage: "map.fill").foregroundColor(.blue)
                     }
                 }
                 .font(.caption)
                 .foregroundColor(.gray)
             }
        }
    }
}

// NOTE: The rest of the ContentView, SearchResultView, AIIntegrationView and Preview
// code from the previous response would follow here, largely unchanged, but
// ensuring wherever `item.thumbnail` was used, it now uses
// `Image(systemName: item.thumbnailSystemName ?? "default_icon")`.
// I've included the updated ItemIndexingView above as the primary example.
// You would also need to replace the old MockAppItem definition with this revised one
// in the complete code file.

#Preview {
    ContentView() // Assuming ContentView exists as defined before
}

// Dummy ContentView for Preview purposes if not fully included
struct ContentView: View {
     @State private var itemsToIndex: [MockAppItem] = [
        MockAppItem(uniqueIdentifier: "doc-001", title: "Project Proposal", contentDescription: "Detailed proposal...", contentType: .rtf, thumbnailSystemName: "doc.richtext"),
        MockAppItem(uniqueIdentifier: "contact-002", title: "Main Office", contentDescription: "Headquarters", contentType: .contact, thumbnailSystemName: "building.2.crop.circle", supportsNavigation: true, latitude: 37.3349, longitude: -122.0090),
        MockAppItem(uniqueIdentifier: "msg-003", title: "Lunch Meeting", contentDescription: "Confirming lunch...", contentType: .message, thumbnailSystemName: "message.fill")
    ]
     var body: some View {
          List {
               Section("Items") {
                    ForEach(itemsToIndex) { item in
                         ItemIndexingView(item: item)
                    }
               }
          }
          .navigationTitle("Preview")
     }
}
