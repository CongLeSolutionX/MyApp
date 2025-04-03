////
////  PressReleaseConsumerProtectionView.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//import SwiftUI
//import Foundation // Needed for URL, Date, XMLParser
//import SafariServices // For SFSafariViewController
//
//// --- Data Model ---
//// Represents a single press release item from the RSS feed
//struct PressReleaseItem: Identifiable, Hashable {
//    let id: String // Use guid for Identifiable conformance
//    let title: String
//    let link: URL?
//    let descriptionHTML: String // Store the raw HTML content
//    let pubDate: Date?
//    let creator: String
//    let guid: String
//
//    // Default initializer for parser delegate temporary object
//    init() {
//        self.id = UUID().uuidString // Temporary ID
//        self.title = ""
//        self.link = nil
//        self.descriptionHTML = ""
//        self.pubDate = nil
//        self.creator = ""
//        self.guid = ""
//    }
//
//    // Designated initializer used by parser
//    init(guid: String, title: String, link: URL?, descriptionHTML: String, pubDate: Date?, creator: String) {
//        self.id = guid // Use the actual GUID as the ID
//        self.title = title
//        self.link = link
//        self.descriptionHTML = descriptionHTML
//        self.pubDate = pubDate
//        self.creator = creator
//        self.guid = guid
//    }
//}
//
//// --- XML Parser Delegate ---
//// Parses the press-release-consumer-protection.xml RSS feed
//class PressReleaseParserDelegate: NSObject, XMLParserDelegate {
//
//    private var items: [PressReleaseItem] = []
//    private var currentElement: String = ""
//    private var currentElementData: String = "" // Accumulates character data for the current element
//
//    // Temporary storage for the item being parsed
//    private var currentTitle: String = ""
//    private var currentLink: String = ""
//    private var currentDescriptionHTML: String = ""
//    private var currentPubDateStr: String = ""
//    private var currentCreator: String = ""
//    private var currentGuid: String = ""
//
//    // Date Formatter for RFC 822 format found in <pubDate>
//    private lazy var pubDateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
//        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
//        return formatter
//    }()
//
//    // Returns the parsed items after parsing is complete
//    func getParsedItems() -> [PressReleaseItem] {
//        return items
//    }
//
//    // Called when parsing starts
//    func parserDidStartDocument(_ parser: XMLParser) {
//        items = []
//        print("XML Parsing Started")
//    }
//
//    // Called when an opening tag is found (e.g., <item>, <title>)
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        currentElement = elementName
//        currentElementData = "" // Reset data accumulator for the new element
//
//        if elementName == "item" {
//            // Reset temporary storage for the new item
//            currentTitle = ""
//            currentLink = ""
//            currentDescriptionHTML = ""
//            currentPubDateStr = ""
//            currentCreator = ""
//            currentGuid = ""
//        }
//        // We don't need special handling for starting <guid> here unless attributes are needed
//    }
//
//    // Called when character data is found between tags
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        // Append characters incrementally. Trimming happens at the end of the element.
//        currentElementData += string
//    }
//
//    // Called when a closing tag is found (e.g., </item>, </title>)
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//
//        // Trim whitespace/newlines from the accumulated data only once
//        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // Only process elements if we are inside an <item> context implicitly
//        // (we reset fields when <item> starts and finalize when </item> ends)
//        switch elementName {
//        case "title":
//            currentTitle = trimmedData
//        case "link":
//            currentLink = trimmedData
//        case "description":
//            currentDescriptionHTML = trimmedData // Store the raw HTML
//        case "pubDate":
//            currentPubDateStr = trimmedData
//        case "dc:creator": // Handle namespaced creator
//            currentCreator = trimmedData
//        case "creator":    // Handle non-namespaced creator (fallback)
//             if currentCreator.isEmpty { // Only use if dc:creator wasn't found
//                 currentCreator = trimmedData
//             }
//        case "guid":
//            currentGuid = trimmedData
//        case "item":
//            // Finished parsing an item, create the PressReleaseItem object
//            // Ensure we have a GUID to use as an ID
//            guard !currentGuid.isEmpty else {
//                print("Skipping item due to missing GUID.")
//                // Reset current element tracking even if skipping
//                currentElement = ""
//                currentElementData = ""
//                return
//            }
//
//            let pubDate = pubDateFormatter.date(from: currentPubDateStr)
//            if pubDate == nil && !currentPubDateStr.isEmpty {
//                 print("Warning: Could not parse pubDate string: \(currentPubDateStr)")
//            }
//
//            let finalItem = PressReleaseItem(
//                guid: currentGuid,
//                title: currentTitle,
//                link: URL(string: currentLink),
//                descriptionHTML: currentDescriptionHTML,
//                pubDate: pubDate,
//                creator: currentCreator
//            )
//            items.append(finalItem)
//
//        default:
//            break // Ignore other elements for now
//        }
//
//        currentElement = "" // Reset current element name tracking
//        currentElementData = "" // Clear data buffer *after* processing element end
//    }
//
//    // Called when parsing finishes
//    func parserDidEndDocument(_ parser: XMLParser) {
//        print("XML Parsing Finished. Found \(items.count) items.")
//    }
//
//    // Called if a parsing error occurs
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        print("XML Parsing Error: \(parseError.localizedDescription)")
//        // Consider setting an error state in the ViewModel here
//    }
//
//    // --- Removed HSR-specific HTML parsing methods ---
//    // private func parseDescriptionHTML(...) { ... }
//    // private func extractField(...) { ... }
//}
//
//// --- ViewModel ---
//// Manages the state and loading of press release feed data
//@MainActor
//class FeedViewModel: ObservableObject {
//    @Published var items: [PressReleaseItem] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var feedTitle: String = "Press Releases" // Store channel title
//
//    private var parserDelegate = PressReleaseParserDelegate()
//
//    func loadItemsFromLocalXML(filename: String) {
//        guard !isLoading else { return }
//
//        isLoading = true
//        errorMessage = nil
//        items = [] // Clear previous items
//
//        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "xml") else {
//            errorMessage = "Error: XML file '\(filename).xml' not found in bundle."
//            isLoading = false
//            print(errorMessage!)
//            return
//        }
//
//        guard let parser = XMLParser(contentsOf: fileURL) else {
//            errorMessage = "Error: Could not create XML parser for file."
//            isLoading = false
//            print(errorMessage!)
//            return
//        }
//
//        parser.delegate = parserDelegate
//        print("Starting XML parsing from local file: \(filename).xml")
//
//        // Perform parsing on a background thread
//        DispatchQueue.global(qos: .userInitiated).async {
//            let success = parser.parse()
//            let parsedItems = self.parserDelegate.getParsedItems() // Get results before switching thread
//
//            // Switch back to the main thread to update UI
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if success {
//                    self.items = parsedItems // Assign results
//                    // Potentially parse channel title here if needed, but that adds complexity
//                    // For now, we just check if items were found
//                    if self.items.isEmpty && self.errorMessage == nil {
//                        self.errorMessage = "No press release items found or parsed from the XML file."
//                        print(self.errorMessage!)
//                    } else if !self.items.isEmpty {
//                        print("Successfully parsed \(self.items.count) press release items.")
//                        self.errorMessage = nil // Clear any previous error on success
//                    }
//                } else {
//                    // If parser.parse() returned false, use the error reported by the delegate
//                    if self.errorMessage == nil {
//                         self.errorMessage = parser.parserError?.localizedDescription ?? "An unknown error occurred during XML parsing."
//                    }
//                    self.items = [] // Clear potentially partial data on failure
//                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
//                }
//            }
//        }
//    }
//}
//
//// --- SwiftUI Views ---
//
//// Main view displaying the list of press releases
//struct PressReleaseConsumerProtectionView: View {
//    @StateObject private var viewModel = FeedViewModel()
//    // Update the filename to match the provided XML
//    private let localXMLFilename = "press-release-consumer-protection"
//
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading Releases...")
//                } else if let errorMessage = viewModel.errorMessage {
//                    // Improved Error Display
//                    VStack(spacing: 10) {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(.orange)
//                        Text("Error Loading Data")
//                            .font(.headline)
//                        Text(errorMessage)
//                            .font(.callout)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                        Button("Retry Loading") {
//                            viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .padding(.top)
//                    }
//                    .padding()
//                } else if viewModel.items.isEmpty {
//                     Text("No Press Releases Found.")
//                        .foregroundColor(.secondary)
//                } else {
//                    List {
//                        ForEach(viewModel.items) { item in
//                            NavigationLink(destination: PressReleaseDetailView(item: item)) {
//                                PressReleaseRow(item: item)
//                            }
//                        }
//                    }
//                    // Consider adding .listStyle(.plain) for a cleaner look
//                }
//            }
//            .navigationTitle(viewModel.feedTitle) // Use dynamic title if parsed, else default
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
//                    } label: {
//                        Label("Refresh", systemImage: "arrow.clockwise")
//                    }
//                    .disabled(viewModel.isLoading)
//                }
//            }
//            .onAppear {
//                // Load automatically only if data isn't already loaded or loading
//                if viewModel.items.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
//                    viewModel.loadItemsFromLocalXML(filename: localXMLFilename)
//                }
//            }
//        }
//        .navigationViewStyle(.stack) // Recommended for broader compatibility
//    }
//}
//
//// View for a single row in the list
//struct PressReleaseRow: View {
//    let item: PressReleaseItem
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text(item.title)
//                .font(.headline)
//                .lineLimit(3) // Allow title to wrap more
//
//            HStack {
//                Text(item.creator.isEmpty ? "Unknown Author" : item.creator)
//                     .font(.caption)
//                     .foregroundColor(.gray)
//                Spacer()
//                if let pubDate = item.pubDate {
//                    Text(pubDate, style: .date)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                } else {
//                    Text("Date N/A")
//                       .font(.caption)
//                       .foregroundColor(.secondary)
//                }
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//// View showing the details of a selected press release
//struct PressReleaseDetailView: View {
//    let item: PressReleaseItem
//    @State private var showSafari: Bool = false
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                DetailItemView(label: "Title:", value: item.title)
//
//                if let pubDate = item.pubDate {
//                    DetailItemView(label: "Published:", value: pubDate.formatted(date: .long, time: .shortened))
//                } else {
//                     DetailItemView(label: "Published:", value: "N/A")
//                 }
//
//                if !item.creator.isEmpty {
//                    DetailItemView(label: "Creator:", value: item.creator)
//                }
//
//                DetailItemView(label: "GUID:", value: item.guid)
//
//                 // Button to open the original link in Safari View
//                 if let link = item.link {
//                     Button {
//                         // Check if URL is valid before attempting to open
//                         if UIApplication.shared.canOpenURL(link) {
//                             showSafari = true
//                         } else {
//                             print("Cannot open invalid URL: \(link)")
//                             // Optionally show an alert to the user here
//                         }
//                     } label: {
//                         HStack {
//                             Image(systemName: "safari.fill")
//                             Text("View Full Release Online")
//                         }
//                         .frame(maxWidth: .infinity)
//                     }
//                     .buttonStyle(.borderedProminent)
//                     .padding(.top)
//                     .disabled(link.absoluteString.isEmpty) // Should be redundant with URL check
//                 } else {
//                      DetailItemView(label: "Link:", value: "Not Available")
//                 }
//
//                // --- Optional: Displaying Raw HTML Description ---
//                // This will likely look messy. A WebView would be better for production.
//                /*
//                 if !item.descriptionHTML.isEmpty {
//                     Divider().padding(.vertical, 10)
//                     Text("Description (Raw HTML):")
//                         .font(.headline)
//                     Text(item.descriptionHTML)
//                         .font(.caption) // Use smaller font for raw HTML
//                         .foregroundColor(.gray)
//                         .lineLimit(nil) // Allow full text display
//                         .textSelection(.enabled)
//                 }
//                 */
//
//                Spacer() // Pushes content to the top
//            }
//            .padding()
//        }
//        .navigationTitle("Press Release") // More generic title
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showSafari) {
//             // Ensure link is valid again just before presenting
//            if let url = item.link, UIApplication.shared.canOpenURL(url) {
//                SafariView(url: url)
//                    .ignoresSafeArea()
//            } else {
//                // Fallback in case the state got triggered with an invalid link
//                Text("Error: Invalid URL for Safari View.")
//                    .padding()
//            }
//        }
//    }
//}
//
//// Helper View for consistent key-value display in Detail View
//struct DetailItemView: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
//            Text(value)
//                .font(.body)
//                .foregroundColor(.primary)
//                .textSelection(.enabled) // Make value selectable
//        }
//        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes full width
//    }
//}
//
//// --- UIViewControllerRepresentable for SFSafariViewController ---
//// (Remains the same - This is a standard wrapper)
//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        let config = SFSafariViewController.Configuration()
//        // config.entersReaderIfAvailable = true // Optional config
//        let safariVC = SFSafariViewController(url: url, configuration: config)
//        return safariVC
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // No update needed for this simple case
//    }
//}
//
//// --- Preview Provider ---
//#Preview {
//    PressReleaseConsumerProtectionView()
//    // Make sure 'press-release-consumer-protection.xml' is added to your
//    // project target and specifically to the "Preview Content" group
//    // or target membership for previews if needed.
//}
