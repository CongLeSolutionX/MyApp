//
//  PressReleaseView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI
import Foundation // Needed for URL, Date, XMLParser, NSRegularExpression
import SafariServices // Needed for SFSafariViewController

// --- Data Model ---
struct PressReleaseItem: Identifiable, Hashable {
    let id: String // Use guid as the unique ID
    let title: String
    let link: URL?
    let descriptionText: String // Cleaned description text
    let publicationDate: Date?
    let creator: String
    let guid: String // Keep the original guid string as well
}

// --- XML Parser Delegate ---
class PressReleaseParserDelegate: NSObject, XMLParserDelegate {

    private var pressReleases: [PressReleaseItem] = []
    private var currentElement: String = ""
    private var currentElementData: String = "" // Accumulator for character data

    // Temporary storage for the item being parsed
    private var currentTitle: String = ""
    private var currentLink: String = ""
    private var currentDescriptionHTML: String = ""
    private var currentPubDateStr: String = ""
    private var currentCreator: String = ""
    private var currentGuid: String = ""
    private var isParsingItem: Bool = false // Flag to track if inside an <item>

    // Date formatter for RFC 822 format (common in RSS)
    private lazy var rfc822DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Use POSIX locale for fixed formats
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822 format
        // Example: Wed, 02 Apr 2025 08:00:00 -0400
        return formatter
    }()

    func getParsedPressReleases() -> [PressReleaseItem] {
        return pressReleases
    }

    // MARK: - XMLParserDelegate Methods

    func parserDidStartDocument(_ parser: XMLParser) {
        pressReleases = []
        print("XML Parsing Started")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentElementData = "" // Reset data accumulator for the new element

        if elementName == "item" {
            isParsingItem = true
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
        // Append characters only if inside an <item> and for relevant elements
        if isParsingItem {
             currentElementData += string //.trimmingCharacters(in: .whitespacesAndNewlines) // Trim later
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        // Process data only if we are inside an item element
        guard isParsingItem else {
            // Ignore elements outside of an <item> like <channel> data for now
             currentElement = ""
            return
        }

        // Trim whitespace accumulated characters *after* the element ends
        let trimmedData = currentElementData.trimmingCharacters(in: .whitespacesAndNewlines)

        // Process data based on the ended element *within* an item
        switch elementName {
        case "title":
            currentTitle = trimmedData
        case "link":
            currentLink = trimmedData
        case "description":
            currentDescriptionHTML = currentElementData // Keep raw HTML for now, process later
        case "pubDate":
            currentPubDateStr = trimmedData
        case "dc:creator": // Handle namespace prefix specifically
            currentCreator = trimmedData
        case "creator": // Handle case where namespace might be omitted (less likely but safe)
            if currentCreator.isEmpty { // Only use if dc:creator wasn't found
                 currentCreator = trimmedData
            }
        case "guid":
            currentGuid = trimmedData
        case "item":
            // Finished parsing an item, create the struct
            isParsingItem = false // Exited the item scope

             // 1. Parse Date
             let publicationDate = rfc822DateFormatter.date(from: currentPubDateStr)
             if publicationDate == nil && !currentPubDateStr.isEmpty {
                 print("Warning: Could not parse publication date string: \(currentPubDateStr)")
             }

            // 2. Clean Description HTML
            let descriptionText = cleanHTMLDescription(htmlString: currentDescriptionHTML)

            // 3. Create PressReleaseItem
            let pressRelease = PressReleaseItem(
                 id: currentGuid.isEmpty ? UUID().uuidString : currentGuid, // Fallback ID if guid is missing
                title: currentTitle,
                link: URL(string: currentLink),
                descriptionText: descriptionText,
                publicationDate: publicationDate,
                creator: currentCreator,
                guid: currentGuid
            )

            pressReleases.append(pressRelease)

        default:
            // Ignore other unexpected elements within <item>
            break
        }

        currentElement = "" // Clear current element name tracking
        // Don't clear currentElementData here, let didStartElement handle it
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML Parsing Finished. Found \(pressReleases.count) press releases.")
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Store the error message to potentially display it in the ViewModel
        print("XML Parsing Error: \(parseError.localizedDescription)")
        // Optionally, you could set a flag or store the error to be retrieved by the ViewModel
    }

    // MARK: - Helper Methods

    /// Cleans the HTML content from the <description> tag.
    /// Attempts to extract text within <p> tags first, falls back to stripping all tags.
    private func cleanHTMLDescription(htmlString: String) -> String {
        var cleanedString = ""

        // Strategy 1: Extract content specifically from <p> tags
        // This regex captures content inside the *first* <p> tag found. Add logic if multiple <p> needed.
        let pTagPattern = "<p>(.*?)</p>"
        do {
            let regex = try NSRegularExpression(pattern: pTagPattern, options: [.dotMatchesLineSeparators, .caseInsensitive])
            let matches = regex.matches(in: htmlString, range: NSRange(htmlString.startIndex..., in: htmlString))

            if let firstMatch = matches.first, let range = Range(firstMatch.range(at: 1), in: htmlString) {
                // Successfully found content within <p> tag
                cleanedString = String(htmlString[range])
                 // Now, strip any *remaining* tags (like <a>) from this extracted content
                 cleanedString = stripHTMLTags(from: cleanedString)
            }
        } catch {
            print("Regex error extracting <p> content: \(error)")
        }

         // Strategy 2: Fallback if Strategy 1 failed or if you want *all* text
         if cleanedString.isEmpty {
             // Strip *all* HTML tags from the original description
              cleanedString = stripHTMLTags(from: htmlString)
              // Also remove the common "View Press Release" link text if present
              cleanedString = cleanedString.replacingOccurrences(of: "View Press Release", with: "")
         }

        // Final cleanup: Trim whitespace and decode HTML entities (like &nbsp;)
        return cleanedString.trimmingCharacters(in: .whitespacesAndNewlines).decodedHTMLentities()
    }

     /// Basic HTML tag stripper using regular expression.
     private func stripHTMLTags(from string: String) -> String {
         // This regex removes content between < and >
         let pattern = "<[^>]+>"
         do {
             let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
             let range = NSRange(location: 0, length: string.utf16.count)
             return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
         } catch {
             print("Regex error stripping HTML tags: \(error)")
             return string // Return original on error
         }
     }
}

// Extension to decode basic HTML entities (add more if needed)
extension String {
    func decodedHTMLentities() -> String {
        var result = self.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        // Add more entities here if necessary
        return result
    }
}

// --- ViewModel ---
@MainActor
class PressReleaseFeedViewModel: ObservableObject {
    @Published var pressReleases: [PressReleaseItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var feedTitle: String = "Press Releases" // Store feed title

     // Keep track of the parser delegate instance
    private var parserDelegate = PressReleaseParserDelegate()
    private var currentParser: XMLParser? // To potentially abort parsing

    func loadReleasesFromLocalXML(filename: String) {
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

         // Reset the delegate's state before parsing
         parserDelegate = PressReleaseParserDelegate() // Create fresh delegate instance
         parser.delegate = parserDelegate
         currentParser = parser // Store reference if needed
        print("Starting XML parsing from local file: \(filename).xml")

        // Run parsing on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parse()
             // Important: Retrieve results *before* switching back to main thread
            let parsedReleases = self.parserDelegate.getParsedPressReleases()
             let parseError = parser.parserError // Check for parser-reported error

            // Update UI on the main thread
            DispatchQueue.main.async {
                self.isLoading = false
                 self.currentParser = nil // Clear parser reference

                if success {
                    self.pressReleases = parsedReleases
                     if self.pressReleases.isEmpty && self.errorMessage == nil {
                         // Check if parsing succeeded but returned no items
                         self.errorMessage = "No press releases found or parsed from the XML file."
                         print(self.errorMessage!)
                     } else if !self.pressReleases.isEmpty {
                         print("Successfully parsed \(self.pressReleases.count) press releases.")
                         self.errorMessage = nil // Clear error on success
                     }
                    // Optionally parse and set feedTitle from <channel><title>
                     // (Would require adding logic to the parser delegate)
                     // self.feedTitle = self.parserDelegate.getFeedTitle() ?? "Press Releases"

                } else {
                    // Parsing failed
                     if self.errorMessage == nil { // If delegate didn't set a specific error
                        if let error = parseError {
                            self.errorMessage = "XML Parsing Error: \(error.localizedDescription)"
                        } else {
                            self.errorMessage = "An unknown error occurred during XML parsing."
                        }
                     }
                    self.pressReleases = [] // Clear potentially partial data
                    print("XML Parsing failed. Error: \(self.errorMessage ?? "Unknown")")
                }
            }
        }
    }
}

// --- SwiftUI Views ---

struct PressReleaseView: View {
    // Use the updated ViewModel
    @StateObject private var viewModel = PressReleaseFeedViewModel()
    // Update the filename to match the provided XML
    private let localXMLFilename = "press-release"

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Releases...")
                } else if let errorMessage = viewModel.errorMessage {
                    // Improved Error View
                    VStack(spacing: 15) {
                         Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                         Text("Error Loading Data")
                             .font(.title2)
                             .fontWeight(.semibold)
                         Text(errorMessage)
                             .font(.body)
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         Button {
                             viewModel.loadReleasesFromLocalXML(filename: localXMLFilename)
                         } label: {
                              Label("Retry", systemImage: "arrow.clockwise")
                         }
                         .buttonStyle(.borderedProminent)
                         .padding(.top)
                    }
                    .padding()
                } else if viewModel.pressReleases.isEmpty {
                    Text("No Press Releases Found.")
                       .foregroundColor(.secondary)
                       .font(.headline)
                } else {
                    // Use the updated Row view
                    List {
                        ForEach(viewModel.pressReleases) { release in
                            NavigationLink(destination: PressReleaseDetailView(pressRelease: release)) {
                                PressReleaseRow(pressRelease: release)
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.feedTitle) // Use dynamic title from VM
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
                // Load initially only if data isn't already loaded/loading/errored
                 if viewModel.pressReleases.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    viewModel.loadReleasesFromLocalXML(filename: localXMLFilename)
                }
            }
        }
        .navigationViewStyle(.stack) // Consistent navigation style
    }
}

