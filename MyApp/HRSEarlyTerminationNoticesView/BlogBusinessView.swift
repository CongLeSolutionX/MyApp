//
//  BlogBusinessView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI
import Foundation
import SafariServices
// If you want to render HTML, you might need WebKit
// import WebKit

// --- Updated Data Model ---
struct BlogPost: Identifiable, Hashable {
    let id: String // Use guid for uniqueness
    let title: String
    let link: URL?
    let descriptionHTML: String // Store the raw HTML from description
    let authorName: String?     // Parsed from description HTML
    let contentDate: Date?      // Parsed from <time> tag in description HTML
    let publicationDate: Date?  // Parsed from <pubDate>
    let creatorIdentifier: String? // Parsed from <dc:creator>
    let guid: String

    // Default initializer for parser setup
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.link = nil
        self.descriptionHTML = ""
        self.authorName = nil
        self.contentDate = nil
        self.publicationDate = nil
        self.creatorIdentifier = nil
        self.guid = ""
    }

    // Designated initializer used by parser
    init(guid: String, title: String, link: URL?, descriptionHTML: String, authorName: String?, contentDate: Date?, publicationDate: Date?, creatorIdentifier: String?) {
        // Use guid as the primary identifier for Identifiable
        self.id = guid.isEmpty ? UUID().uuidString : guid
        self.guid = guid
        self.title = title
        self.link = link
        self.descriptionHTML = descriptionHTML
        self.authorName = authorName
        self.contentDate = contentDate
        self.publicationDate = publicationDate
        self.creatorIdentifier = creatorIdentifier
    }
}

// --- Updated XML Parser Delegate ---
class BlogFeedParserDelegate: NSObject, XMLParserDelegate {

    private var posts: [BlogPost] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    // Temporary storage for the current item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""

