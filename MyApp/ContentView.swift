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
import Foundation // Needed for URL, Date, XMLParser

// --- Data Model ---
// (Remains the same as before)
struct HSRNotice: Identifiable, Hashable {
    let id: String // Using transactionNumber for identifiable ID
    let title: String
    let link: URL?
    let transactionNumber: String
    let acquiringParty: String
    let acquiredParty: String
    let grantingStatus: String
    let acquiredEntities: [String]
    let noticeDate: Date? // Date from description's <time> tag
    let publicationDate: Date? // Date from <pubDate> tag
    let creator: String
    let guid: String

    // Helper to create an empty notice during parsing
    init() {
        self.id = UUID().uuidString // Temporary ID until transactionNumber is parsed
        self.title = ""
        self.link = nil
        self.transactionNumber = ""
        self.acquiringParty = ""
        self.acquiredParty = ""
        self.grantingStatus = ""
        self.acquiredEntities = []
        self.noticeDate = nil
        self.publicationDate = nil
        self.creator = ""
        self.guid = ""
    }

    // Designated initializer used by parser once data collected
    init(id: String, title: String, link: URL?, transactionNumber: String, acquiringParty: String, acquiredParty: String, grantingStatus: String, acquiredEntities: [String], noticeDate: Date?, publicationDate: Date?, creator: String, guid: String) {
        self.id = id
        self.title = title
        self.link = link
        self.transactionNumber = transactionNumber
        self.acquiringParty = acquiringParty
        self.acquiredParty = acquiredParty
        self.grantingStatus = grantingStatus
        self.acquiredEntities = acquiredEntities
        self.noticeDate = noticeDate
        self.publicationDate = publicationDate
        self.creator = creator
        self.guid = guid
    }
}


// --- XML Parser Delegate ---

class HSRNoticeParserDelegate: NSObject, XMLParserDelegate {

    // Variables to store parsed data
    private var notices: [HSRNotice] = []
    private var currentElement: String = ""
    private var currentElementData: String = "" // Accumulates character data

    // State for building a single notice
    private var currentNotice: HSRNotice?
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""

    // Date Formatters
    private lazy var pubDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        // Adjust options based on the exact format in your XML's pubDate
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

