//
//  BlogCompetitionMattersView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI
import Foundation // Needed for URL, Date, XMLParser, DateFormatter
import SafariServices // For SFSafariViewController
import WebKit // For WKWebView

// --- Data Model for Blog Posts ---
struct BlogItem: Identifiable, Hashable {
    let id: String // Use guid as the identifier
    let title: String
    let link: URL?
    let descriptionHTML: String // Store the unescaped HTML content
    let pubDate: Date? // Date from <pubDate>
    let creator: String // Identifier from <dc:creator>
    let guid: String
    let author: String? // Extracted from description HTML
    let contentDate: Date? // Extracted from <time> tag in description HTML

    // Default initializer for parser setup
    init() {
        self.id = UUID().uuidString // Temporary ID
        self.title = ""
        self.link = nil
        self.descriptionHTML = ""
        self.pubDate = nil
        self.creator = ""
        self.guid = ""
        self.author = nil
        self.contentDate = nil
    }

    // Designated initializer used by parser
    init(id: String, title: String, link: URL?, descriptionHTML: String, pubDate: Date?, creator: String, guid: String, author: String?, contentDate: Date?) {
        self.id = id
        self.title = title
        self.link = link
        self.descriptionHTML = descriptionHTML
        self.pubDate = pubDate
        self.creator = creator
        self.guid = guid
        self.author = author
        self.contentDate = contentDate
    }
}

// --- XML Parser Delegate for Blog Posts ---
class BlogItemParserDelegate: NSObject, XMLParserDelegate {

    private var blogItems: [BlogItem] = []
    private var currentElement: String = ""
    private var currentElementData: String = "" // Accumulates characters for the current element

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTMLAccumulator: String = "" // Accumulate raw description data including HTML entities
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""
    private var parsingItem: Bool = false

    // Date formatter for the <pubDate> element (RFC 822)
    private lazy var pubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
        return formatter
    }()

    // Date formatter for the <time datetime="..."> attribute inside description (ISO 8601)
     private lazy var descriptionContentDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        // Handles formats like 2017-02-03T08:46:03-05:00
        formatter.formatOptions = [.withInternetDateTime] // Includes timezone offset
        return formatter
    }()

    func getParsedItems() -> [BlogItem] {
        return blogItems
    }

    // MARK: - XMLParserDelegate Methods

    func parserDidStartDocument(_ parser: XMLParser) {
        blogItems = []
        print("Blog XML Parsing Started")
    }

   func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentElementData = "" // Reset data accumulator for the new element

        if elementName == "item" {
            parsingItem = true
            // Reset temporary storage for the new item
            currentTitle = ""
            currentLink = ""
            currentDescriptionHTMLAccumulator = ""
            currentPubDateStr = ""
            currentCreator = ""
            currentGuid = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters found. The parser handles unescaping standard XML entities like &lt; &gt; &amp; itself
        currentElementData += string
    }

     func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        guard parsingItem else {
             // Ignore elements outside of an <item>
            return
        }

        // Process data based on the ended element using the accumulated string
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentTitle = trimmedData
        case "link":
            currentLink = trimmedData
        case "description":
            // Store the complete, unescaped HTML content as received from the parser
            currentDescriptionHTMLAccumulator = currentElementData // Keep original spacing/newlines if needed
        case "pubDate":
            currentPubDateStr = trimmedData
        case "dc:creator", "creator": // Handle with or without namespace
            currentCreator = trimmedData
        case "guid":
            currentGuid = trimmedData // Use the content as the GUID
        case "item":
            // Finished parsing an item, process description and finalize
            parsingItem = false

            // Attempt to parse the description HTML for extra details
            let descriptionDetails = parseDescriptionDetails(htmlString: currentDescriptionHTMLAccumulator)

            // Finalize the blog item object
            let finalItem = BlogItem(
                id: currentGuid.isEmpty ? UUID().uuidString : currentGuid, // Use guid content as ID, fallback to UUID
                title: currentTitle,
                link: URL(string: currentLink),
                descriptionHTML: currentDescriptionHTMLAccumulator, // Store the full HTML
                pubDate: pubDateFormatter.date(from: currentPubDateStr),
                creator: currentCreator,
                guid: currentGuid,
                author: descriptionDetails.author, // Use extracted author
                contentDate: descriptionDetails.contentDate // Use extracted date
            )

            blogItems.append(finalItem)

        default:
            break // Ignore other elements within item
        }

         // Don't reset currentElementData here, as foundCharacters might be called multiple times for one element
    }

    func parserDidEndDocument(_ parser: XMLParser) {
         print("Blog XML Parsing Finished. Found \(blogItems.count) items.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Note: The standard parser might report errors for unescaped '&' within URLs in the HTML description.
        // Consider using a more robust HTML parser if this becomes an issue, but for extraction, regex might suffice.
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Might want to signal the error to the ViewModel here
    }

    // MARK: - Description HTML Parsing Helper

    // Parses the unescaped HTML string from the <description> tag
    private func parseDescriptionDetails(htmlString: String) -> (author: String?, contentDate: Date?) {
         var author: String?
         var contentDate: Date?

        // 1. Extract Author using Regex
        // Pattern looks for the specific div structure containing the author
         let authorPattern = "<div class=\"field field--name-field-author.*?<div class=\"field__item\">([^<]+)</div>"
         do {
             let regex = try NSRegularExpression(pattern: authorPattern, options: [.dotMatchesLineSeparators, .caseInsensitive])
             if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                let range = Range(match.range(at: 1), in: htmlString) { // Group 1 captures the author name
                  // Clean up potential HTML entities manually if needed (though parser often handles standard ones)
                 author = String(htmlString[range])
                     .replacingOccurrences(of: "&amp;", with: "&") // Example cleanup
                     .trimmingCharacters(in: .whitespacesAndNewlines)
             }
         } catch {
             print("Regex Error extracting author: \(error)")
         }

        // 2. Extract Content Date using Regex
        // Pattern looks for the <time> tag and captures the datetime attribute value
        let timePattern = "<time datetime=\"([^\"]+)\""
        do {
            let regex = try NSRegularExpression(pattern: timePattern, options: .caseInsensitive)
            if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
               let range = Range(match.range(at: 1), in: htmlString) { // Group 1 is the date string
                let dateString = String(htmlString[range])
                contentDate = descriptionContentDateFormatter.date(from: dateString)
                if contentDate == nil {
                     print("Warning: Could not parse description content date string: \(dateString)")
                 }
            }
        } catch {
            print("Regex error parsing content date: \(error)")
        }

        return (author, contentDate)
    }
}

