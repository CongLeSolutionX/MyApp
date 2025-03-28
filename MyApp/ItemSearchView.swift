//
//  ItemSearchView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI
import UniformTypeIdentifiers // For UTType

// --- Paste the UPDATED MockAppItem struct definition here ---
// Ensure MockAppItem has the `thumbnailSystemName: String?` and corrected Hashable/Equatable conformance
struct MockAppItem: Identifiable, Hashable {
    let id = UUID()
    var uniqueIdentifier: String
    var title: String
    var contentDescription: String
    var keywords: [String] = ["example", "mock", "data"]
    var contentType: UTType = .plainText
    var thumbnailSystemName: String? = "doc.text.fill" // Store system name
    var contentURL: URL? = URL(string: "myapp://item/\(UUID().uuidString)")
    var supportsPhoneCall: Bool = false
    var phoneNumber: String? = nil
    var supportsNavigation: Bool = false
    var latitude: Double? = nil
    var longitude: Double? = nil
    var expirationDate: Date? = nil
    var creationDate: Date = Date()
    var authorNames: [String]? = ["Demo Author"]

    // IsEligibleForAI computed property ... (keep as before)
     var isEligibleForAI: Bool {
         let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
         let isRecent = creationDate >= twentyFourHoursAgo
         let hasContent = !contentDescription.isEmpty // Simplification
         let minLength = 200 // For summary
         _ = contentDescription.count >= minLength
         // Use contains check for UTI conformance comparison as direct equality can be tricky with dynamic UTIs
         let validContentType = contentType.conforms(to: .message) || contentType.conforms(to: .emailMessage) || contentType.conforms(to: .audiovisualContent) // More general example

         return isRecent && hasContent && validContentType // Length check applied later based on flag
     }

    // Explicit Equatable & Hashable conformances... (keep as before)
     static func == (lhs: MockAppItem, rhs: MockAppItem) -> Bool {
         return lhs.id == rhs.id
     }

     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
}

// --- Suggestion Struct (Simple String wrapper for this example) ---
struct SearchSuggestion: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

// --- View to display a single search result row ---
struct SearchResultRow: View {
    let item: MockAppItem

    var body: some View {
        HStack {
            // Create Image from system name
            Group {
                if let systemName = item.thumbnailSystemName {
                    Image(systemName: systemName)
                } else {
                    Image(systemName: "doc") // Default fallback
                }
            }
            .font(.title2)
            .foregroundStyle(.secondary)
            .frame(width: 30)

            VStack(alignment: .leading) {
                Text(item.title).bold()
                Text(item.contentDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                // Highlight keywords (simple example)
                Text("Keywords: \(item.keywords.joined(separator: ", "))")
                  .font(.caption2)
                  .foregroundColor(.orange)
                  .lineLimit(1)
            }
        }
    }
}

// --- The Main Search View ---
struct ItemSearchView: View {
    // The full list of items (passed in or loaded)
    @State private var allItems: [MockAppItem] = [
        // Add sample MockAppItem instances here (using the corrected struct)
        MockAppItem(uniqueIdentifier: "doc-001", title: "Project Proposal", contentDescription: "Detailed proposal for the Q3 project initiative, covering scope, resources, and timeline.", keywords: ["project", "proposal", "q3"], contentType: .rtf, thumbnailSystemName: "doc.richtext"),
        MockAppItem(uniqueIdentifier: "contact-002", title: "Main Office", contentDescription: "Company Headquarters Location", keywords: ["contact", "office", "address"], contentType: .contact, thumbnailSystemName: "building.2.fill", supportsNavigation: true, latitude: 37.3349, longitude: -122.0090),
        MockAppItem(uniqueIdentifier: "msg-003", title: "Lunch Meeting Confirmation", contentDescription: "Confirming our lunch meeting for tomorrow at 12:30 PM at the usual place.", keywords: ["meeting", "lunch", "confirmation"], contentType: .message, thumbnailSystemName: "message.circle.fill", authorNames: ["Alice"]),
         MockAppItem(uniqueIdentifier: "audio-004", title: "Meeting Recap (Audio)", contentDescription: "Transcribed text from the project sync meeting held on Monday.", keywords: ["meeting", "recap", "audio", "transcript"], contentType: UTType("public.voice-audio") ?? .audio, thumbnailSystemName: "waveform"), // Provide default UTI if custom fails
        MockAppItem(uniqueIdentifier: "doc-005", title: "Onboarding Checklist", contentDescription: "List of tasks for new employee onboarding.", keywords: ["onboarding", "checklist", "hr"], contentType: .plainText, thumbnailSystemName: "checklist")
    ]