    // Formatter for the <pubDate> element (RFC 822)
    private lazy var pubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
        return formatter
    }()

    // Formatter for the <time datetime="..."> within the description (ISO 8601 variant)
    private lazy var descriptionDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        // Common format like "2019-01-28T14:40:29-05:00"
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        // Add other options if needed based on variations in the feed
         // Example: .withFractionalSeconds if time like ...29.123-05:00 exists
        return formatter
    }()

    func getParsedPosts() -> [BlogPost] {
        return posts
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        posts = []
        print("XML Parsing Started (Blog Feed)")
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
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters. Trimming happens at the end of the element.
        currentElementData += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Trim whitespace and newlines from accumulated data *after* finding all characters
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        // Use the qualified name (qName) if available to handle namespaces robustly,
        // otherwise fall back to elementName.
        let effectiveElementName = qName ?? elementName

        switch effectiveElementName {
        case "title":
            currentTitle = trimmedData
        case "link":
            currentLink = trimmedData
        case "description":
            currentDescriptionHTML = trimmedData // Store the raw HTML
        case "pubDate":
            currentPubDateStr = trimmedData
        case "dc:creator": // Specifically handle the dc namespace
            currentCreator = trimmedData
        case "creator": // Fallback if namespace isn't used/parsed correctly
            if currentCreator.isEmpty { // Only set if dc:creator wasn't found
                 currentCreator = trimmedData
            }
        case "guid":
            currentGuid = trimmedData
        case "item":
            // Finished parsing an item, process description and finalize
            // Attempt to parse details from the embedded description HTML
            let descDetails = parseBlogDescriptionHTML(htmlString: currentDescriptionHTML)

            // Attempt to parse dates
            let publicationDate = pubDateFormatter.date(from: currentPubDateStr)
            if publicationDate == nil && !currentPubDateStr.isEmpty {
                print("Warning: Could not parse pubDate string: \(currentPubDateStr)")
            }

            // Finalize the post object
            let post = BlogPost(
                guid: currentGuid,
                title: currentTitle,
                link: URL(string: currentLink),
                descriptionHTML: currentDescriptionHTML, // Store the full HTML
                authorName: descDetails.authorName,
                contentDate: descDetails.contentDate,
                publicationDate: publicationDate,
                creatorIdentifier: currentCreator.isEmpty ? nil : currentCreator
            )

            posts.append(post)

        default:
            break // Ignore other elements like channel-level tags or unknown item tags
        }

        currentElement = "" // Clear current element name tracking
        currentElementData = "" // Clear data buffer
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML Parsing Finished. Found \(posts.count) blog posts.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Consider setting an error state in the ViewModel here
    }

    /// Parses the HTML content within the <description> tag to find specific details.
    private func parseBlogDescriptionHTML(htmlString: String) -> (
        authorName: String?,
        contentDate: Date?
    ) {
        var authorName: String?
        var contentDate: Date?

        // 1. Extract Author Name
        // Pattern looks for the specific div structure containing the author's name
        let authorPattern = "<div class=\"field field--name-field-author.*?<div class=\"field__item\">([^<]+)</div>"
        do {
            let regex = try NSRegularExpression(pattern: authorPattern, options: .dotMatchesLineSeparators)
            if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
               let range = Range(match.range(at: 1), in: htmlString) { // captured group 1
                authorName = String(htmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Regex Error extracting author name: \(error)")
        }

        // 2. Extract Content Date from <time> tag
        // Pattern captures the value of the datetime attribute within a <time> tag
        // This looks for *any* <time> tag, adjust if more specificity needed
        let timePattern = "<time datetime=\"([^\"]+)\"" // Capture datetime value
             do {
                 let regex = try NSRegularExpression(pattern: timePattern)
                 // Find the *first* match, as there might be others (like in comments)
                 if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                    let range = Range(match.range(at: 1), in: htmlString) { // Group 1: the date string
                     let dateString = String(htmlString[range])
                     contentDate = descriptionDateFormatter.date(from: dateString)
                     if contentDate == nil {
                         // Attempt fallback parsing if primary ISO fails (optional)
                         print("Warning: Could not parse description date string with ISO8601: \(dateString)")
                     }
                 }
             } catch {
                 print("Regex error parsing date from description: \(error)")
             }

        return (authorName, contentDate)
    }
}

// --- Updated ViewModel ---
@MainActor
class BlogFeedViewModel: ObservableObject {
    @Published var posts: [BlogPost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = BlogFeedParserDelegate() // Use the updated delegate

    func loadPostsFromLocalXML(filename: String) { // Renamed function
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        posts = [] // Update property name

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
            let parsedPosts = self.parserDelegate.getParsedPosts() // Get results

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.posts = parsedPosts // Assign results
                    if self.posts.isEmpty && self.errorMessage == nil {
                        self.errorMessage = "No posts found or parsed from the XML file."
                        print(self.errorMessage!)
                    } else if !self.posts.isEmpty {
                         print("Successfully parsed \(self.posts.count) posts.")
                         self.errorMessage = nil // Clear error on success
                    }
                } else {
                    // Use the error reported by the parser if available
                    if self.errorMessage == nil { // Check if parser delegate already set an error
                        if let parserError = parser.parserError {
                             self.errorMessage = "XML Parsing Failed: \(parserError.localizedDescription)"
                        } else {
                             self.errorMessage = "An unknown error occurred during XML parsing."
                        }
                    }
                    self.posts = [] // Clear potentially partial data
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- Updated SwiftUI Views ---

struct BlogBusinessView: View {
    // Use the updated ViewModel
    @StateObject private var viewModel = BlogFeedViewModel()
    // Point to the correct XML file name (without extension)
    private let localXMLFilename = "blog-business"

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Blog Posts...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.orange)
                        Text("Error Loading Data").font(.headline).padding(.top, 5)
                        Text(errorMessage).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") {
                            viewModel.loadPostsFromLocalXML(filename: localXMLFilename) // Call updated function
                        }
                        .padding(.top).buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.posts.isEmpty { // Check updated property
                    Text("No Blog Posts found.")
                       .foregroundColor(.secondary)
                } else {
                    List {
                        // Iterate over the updated property name `posts`
                        ForEach(viewModel.posts) { post in
                            // Navigate to the updated detail view
                            NavigationLink(destination: BlogPostDetailView(post: post)) {
                                // Use the updated row view
                                BlogPostRow(post: post)
                            }
                        }
                    }
                }
            }
            .navigationTitle("FTC Business Blog") // Update title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadPostsFromLocalXML(filename: localXMLFilename) // Call updated function
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // Load automatically if view appears and data isn't loaded/loading/errored
                if viewModel.posts.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadPostsFromLocalXML(filename: localXMLFilename) // Call updated function
                }
            }
        }
        .navigationViewStyle(.stack) // Use stack style for better compatibility
    }
}

