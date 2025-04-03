//
//  PressReleaseCompetitionView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//


import SwiftUI
import Foundation // Needed for URL, Date, XMLParser
import SafariServices // For SFSafariViewController
import WebKit // Potentially needed for HTML description rendering (Using AttributedString instead for now)

// --- Data Model (Updated) ---
struct PressReleaseItem: Identifiable, Hashable {
    let id: String // Use guid for Identifiable conformance
    let title: String
    let link: URL?
    let descriptionHTML: String // Store the raw HTML content from <description>
    let pubDate: Date?
    let creator: String
    let guid: String

    // Helper initializer (can be removed if not needed elsewhere)
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.link = nil
        self.descriptionHTML = ""
        self.pubDate = nil
        self.creator = ""
        self.guid = UUID().uuidString // Ensure guid is initialized
    }

    // Designated initializer used by parser
    init(guid: String, title: String, link: URL?, descriptionHTML: String, pubDate: Date?, creator: String) {
        self.id = guid // Use guid as the unique ID
        self.guid = guid
        self.title = title
        self.link = link
        self.descriptionHTML = descriptionHTML
        self.pubDate = pubDate
        self.creator = creator
    }
}

// --- XML Parser Delegate (Updated) ---
class PressReleaseParserDelegate: NSObject, XMLParserDelegate {

    private var items: [PressReleaseItem] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""
    private var isParsingItem: Bool = false // Flag to track if inside an <item>

    // Date formatter for RFC 822 format used in <pubDate>
    private lazy var pubDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for reliable parsing
        return formatter
    }()

    func getParsedItems() -> [PressReleaseItem] {
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
            isParsingItem = true
             // Reset temporary storage for the new item
            currentTitle = ""
            currentLink = ""
            currentDescriptionHTML = ""
            currentPubDateStr = ""
            currentCreator = ""
            currentGuid = ""
        } else if elementName == "guid", isParsingItem {
            // (Attributes like isPermaLink could be captured here if needed)
            // Data will be captured in foundCharacters
        }
        // No need to create a placeholder item here, build it at the end of </item>
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters only if inside an <item> and for relevant elements
         if isParsingItem {
            // Append raw characters for description, including potential HTML tags
             if currentElement == "description" {
                currentElementData += string
             } else {
                // Trim whitespace for other elements
                currentElementData += string.trimmingCharacters(in: .whitespacesAndNewlines)
             }
         }
    }

     func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

         guard isParsingItem else {
             // Ignore elements outside of an <item> (like channel info)
            return
        }

        // Process data based on the ended element
        switch elementName {
        case "title":
             currentTitle = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines) // Trim just in case
        case "link":
            currentLink = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
        case "description":
            // Store the accumulated HTML content AS IS. No regex parsing.
            currentDescriptionHTML = currentElementData
        case "pubDate":
            currentPubDateStr = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
        case "dc:creator": // Handle namespace prefix
            currentCreator = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
         case "creator": // Handle if namespace isn't used
             currentCreator = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
        case "guid":
            currentGuid = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)
        case "item":
            // Finished parsing an item, create the final object
            let parsedDate = pubDateFormatter.date(from: currentPubDateStr)
             if parsedDate == nil && !currentPubDateStr.isEmpty {
                 print("Warning: Could not parse publication date string: \(currentPubDateStr)")
             }

             // Ensure GUID is present, otherwise generate one (though RSS usually has it)
             let finalGuid = currentGuid.isEmpty ? UUID().uuidString : currentGuid

            let finalItem = PressReleaseItem(
                 guid: finalGuid,
                 title: currentTitle,
                 link: URL(string: currentLink), // Handle potential invalid URL
                 descriptionHTML: currentDescriptionHTML,
                 pubDate: parsedDate,
                 creator: currentCreator
             )

             items.append(finalItem)
             isParsingItem = false // Exited the item scope
        default:
            break // Ignore other elements within item for now
        }

         currentElement = "" // Clear current element name tracking
         // Don't clear currentElementData here, foundCharacters handles accumulation per element
    }

    func parserDidEndDocument(_ parser: XMLParser) {
         print("XML Parsing Finished. Found \(items.count) items.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Consider setting an error state in the ViewModel here
    }

    // Removed parseDescriptionHTML and extractField methods as they are no longer needed
}