     private lazy var descriptionDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
         // Format for the datetime attribute in <time> tag inside description
        formatter.formatOptions = [.withInternetDateTime]
        formatter.formatOptions.insert(.withFractionalSeconds) // If needed
        return formatter
    }()


    // MARK: - Public Accessor
    func getParsedNotices() -> [HSRNotice] {
        return notices
    }

    // MARK: - XMLParserDelegate Methods

    func parserDidStartDocument(_ parser: XMLParser) {
        notices = []
        print("XML Parsing Started")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentElementData = "" // Reset data accumulator

        if elementName == "item" {
            // Start building a new notice object
            currentNotice = HSRNotice()
             // Reset temporary storage for the new item
            currentTitle = ""
            currentLink = ""
            currentDescriptionHTML = ""
            currentPubDateStr = ""
            currentCreator = ""
            currentGuid = ""
        } else if elementName == "guid", let notice = currentNotice {
            // Capture attributes if needed, e.g., isPermaLink
            currentGuid = "" // Will be filled by foundCharacters
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Append characters to the current element's data
         currentElementData += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        guard currentNotice != nil else {
             // Ignore elements outside of an <item> for now
            return
        }

        // Process data based on the ended element
        switch elementName {
        case "title":
             currentTitle = currentElementData
        case "link":
            currentLink = currentElementData
        case "description":
            currentDescriptionHTML = currentElementData // Store the raw HTML
        case "pubDate":
            currentPubDateStr = currentElementData
        case "dc:creator": // Handle namespace prefix if present
            currentCreator = currentElementData
         case "creator": // Handle if namespace isn't used consistently
             currentCreator = currentElementData
        case "guid":
            currentGuid = currentElementData
        case "item":
            // Finished parsing an item, process description and finalize
            if var notice = currentNotice {
                 // Attempt to parse the description HTML
                let descData = parseDescriptionHTML(htmlString: currentDescriptionHTML)

                // Finalize the notice object
                 let finalNotice = HSRNotice(
                     id: descData.transactionNumber ?? UUID().uuidString, // Use parsed ID or fallback
                     title: currentTitle,
                     link: URL(string: currentLink),
                     transactionNumber: descData.transactionNumber ?? "N/A",
                     acquiringParty: descData.acquiringParty ?? "N/A",
                     acquiredParty: descData.acquiredParty ?? "N/A",
                     grantingStatus: descData.grantingStatus ?? "N/A",
                     acquiredEntities: descData.acquiredEntities,
                     noticeDate: descData.noticeDate,
                     publicationDate: pubDateFormatter.date(from: currentPubDateStr),
                     creator: currentCreator,
                     guid: currentGuid
                 )

                  notices.append(finalNotice)
                currentNotice = nil // Reset for the next item
            }
         default:
             break // Ignore other elements within item for now
        }

         currentElementData = "" // Clear data buffer after processing element end
    }

    func parserDidEndDocument(_ parser: XMLParser) {
         print("XML Parsing Finished. Found \(notices.count) notices.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Optionally store the error state
        currentNotice = nil // Stop processing potentially corrupt item
    }

    // MARK: - HTML Description Parsing Helper

    /// Parses the HTML content found within the <description> tag.
    /// NOTE: This is a simplified parser using string searching.
    /// It's FRAGILE and assumes the HTML structure is consistent.
    /// A dedicated HTML parser (like SwiftSoup) is recommended for production.
    private func parseDescriptionHTML(htmlString: String) -> (
        transactionNumber: String?,
        acquiringParty: String?,
        acquiredParty: String?,
        grantingStatus: String?,
        acquiredEntities: [String],
        noticeDate: Date?
    ) {
        var transactionNumber: String?
        var acquiringParty: String?
        var acquiredParty: String?
        var grantingStatus: String?
        var acquiredEntities: [String] = []
        var noticeDate: Date?

        // --- Extract Date ---
        // Look for <time datetime="...">...</time> within a specific div
        if let dateRange = htmlString.range(of: "<div class=\"field field--name-field-date.*?</div>", options: .regularExpression) {
            let dateDiv = String(htmlString[dateRange])
            if let timeRange = dateDiv.range(of: "<time datetime=\"([^\"]+)\"", options: .regularExpression) {
                 // Extract the datetime attribute value (Group 1)
                 // This requires slightly more complex Regex handling or string slicing
                 // Simplified approach: Find 'datetime="' and the closing '"'
                 if let startQuote = dateDiv.range(of: "datetime=\"")?.upperBound,
                    let endQuote = dateDiv[startQuote...].range(of: "\"")?.lowerBound {
                     let dateString = String(dateDiv[startQuote..<endQuote])
                     noticeDate = descriptionDateFormatter.date(from: dateString)
                 }
            }
        }

        // --- Extract Other Fields using helper ---
        transactionNumber = extractField(htmlString: htmlString, fieldNameClass: "field--name-field-unique-identifier")
        acquiringParty = extractField(htmlString: htmlString, fieldNameClass: "field--name-field-acquiring-party")
        acquiredParty = extractField(htmlString: htmlString, fieldNameClass: "field--name-field-acquired-party")
        grantingStatus = extractField(htmlString: htmlString, fieldNameClass: "field--name-field-granting-status")

        // --- Extract Acquired Entities (Multiple) ---
        if let entitiesRange = htmlString.range(of: "<div class=\"field field--name-field-other-entities.*?</div>\\s*</div>", options: .regularExpression) {
             let entitiesDiv = String(htmlString[entitiesRange])
             // Find all <div class="field__item"> within this block
             let itemPattern = "<div class=\"field__item\">([^<]+)</div>"
             do {
                 let regex = try NSRegularExpression(pattern: itemPattern)
                 let results = regex.matches(in: entitiesDiv, range: NSRange(entitiesDiv.startIndex..., in: entitiesDiv))
                 acquiredEntities = results.map {
                     // Extract captured group 1
                     if let range = Range($0.range(at: 1), in: entitiesDiv) {
                         return String(entitiesDiv[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                     }
                     return ""
                 }.filter { !$0.isEmpty }
             } catch {
                 print("Regex Error parsing entities: \(error)")
             }
         }


        return (transactionNumber, acquiringParty, acquiredParty, grantingStatus, acquiredEntities, noticeDate)
    }

    /// Helper to extract text content from a specific field div structure.
    private func extractField(htmlString: String, fieldNameClass: String) -> String? {
         // Pattern looks for the div with the specific class, then finds the nested field__item div's content.
        // It assumes only one field__item per field (except for 'other-entities').
        let pattern = "<div class=\"field field--name-\(fieldNameClass).*?<div class=\"field__item\">([^<]+)</div>"
        do {
             let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) // Allow . to match newline
             if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                let range = Range(match.range(at: 1), in: htmlString) { // Group 1 has the content
                 return String(htmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
             }
         } catch {
             print("Regex Error extracting field \(fieldNameClass): \(error)")
         }
         return nil
    }

}


// --- ViewModel ---

@MainActor // Ensure UI updates happen on the main thread
class HSRFeedViewModel: ObservableObject {
    @Published var notices: [HSRNotice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = HSRNoticeParserDelegate()

    // Function to load data from a local XML file in the bundle
    func loadNoticesFromLocalXML(filename: String) {
        guard !isLoading else { return } // Prevent concurrent loading

        isLoading = true
        errorMessage = nil
        notices = [] // Clear previous notices

        // 1. Get URL for the local file in the main bundle
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "xml") else {
            errorMessage = "Error: XML file '\(filename).xml' not found in bundle."
            isLoading = false
            print(errorMessage!)
            return
        }

        // 2. Create XMLParser
        guard let parser = XMLParser(contentsOf: fileURL) else {
             errorMessage = "Error: Could not create XML parser for file."
             isLoading = false
             print(errorMessage!)
             return
        }

        // 3. Set delegate and parse
        parser.delegate = parserDelegate
        print("Starting XML parsing from local file: \(filename).xml")

        // Run parsing in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()

            // Switch back to main thread to update UI
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.notices = self.parserDelegate.getParsedNotices()
                    if self.notices.isEmpty && self.errorMessage == nil {
                        // If parsing succeeded but found no items (or delegate didn't add any)
                        self.errorMessage = "No notices found in the XML file."
                        print(self.errorMessage!)
                    } else {
                         print("Successfully parsed \(self.notices.count) notices.")
                    }
                } else {
                    // Error message likely set by the delegate's parseErrorOccurred
                    if self.errorMessage == nil {
                         self.errorMessage = "An unknown error occurred during XML parsing."
                    }
                   print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views ---
// (ContentView, HSRNoticeRow, HSRNoticeDetailView, DetailRow remain the same
// as in the previous response, they react to the ViewModel's published data)


struct ContentView: View {
    // Use @StateObject for ViewModels owned by the view
    @StateObject private var viewModel = HSRFeedViewModel()
    private let localXMLFilename = "hsr_notices" // ** NAME OF YOUR XML FILE (without .xml) **

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Notices...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                         Text("Error:")
                             .bold()
                         Text(errorMessage)
                             .foregroundColor(.red)
                             .multilineTextAlignment(.center)
                         Button("Retry") {
                             viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                         }
                         .padding(.top)
                    }
                    .padding()
                } else if viewModel.notices.isEmpty {
                    Text("No HSR Notices found.")
                       .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(viewModel.notices) { notice in
                            NavigationLink(destination: HSRNoticeDetailView(notice: notice)) {
                                HSRNoticeRow(notice: notice)
                            }
                        }
                    }
                }
            }
            .navigationTitle("HSR Notices (Local)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                          // Trigger reload from local file
                         viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                     } label: {
                         Image(systemName: "arrow.clockwise")
                     }
                     .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                // Load data when the view first appears if not already loaded
                if viewModel.notices.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Row view for the list
struct HSRNoticeRow: View {
    let notice: HSRNotice

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(notice.title)
                .font(.headline)
             Text("TXN: \(notice.transactionNumber)") // Added TXN for clarity
                 .font(.subheadline)
                 .foregroundColor(.gray)
            HStack {
                Text("Acquiring:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(notice.acquiringParty)
                    .font(.caption)
                    .lineLimit(1) // Prevent wrapping in list row
            }
             HStack {
                 Text("Acquired:")
                     .font(.caption)
                     .foregroundColor(.gray)
                 Text(notice.acquiredParty)
                     .font(.caption)
                     .lineLimit(1) // Prevent wrapping in list row
             }
            if let noticeDate = notice.noticeDate {
                Text("Notice Date: \(noticeDate, style: .date)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Detail view for a selected notice
struct HSRNoticeDetailView: View {
    let notice: HSRNotice

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: notice.title) // Use DetailRow for consistency
                DetailRow(label: "Transaction #", value: notice.transactionNumber)
                DetailRow(label: "Acquiring Party", value: notice.acquiringParty)
                DetailRow(label: "Acquired Party", value: notice.acquiredParty)
                DetailRow(label: "Granting Status", value: notice.grantingStatus)

                if let noticeDate = notice.noticeDate {
                    DetailRow(label: "Notice Date", value: noticeDate.formatted(date: .long, time: .omitted))
                }
                if let pubDate = notice.publicationDate {
                    DetailRow(label: "Publication Date", value: pubDate.formatted(date: .long, time: .shortened))
                }

                 DetailRow(label: "GUID", value: notice.guid) // Display GUID
                 DetailRow(label: "Creator", value: notice.creator)


                // Display Acquired Entities if available
                if !notice.acquiredEntities.isEmpty {
                    VStack(alignment: .leading, spacing: 4) { // Reduced spacing
                        Text("Acquired Entities:")
                            .font(.headline)
                        ForEach(notice.acquiredEntities, id: \.self) { entity in
                            Text("• \(entity)")
                                .padding(.leading, 8)
                                .font(.subheadline) // Slightly smaller font
                        }
                    }
                     .padding(.top, 5) // Add slight top padding
                }


                // Link to the source (optional)
                if let link = notice.link {
                     Link("View Original Notice", destination: link)
                         .padding(.top)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Notice \(notice.transactionNumber)") // More specific title
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper View for consistent detail rows
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) { // Reduce spacing
            Text(label)
                .font(.headline)
                 .foregroundColor(.primary) // Ensure label is clearly visible
            Text(value)
                 .font(.body) // Use body font for value clarity
                .foregroundColor(.secondary)
        }
    }
}


// --- App Entry Point (if creating a full app project) ---
/*
 @main
 struct HSRLocalViewerApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
*/

// --- Preview Provider ---

#Preview {
    // Preview uses the ViewModel which now loads from local file by default on init/appear
    // Ensure 'hsr_notices.xml' exists in your project and is added to the target's bundle resources.
    ContentView()
}