// Updated Row View
struct BlogPostRow: View {
    let post: BlogPost // Use updated model

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(post.title)
                .font(.headline)
                .lineLimit(3) // Allow more lines for potentially longer blog titles

            // Show author name if available, otherwise fallback to identifier or N/A
            Text("By: \(post.authorName ?? post.creatorIdentifier ?? "N/A")")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Show publication date if available
            if let pubDate = post.publicationDate {
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

// Updated Detail View
struct BlogPostDetailView: View {
    let post: BlogPost // Use updated model
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: post.title)

                // Display Author and Creator ID if available
                if let author = post.authorName {
                    DetailRow(label: "Author", value: author)
                }
                if let creator = post.creatorIdentifier {
                    DetailRow(label: "Creator ID", value: creator)
                }

                // Display Dates
                if let pubDate = post.publicationDate {
                    DetailRow(label: "Published Date", value: pubDate.formatted(date: .long, time: .shortened))
                } else {
                    DetailRow(label: "Published Date", value: "N/A")
                }
                 if let contentDate = post.contentDate {
                     DetailRow(label: "Content Date (from HTML)", value: contentDate.formatted(date: .long, time: .shortened))
                 }

                DetailRow(label: "GUID", value: post.guid)

                Divider().padding(.vertical, 5)

                // Display the HTML content (simple text representation for now)
                // For full rendering, replace Text with a WebViewRepresentable
                VStack(alignment: .leading) {
                    Text("Content (HTML):")
                        .font(.headline)
                    Text(post.descriptionHTML) // Displaying raw HTML - consider stripping or rendering
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil) // Allow full text
                        .textSelection(.enabled)
                }

                // Button to open link remains the same logic
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
                    .disabled(link.absoluteString.isEmpty) // Check for empty string as well
                } else {
                    Text("Original Post Link: Not Available")
                        .font(.caption).foregroundColor(.secondary).padding(.top)
                }

                Spacer()
            }
            .padding()
        }
        // Use first few words of title or fallback for navigation title
        .navigationTitle(post.title.prefix(20) + (post.title.count > 20 ? "..." : ""))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            // Ensure URL is valid before presenting SafariView
             if let url = post.link, UIApplication.shared.canOpenURL(url) {
                SafariView(url: url)
                    .ignoresSafeArea()
             } else {
                 // Simple fallback if URL is nil or invalid
                 Text("Unable to open link.")
                     .padding()
            }
        }
    }
}

// Helper View for consistent detail rows (can remain mostly the same)
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

// SafariView remains unchanged
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

// --- Preview Provider ---
#Preview {
    BlogBusinessView()
    // Ensure 'blog-business.xml' is in your Preview Assets or project bundle
}

// --- Optional: WebView for rendering HTML in Detail View ---
/*
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Optional: Configure webView if needed
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load the HTML string. You might want a base URL for relative links if any exist.
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// In BlogPostDetailView, replace Text(post.descriptionHTML) with:
// WebViewRepresentable(htmlContent: post.descriptionHTML)
//    .frame(height: 400) // Give it a fixed height or let it grow
*/
