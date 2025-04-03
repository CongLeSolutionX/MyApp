//
//  DataSpotlightView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//
import SwiftUI
import Foundation // Needed for URL, Date, XMLParser, DateFormatter
import SafariServices // For SFSafariViewController

// --- NEW Data Model ---
struct BlogPost: Identifiable, Hashable {
    let id: String // Use Guid content
    let title: String
    let link: URL?
    let descriptionHTML: String // Store the raw HTML description
    let pubDate: Date?
    let creator: String // From <dc:creator>
    let guid: String
    // Optional: Extracted author name from description
    let authorName: String?

    // Helper Initializer (Optional, but can be useful)
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.link = nil
        self.descriptionHTML = ""
        self.pubDate = nil
        self.creator = ""
        self.guid = ""
        self.authorName = nil
    }

    // Designated initializer used by parser
    init(id: String, title: String, link: URL?, descriptionHTML: String, pubDate: Date?, creator: String, guid: String, authorName: String?) {
        self.id = id
        self.title = title
        self.link = link
        self.descriptionHTML = descriptionHTML
        self.pubDate = pubDate
        self.creator = creator
        self.guid = guid
        self.authorName = authorName
    }
}

// --- UPDATED XML Parser Delegate ---
class BlogPostParserDelegate: NSObject, XMLParserDelegate {

    private var blogPosts: [BlogPost] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""

    // Date Formatter for RFC 822 format used in <pubDate>
    private lazy var pubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Important for fixed formats
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
        return formatter
    }()

    // Optional: Date formatter for ISO8601 dates potentially inside <description>
     private lazy var descriptionDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        // Handles formats like 2019-02-12T09:23:22-05:00
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        return formatter
     }()

    func getParsedBlogPosts() -> [BlogPost] {
        return blogPosts
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        blogPosts = []
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
        // No need to create a temporary BlogPost object here, we'll do it at the end of the item
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters, trim whitespace later during assignment
        currentElementData += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Trim whitespace before assignment
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentTitle = trimmedData
        case "link":
            currentLink = trimmedData
        case "description":
            // Store the raw HTML, including surrounding CDATA if present
            currentDescriptionHTML = currentElementData // Keep original spacing for HTML
        case "pubDate":
            currentPubDateStr = trimmedData
        case "dc:creator": // Handle namespace prefix
             currentCreator = trimmedData
         case "creator": // Handle if no namespace prefix is used
             currentCreator = trimmedData
        case "guid":
            currentGuid = trimmedData
        case "item":
            // Finished parsing an <item>, create the BlogPost object
            let publicationDate = pubDateFormatter.date(from: currentPubDateStr)
             if publicationDate == nil && !currentPubDateStr.isEmpty {
                  print("Warning: Could not parse pubDate string: \(currentPubDateStr)")
             }

            // --- Extract Author Name from Description HTML ---
            let authorName = extractAuthorFromDescription(htmlString: currentDescriptionHTML)
            // ------------------------------------------------

            let blogPost = BlogPost(
                id: currentGuid.isEmpty ? UUID().uuidString : currentGuid, // Use GUID or generate UUID
                title: currentTitle,
                link: URL(string: currentLink),
                descriptionHTML: currentDescriptionHTML,
                pubDate: publicationDate,
                creator: currentCreator,
                guid: currentGuid,
                authorName: authorName
            )
            blogPosts.append(blogPost)

        default:
            break // Ignore other tags like channel-level tags or unknown item tags
        }

        currentElement = "" // Clear current element name tracking
        currentElementData = "" // Clear data buffer after processing element end
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML Parsing Finished. Found \(blogPosts.count) blog posts.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Potentially set an error state in the ViewModel here
    }

    // --- Helper to Extract Author Name from Description ---
    private func extractAuthorFromDescription(htmlString: String) -> String? {
         // Regex to find the author div and capture the name inside field__item
         // Pattern breakdown:
         // <div class="field field--name-field-author.*?   : Start of the author div (non-greedy match for attributes)
         // <div class="field__item">                       : The specific div containing the name
         // ([^<]+)                                        : Capture group 1: one or more characters that are NOT '<' (the name itself)
         // </div>                                          : End of the inner div
         // This regex assumes the structure seen in the sample XML.
        let pattern = "<div class=\"field field--name-field-author.*?<div class=\"field__item\">([^<]+)</div>"
         do {
             // Use .dotMatchesLineSeparators if the div might span multiple lines (though unlikely here)
             let regex = try NSRegularExpression(pattern: pattern, options: [])
             if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                let range = Range(match.range(at: 1), in: htmlString) { // Get range of the captured group (the name)
                 return String(htmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
             }
         } catch {
             print("Regex Error extracting author name: \(error)")
         }
         return nil // Return nil if not found or on error
    }
}