// Updated Row View
struct PressReleaseRow: View {
    let pressRelease: PressReleaseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(pressRelease.title)
                .font(.headline)
                .lineLimit(3) // Allow more lines for potentially longer titles

             // Display cleaned description snippet
             Text(pressRelease.descriptionText)
                 .font(.subheadline)
                 .foregroundColor(.gray)
                 .lineLimit(2) // Show a preview of the description
                 .padding(.bottom, 2)

            // Display publication date if available
            if let pubDate = pressRelease.publicationDate {
                Text("Published: \(pubDate, style: .date)") // Format as just date for row
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                 // Optionally show something if date is missing
                 // Text("Date: N/A").font(.footnote).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5) // Adjust padding
    }
}

// Updated Detail View
struct PressReleaseDetailView: View {
    let pressRelease: PressReleaseItem
    @State private var showSafari: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) { // Increased spacing

                DetailItemView(label: "Title", value: pressRelease.title, isTitle: true)

                if let pubDate = pressRelease.publicationDate {
                    DetailItemView(label: "Published", value: pubDate.formatted(date: .long, time: .shortened))
                 } else {
                    DetailItemView(label: "Published", value: "N/A")
                }

                 if !pressRelease.creator.isEmpty {
                      DetailItemView(label: "Creator", value: pressRelease.creator)
                 }

                if !pressRelease.descriptionText.isEmpty {
                    DetailItemView(label: "Description", value: pressRelease.descriptionText)
                }

                 // --- Button to open link ---
                 if let link = pressRelease.link {
                     Button {
                         showSafari = true
                     } label: {
                          Label("View Full Release", systemImage: "safari.fill") // More descriptive text
                               .padding(.vertical, 8) // Make button slightly taller
                               .frame(maxWidth: .infinity)
                     }
                     .buttonStyle(.borderedProminent)
                     .tint(.blue) // Consistent tint
                     .padding(.top, 10) // Add space above button
                     // Simple check if URL string isn't empty, SafariView does better check
                     .disabled(link.absoluteString.isEmpty || link.absoluteString == "about:blank" )
                 } else {
                      Text("Original Link: Not Available")
                          .font(.caption)
                          .foregroundColor(.secondary)
                          .padding(.top, 10)
                  }

                // Optionally display GUID for debugging/info
                DetailItemView(label: "GUID", value: pressRelease.guid)
                   .font(.caption) // Make GUID smaller
                   .foregroundColor(.gray)
                   .padding(.top, 5)

                Spacer() // Pushes content to the top
            }
            .padding()
        }
        .navigationTitle("Press Release") // More generic title
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari) {
            // Ensure URL is valid before presenting
            if let url = pressRelease.link, UIApplication.shared.canOpenURL(url) {
                SafariView(url: url)
                     // Consider `.presentationDetents` for iOS 16+ if desired
                     .ignoresSafeArea() // Use full screen for Safari
            } else {
                // Fallback or alert if URL is bad
                 VStack {
                      Text("Could not open link.")
                          .padding()
                     Button("Dismiss") { showSafari = false }
                          .buttonStyle(.bordered)
                 }

            }
        }
    }
}

// Reusable Detail Item View Helper
struct DetailItemView: View {
    let label: String
    let value: String
     var isTitle: Bool = false // Flag for special title styling

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(isTitle ? .caption : .headline) // Smaller label for title
                .foregroundColor(isTitle ? .secondary : .primary)
                 .textCase(isTitle ? .uppercase : .none) // Uppercase label for title

            Text(value)
                 .font(isTitle ? .title2.weight(.medium) : .body) // Larger font for title value
                 .foregroundColor(isTitle ? .primary : .secondary)
                 .textSelection(.enabled) // Allow copy
                 .lineLimit(nil) // Allow multiple lines
                 .fixedSize(horizontal: false, vertical: true) // Prevent text truncation vertically
        }
    }
}

// --- Safari View (No changes needed) ---
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        // config.entersReaderIfAvailable = true // Optional customization
        let safariVC = SFSafariViewController(url: url, configuration: config)
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed for this simple case
    }
}

// --- Preview Provider ---
#Preview {
    PressReleaseView()
    // **IMPORTANT:** Make sure 'press-release.xml' is added to your project
    // and included in the target's "Copy Bundle Resources" build phase.
    // Also ensure it's available for Previews (often requires adding to Preview Assets).
}
