//
//  USCIS_RSSView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // For ObservableObject
import WebKit   // For HTMLWebView (Optional Detail View Enhancement)
import SafariServices // For SFSafariViewController

// MARK: - Data Model

// Represents a single item from the USCIS Developer Portal RSS feed.
struct FeedItem: Identifiable, Hashable {
    let id: String // Use the GUID as a unique identifier
    let title: String
    let link: URL? // Store the link as a URL
    let publishDate: Date? // Store the publication date
    let creator: String
    let description: String // Store the raw HTML description

    // Conformance to Hashable (needed for ForEach with fetched data)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conformance to Equatable (part of Hashable)
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }

    // Static Sample Data (Kept for Previews if needed)
    static let sampleData: [FeedItem] = [
        FeedItem(id: "114", title: "Developer Teams & Developer Apps Preview", link: URL(string: "https://developer.uscis.gov/article/developer-teams-developer-apps"), publishDate: Date(), creator: "dev-portal-admin", description: "<span...>Preview...</span>"),
        FeedItem(id: "126", title: "Managing Client Credentials Preview", link: URL(string: "https://developer.uscis.gov/article/managing-client-credentials"), publishDate: Date(), creator: "dev-portal-admin", description: "<span...>Preview...</span>"),
        FeedItem(id: "125", title: "Recent Changes Preview", link: URL(string: "https://developer.uscis.gov/article/portal-updates"), publishDate: Date(), creator: "dev-portal-admin", description: "<span...>Preview...</span>"),
    ]
}

// Make URL Identifiable for the .sheet(item:) modifier
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}

// MARK: - XML Parser Delegate

class RSSParserDelegate: NSObject, XMLParserDelegate {
    private var feedItems: [FeedItem] = []
    private var currentElement = ""
    private var currentValue: String = "" // Accumulator for element text content
    private var currentItemDict: [String: String] = [:] // Store current item's data
    private var isInsideItem = false

    // Closure to call when parsing is complete
    var completionHandler: (([FeedItem], Error?) -> Void)?

    // Date Formatter for RSS dates
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // Standard RSS date format
        return formatter
    }()

    func parse(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            completionHandler?(feedItems, nil)
        } else {
            completionHandler?(feedItems, parser.parserError ?? NSError(domain: "RSSParserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown parsing error"]))
        }
    }

    // Called when an opening tag is found (e.g., <item>, <title>)
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentValue = "" // Reset accumulator for new element

        if elementName == "item" {
            isInsideItem = true
            currentItemDict = [:] // Clear dictionary for new item
        }
    }

    // Called when character data is found between tags
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters only if inside an item or relevant channel element (though we only care about items here)
        if isInsideItem {
            currentValue += string
        }
    }

    // Called when a closing tag is found (e.g., </title>, </item>)
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if isInsideItem {
            // Trim whitespace and store value in the dictionary for the current item
            let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)

            // Handle namespaced elements correctly (like dc:creator)
            let key = (qName ?? elementName) // Use qualified name if available (includes namespace)

            currentItemDict[key] = trimmedValue

            if elementName == "item" {
                // End of an item, create the FeedItem object
                let id = currentItemDict["guid"] ?? UUID().uuidString // Use GUID or generate fallback ID
                let title = currentItemDict["title"] ?? "No Title"
                let linkString = currentItemDict["link"] ?? ""
                let pubDateString = currentItemDict["pubDate"] ?? ""
                let creator = currentItemDict["dc:creator"] ?? "Unknown Creator" // Note the key 'dc:creator'
                let description = currentItemDict["description"] ?? ""

                let feedItem = FeedItem(
                    id: id,
                    title: title,
                    link: URL(string: linkString),
                    publishDate: dateFormatter.date(from: pubDateString),
                    creator: creator,
                    description: description
                )
                feedItems.append(feedItem)
                isInsideItem = false // Exited item scope
            }
        }
        currentElement = "" // Reset current element name
        currentValue = ""   // Reset accumulator after processing element
    }

    // Called if a parsing error occurs
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("RSS Parsing Error: \(parseError.localizedDescription)")
        // Consider calling completion handler with the error here
        // completionHandler?([], parseError)
    }
}

// MARK: - View Model

class FeedViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    let feedURL = URL(string: "https://developer.uscis.gov/rss.xml")! // Handle potential nil URL gracefully in production

    func fetchFeed() {
        // Avoid multiple simultaneous fetches
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        // Optionally clear items immediately or wait for success
        // items = []

        URLSession.shared.dataTaskPublisher(for: feedURL)
            .map(\.data) // Extract data
            .tryMap { [weak self] data -> [FeedItem] in
                // Use a separate method that returns a Publisher or uses async/await for cleaner parsing setup
                 try await self?.parseRSSDataAsync(data) ?? [] // Example using async/await helper
            }
            .receive(on: DispatchQueue.main) // Switch to main thread for UI updates
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    print("Feed fetched and parsed successfully. Items: \(self?.items.count ?? 0)")
                case .failure(let error):
                    print("Error fetching or parsing feed: \(error)")
                    // Provide a more user-friendly error message
                    self?.errorMessage = "Failed to load feed. Please check your connection and try again."
                    // Optionally keep stale data: if self?.items.isEmpty == true { self?.items = [] }
                    self?.items = [] // Clear items on failure
                }
            }, receiveValue: { [weak self] fetchedItems in
                // Sort items by date, newest first (optional but good UX)
                self?.items = fetchedItems.sorted {
                    ($0.publishDate ?? .distantPast) > ($1.publishDate ?? .distantPast)
                }
            })
            .store(in: &cancellables) // Store the subscription
    }

    // Helper function using async/await for parsing (requires Swift 5.5+)
    private func parseRSSDataAsync(_ data: Data) async throws -> [FeedItem] {
        return try await withCheckedThrowingContinuation { continuation in
            let parserDelegate = RSSParserDelegate()
            parserDelegate.completionHandler = { items, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: items)
                }
            }

            // Run parsing on a background thread
            DispatchQueue.global(qos: .background).async {
                parserDelegate.parse(data: data)
            }
        }
    }

    // Original semaphore-based helper (kept for reference if not using async/await)
    /*
    private func parseRSSData(_ data: Data) throws -> [FeedItem] {
        let parserDelegate = RSSParserDelegate()
        var parsedItems: [FeedItem] = []
        var parseError: Error?
        let semaphore = DispatchSemaphore(value: 0)

        parserDelegate.completionHandler = { items, error in
            parsedItems = items
            parseError = error
            semaphore.signal()
        }

        DispatchQueue.global(qos: .background).async {
            parserDelegate.parse(data: data)
        }

        _ = semaphore.wait(timeout: .now() + 30)

        if let error = parseError { throw error }
        return parsedItems
    }
    */
}

// MARK: - SwiftUI Views

// Represents a single row in the feed list
struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)

            Text("By: \(item.creator)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let date = item.publishDate {
                Text(date, style: .relative) + Text(" ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                 Text("Date unavailable")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// Displays the list of feed items
struct FeedListView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        List {
             if viewModel.isLoading && viewModel.items.isEmpty {
                 ProgressView("Loading Feed...")
                     .frame(maxWidth: .infinity, alignment: .center)
             } else if let errorMessage = viewModel.errorMessage {
                  VStack(alignment: .center, spacing: 10) {
                      Image(systemName: "exclamationmark.triangle.fill")
                          .resizable()
                          .scaledToFit().frame(width: 50, height: 50).foregroundColor(.orange)
                      Text("Error Loading Feed").font(.headline)
                      Text(errorMessage).font(.callout).foregroundColor(.secondary).multilineTextAlignment(.center)
                      Button("Retry") { viewModel.fetchFeed() }
                          .buttonStyle(.borderedProminent).padding(.top)
                  }
                  .frame(maxWidth: .infinity).padding()
             } else if viewModel.items.isEmpty && !viewModel.isLoading {
                  Text("No articles found.").foregroundColor(.secondary)
                      .frame(maxWidth: .infinity, alignment: .center).padding()
             } else {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: FeedDetailView(item: item)) {
                        FeedItemRow(item: item)
                    }
                }
             }
        }
        .navigationTitle("USCIS Dev Portal")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                 Button { viewModel.fetchFeed() } label: {
                     Label("Refresh", systemImage: "arrow.clockwise") // Added Label for accessibility
                 }
                 .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            // Fetch only if items are empty AND not currently loading
            if viewModel.items.isEmpty && !viewModel.isLoading {
                 viewModel.fetchFeed()
            }
        }
         .refreshable { // Standard pull-to-refresh
             viewModel.fetchFeed()
         }
    }
}

// Displays the details of a selected feed item
struct FeedDetailView: View {
    let item: FeedItem

    // State variables to control the Safari sheet presentation
    @State private var urlToShow: URL? = nil // Use .sheet(item:), implies presentation state

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(item.title)
                    .font(.title2)
                    .bold()

                HStack {
                   Text("By: \(item.creator)")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                    Spacer()
                   if let date = item.publishDate {
                       Text(date, style: .date)
                           .font(.caption)
                           .foregroundColor(.gray)
                   }
                }
                .padding(.bottom, 5)

                Divider()

                // Optional: Raw Description (Uncomment for Debugging)
                /*
                 Group {
                     Text("Raw Description (Debug):")
                         .font(.caption).foregroundColor(.gray)
                     Text(item.description)
                          .font(.footnote).foregroundColor(.secondary)
                          .padding(.bottom).lineLimit(10)
                 }
                 */