// --- UPDATED ViewModel ---
@MainActor
class FeedViewModel: ObservableObject { // Renamed for generality
    @Published var blogPosts: [BlogPost] = [] // Use the new model
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = BlogPostParserDelegate() // Use the new delegate

    // Function to load from local XML file
    func loadPostsFromLocalXML(filename: String) {
         guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        blogPosts = []

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
            // IMPORTANT: Get results *before* switching back to main thread
            let parsedPosts = self.parserDelegate.getParsedBlogPosts()

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                     self.blogPosts = parsedPosts // Assign parsed results
                    if self.blogPosts.isEmpty && self.errorMessage == nil {
                         // Check if parsing finished but no items were found
                         self.errorMessage = "No blog posts found or parsed from the XML file."
                         print(self.errorMessage!)
                    } else if !self.blogPosts.isEmpty {
                          print("Successfully parsed \(self.blogPosts.count) blog posts.")
                         self.errorMessage = nil // Clear error message on success
                    }
                } else {
                     // If parser.parse() returned false, check if the delegate set an error
                    if self.errorMessage == nil {
                         // If delegate didn't specify, set a generic error
                         let parserError = parser.parserError?.localizedDescription ?? "Unknown parsing error"
                         self.errorMessage = "XML Parsing Failed: \(parserError)"
                    }
                    self.blogPosts = [] // Clear potentially partial data on failure
                    print(self.errorMessage!)
                }
            }
        }
    }
}

// --- UPDATED SwiftUI Views ---

struct DataSpotlightView: View {
    @StateObject private var viewModel = FeedViewModel() // Use updated ViewModel
    private let localXMLFilename = "data-spotlight" // <--- UPDATE FILENAME HERE

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Posts...")
                } else if let errorMessage = viewModel.errorMessage {
                     // Error View (same as before, conceptually)
                     VStack {
                         Image(systemName: "exclamationmark.triangle")
                             .resizable().scaledToFit().frame(width: 50, height: 50)
                             .foregroundColor(.orange)
                         Text("Error Loading Data").font(.headline).padding(.top, 5)
                         Text(errorMessage).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                         Button("Retry") {
                              viewModel.loadPostsFromLocalXML(filename: localXMLFilename)
                          }
                          .padding(.top).buttonStyle(.bordered)
                     }
                     .padding()
                } else if viewModel.blogPosts.isEmpty {
                    Text("No Blog Posts found.")
                       .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.blogPosts) { post in // Use updated array/model
                            NavigationLink(destination: BlogPostDetailView(post: post)) { // Use updated detail view
                                BlogPostRow(post: post) // Use updated row view
                            }
                        }
                    }
                }
            }
            .navigationTitle("Data Spotlight") // Update title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                         viewModel.loadPostsFromLocalXML(filename: localXMLFilename)
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise")
                     }
                     .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                 // Load initially if empty, not loading, and no error
                 if viewModel.blogPosts.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadPostsFromLocalXML(filename: localXMLFilename)
                 }
            }
        }
        .navigationViewStyle(.stack) // Use stack style for broader compatibility
    }
}

// --- Updated Row View ---
struct BlogPostRow: View {
    let post: BlogPost // Use the new model

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(post.title)
                .font(.headline)
                .lineLimit(2)