// --- ViewModel (Updated) ---
@MainActor
class PressReleaseFeedViewModel: ObservableObject {
    @Published var pressReleases: [PressReleaseItem] = [] // Changed type
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = PressReleaseParserDelegate() // Using updated delegate

    func loadFeedFromLocalXML(filename: String) { // Renamed method for clarity
         guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        pressReleases = [] // Clear previous results

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

        parser.delegate = parserDelegate // Use the updated delegate instance
        print("Starting XML parsing from local file: \(filename).xml")

        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()
            let parsedItems = self.parserDelegate.getParsedItems() // Get results before switching thread

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.pressReleases = parsedItems // Assign results to the correct property
                    if self.pressReleases.isEmpty && self.errorMessage == nil {
                         self.errorMessage = "No press releases found or parsed from the XML file."
                         print(self.errorMessage!)
                    } else if !self.pressReleases.isEmpty {
                         print("Successfully parsed \(self.pressReleases.count) press releases.")
                         self.errorMessage = nil // Clear any previous error on success
                    }
                } else {
                     // Check if parser delegate set an error message first
                     if self.errorMessage == nil {
                         // Attempt to get error from parser if delegate didn't set one
                         let parserError = parser.parserError?.localizedDescription ?? "Unknown parsing error"
                         self.errorMessage = "XML Parsing Failed: \(parserError)"
                     }
                    self.pressReleases = [] // Clear potentially partial data on failure
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views (Updated) ---

struct PressReleaseCompetitionView: View {
    @StateObject private var viewModel = PressReleaseFeedViewModel()
    private let localXMLFilename = "press-release-competition" // ** Use the correct filename **

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Press Releases...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                         Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                         Text("Error Loading Feed") // Updated title
                             .font(.headline)
                             .padding(.top, 5)
                         Text(errorMessage)
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         Button("Retry") {
                             viewModel.loadFeedFromLocalXML(filename: localXMLFilename) // Call updated method
                         }
                         .padding(.top)
                         .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.pressReleases.isEmpty { // Check updated property
                    Text("No Press Releases found.")
                       .foregroundColor(.secondary)
                } else {
                    List {
                        // Iterate over the updated property name
                        ForEach(viewModel.pressReleases) { item in
                            NavigationLink(destination: PressReleaseDetailView(item: item)) { // Use updated detail view
                                PressReleaseRow(item: item) // Use updated row view
                            }
                        }
                    }
                }
            }
            .navigationTitle("FTC Press Releases") // Updated title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                         viewModel.loadFeedFromLocalXML(filename: localXMLFilename) // Call updated method
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise")
                     }
                     .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // Load automatically only if list is empty and not already loading/in error state
                 if viewModel.pressReleases.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                     viewModel.loadFeedFromLocalXML(filename: localXMLFilename) // Call updated method
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Updated Row View
struct PressReleaseRow: View {
    let item: PressReleaseItem // Use the new model

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(.headline)
                 .lineLimit(3) // Allow more lines for potentially longer titles

            if let pubDate = item.pubDate {
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

// Helper kept from original for Detail View consistency
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
                 .textSelection(.enabled) // Allow users to select/copy values
        }
    }
}

