//
//  HRSEarlyTerminationNoticesView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI
import Foundation // Needed for URL, Date, XMLParser
import SafariServices // <-- Import SafariServices

// --- Data Model ---
// (Remains the same as before)
struct HSRNotice: Identifiable, Hashable {
    let id: String
    let title: String
    let link: URL?
    let transactionNumber: String
    let acquiringParty: String
    let acquiredParty: String
    let grantingStatus: String
    let acquiredEntities: [String]
    let noticeDate: Date?
    let publicationDate: Date?
    let creator: String
    let guid: String

    init() { // Helper initializer
        self.id = UUID().uuidString
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

    // Designated initializer used by parser
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
// (Remains the same as before)
class HSRNoticeParserDelegate: NSObject, XMLParserDelegate {

    private var notices: [HSRNotice] = []
    private var currentElement: String = ""
    private var currentElementData: String = ""

    private var currentNotice: HSRNotice?
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""

    private lazy var pubDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

     private lazy var descriptionDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }()

    func getParsedNotices() -> [HSRNotice] {
        return notices
    }

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
            if let notice = currentNotice { // Use non-mutable let here
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
                // No need to explicitly nil currentNotice here, it Cgo out of scope
            }
         default:
             break // Ignore other elements within item for now
        }

         currentElement = "" // Clear current element name tracking
         currentElementData = "" // Clear data buffer after processing element end
    }

    func parserDidEndDocument(_ parser: XMLParser) {
         print("XML Parsing Finished. Found \(notices.count) notices.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Error: \(parseError.localizedDescription)")
    }

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

          if let dateRange = htmlString.range(of: "<div class=\"field field--name-field-date.*?</div>", options: .regularExpression) {
             let dateDiv = String(htmlString[dateRange])
             let timePattern = "<time datetime=\"([^\"]+)\"" // Capture datetime value
             do {
                 let regex = try NSRegularExpression(pattern: timePattern)
                 if let match = regex.firstMatch(in: dateDiv, range: NSRange(dateDiv.startIndex..., in: dateDiv)),
                    let range = Range(match.range(at: 1), in: dateDiv) { // Group 1: the date string
                     let dateString = String(dateDiv[range])
                     noticeDate = descriptionDateFormatter.date(from: dateString)
                     if noticeDate == nil {
                          print("Warning: Could not parse description date string: \(dateString)")
                      }
                 }
             } catch {
                 print("Regex error parsing date: \(error)")
             }
         }

        transactionNumber = extractField(htmlString: htmlString, fieldNameClass: "unique-identifier")
        acquiringParty = extractField(htmlString: htmlString, fieldNameClass: "acquiring-party")
        acquiredParty = extractField(htmlString: htmlString, fieldNameClass: "acquired-party")
        grantingStatus = extractField(htmlString: htmlString, fieldNameClass: "granting-status")

        if let entitiesRange = htmlString.range(of: "<div class=\"field field--name-field-other-entities.*?</div>\\s*</div>", options: [.regularExpression]) {
             let entitiesDiv = String(htmlString[entitiesRange])
             let itemPattern = "<div class=\"field__item\">([^<]+)</div>"
             do {
                 let regex = try NSRegularExpression(pattern: itemPattern)
                 let results = regex.matches(in: entitiesDiv, range: NSRange(entitiesDiv.startIndex..., in: entitiesDiv))
                 acquiredEntities = results.compactMap { // Use compactMap to handle potential nil from range conversion
                     // Extract captured group 1
                     guard let range = Range($0.range(at: 1), in: entitiesDiv) else { return nil }
                      return String(entitiesDiv[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                 }.filter { !$0.isEmpty } // Extra filter for safety
                 // Handle pipe-separated entities within a single item
                 acquiredEntities = acquiredEntities.flatMap { $0.split(separator: "|").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } }
             } catch {
                 print("Regex Error parsing entities: \(error)")
             }
         }

        return (transactionNumber, acquiringParty, acquiredParty, grantingStatus, acquiredEntities, noticeDate)
    }

    private func extractField(htmlString: String, fieldNameClass: String) -> String? {
        let pattern = "<div class=\"field field--name-field-\(fieldNameClass).*?<div class=\"field__item\">([^<]+)</div>"
        do {
             let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
             if let match = regex.firstMatch(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString)),
                let range = Range(match.range(at: 1), in: htmlString) {
                 return String(htmlString[range]).trimmingCharacters(in: .whitespacesAndNewlines)
             }
         } catch {
             print("Regex Error extracting field \(fieldNameClass): \(error)")
         }
         return nil
    }
}