                // WebView for embedded content
                 if !item.description.isEmpty {
                     Text("Content:")
                         .font(.headline)
                     HTMLWebView(htmlString: item.description)
                          // Give it a minimum height, let it grow if needed
                         .frame(minHeight: 200) // Adjusted min height
                         .border(Color.gray.opacity(0.3), width: 1) // Optional border to see frame

                     Divider().padding(.vertical)
                 } else {
                    Text("No description content available.")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                 }

                // Button to open link in SFSafariViewController
                if let url = item.link {
                    Button {
                        // Set the URL to trigger the sheet presentation
                         self.urlToShow = url
                    } label: {
                        HStack {
                            Image(systemName: "safari.fill") // Changed icon
                            Text("Read Full Article Online")
                        }
                        .font(.headline)
                        .padding(.vertical, 10) // Increased padding
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor) // Use accent color for background
                        .foregroundColor(.white) // White text on accent color
                        .cornerRadius(10) // Rounded corners
                    }
                    .buttonStyle(.plain) // Remove default button styling to apply custom
                    .padding(.top)
                } else {
                    Text("Article link not available.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
            }
            .padding() // Padding for the whole VStack content
        }
        .navigationTitle("Article Details")
        .navigationBarTitleDisplayMode(.inline)
        // Use .sheet(item:) to present the SafariView modally
        // It automatically handles presentation when urlToShow is non-nil
        .sheet(item: $urlToShow) { url in
             SafariView(url: url)
                 .ignoresSafeArea() // Allow Safari view to use full screen
        }
    }
}

// --- WKWebView Wrapper ---
struct HTMLWebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Optional: Add observers or configurations if needed
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Basic styling to make it fit better visually
        let styledHTML = """
        <html>
        <head>
            <meta name='viewport' content='width=device-width, initial-scale=1.0, shrink-to-fit=no'>
            <style>
                body {
                    font-family: -apple-system, sans-serif;
                    padding: 5px; /* Reduced padding */
                    margin: 0;
                    font-size: 100%; /* Adjust base font size if needed */
                    color: #333; /* Darker text */
                }
                img { max-width: 100%; height: auto; display: block; margin: 10px 0; }
                p, h1, h2, h3, h4, h5, h6 { margin-bottom: 0.8em; }
                a { color: #007AFF; text-decoration: none; }
                /* Add more styles as needed */
            </style>
        </head>
        <body>
            \(htmlString)
        </body>
        </html>
        """
        uiView.loadHTMLString(styledHTML, baseURL: nil)
    }

    // Optional: Calculate dynamic height (more complex)
    // See examples online for WKWebView content height calculation
}

// MARK: - SFSafariViewController Wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Customize appearance if desired
        // let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Example
        // let safariVC = SFSafariViewController(url: url, configuration: config)
        // safariVC.preferredControlTintColor = .systemBlue // Example color change

        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates typically needed
    }
}

// MARK: - Main Content View

struct USCIS_RSSView_V3: View {
    // Use @StateObject to ensure the ViewModel persists through view updates
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            FeedListView(viewModel: viewModel)
        }
        .navigationViewStyle(.stack) // Consistent navigation style
    }
}

// MARK: - App Entry Point

@main
struct USCISFeedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// --- SwiftUI Previews ---

struct FeedItemRow_Previews: PreviewProvider {
    static var previews: some View {
        // Use sample data if available
        if !FeedItem.sampleData.isEmpty {
             FeedItemRow(item: FeedItem.sampleData[0])
                 .previewLayout(.sizeThatFits)
                 .padding()
        } else {
            Text("No sample data available for FeedItemRow preview")
        }
    }
}

struct FeedListView_Previews: PreviewProvider {
    static var previews: some View {
        // Example: Preview Loading State
        NavigationView {
            FeedListView(viewModel: {
                let vm = FeedViewModel()
                vm.isLoading = true
                return vm
            }())
        }.previewDisplayName("Loading State")

        // Example: Preview Error State
        NavigationView {
            FeedListView(viewModel: {
                let vm = FeedViewModel()
                vm.errorMessage = "Network error. Could not load feed."
                return vm
            }())
        }.previewDisplayName("Error State")

        // Example: Preview with Sample Data
        NavigationView {
            FeedListView(viewModel: {
                let vm = FeedViewModel()
                vm.items = FeedItem.sampleData // Assign sample data directly
                return vm
            }())
        }.previewDisplayName("With Sample Data")
    }
}

struct FeedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Use sample data if available
        if !FeedItem.sampleData.isEmpty {
             NavigationView { // Include NavigationView for context
                FeedDetailView(item: FeedItem.sampleData[1])
             }
        } else {
            Text("No sample data available for FeedDetailView preview")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        USCIS_RSSView_V3()
    }
}
