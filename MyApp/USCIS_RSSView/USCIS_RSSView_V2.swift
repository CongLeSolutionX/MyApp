////
////  USCIS_RSSView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import WebKit // Needed for WebView (Optional Detail View Enhancement)
//import Combine // For ObservableObject
//
//// MARK: - Data Model
//
//// Represents a single item from the USCIS Developer Portal RSS feed.
//struct FeedItem: Identifiable, Hashable {
//    let id: String // Use the GUID as a unique identifier
//    let title: String
//    let link: URL? // Store the link as a URL
//    let publishDate: Date? // Store the publication date
//    let creator: String
//    let description: String // Store the raw HTML description
//
//    // Conformance to Hashable (needed for ForEach with fetched data)
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    // Conformance to Equatable (part of Hashable)
//    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    // Static Sample Data (Kept for Previews if needed, but not used for live data)
//    static let sampleData: [FeedItem] = [
//        // ... (sample data can remain here for preview purposes if desired)
//         FeedItem(id: "114", title: "Developer Teams & Developer Apps Preview", link: URL(string: "https://developer.uscis.gov/article/developer-teams-developer-apps"), publishDate: Date(), creator: "dev-portal-admin", description: "<span...>Preview...</span>"),
//         FeedItem(id: "126", title: "Managing Client Credentials Preview", link: URL(string: "https://developer.uscis.gov/article/managing-client-credentials"), publishDate: Date(), creator: "dev-portal-admin", description: "<span...>Preview...</span>")
//    ]
//}
//
//// MARK: - XML Parser Delegate
//
//class RSSParserDelegate: NSObject, XMLParserDelegate {
//    private var feedItems: [FeedItem] = []
//    private var currentElement = ""
//    private var currentTitle = ""
//    private var currentLink = ""
//    private var currentPubDate = ""
//    private var currentCreator = ""
//    private var currentDescription = ""
//    private var currentGuid = ""
//
//    // Closure to call when parsing is complete
//    var completionHandler: (([FeedItem], Error?) -> Void)?
//
//    // Date Formatter for RSS dates
//    private lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
//        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // Standard RSS date format
//        return formatter
//    }()
//
//    func parse(data: Data) {
//        let parser = XMLParser(data: data)
//        parser.delegate = self
//        if parser.parse() {
//            // Parsing succeeded
//            completionHandler?(feedItems, nil)
//        } else {
//            // Parsing failed, pass the parser's error
//            completionHandler?(feedItems, parser.parserError ?? NSError(domain: "RSSParserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown parsing error"]))
//        }
//    }
//
//    // Called when an opening tag is found (e.g., <item>, <title>)
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        currentElement = elementName
//        if currentElement == "item" {
//            // Reset values for a new item
//            currentTitle = ""
//            currentLink = ""
//            currentPubDate = ""
//            currentCreator = ""
//            currentDescription = ""
//            currentGuid = ""
//        } else {
//            // Clear the accumulator string for elements within item
//             // No need to clear here, foundCharacters will handle accumulation
//        }
//
//        // Clear the accumulator string whenever a new element starts
//        // (except for the item itself)
//        if currentElement != "item" {
//             currentValue = ""
//        }
//    }
//
//    // Called when character data is found between tags
//    // This might be called multiple times for a single element's content
//    private var currentValue: String = ""
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//         // Append characters to the accumulator string
//         currentValue += string
//    }
//
//    // Called when a closing tag is found (e.g., </title>, </item>)
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        switch elementName {
//        case "title":
//            if currentGuid != "" { // Only capture title if we are inside an <item>
//                 currentTitle = trimmedValue
//            }
//        case "link":
//            currentLink = trimmedValue
//        case "pubDate":
//            currentPubDate = trimmedValue
//        case "dc:creator": // Note the namespace prefix
//            currentCreator = trimmedValue
//        case "description":
//            currentDescription = trimmedValue // Keep the HTML content
//        case "guid":
//             currentGuid = trimmedValue // GUID is the text content, not attribute here based on data
//        case "item":
//            // End of an item, create the FeedItem object
//            let feedItem = FeedItem(
//                id: currentGuid, // Use GUID as ID
//                title: currentTitle,
//                link: URL(string: currentLink),
//                publishDate: dateFormatter.date(from: currentPubDate),
//                creator: currentCreator,
//                description: currentDescription
//            )
//            feedItems.append(feedItem)
//             // Reset temporary vars (optional, as they get reset on next <item>)
//             currentGuid = "" // Reset to avoid adding channel title etc.
//        default:
//            break
//        }
//         // Reset accumulator for the next element's characters
//         currentValue = ""
//    }
//
//    // Called if a parsing error occurs
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        print("RSS Parsing Error: \(parseError.localizedDescription)")
//        // Stop parsing? Optionally call completion handler with error
//        // completionHandler?([], parseError) // Or let parser.parse() return false
//    }
//
//    // Called when the document is finished parsing
//    func parserDidEndDocument(_ parser: XMLParser) {
//        // This could also be where you call the completion handler if
//        // you don't pass the error from parser.parse() failure immediately.
//        // print("Parsing finished successfully. Items found: \(feedItems.count)")
//    }
//}
//
//// MARK: - View Model
//
//class FeedViewModel: ObservableObject {
//    @Published var items: [FeedItem] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    private var cancellables = Set<AnyCancellable>()
//
//    let feedURL = URL(string: "https://developer.uscis.gov/rss.xml")! // Force unwrap for simplicity, handle gracefully in prod
//
//    func fetchFeed() {
//        isLoading = true
//        errorMessage = nil
//        items = [] // Clear previous items
//
//        URLSession.shared.dataTaskPublisher(for: feedURL)
//            .map(\.data) // Extract data
//            .tryMap { [weak self] data -> [FeedItem] in
//                // Use a promise-like structure with Future for cleaner async parsing
//                return try self?.parseRSSData(data) ?? []
//            }
//            .receive(on: DispatchQueue.main) // Switch to main thread for UI updates
//            .sink(receiveCompletion: { [weak self] completion in
//                self?.isLoading = false
//                switch completion {
//                case .finished:
//                    print("Feed fetched and parsed successfully.")
//                case .failure(let error):
//                    print("Error fetching or parsing feed: \(error)")
//                    self?.errorMessage = "Failed to load feed. \(error.localizedDescription)"
//                }
//            }, receiveValue: { [weak self] fetchedItems in
//                self?.items = fetchedItems
//            })
//            .store(in: &cancellables) // Store the subscription to keep it alive
//    }
//
//    // Helper function to bridge delegate-based parsing with Combine/async
//    private func parseRSSData(_ data: Data) throws -> [FeedItem] {
//        let parserDelegate = RSSParserDelegate()
//        var parsedItems: [FeedItem] = []
//        var parseError: Error?
//
//        // Use a semaphore to wait for the delegate's completion
//        let semaphore = DispatchSemaphore(value: 0)
//
//        parserDelegate.completionHandler = { items, error in
//            parsedItems = items
//            parseError = error
//            semaphore.signal() // Signal completion
//        }
//
//        // Run parsing on a background thread to avoid blocking Combine pipeline
//        DispatchQueue.global(qos: .background).async {
//            parserDelegate.parse(data: data)
//        }
//
//        // Wait for the parsing to complete
//        _ = semaphore.wait(timeout: .now() + 30) // Add a reasonable timeout
//
//        if let error = parseError {
//            throw error // Propagate the error
//        }
//
//        return parsedItems
//    }
//}
//
//// MARK: - SwiftUI Views (Mostly Unchanged)
//
//// Represents a single row in the feed list
//struct FeedItemRow: View {
//    let item: FeedItem
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text(item.title)
//                .font(.headline)
//                .lineLimit(2) // Limit title lines
//
//            Text("By: \(item.creator)")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//
//            if let date = item.publishDate {
//                // Use relative date formatting for better UX
//                Text(date, style: .relative) + Text(" ago")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            } else {
//                 Text("Date unavailable")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.vertical, 4) // Add some vertical padding
//    }
//}
//
//// Displays the list of feed items
//struct FeedListView: View {
//    @ObservedObject var viewModel: FeedViewModel
//
//    var body: some View {
//        List {
//             if viewModel.isLoading && viewModel.items.isEmpty {
//                 // Show loading indicator only when initially loading
//                 ProgressView("Loading Feed...")
//                     .frame(maxWidth: .infinity, alignment: .center)
//             } else if let errorMessage = viewModel.errorMessage {
//                  // Show error message
//                  VStack(alignment: .center, spacing: 10) {
//                      Image(systemName: "exclamationmark.triangle.fill")
//                          .resizable()
//                          .scaledToFit()
//                          .frame(width: 50, height: 50)
//                          .foregroundColor(.orange)
//                      Text("Error Loading Feed")
//                          .font(.headline)
//                      Text(errorMessage)
//                          .font(.callout)
//                          .foregroundColor(.secondary)
//                          .multilineTextAlignment(.center)
//                      Button("Retry") {
//                          viewModel.fetchFeed()
//                      }
//                      .buttonStyle(.borderedProminent)
//                      .padding(.top)
//                  }
//                  .frame(maxWidth: .infinity)
//                  .padding()
//
//             } else if viewModel.items.isEmpty && !viewModel.isLoading {
//                 // Show empty state if load finished but no items
//                  Text("No articles found.")
//                      .foregroundColor(.secondary)
//                      .frame(maxWidth: .infinity, alignment: .center)
//                      .padding()
//             } else {
//                 // Show the list of items
//                ForEach(viewModel.items) { item in
//                    NavigationLink(destination: FeedDetailView(item: item)) {
//                        FeedItemRow(item: item)
//                    }
//                }
//             }
//        }
//        .navigationTitle("USCIS Dev Portal")
//        .toolbar {
//             // Add a refresh button to the toolbar explicitly
//            ToolbarItem(placement: .navigationBarTrailing) {
//                 Button {
//                     viewModel.fetchFeed()
//                 } label: {
//                     Image(systemName: "arrow.clockwise")
//                 }
//                 .disabled(viewModel.isLoading) // Disable while loading
//            }
//        }
//        .onAppear {
//            // Fetch feed only if items are empty when the view appears
//            if viewModel.items.isEmpty {
//                 viewModel.fetchFeed()
//            }
//        }
//        // Optional: Add pull-to-refresh functionality
//         .refreshable {
//             viewModel.fetchFeed()
//         }
//    }
//}
//
//// Displays the details of a selected feed item
//struct FeedDetailView: View {
//    let item: FeedItem
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text(item.title)
//                    .font(.title2) // Slightly smaller title for detail view
//                    .bold()
//
//                HStack {
//                   Text("By: \(item.creator)")
//                       .font(.subheadline)
//                       .foregroundColor(.secondary)
//                    Spacer()
//                   if let date = item.publishDate {
//                       Text(date, style: .date) // Show full date here
//                           .font(.caption)
//                           .foregroundColor(.gray)
//                   }
//                }
//                .padding(.bottom, 5)
//
//                Divider()
//
//                // Option 1: Simple Text view (HTML tags visible)
//                // Useful for debugging the raw description
//                 Text("Raw Description (Debug):")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//                 Text(item.description)
//                      .font(.footnote) // Smaller font for raw HTML
//                      .foregroundColor(.secondary)
//                      .padding(.bottom)
//                      .lineLimit(10) // Limit raw view
//
//                // Option 2: Basic WebView to render HTML (Recommended for display)
//                 Text("Content:")
//                     .font(.headline)
//                 HTMLWebView(htmlString: item.description)
//                     .frame(height: 400) // Start with a fixed height, adjust as needed
//                     // Consider dynamic height calculation if necessary
//
//                Divider()
//                    .padding(.vertical)
//
//                if let url = item.link {
//                    // Link to open the original article in Safari
//                    Link(destination: url) {
//                         HStack {
//                             Image(systemName: "safari")
//                             Text("Read Full Article Online")
//                         }
//                         .font(.headline)
//                    }
//                     .padding(.top)
//                }
//            }
//            .padding() // Add padding around the content
//        }
//        .navigationTitle("Article Details") // Use a generic title or part of the item title
//        .navigationBarTitleDisplayMode(.inline) // Smaller title bar
//    }
//}
//
//// --- WKWebView Wrapper (Unchanged) ---
//// A simple wrapper to use WKWebView within SwiftUI
//struct HTMLWebView: UIViewRepresentable {
//    let htmlString: String
//
//    func makeUIView(context: Context) -> WKWebView {
//        return WKWebView()
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // Basic styling to make it fit better visually
//        let styledHTML = """
//        <html>
//        <head>
//            <meta name='viewport' content='width=device-width, initial-scale=1.0, shrink-to-fit=no'>
//            <style>
//                body { font-family: -apple-system, sans-serif; padding: 10px; }
//                img { max-width: 100%; height: auto; } /* Basic responsive images */
//            </style>
//        </head>
//        <body>
//            \(htmlString)
//        </body>
//        </html>
//        """
//        uiView.loadHTMLString(styledHTML, baseURL: nil)
//    }
//}
//
//// --- Main Content View (Unchanged) ---
//// Sets up the navigation structure
//struct USCIS_RSSView_V2: View {
//    @StateObject private var viewModel = FeedViewModel()
//
//    var body: some View {
//        NavigationView {
//            FeedListView(viewModel: viewModel)
//        }
//         // Use stack navigation style for standard iOS behavior
//        .navigationViewStyle(.stack)
//    }
//}
//
//// --- App Entry Point ---
////@main
////struct USCISFeedApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//// --- SwiftUI Previews (Can use sample data or mock view models) ---
//
//// Preview using sample data if needed
//struct FeedItemRow_Previews: PreviewProvider {
//    static var previews: some View {
//        if !FeedItem.sampleData.isEmpty {
//             FeedItemRow(item: FeedItem.sampleData[0])
//                 .previewLayout(.sizeThatFits)
//                 .padding()
//        } else {
//            Text("No sample data for preview")
//        }
//    }
//}
//
//// Preview for the list view, potentially mocking the view model state
//struct FeedListView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview with sample data loaded instantly
//        NavigationView {
//            FeedListView(viewModel: {
//                let vm = FeedViewModel()
//                // Comment out fetchFeed call for preview with samples
//                // vm.items = FeedItem.sampleData // Preload sample data
//                // Simulate loading state
//                 vm.isLoading = true
//                // Simulate error state
//                // vm.errorMessage = "Network connection failed. Please try again."
//                return vm
//            }())
//        }
//        .previewDisplayName("List Loading State")
//
//         NavigationView {
//            FeedListView(viewModel: {
//                let vm = FeedViewModel()
//                 vm.items = FeedItem.sampleData // Preload sample data
//                return vm
//            }())
//        }
//        .previewDisplayName("List With Sample Data")
//
//         NavigationView {
//            FeedListView(viewModel: {
//                let vm = FeedViewModel()
//                 vm.errorMessage = "Failed to parse feed data."
//                return vm
//            }())
//        }
//        .previewDisplayName("List Error State")
//    }
//}
//
//// Preview detail view with sample data
//struct FeedDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        if !FeedItem.sampleData.isEmpty {
//             NavigationView {
//                FeedDetailView(item: FeedItem.sampleData[0])
//             }
//        } else {
//            Text("No sample data for preview")
//        }
//    }
//}
//
//// Preview the main ContentView
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        USCIS_RSSView_V2()
//    }
//}