             // Display Author or Creator
             if let author = post.authorName, !author.isEmpty {
                  Text("By: \(author)")
                      .font(.subheadline)
                      .foregroundColor(.gray)
             } else if !post.creator.isEmpty {
                 Text("Creator: \(post.creator)") // Fallback to creator username
                     .font(.subheadline)
                     .foregroundColor(.gray)
             }

            if let pubDate = post.pubDate {
                Text("Published: \(pubDate, style: .date)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                 Text("Published: N/A")
                    .font(.footnote)
                    .foregroundColor(.secondary)
           }
        }
        .padding(.vertical, 4)
    }
}

// --- Updated Detail View ---
struct BlogPostDetailView: View {
    let post: BlogPost // Use the new model
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: post.title)

                 // Display Author or Creator
                 if let author = post.authorName, !author.isEmpty {
                     DetailRow(label: "Author", value: author)
                 } else if !post.creator.isEmpty {
                     DetailRow(label: "Creator", value: post.creator)
                 }

                if let pubDate = post.pubDate {
                    DetailRow(label: "Published", value: pubDate.formatted(date: .long, time: .shortened))
                 } else {
                     DetailRow(label: "Published", value: "N/A")
                 }

                 DetailRow(label: "GUID", value: post.guid)

                // Link Button (remains the same logic)
                if let link = post.link {
                     Button {
                         showSafari = true
                     } label: {
                          HStack {
                              Image(systemName: "safari")
                              Text("View Original Post")
                          }
                           .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.borderedProminent)
                     .padding(.top)
                      .disabled(link.absoluteString.isEmpty || !UIApplication.shared.canOpenURL(link)) // Extra check
                 } else {
                      Text("Original Post Link: Not Available")
                          .font(.caption)
                          .foregroundColor(.secondary)
                          .padding(.top)
                  }

                // --- Optionally Display Description ---
                // Displaying raw HTML is complex in pure SwiftUI Text.
                // You could:
                // 1. Show a placeholder:
                //    DetailRow(label: "Description", value: "(HTML Content - View Original)")
                // 2. Attempt basic text extraction (might lose formatting):
                //    DetailRow(label: "Description", value: extractPlainText(from: post.descriptionHTML))
                // 3. Integrate WKWebView (more complex setup required).
                // For now, let's just show a placeholder.
                 Divider().padding(.vertical)
                 Text("Description (Raw HTML):")
                     .font(.headline)
                 Text(post.descriptionHTML)
                      .font(.caption) // Show raw HTML small
                      .foregroundColor(.gray)
                      .lineLimit(10) // Limit display length
                      .textSelection(.enabled)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Details") // More generic title
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            // SafariView presentation (remains the same)
            if let url = post.link, UIApplication.shared.canOpenURL(url) {
                SafariView(url: url)
                    .ignoresSafeArea()
            } else {
                 Text("Invalid or missing URL.")
                     .padding() // Add padding to make it visible
             }
        }
    }

     // --- Helper for basic plain text extraction (Example - Very basic) ---
     func extractPlainText(from html: String) -> String {
         // This is a VERY naive approach. It will strip tags but not handle entities well.
         // For better results, use SwiftSoup or similar HTML parsing libraries.
         return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                   .replacingOccurrences(of: "&lt;", with: "<")
                   .replacingOccurrences(of: "&gt;", with: ">")
                   .replacingOccurrences(of: "&amp;", with: "&")
                   .replacingOccurrences(of: "&nbsp;", with: " ") // Handle non-breaking space
                   .trimmingCharacters(in: .whitespacesAndNewlines)
     }
}

// Helper View for consistent detail rows (remains the same)
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
    }
}

// UIViewControllerRepresentable for SFSafariViewController (remains the same)
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// --- App Entry Point (if needed) ---
/*
 @main
 struct DataSpotlightApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/

// --- Preview Provider ---
#Preview {
    DataSpotlightView()
    // Make sure 'data-spotlight.xml' is added to your project and
    // included in the target's "Copy Bundle Resources" build phase,
    // or added to Preview Assets if using Xcode Previews extensively.
}