// --- ViewModel for Blog Feed ---
@MainActor
class BlogFeedViewModel: ObservableObject {
    @Published var blogItems: [BlogItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = BlogItemParserDelegate()

    func loadItemsFromLocalXML(filename: String) {
         guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        blogItems = [] // Clear previous items

        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "xml") else {
            errorMessage = "Error: XML file '\(filename).xml' not found in bundle."
            isLoading = false
            print(errorMessage!)
            return
        }

        // Use Data to potentially handle encoding issues better
        guard let xmlData = try? Data(contentsOf: fileURL) else {
             errorMessage = "Error: Could not load data from XML file."
             isLoading = false
             print(errorMessage!)
             return
        }

        let parser = XMLParser(data: xmlData) // Initialize with Data
        parser.delegate = parserDelegate
        print("Starting XML parsing from local file: \(filename).xml")

        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()
            // Important: Retrieve results *before* switching back to main thread
            let parsedItems = self.parserDelegate.getParsedItems()

            DispatchQueue.main.async {
                self.isLoading = false
                if success || !parsedItems.isEmpty { // Consider success even if parser reports error but we got items
                    self.blogItems = parsedItems // Assign results
                    if self.blogItems.isEmpty && parser.parserError == nil {
                         self.errorMessage = "No blog items found or parsed from the XML file."
                         print(self.errorMessage!)
                    } else if !self.blogItems.isEmpty {
                         print("Successfully parsed \(self.blogItems.count) blog items.")
                        // Clear error only if we successfully got items
                         self.errorMessage = nil
                    } else if let parserError = parser.parserError {
                         // If parsing explicitly failed *and* we have no items
                         self.errorMessage = "XML Parsing Error: \(parserError.localizedDescription)"
                         print(self.errorMessage!)
                         self.blogItems = [] // Ensure empty on definite failure
                    }
                } else {
                     // Handle case where parsing fails early or other issues
                    if self.errorMessage == nil { // Check if parser delegate already set an error
                        self.errorMessage = parser.parserError?.localizedDescription ?? "An unknown error occurred during XML parsing."
                    }
                    self.blogItems = [] // Clear potentially partial data on failure
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views ---

// Main View displaying the list
struct BlogFeedView: View {
    @StateObject private var viewModel = BlogFeedViewModel()
    // *** IMPORTANT: Update this to your actual XML filename ***
    private let localXMLFilename = "blog-competition-matters"

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Blog Posts...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        // Retry action
                        viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
                    }
                } else if viewModel.blogItems.isEmpty {
                    Text("No Blog Posts Found.")
                       .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.blogItems) { item in
                            NavigationLink(destination: BlogItemDetailView(item: item)) {
                                BlogItemRow(item: item)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Competition Matters")
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
                // Load initially only if data isn't already loaded and no error occurred
                if viewModel.blogItems.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack) // Use stack style for broader compatibility
    }
}

// View for displaying errors
struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.orange)
            Text("Error Loading Data")
                .font(.headline)
            Text(errorMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// Row View for the list
struct BlogItemRow: View {
    let item: BlogItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2)

             if let author = item.author, !author.isEmpty {
                 Text("By: \(author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else if !item.creator.isEmpty {
                 Text("Creator: \(item.creator)") // Fallback to creator ID
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if let pubDate = item.pubDate {
                Text("Published: \(pubDate, style: .date)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
             if let contentDate = item.contentDate, item.contentDate != item.pubDate { // Show only if different from pubDate
                 Text("Content Date: \(contentDate, style: .date)")
                     .font(.footnote)
                     .foregroundColor(.secondary)
             }
        }
        .padding(.vertical, 4)
    }
}

// Detail View for a single blog item
struct BlogItemDetailView: View {
    let item: BlogItem
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(item.title)
                     .font(.title2)
                     .bold()
                     .padding(.bottom, 5)
                     .textSelection(.enabled)

                 DetailRow(label: "Author", value: item.author ?? item.creator) // Show author or fallback to creator
                if let pubDate = item.pubDate {
                    DetailRow(label: "Published Date", value: pubDate.formatted(date: .long, time: .shortened))
                }
                if let contentDate = item.contentDate {
                     DetailRow(label: "Content Date", value: contentDate.formatted(date: .long, time: .shortened))
                 }
                DetailRow(label: "GUID", value: item.guid)

                // --- Button to open external link ---
                if let link = item.link {
                    Button {
                        // Basic validation before attempting to open
                        if UIApplication.shared.canOpenURL(link) {
                             showSafari = true
                        } else {
                            print("Cannot open invalid URL: \(link.absoluteString)")
                            // Optionally show an alert to the user here
                        }
                    } label: {
                         HStack {
                             Image(systemName: "safari.fill")
                             Text("View Original Post")
                         }
                          .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered) // Use bordered style for less emphasis than prominent
                    .padding(.top, 5)
                } else {
                     Text("Original Post Link: Not Available")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.top, 5)
                 }

                 Divider().padding(.vertical, 10)

                 Text("Content")
                     .font(.headline)
                     .padding(.bottom, 5)

                 // --- Display HTML Content ---
                 // Use a WebView to render the HTML from the description
                 if !item.descriptionHTML.isEmpty {
                     WebView(htmlContent: item.descriptionHTML, baseURL: item.link)
                           .frame(height: 400) // Adjust height as needed or make dynamic
                          .border(Color.gray.opacity(0.3)) // Optional border
                 } else {
                      Text("No content available in description.")
                          .foregroundColor(.secondary)
                 }

                Spacer() // Push content to top
            }
            .padding()
        }
        .navigationTitle("Blog Post") // More generic title
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            // Present SafariView only if link exists
            // The canOpenURL check is done before setting showSafari=true
             if let url = item.link {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// Helper View for consistent detail rows
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .textSelection(.enabled)
        }
    }
}

// --- UIViewControllerRepresentable for SFSafariViewController ---
// (Remains the same, handles opening any valid URL)
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional
        return SFSafariViewController(url: url, configuration: config)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// --- UIViewRepresentable for WKWebView ---
struct WebView: UIViewRepresentable {
    let htmlContent: String
    let baseURL: URL? // Optional base URL for resolving relative links in HTML

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
         // Load the HTML string. Using baseURL helps resolve relative paths for images/CSS if present in the HTML.
         // If baseURL is nil, it assumes resources are self-contained or use absolute URLs.
        uiView.loadHTMLString(htmlContent, baseURL: baseURL)
    }
}

// --- App Entry Point (Example) ---
/*
 @main
 struct BlogReaderApp: App {
     var body: some Scene {
         WindowGroup {
             BlogFeedView()
         }
     }
 }
*/

// --- Preview Provider ---
struct BlogFeedView_Previews: PreviewProvider {
    static var previews: some View {
        BlogFeedView()
        // Make sure 'blog-competition-matters.xml' is added to your project
        // and included in the Target Membership for previews to work.
    }
}