    // State for the search text entered by the user
    @State private var searchText: String = ""

    // State for the filtered items to be displayed
    @State private var filteredItems: [MockAppItem] = []

    // State for dynamic search suggestions
    @State private var currentSuggestions: [SearchSuggestion] = [
        SearchSuggestion(text: "Project"),
        SearchSuggestion(text: "Meeting"),
        SearchSuggestion(text: "Checklist")
    ]

    var body: some View {
        NavigationStack {
            List {
                // Display search results
                ForEach(filteredItems) { item in
                    SearchResultRow(item: item)
                }

                // Show message if no results found for the search term
                if filteredItems.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText) // Standard iOS 'No Results' view
                }
            }
            .navigationTitle("Search Items")
            // --- Searchable Modifier ---
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always), // Common placement
                        prompt: "Search by Title, Desc, Keywords")
            // --- Search Suggestions ---
            .searchSuggestions {
                // Display dynamic suggestions based on current state
                ForEach(currentSuggestions) { suggestion in
                     // Simple text suggestion
                    Text(suggestion.text)
                         // This modifier makes the suggestion tappable
                         // and fills the search bar with its text
                        .searchCompletion(suggestion.text)
                }

                // Could add sections for different suggestion types (e.g., Recent)
                // Section("Recent Searches") { ... }
            }
            // --- Respond to Search Text Changes ---
            .onChange(of: searchText) { _, newValue in // Use new signature for iOS 17+
                updateFilteredItems(query: newValue)
                updateSuggestions(query: newValue)
            }
            // --- Initial Load ---
            .onAppear {
                // Initially, show all items when the view appears and search is empty
                updateFilteredItems(query: "")
            }
        }
    }

    // --- Filtering Logic ---
    private func updateFilteredItems(query: String) {
        if query.isEmpty {
            // If search query is empty, show all items
            filteredItems = allItems
        } else {
            // Filter items based on title, description, or keywords containing the query
            // This simulates the result of a Core Spotlight query
            let lowercasedQuery = query.lowercased()
            filteredItems = allItems.filter { item in
                item.title.lowercased().contains(lowercasedQuery) ||
                item.contentDescription.lowercased().contains(lowercasedQuery) ||
                item.keywords.contains { $0.lowercased().contains(lowercasedQuery) }
            }
        }
        print("Simulating search completion. Found \(filteredItems.count) items for query '\(query)'")
    }

    // --- Suggestion Logic (Example) ---
    private func updateSuggestions(query: String) {
        if query.isEmpty {
            // Reset to default suggestions when search is cleared
            currentSuggestions = [
                SearchSuggestion(text: "Project"),
                SearchSuggestion(text: "Meeting"),
                SearchSuggestion(text: "Checklist")
            ]
        } else {
            // Offer suggestions based on potential matches in titles (simple example)
            let potentialMatches = allItems
                .filter { $0.title.lowercased().hasPrefix(query.lowercased()) }
                .map { SearchSuggestion(text: $0.title) } // Suggest the full title
                .prefix(3) // Limit suggestions

            // Offer suggestions based on keywords
             let keywordMatches = allItems
                .flatMap { $0.keywords } // Get all keywords
                .filter { $0.lowercased().contains(query.lowercased()) } // Find keywords containing query
                .map{ SearchSuggestion(text: $0)} // Suggest the keyword
                .prefix(2) // Limit suggestions

             // Combine and remove duplicates (simplified)
            currentSuggestions = Array(Set(potentialMatches + keywordMatches)).sorted { $0.text < $1.text }

        }
        print("Updating suggestions for query '\(query)'. Current suggestions: \(currentSuggestions.map { $0.text })")
    }
}

// --- Preview ---
#Preview {
    ItemSearchView()
}
