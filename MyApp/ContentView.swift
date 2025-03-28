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
import CoreSpotlight // Import for types like UTType, but actual API calls are omitted
import UniformTypeIdentifiers // For UTType

// --- Mock Data Structures ---

struct MockAppItem: Identifiable, Hashable {
    let id = UUID()
    var uniqueIdentifier: String
    var title: String
    var contentDescription: String
    var keywords: [String] = ["example", "mock", "data"]
    var contentType: UTType = .plainText // Example type
    var thumbnail: Image? = Image(systemName: "doc.text.fill")
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
        // Simplified eligibility check based on documentation
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
        let isRecent = creationDate >= twentyFourHoursAgo
        let hasContent = !contentDescription.isEmpty // Simplification
        let minLength = 200 // For summary
        let meetsLength = contentDescription.count >= minLength
        let validContentType = contentType == .message || contentType == .emailMessage || contentType == UTType("public.voice-audio") // Faking voice audio UTI

        return isRecent && hasContent && validContentType // Length check applied later based on flag
    }
}

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

struct ContentView: View {
    @State private var itemsToIndex: [MockAppItem] = [
        MockAppItem(uniqueIdentifier: "doc-001", title: "Project Proposal", contentDescription: "Detailed proposal for the Q3 project initiative, covering scope, resources, and timeline.", contentType: .rtf),
        MockAppItem(uniqueIdentifier: "contact-002", title: "Main Office", contentDescription: "Company Headquarters", contentType: .contact, supportsPhoneCall: true, phoneNumber: "1-800-555-1212", supportsNavigation: true, latitude: 37.3349, longitude: -122.0090),
        MockAppItem(uniqueIdentifier: "msg-003", title: "Lunch Meeting Confirmation", contentDescription: "Confirming our lunch meeting for tomorrow at 12:30 PM at the usual place. Let me know if anything changes. This message content is long enough, definitely over two hundred characters, to ensure it meets the basic length requirement for potential summarization by Apple Intelligence if the appropriate flags are set and other conditions like recency are met.", contentType: .message, authorNames: ["Alice"]),
        MockAppItem(uniqueIdentifier: "audio-004", title: "Meeting Recap", contentDescription: "Transcribed text from the project sync meeting held on Monday. We discussed blockers, next steps, and assigned action items. The transcript is quite detailed, running several paragraphs long and certainly exceeding the two hundred character minimum needed for summarization eligibility via Apple Intelligence. Key decisions were captured.", contentType: UTType("public.voice-audio")!, authorNames: nil) // Fake UTI
    ]

    // State for Search UI
    @State private var searchText: String = ""
    @State private var searchResults: [MockSearchResult] = []
    @State private var currentSuggestions: [MockSuggestion] = [
        MockSuggestion(text: "Project", displayIcon: "doc.text.magnifyingglass"),
        MockSuggestion(text: "Meeting", displayIcon: "calendar.magnifyingglass"),
        MockSuggestion(text: "Contact", displayIcon: "person.crop.circle")
    ]

    // State for Programmatic Search
    @State private var programmaticQueryString: String = "(title == \"*Proposal*\"cd || keywords == \"example\") && contentType == \"public.rtf\""
    @State private var programmaticSearchResults: [MockSearchResult] = []
    @State private var fetchAttributes: Set<String> = ["title", "contentDescription"]

