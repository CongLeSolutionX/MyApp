//
//  InspectorGeneralReleasesAndReportsView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//
//

import SwiftUI
import Foundation // Needed for URL, Date, XMLParser
import SafariServices // For SFSafariViewController

// --- Data Model for OIG Press Releases ---
struct OIGPressRelease: Identifiable, Hashable {
    let id: String // Preferably from GUID, fallback to UUID
    let title: String
    let link: URL?
    let description: String // Store the description content
    let publicationDate: Date?
    // let creator: String? // Optional: Add if dc:creator is needed

    // Designated initializer used by parser
    init(id: String, title: String, link: URL?, description: String, publicationDate: Date?) {
        self.id = id
        self.title = title
        self.link = link
        self.description = description
        self.publicationDate = publicationDate
    }

    // Helper empty initializer (optional, but can be useful)
    init() {
        self.id = UUID().uuidString
        self.title = ""
        self.link = nil
        self.description = ""
        self.publicationDate = nil
    }
}

// --- XML Parser Delegate for OIG Press Releases ---
class OIGPressReleaseParserDelegate: NSObject, XMLParserDelegate {

    private var pressReleases: [OIGPressRelease] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescription: String = ""
    private var currentPubDateStr: String = ""
    private var currentGuid: String = ""
    private var isInsideItem: Bool = false // Track if currently inside an <item>

    // Date Formatter for RSS pubDate (Often RFC-822/RFC-1123, but ISO8601 is common too)
    // Note: You might need to adjust the format based on the actual feed.
    // RFC 1123 format "EEE, dd MMM yyyy HH:mm:ss zzz" is very common in RSS.
    private lazy var pubDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed formats
            // Try multiple formats if necessary
            // Format 1: RFC 1123
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            // Format 2: ISO8601 (as fallback, less common for pubDate but possible)
            // formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter
       }()

    // Alternative ISO8601 formatter if needed
    // private lazy var isoDateFormatter: ISO8601DateFormatter = {
    //     let formatter = ISO8601DateFormatter()
    //     formatter.formatOptions = [.withInternetDateTime]
    //     return formatter
    // }()

    func getParsedPressReleases() -> [OIGPressRelease] {
        return pressReleases
    }

    // MARK: - XMLParserDelegate Methods

    func parserDidStartDocument(_ parser: XMLParser) {
        pressReleases = []
        print("XML Parsing Started")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentElementData = "" // Reset data accumulator

        if elementName == "item" {
            isInsideItem = true
            // Reset temporary storage for the new item
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDateStr = ""
            currentGuid = ""
        }
        // No need to capture attributes for simple RSS elements typically
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters, trimming can happen at the end
        currentElementData += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Trim whitespace only when processing the ended element's data
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        if isInsideItem {
            // Process data based on the ended element *within an item*
            switch elementName {
            case "title":
                currentTitle = trimmedData
            case "link":
                currentLink = trimmedData
            case "description":
                currentDescription = trimmedData // Store the raw description
            case "pubDate":
                currentPubDateStr = trimmedData
            case "guid":
                currentGuid = trimmedData
            // case "dc:creator": // Example if creator needed
            //     currentCreator = trimmedData
            case "item":
                // Finished parsing an item, create the object
                let id = (!currentGuid.isEmpty) ? currentGuid : UUID().uuidString
                let linkURL = URL(string: currentLink)

                // Attempt to parse the publication date
                  var parsedPubDate: Date? = pubDateFormatter.date(from: currentPubDateStr)
                  // Add more format checks if needed here...
//                if parsedPubDate == nil { // Try ISO as fallback?
//                    parsedPubDate = isoDateFormatter.date(from: currentPubDateStr)
//                }
                if parsedPubDate == nil && !currentPubDateStr.isEmpty {
                     print("Warning: Could not parse publication date string: \(currentPubDateStr)")
                }

                let pressRelease = OIGPressRelease(
                    id: id,
                    title: currentTitle,
                    link: linkURL,
                    description: currentDescription,
                    publicationDate: parsedPubDate
                    // creator: currentCreator // If added
                )
                pressReleases.append(pressRelease)
                isInsideItem = false // Exited the item scope

            default:
                break // Ignore other elements within item for now
            }
        }

        currentElement = "" // Clear current element name tracking
        currentElementData = "" // Clear data buffer *after* processing element end
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        // Note: For the provided sample XML, count will be 0.
        print("XML Parsing Finished. Found \(pressReleases.count) press releases.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Keep track of the error, the ViewModel will handle displaying it
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Optionally, store the error string to pass back to the ViewModel
    }

    // REMOVED: parseDescriptionHTML() - Not needed for standard RSS
    // REMOVED: extractField() - Not needed for standard RSS
}