// --- ViewModel ---
// (Remains the same as before)
@MainActor
class HSRFeedViewModel: ObservableObject {
    @Published var notices: [HSRNotice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var parserDelegate = HSRNoticeParserDelegate()

    func loadNoticesFromLocalXML(filename: String) {
         guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        notices = []

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
            let parsedNotices = self.parserDelegate.getParsedNotices() // Get results before switching thread

            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.notices = parsedNotices // Assign results
                    if self.notices.isEmpty && self.errorMessage == nil {
                         self.errorMessage = "No notices found or parsed from the XML file."
                         print(self.errorMessage!)
                    } else if !self.notices.isEmpty {
                         print("Successfully parsed \(self.notices.count) notices.")
                          self.errorMessage = nil // Clear any previous error on success
                    }
                } else {
                     if self.errorMessage == nil {
                          self.errorMessage = "An unknown error occurred during XML parsing."
                     }
                    self.notices = [] // Clear potentially partial data on failure
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views ---

struct ContentView: View {
    @StateObject private var viewModel = HSRFeedViewModel()
    private let localXMLFilename = "hsr_notices" // Ensure this file exists in your bundle

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Notices...")
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
                             viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                         }
                         .padding(.top)
                         .buttonStyle(.bordered) // Add some style
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
                         viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise") // Added label for accessibility
                     }
                     .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                if viewModel.notices.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadNoticesFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HSRNoticeRow: View {
    let notice: HSRNotice

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(notice.title)
                .font(.headline)
                 .lineLimit(2) // Allow slightly more space for title if needed

             Text("TXN: \(notice.transactionNumber)")
                 .font(.subheadline)
                 .foregroundColor(.gray)
                 .padding(.bottom, 2) // Add a little space

            InfoRow(label: "Acquiring:", value: notice.acquiringParty)
            InfoRow(label: "Acquired:", value: notice.acquiredParty)

            if let noticeDate = notice.noticeDate {
                Text("Notice Date: \(noticeDate, style: .date)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                 Text("Notice Date: N/A") // Handle missing date
                    .font(.footnote)
                    .foregroundColor(.secondary)
           }
        }
        .padding(.vertical, 4)
    }
}

// Helper for consistent inline info rows in the list
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) { // Align text nicely
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.caption)
                .lineLimit(1) // Keep it to one line in the list row
        }
    }
}

// --- Updated Detail View ---
struct HSRNoticeDetailView: View {
    let notice: HSRNotice
    @State private var showSafari: Bool = false // <-- State to control sheet presentation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(label: "Title", value: notice.title)
                DetailRow(label: "Transaction #", value: notice.transactionNumber)
                DetailRow(label: "Acquiring Party", value: notice.acquiringParty)
                DetailRow(label: "Acquired Party", value: notice.acquiredParty)
                DetailRow(label: "Granting Status", value: notice.grantingStatus)

                if let noticeDate = notice.noticeDate {
                    DetailRow(label: "Notice Date", value: noticeDate.formatted(date: .long, time: .omitted))
                 } else {
                     DetailRow(label: "Notice Date", value: "N/A")
                 }
                if let pubDate = notice.publicationDate {
                    DetailRow(label: "Publication Date", value: pubDate.formatted(date: .long, time: .shortened))
                 } else {
                    DetailRow(label: "Publication Date", value: "N/A")
                }

                 DetailRow(label: "GUID", value: notice.guid)
                 DetailRow(label: "Creator", value: notice.creator)

                if !notice.acquiredEntities.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Acquired Entities:")
                            .font(.headline)
                        ForEach(notice.acquiredEntities, id: \.self) { entity in
                            Text("• \(entity)")
                                .padding(.leading, 8)
                                .font(.subheadline)
                        }
                    }
                     .padding(.top, 5)
                }

                // --- Button to open link ---
                if let link = notice.link {
                    Button {
                        showSafari = true // <-- Set state to true on tap
                    } label: {
                         HStack { // Enhance button appearance
                             Image(systemName: "safari") // Use Safari icon
                             Text("View Original Notice")
                         }
                          .frame(maxWidth: .infinity) // Make button wider
                    }
                    .buttonStyle(.borderedProminent) // Use a prominent style
                    .padding(.top)
                    .disabled(link.absoluteString.isEmpty) // Disable if URL is empty string
                } else {
                     Text("Original Notice Link: Not Available") // Show if link is nil
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .padding(.top)
                 }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Notice \(notice.transactionNumber)")
        .navigationBarTitleDisplayMode(.inline)
        // --- Sheet Modifier to Present Safari ---
        .sheet(isPresented: $showSafari) {
            // Present SafariView only if link exists and is valid
            if let url = notice.link, UIApplication.shared.canOpenURL(url) { // Added check for valid URL scheme
                SafariView(url: url)
                    .ignoresSafeArea() // Allow Safari view to use full screen
            } else {
                // Optional: Show an alert if the link is invalid or missing
                 Text("Invalid or missing URL.") // Simple fallback
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
                .font(.headline)
                 .foregroundColor(.primary)
            Text(value)
                 .font(.body)
                .foregroundColor(.secondary)
                 .textSelection(.enabled) // Allow users to select/copy values
        }
    }
}

// --- UIViewControllerRepresentable for SFSafariViewController ---
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Create the Safari ViewController with the URL
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional: Enable Reader mode if available
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed based on SwiftUI state changes in this simple case
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
    ContentView()
    // Ensure 'hsr_notices.xml' is in your Preview Assets or project bundle
}