    var body: some View {
        NavigationStack {
            List {
                // --- Section: Indexing Content ---
                Section("1. Indexing App Content (CSSearchableItem)") {
                    ForEach(itemsToIndex) { item in
                        ItemIndexingView(item: item)
                    }

                    HStack {
                        Spacer()
                        Button { /* Simulate batch indexing */ } label: {
                            Label("Index All (Batch)", systemImage: "text.append")
                        }
                        Spacer()
                        Button(role: .destructive) { /* Simulate deleting all */ } label: {
                            Label("Delete All", systemImage: "trash")
                        }
                        Spacer()
                    }
                }

                // --- Section: Building Search Interface ---
                Section("2. In-App Search (CSUserQuery)") {
                    Text("Use the search bar above to simulate user search.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Display simulated results
                    if !searchResults.isEmpty {
                        Text("Simulated Results:").font(.headline)
                        ForEach(searchResults.prefix(5)) { result in // Limit results displayed
                            SearchResultView(result: result)
                        }
                    } else if !searchText.isEmpty {
                         Text("No simulated results found for '\(searchText)'").foregroundColor(.secondary)
                    }

                    // Mention Prepare
                     Text("Spotlight Prepared: \(Image(systemName: "checkmark.circle.fill"))")
                        .font(.caption)
                        .foregroundColor(.green)
                        .onAppear {
                            // Represents calling CSUserQuery.prepare()
                            print("Simulating CSUserQuery.prepare()")
                        }

                    Text("Debounce: Wait ~0.3s after typing before querying.")
                       .font(.caption).foregroundColor(.orange)
                }

                 // --- Section: Apple Intelligence ---
                 Section("3. Apple Intelligence Features") {
                     Text("Enable Summarization/Prioritization (iOS 18.4+/macOS 15.4+)")
                         .font(.headline)
                     ForEach(itemsToIndex.filter { $0.contentType == .message || $0.contentType == .emailMessage || $0.contentType == UTType("public.voice-audio") }) { item in
                         AIIntegrationView(item: item)
                     }
                     DisclosureGroup("Eligibility & Process") {
                         Text("""
                         - Requires Spotlight Delegate Extension.
                         - Item ContentType: .message, .emailMessage, public.voice-audio.
                         - Item Age: < 24 hours.
                         - Flags: .summarization or .priority set via updateListenerOptions.
                         - Summary requires min 200 chars (textContent, htmlContentData, or transcribedTextContent).
                         - Thread Summary: Needs INSearchForMessagesIntent (Messages) or AssistantEntity (Mail) + domainIdentifier.
                         - Delegate's searchableItemsDidUpdate receives updates.
                         """)
                         .font(.caption)
                         .foregroundColor(.secondary)
                     }
                 }

                // --- Section: Programmatic Search ---
                Section("4. Programmatic Search (CSSearchQuery)") {
                    Text("Query String (Attribute-Based):").font(.headline)
                    TextField("Enter Query String", text: $programmaticQueryString, axis: .vertical)
                        .font(.caption.monospaced())
                        .tint(.blue)
                        .padding(5)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)

                    DisclosureGroup("Query Syntax Examples") {
                       Text("""
                       `title == "Value"c` (Case-insensitive)
                       `keywords == "*word*"` (Wildcard contains)
                       `InRange(creationDate, $time.today(-7), $time.now)`
                       `authorNames == "Steve"wc && contentType == "audio"`
                       `(priority > 0.5 || isUrgent == 1)`
                       """)
                       .font(.caption.monospaced())
                       .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading) {
                         Text("Attributes to Fetch:").font(.caption)
                         HStack {
                             ForEach(["title", "contentDescription", "keywords", "authorNames"], id: \.self) { attr in
                                 Button {
                                     if fetchAttributes.contains(attr) {
                                         fetchAttributes.remove(attr)
                                     } else {
                                         fetchAttributes.insert(attr)
                                     }
                                 } label: {
                                     Text(attr)
                                         .font(.caption2)
                                         .padding(4)
                                         .background(fetchAttributes.contains(attr) ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                                         .foregroundColor(fetchAttributes.contains(attr) ? .white : .primary)
                                         .cornerRadius(4)
                                 }
                                 .buttonStyle(.plain)
                             }
                         }
                     }

                    Button { /* Simulate running programmatic query */
                        programmaticSearchResults = itemsToIndex
                            .filter { _ in Bool.random() } // Randomly filter for simulation
                            .map { MockSearchResult(item: $0) }
                            .shuffled() // Simulate Spotlight ranking loosely
                    } label: {
                        Label("Run Programmatic Query", systemImage: "magnifyingglass.circle")
                    }

                    if !programmaticSearchResults.isEmpty {
                        Text("Simulated Programmatic Results:").font(.headline)
                        ForEach(programmaticSearchResults.prefix(3)) { result in
                            VStack(alignment: .leading) {
                                Text(result.item.title).bold()
                                // Display only fetched attributes
                                ForEach(fetchAttributes.sorted(), id: \.self) { attr in
                                    if let value = getAttributeValue(item: result.item, attribute: attr) {
                                         Text("\(attr): \(value)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Core Spotlight Concepts")
            .searchable(text: $searchText, prompt: "Search Indexed Content")
            .searchSuggestions { // Simulate Suggestions UI
                ForEach(currentSuggestions.filter { $0.text.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty }) { suggestion in
                    Label(suggestion.text, systemImage: suggestion.displayIcon ?? "magnifyingglass")
                        .searchCompletion(suggestion.text) // Connects suggestion to search field
                }
            }
            .onChange(of: searchText) { newValue in
                // Simulate query execution with debounce (actual debounce timer not implemented here for simplicity)
                print("Search text changed, simulating query for: \(newValue)")
                if newValue.isEmpty {
                    searchResults = []
                } else {
                     // Simple simulation: Filter mock items based on title containing search text
                     searchResults = itemsToIndex
                         .filter { $0.title.localizedCaseInsensitiveContains(newValue) || $0.contentDescription.localizedCaseInsensitiveContains(newValue)}
                         .map { MockSearchResult(item: $0) }
                         .sorted { $0.relevance > $1.relevance } // Simulate ranking
                }

                // Simulate dynamic suggestions (e.g., based on history or text)
                if !newValue.isEmpty {
                    currentSuggestions = [
                        MockSuggestion(text: "\(newValue) example"),
                        MockSuggestion(text: "Find \(newValue) document")
                    ] + currentSuggestions.prefix(1) // Keep one old one
                } else {
                     currentSuggestions = [
                        MockSuggestion(text: "Project", displayIcon: "doc.text.magnifyingglass"),
                        MockSuggestion(text: "Meeting", displayIcon: "calendar.magnifyingglass"),
                        MockSuggestion(text: "Contact", displayIcon: "person.crop.circle")
                    ]
                }
            }
        }
    }

     // Helper to get attribute values for programmatic search display
     func getAttributeValue(item: MockAppItem, attribute: String) -> String? {
         switch attribute {
         case "title": return item.title
         case "contentDescription": return item.contentDescription
         case "keywords": return item.keywords.joined(separator: ", ")
         case "authorNames": return item.authorNames?.joined(separator: ", ")
         default: return nil
         }
     }
}

struct ItemIndexingView: View {
    let item: MockAppItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                item.thumbnail ?? Image(systemName: "doc")
                Text(item.title).font(.headline)
                Spacer()
                Image(systemName: "lock.fill").foregroundColor(.blue).opacity(item.contentType == .contact ? 1 : 0) // Represent secure index need
                 Image(systemName: "tray.and.arrow.up.fill") // Represent indexing
                     .foregroundColor(.green)

            }
            Text("ID: \(item.uniqueIdentifier)").font(.caption).foregroundColor(.secondary)
            Text("Type: \(item.contentType.localizedDescription ?? item.contentType.identifier)").font(.caption).foregroundColor(.secondary)

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

struct SearchResultView: View {
    let result: MockSearchResult

    var body: some View {
        HStack {
            result.item.thumbnail ?? Image(systemName: "doc")
            VStack(alignment: .leading) {
                Text(result.item.title).bold()
                Text(result.item.contentDescription).font(.caption).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer()
            // Simulate relevance visually
             VStack {
                 Text("Relevance")
                 ProgressView(value: result.relevance, total: 1.0)
                     .progressViewStyle(.linear)
             }.font(.caption2).frame(width: 50)
        }
    }
}

struct AIIntegrationView: View {
    let item: MockAppItem
    @State private var enableSummary: Bool = false
    @State private var enablePriority: Bool = false
    @State private var summaryText: String = "Summary will appear here..."
    @State private var priorityStatus: String = "Priority status unknown"

     var eligibilityColor: Color {
         item.isEligibleForAI ? .green : .orange
     }
     var eligibilityIcon: String {
         item.isEligibleForAI ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
     }

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title).font(.headline)
            Label(item.isEligibleForAI ? "Eligible for AI Processing" : "Potentially Ineligible (Check Criteria)", systemImage: eligibilityIcon)
                .font(.caption)
                .foregroundColor(eligibilityColor)

            Toggle("Enable Summarization (.summarization)", isOn: $enableSummary)
                 .disabled(!item.isEligibleForAI || item.contentDescription.count < 200) // Also disable if too short
             Toggle("Enable Prioritization (.priority)", isOn: $enablePriority)
                 .disabled(!item.isEligibleForAI)

            if enableSummary {
                Text("Summary:")
                    .font(.caption).bold()
                Text(summaryText)
                    .font(.caption).italic().foregroundColor(.secondary)
            }
            if enablePriority {
                 Text("Priority Status:")
                    .font(.caption).bold()
                 Text(priorityStatus)
                    .font(.caption).italic().foregroundColor(.secondary)
            }
        }
        .onChange(of: enableSummary) { newValue in
             if newValue {
                 // Simulate receiving summary via delegate
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                     summaryText = "This is a simulated summary of '\(item.title)' generated by Apple Intelligence."
                 }
                 print("Simulating: Set .summarization flag for \(item.uniqueIdentifier)")
             } else {
                 summaryText = "Summary will appear here..."
             }
         }
         .onChange(of: enablePriority) { newValue in
             if newValue {
                  // Simulate receiving priority via delegate
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                     priorityStatus = Bool.random() ? "High Priority" : "Normal Priority"
                 }
                 print("Simulating: Set .priority flag for \(item.uniqueIdentifier)")
             } else {
                 priorityStatus = "Priority status unknown"
             }
         }
    }
}

// --- Preview ---

#Preview {
    ContentView()
}
