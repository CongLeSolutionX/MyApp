//
//  ConsumerBlogView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//
import SwiftUI
import Foundation // Needed for URL, Date, XMLParser, DateFormatter
import SafariServices // For displaying web content

// --- Data Model (Updated) ---
struct FeedItem: Identifiable, Hashable {
    let id: String // Use guid as the unique ID
    let title: String
    let link: URL?
    let descriptionHTML: String // Store raw HTML description
    let publicationDate: Date?
    let creator: String
    let guid: String

    // Convenience initializer for previews or default states if needed
    init(id: String = UUID().uuidString, title: String = "", link: URL? = nil, descriptionHTML: String = "", publicationDate: Date? = nil, creator: String = "", guid: String = "") {
        self.id = id
        self.title = title
        self.link = link
        self.descriptionHTML = descriptionHTML
        self.publicationDate = publicationDate
        self.creator = creator
        self.guid = guid
    }
}

// --- XML Parser Delegate (Updated) ---
class FeedItemParserDelegate: NSObject, XMLParserDelegate {

    private var items: [FeedItem] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""

    // Custom Date Formatter for the specific "Month Day, Year | Hour:MinuteAM/PM" format
    private lazy var pubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Example format: "April 3, 2025 | 9:07AM"
        formatter.dateFormat = "MMMM d, yyyy | h:mma"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for consistent month/AM/PM parsing
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Assume UTC or adjust if feed indicates timezone
        return formatter
    }()

    func getParsedItems() -> [FeedItem] {
        return items
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        items = []
        print("XML Parsing Started")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentElementData = "" // Reset data accumulator

        if elementName == "item" {
            // Reset temporary storage for the new item
            currentTitle = ""
            currentLink = ""
            currentDescriptionHTML = ""
            currentPubDateStr = ""
            currentCreator = ""
            currentGuid = ""
        }
        // No special handling needed for guid start, value captured in foundCharacters
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append trimmed string data. It might come in chunks.
        currentElementData += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Trim whitespace/newlines from accumulated data *once* at the end of the element
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        // Process data based on the ended element *only within an item context*
        // We check this implicitly by only processing when *inside* an item scope (i.e., after <item> started)
        switch elementName {
        case "title":
            currentTitle = trimmedData
        case "link":
            currentLink = trimmedData
        case "description":
            currentDescriptionHTML = trimmedData // Store the raw HTML
        case "pubDate":
            currentPubDateStr = trimmedData
        case "dc:creator": // Handle namespace explicitly
            currentCreator = cleanCreatorString(trimmedData)
        case "creator": // Fallback if namespace prefix is omitted
            currentCreator = cleanCreatorString(trimmedData)
        case "guid":
            currentGuid = trimmedData
        case "item":
            // Finished parsing an item, create the FeedItem object
            let publicationDate = pubDateFormatter.date(from: currentPubDateStr)
            if publicationDate == nil && !currentPubDateStr.isEmpty {
                print("Warning: Could not parse publication date string: \(currentPubDateStr)")
            }

            let feedItem = FeedItem(
                id: currentGuid.isEmpty ? UUID().uuidString : currentGuid, // Use guid for ID, fallback to UUID
                title: currentTitle,
                link: URL(string: currentLink),
                descriptionHTML: currentDescriptionHTML,
                publicationDate: publicationDate,
                creator: currentCreator,
                guid: currentGuid
            )
            items.append(feedItem)

            // Reset temporary vars (though they'll be reset again at the start of the next <item>)
            currentTitle = ""
            currentLink = ""
            currentDescriptionHTML = ""
            currentPubDateStr = ""
            currentCreator = ""
            currentGuid = ""

        default:
            // Ignore other elements like channel metadata for now
            break
        }

        // Reset tracking vars for the next element
        currentElement = ""
        currentElementData = ""
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML Parsing Finished. Found \(items.count) items.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Capture the error message to be displayed in the UI
        // Note: This might be called before parserDidEndDocument on failure
        print("XML Parsing Error: \(parseError.localizedDescription) at line \(parser.lineNumber), column \(parser.columnNumber)")
        // You might want to set an error state in the delegate that the ViewModel can check
    }

    // Helper to clean up the creator string (remove potential HTML tags like <br>)
    private func cleanCreatorString(_ rawString: String) -> String {
        // Simple replacement for common tags found in the example
        return rawString
            .replacingOccurrences(of: "<br>", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "<br/>", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// --- ViewModel (Updated) ---
@MainActor
class FeedViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = FeedItemParserDelegate() // Use updated delegate

    // Load data from a local XML file included in the app bundle
    func loadItemsFromLocalXML(filename: String) {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        items = [] // Clear previous items

        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "xml") else {
            errorMessage = "Error: XML file '\(filename).xml' not found in bundle."
            isLoading = false
            print(errorMessage!)
            return
        }

        guard let parser = XMLParser(contentsOf: fileURL) else {
            errorMessage = "Error: Could not create XML parser for file."
            isLoading = false
            print(errorMessage!)
            return
        }

        parser.delegate = parserDelegate
        print("Starting XML parsing from local file: \(filename).xml")

        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()
            // Retrieve results *before* switching back to main thread
            let parsedItems = self.parserDelegate.getParsedItems()
            // Check for errors reported by the delegate if needed (e.g., via a property)
            // let parsingError = self.parserDelegate.parsingError // Hypothetical property

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.items = parsedItems // Assign successfully parsed items
                    if self.items.isEmpty && self.errorMessage == nil {
                        // If parsing succeeded but no items found (or filtered out)
                        self.errorMessage = "No feed items found or parsed from the XML file."
                        print(self.errorMessage!)
                    } else if !self.items.isEmpty {
                        print("Successfully parsed \(self.items.count) items.")
                        self.errorMessage = nil // Clear error on success
                    }
                } else {
                    // Parsing failed (XML malformed, delegate reported error, etc.)
                    if self.errorMessage == nil { // Check if the delegate didn't already set a specific error
                         // Use the error reported by the parser if available
                        self.errorMessage = parser.parserError?.localizedDescription ?? "An unknown error occurred during XML parsing."
                    }
                    self.items = [] // Clear potentially partial data on failure
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views (Updated) ---

struct ConsumerBlogView: View {
    // Use the updated ViewModel and specify the correct filename
    @StateObject private var viewModel = FeedViewModel()
    private let localXMLFilename = "gd-rss" // Ensure gd-rss.xml is in your project bundle

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Feed...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        Text("Error Loading Feed")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
                        }
                        .padding(.top)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if viewModel.items.isEmpty {
                    Text("No feed items found.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        // Iterate over the updated 'items' array
                        ForEach(viewModel.items) { item in
                            // Link to the updated detail view
                            NavigationLink(destination: FeedItemDetailView(item: item)) {
                                // Use the updated row view
                                FeedItemRow(item: item)
                            }
                        }
                    }
                }
            }
            // Update Navigation Title
            .navigationTitle("FTC Consumer Blog")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // Load data automatically on first appearance if needed
                if viewModel.items.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack) // Use stack style for broad compatibility
    }
}