// --- ViewModel ---
@MainActor
class OIGFeedViewModel: ObservableObject { // Renamed ViewModel
    @Published var pressReleases: [OIGPressRelease] = [] // Use new data model
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = OIGPressReleaseParserDelegate() // Use new parser delegate

    func loadReleasesFromLocalXML(filename: String) { // Renamed function
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

        parser.delegate = parserDelegate
        print("Starting XML parsing from local file: \(filename).xml")

        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()
            // Check for parser-reported error first
            let parserError = parser.parserError // Access error *before* switching threads if needed

            // Get results *after* parsing finishes on the background thread
            let parsedReleases = self.parserDelegate.getParsedPressReleases()

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.pressReleases = parsedReleases // Assign results
                    // Handle case where parsing succeeded but found no items (like the sample XML)
                    if self.pressReleases.isEmpty {
                         self.errorMessage = "No press releases found in the XML file."
                         print(self.errorMessage!)
                         // Consider not setting errorMessage if 0 items is a valid (though perhaps unexpected) state
                    } else {
                         print("Successfully parsed \(self.pressReleases.count) press releases.")
                         self.errorMessage = nil // Clear any previous error on success
                    }
                } else {
                     // Use the parser's error if available, otherwise a generic message
                     self.errorMessage = parserError?.localizedDescription ?? "An unknown error occurred during XML parsing."
                     self.pressReleases = [] // Clear potentially partial data on failure
                     print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views ---

struct OIGPressReleasesView: View {
    @StateObject private var viewModel = OIGFeedViewModel() // Use new ViewModel
    private let localXMLFilename = "oig-reports-press-releases" // Use the target filename

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Releases...") // Updated text
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                         Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                         Text("Error Loading Data")
                             .font(.headline)
                             .padding(.top, 5)
                         Text(errorMessage)
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         Button("Retry") {
                             viewModel.loadReleasesFromLocalXML(filename: localXMLFilename)
                         }
                         .padding(.top)
                         .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.pressReleases.isEmpty {
                    // This state will be reached with the sample XML
                    Text("No OIG Press Releases found.")
                       .foregroundColor(.secondary)
                       .padding()
                } else {
                    // This List will be empty with the sample XML
                    List {
                        ForEach(viewModel.pressReleases) { release in // Use new data model name
                            NavigationLink(destination: OIGPressReleaseDetailView(release: release)) { // Use new detail view
                                OIGPressReleaseRow(release: release) // Use new row view
                            }
                        }
                    }
                }
            }
            .navigationTitle("OIG Press Releases") // Updated title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                         viewModel.loadReleasesFromLocalXML(filename: localXMLFilename)
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise")
                     }
                     .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                 // Load automatically only if list is empty and no error/loading
                if viewModel.pressReleases.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadReleasesFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Row View for the list
struct OIGPressReleaseRow: View {
    let release: OIGPressRelease

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(release.title)
                .font(.headline)
                .lineLimit(2)

            Text(release.description) // Show a snippet of the description
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3) // Limit description lines in the row
                .padding(.bottom, 2)

            if let pubDate = release.publicationDate {
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

// Detail View
struct OIGPressReleaseDetailView: View {
    let release: OIGPressRelease
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: release.title)

                // Display the full description
                DetailRow(label: "Description", value: release.description)

                if let pubDate = release.publicationDate {
                    DetailRow(label: "Publication Date", value: pubDate.formatted(date: .long, time: .shortened))
                 } else {
                     DetailRow(label: "Publication Date", value: "N/A")
                 }

                // Keep the GUID display if useful for debugging or reference
                DetailRow(label: "GUID/ID", value: release.id)

                // --- Button to open link ---
                if let link = release.link {
                    Button {
                        showSafari = true
                    } label: {
                         HStack {
                             Image(systemName: "safari")
                             Text("View Original Release") // Updated text
                         }
                          .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    .disabled(link.absoluteString.isEmpty)
                } else {
                     Text("Original Release Link: Not Available")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.top)
                 }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Press Release") // Generic title or use part of release title
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            // Present SafariView only if link exists and is valid
            // Added check for canOpenURL for robustness
            if let url = release.link, UIApplication.shared.canOpenURL(url) {
                SafariView(url: url)
                    .ignoresSafeArea()
            } else {
                 // Simple fallback if link is bad or missing
                 // In a real app, might show an Alert
                 Text("Unable to open link.")
                    .padding()
            }
        }
    }
}

// Helper View for consistent detail rows (Remains the same)
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

// UIViewControllerRepresentable for SFSafariViewController (Remains the same)
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

// --- Preview Provider ---
#Preview {
    OIGPressReleasesView()
    // Ensure 'oig-reports-press-releases.xml' is in your Preview Assets or project bundle
    // Note: Preview will show "No OIG Press Releases found." because the sample XML has no <item> elements.
}