// --- Updated Detail View ---
struct PressReleaseDetailView: View {
    let item: PressReleaseItem // Use the new model
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: item.title)

                if let pubDate = item.pubDate {
                    DetailRow(label: "Published Date", value: pubDate.formatted(date: .long, time: .shortened))
                 } else {
                     DetailRow(label: "Published Date", value: "N/A")
                 }

                if !item.creator.isEmpty {
                   DetailRow(label: "Creator", value: item.creator)
                }

                DetailRow(label: "GUID", value: item.guid)

                // --- Button to open link ---
                if let link = item.link {
                    Button {
                        // Basic validation: Check if the scheme is http or https
                         if let scheme = link.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                            showSafari = true
                         } else {
                             print("Attempted to open invalid URL: \(link)")
                             // Optionally show an alert to the user here
                         }
                    } label: {
                         HStack {
                             Image(systemName: "safari")
                             Text("View Full Press Release") // Updated label
                         }
                          .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    .disabled(link.absoluteString.isEmpty) // Disable if URL is empty
                } else {
                     Text("Original Link: Not Available")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.top)
                 }

                 Divider().padding(.vertical, 5)

                // --- Display Description (HTML Content) ---
                VStack(alignment: .leading) {
                   Text("Description")
                       .font(.headline)
                       .padding(.bottom, 2)

                   // Attempt to display HTML as AttributedString
                   if let attributedString = item.descriptionHTML.htmlToAttributedString {
                       Text(attributedString)
                           .font(.body) // Use appropriate font
                            .foregroundColor(.primary)
                           .textSelection(.enabled)
                    } else {
                       // Fallback: Display raw HTML or plain text
                       Text(item.descriptionHTML.stripHTML() ?? "Description unavailable or failed to parse.")
                            .font(.body)
                           .foregroundColor(.secondary) // Indicate it might be simplified
                            .textSelection(.enabled)
                    }
                   // --- Alternative using Text directly (will show raw HTML tags) ---
                   // Text(item.descriptionHTML)
                   //    .font(.body)
                   //    .foregroundColor(.secondary)
                   //    .lineLimit(nil) // Allow multiple lines
                   //    .textSelection(.enabled)
                }

                Spacer() // Pushes content to the top
            }
            .padding()
        }
        .navigationTitle("Press Release Details") // Updated title
        .navigationBarTitleDisplayMode(.inline)
        // --- Sheet Modifier to Present Safari ---
        .sheet(isPresented: $showSafari) {
            // Present SafariView only if link exists and is likely valid
             if let url = item.link, UIApplication.shared.canOpenURL(url) {
                SafariView(url: url)
                    .ignoresSafeArea()
            } else {
                 // Fallback in case the state got triggered with an invalid URL somehow
                 VStack { // Provide a view for the sheet
                     Text("Unable to open link.")
                         .padding()
                     Button("Dismiss") {
                         showSafari = false
                     }
                     .buttonStyle(.bordered)
                 }
            }
        }
    }
}

// --- UIViewControllerRepresentable for SFSafariViewController (Unchanged) ---
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// --- String Extension for HTML to AttributedString Conversion (Helper) ---
extension String {
    var htmlToAttributedString: AttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
             // Use modern AttributedString initializer if targeting iOS 15+
             if #available(iOS 15.0, *) {
                 let nsAttributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                  return AttributedString(nsAttributedString)
             } else {
                 // Fallback or handle older versions differently if needed
                  // This simple conversion might lose some complex styling on older OS
                  let nsAttributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                 // Basic conversion, might not fully map to SwiftUI AttributedString
                 return AttributedString(nsAttributedString.string) // Less ideal fallback
             }
        } catch {
            print("Error converting HTML to AttributedString: \(error)")
            return nil
        }
    }

     // Simple HTML tag stripping (fallback if AttributedString fails)
     func stripHTML() -> String? {
         return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
     }
}

// --- App Entry Point (Keep commented out unless building a full app) ---
/*
 @main
 struct PressReleaseApp: App { // Renamed app struct (Optional)
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/

// --- Preview Provider (Updated) ---
#Preview {
    PressReleaseCompetitionView()
    // Ensure 'press-release-competition.xml' is added to your project
    // and included in the Target Membership for the main app target.
    // Also, add it to the Preview Assets folder or ensure it's copied
    // to the preview's bundle resources if needed.
}