// Updated Row View
struct FeedItemRow: View {
    let item: FeedItem // Use the correct model type

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2) // Allow two lines for title

            if let pubDate = item.publicationDate {
                // Format date concisely for the row
                Text("Published: \(pubDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !item.creator.isEmpty {
                 Text("By: \(item.creator)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4) // Add a little vertical padding
    }
}

// Updated Detail View
struct FeedItemDetailView: View {
    let item: FeedItem // Use the correct model type
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: item.title)

                if let pubDate = item.publicationDate {
                    DetailRow(label: "Published Date", value: pubDate.formatted(date: .long, time: .shortened))
                } else {
                    DetailRow(label: "Published Date", value: "N/A")
                }

                 if !item.creator.isEmpty {
                     DetailRow(label: "Author", value: item.creator)
                 }

                 DetailRow(label: "GUID", value: item.guid)

                 // Optionally display the raw description HTML (might not look great)
                 // Or simply rely on the link for full content
                 // DetailRow(label: "Description Snippet", value: item.descriptionHTML)

                // Button to open the original link in Safari
                if let link = item.link {
                    Button {
                        // Check if the URL can be opened before attempting
                        if UIApplication.shared.canOpenURL(link) {
                           showSafari = true
                        } else {
                            print("Cannot open URL: \(link)")
                            // Optionally show an alert to the user
                        }
                    } label: {
                        HStack {
                            Image(systemName: "safari.fill")
                            Text("View Full Post Online")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    // Disable button if URL string was empty, parsed to nil, or invalid scheme
                    .disabled(item.link == nil || !UIApplication.shared.canOpenURL(item.link!))
                } else {
                    Text("Original Post Link: Not Available")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.top)
                 }

                Spacer() // Push content to the top
            }
            .padding() // Add padding around the VStack content
        }
        .navigationTitle("Article Details") // More generic title
        .navigationBarTitleDisplayMode(.inline)
        // Sheet modifier to present SFSafariViewController
        .sheet(isPresented: $showSafari) {
            // Ensure link exists again just before presenting
            if let url = item.link {
                SafariView(url: url)
                    // Allow Safari view to potentially go under safe areas
                    // .ignoresSafeArea() // Consider if needed based on design
            }
        }
    }
}

// Helper View for consistent detail rows (Remains the same, but usage updated)
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) { // Slightly adjusted spacing
            Text(label)
                .font(.caption.weight(.medium)) // Make label slightly distinct
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .textSelection(.enabled) // Good for copying GUID, etc.
        }
    }
}

// --- SFSafariViewController Representable (Remains the same) ---
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional: Try enabling reader mode
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No dynamic updates needed here
    }
}

// --- Preview Provider (Updated) ---
#Preview {
    // Test with the ContentView
    ConsumerBlogView()
    // Make sure 'gd-rss.xml' is added to your project and included in the target,
    // and specifically added to the Preview Assets folder if needed for previews.
}
