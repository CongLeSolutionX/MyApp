//
//  FullRSSAndWebViewImplementation_Refactored.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
@preconcurrency import WebKit // Keep @preconcurrency if needed for specific compiler versions/warnings
import UIKit

// MARK: - Data Model

struct RSSItem: Identifiable, Sendable, Equatable, Hashable { // Added Equatable/Hashable for potential diffing/animation
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date? // Date is conditionally Sendable in Swift 5.7+
    var itemDescription: String
    var imageURL: String?

    // Equatable conformance (based on ID or link usually sufficient for feeds)
    static func == (lhs: RSSItem, rhs: RSSItem) -> Bool {
        lhs.id == rhs.id || lhs.link == rhs.link
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(link) // Use link as part of identity if IDs can be unstable across fetches
    }
}

// MARK: - RSS Parser

// Note: RSSParser itself is NOT Sendable due to its stateful nature and NSObject inheritance.
// It must be used exclusively by its owning actor (MainActor in this case).
final class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    private var currentImageURL = ""

    private var items: [RSSItem] = []
    private var inItem = false
    private var inImage = false // Keep track if inside an image-related tag potentially holding a URL attribute
    private var parseError: Error?

    private static let dateFormats: [String] = [
        "EEE, dd MMM yyyy HH:mm:ss Z",       // Standard RSS date format
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",       // ISO 8601 with milliseconds
        "yyyy-MM-dd'T'HH:mm:ssZ",           // ISO 8601 without milliseconds
        "EEE, dd MMM yyyy HH:mm:ss zzz",    // Format with timezone name (e.g., GMT, PST)
        "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",     // ISO 8601 with timezone offset (e.g., +00:00)
        "yyyy-MM-dd'T'HH:mm:ssXXX",         // ISO 8601 with timezone offset without milliseconds
        "dd MMM yyyy HH:mm:ss Z"            // Less common variation
    ]

    // DateFormatter is not thread-safe if mutated. Creating statically and using consistently is okay here.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed-format dates
        return formatter
    }()

    // This method is synchronous and will be called on the actor that owns the RSSParser instance.
    func parse(data: Data) -> (items: [RSSItem], error: Error?) {
        items = []
        parseError = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse() // Check return value for early exit
        if !success && parseError == nil {
             // If parse() returns false but no specific error was set by the delegate, use the parser's error
             parseError = parser.parserError ?? NSError(domain: "RSSParserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "XML parsing failed."])
        }
        // The returned [RSSItem] is Sendable because RSSItem is Sendable.
        return (items, parseError)
    }

    // MARK: - XMLParserDelegate Methods

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            inItem = true
            // Reset current item properties
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
            currentImageURL = ""
            inImage = false // Reset image context for new item
        }
        // Handle common image elements within an item
        // Added 'media:thumbnail' and improved logic slightly
        else if inItem, ["media:content", "enclosure", "image", "media:thumbnail"].contains(elementName) {
            // Determine the attribute key likely holding the URL
            var potentialUrl: String? = nil

            switch elementName {
                case "media:content", "media:thumbnail":
                    // Prioritize media tags if they specify image/* type
                    if let type = attributeDict["type"], type.hasPrefix("image") {
                        potentialUrl = attributeDict["url"]
                    } else if attributeDict["type"] == nil { // Accept if no type specified
                         potentialUrl = attributeDict["url"]
                    }
                    // Check medium attribute (common in media:content)
                    if potentialUrl == nil && attributeDict["medium"] == "image" {
                        potentialUrl = attributeDict["url"]
                    }
                case "enclosure":
                    // Enclosure requires type starting with 'image'
                    if let type = attributeDict["type"], type.hasPrefix("image") {
                        potentialUrl = attributeDict["url"]
                    }
                case "image":
                    // RSS <image> usually child of <channel>, but check attributes if inside <item>
                    potentialUrl = attributeDict["href"] ?? attributeDict["url"]
                default: break
            }

            // Assign if found and currentImageURL is still empty for this item
            if let urlString = potentialUrl, !urlString.isEmpty, currentImageURL.isEmpty {
                currentImageURL = urlString
            }
            inImage = true // Flag that we are inside an image tag context (even if URL wasn't found here)
        }
         // Handle nested 'url' tag within 'image' tag (non-standard but possible)
         else if inItem && inImage && elementName == "url" {
             // Prepare to capture characters if we are inside an <image> context
             // This assumes the <image> tag itself didn't provide a URL attribute
             if currentImageURL.isEmpty {
                  currentElement = "imageURLNested" // Use a distinct state
             }
         }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        // Do not trim here, accumulate raw characters. Trimming happens at the end.
        let newCharacters = string
        // Append characters to the current element's string buffer
        switch currentElement {
        case "title":             currentTitle += newCharacters
        case "link":              currentLink += newCharacters
        case "pubDate":           currentPubDate += newCharacters // Accumulate date string fragments
        case "description":       currentDescription += newCharacters
        case "imageURLNested":    currentImageURL += newCharacters // Append to image URL if nested tag
        default:                  break
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        if elementName == "item" {
            inItem = false // Exiting the item scope
            inImage = false // Reset image context

            // --- Process the completed item ---

            // 1. Date Parsing
            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            var parsedDate: Date? = nil
            if !trimmedPubDate.isEmpty {
                for format in RSSParser.dateFormats {
                    // Must set dateFormat each time as DateFormatter caches it
                    RSSParser.dateFormatter.dateFormat = format
                    if let date = RSSParser.dateFormatter.date(from: trimmedPubDate) {
                        parsedDate = date
                        break // Stop after the first successful parse
                    }
                }
                if parsedDate == nil {
                    print("⚠️ Warning: Failed to parse date string '\(trimmedPubDate)' for item '\(currentTitle.prefix(50))...'")
                }
            }

            // 2. Link Processing (ensure it's a valid URL)
            let rawLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalLink: String
            if let url = URL(string: rawLink), url.scheme != nil, url.host != nil {
                 finalLink = rawLink // Looks like a valid URL
            } else {
                 print("⚠️ Warning: Skipping item '\(currentTitle.prefix(50))...' due to invalid link: \(rawLink)")
                 // Reset potentially accumulated values before next item starts
                 currentPubDate = ""; currentDescription = ""; currentImageURL = ""; currentTitle = ""; currentLink = ""
                 currentElement = ""
                 return // Skip adding this item
            }

            // 3. Image URL Processing
            let finalImageURL = currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)

            // 4. Description Cleaning (More robust HTML stripping)
            let rawDescription = currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            // Basic stripping (can be improved with libraries if needed)
            let cleanedDescription = rawDescription
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) // Strip tags
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // Collapse whitespace
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#39;", with: "'")
                .trimmingCharacters(in: .whitespacesAndNewlines)


            // 5. Create and append the new RSSItem
            let newItem = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: finalLink,
                pubDate: parsedDate,
                itemDescription: cleanedDescription,
                imageURL: finalImageURL.isEmpty ? nil : finalImageURL
            )
            items.append(newItem)

            // Reset accumulated values (done at start of next item, but good practice here too)
             currentPubDate = ""; currentDescription = ""; currentImageURL = ""; currentTitle = ""; currentLink = ""

        } else if inItem, ["media:content", "enclosure", "image", "media:thumbnail"].contains(elementName) {
            inImage = false // Exiting an image-related tag
        } else if inItem && inImage && elementName == "url" && currentElement == "imageURLNested" {
             // Reset specific nested state if needed
        }


        // Reset current element name after processing the closing tag helps avoid mis-appending characters
        currentElement = ""
    }

    // Error Handling
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Only set the error if one hasn't been set already (first error is usually most relevant)
        if self.parseError == nil {
            self.parseError = parseError
        }
        print("❌ Parse error occurred: \(parseError.localizedDescription) at line \(parser.lineNumber), column \(parser.columnNumber)")
        parser.abortParsing() // Stop parsing on critical error
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        // Treat validation errors less severely, maybe log and continue?
        if self.parseError == nil { // Don't overwrite a more critical parse error
            // self.parseError = validationError // Optionally treat as fatal
        }
        print("⚠️ Validation error occurred: \(validationError.localizedDescription) at line \(parser.lineNumber), column \(parser.columnNumber)")
        // parser.abortParsing() // Optionally abort
    }

    func parserDidEndDocument(_ parser: XMLParser) {
         print("Finished parsing document.")
    }
}


// MARK: - View Model

@MainActor // Ensure published properties are updated on the main thread
class RSSViewModel: ObservableObject {
    @Published var rssItems: [RSSItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // This parser instance is bound to the Main Actor because RSSViewModel is @MainActor
    private let parser = RSSParser()
    private var dataTask: URLSessionDataTask? // To allow cancelling

    // Debounce mechanism to prevent rapid reloads
    private var loadDebounceTimer: Timer?

    func loadRSS(urlString: String = "https://www.law360.com/ip/rss", isRefresh: Bool = false) {
        // Cancel previous timer if new load is requested quickly
        loadDebounceTimer?.invalidate()

        // Debounce refresh calls slightly
        if isRefresh {
            loadDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.performLoad(urlString: urlString, isRefresh: isRefresh)
            }
        } else {
             // Load immediately if not a refresh
             performLoad(urlString: urlString, isRefresh: isRefresh)
        }
    }

    private func performLoad(urlString: String, isRefresh: Bool) {
         print("Performing load for URL: \(urlString), Refresh: \(isRefresh)")
         guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        // Cancel ongoing task before starting a new one
        dataTask?.cancel()

        // Set loading state only if not refreshing silently, or if item list is empty
        if !isRefresh || rssItems.isEmpty {
            isLoading = true
        }
        errorMessage = nil // Clear previous errors on new load attempt

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30) // Force refresh
        request.setValue("FeedFetcher-App/1.0", forHTTPHeaderField: "User-Agent") // Set user agent

        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // --- This closure runs on a BACKGROUND THREAD ---

            // Ensure self is still available
            guard let self = self else {
                 print("ViewModel deallocated before network task finished.")
                 return
             }

            // Ensure task wasn't cancelled
            if let error = error as? URLError, error.code == .cancelled {
                print("Data task cancelled.")
                // Don't modify state if cancelled, just return. isLoading will be handled by the new task.
                return
            }

            // Check for network errors first
            if let error = error {
                print("❌ Network Error: \(error)")
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = "Network Error: \(error.localizedDescription)"
                }
                return
            }

            // Check for HTTP status code errors
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                 print("❌ HTTP Error: \(httpResponse.statusCode)")
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = "Server Error: \(httpResponse.statusCode)" // User-friendly message
                }
                return
            }

            // Ensure data is present
            guard let data = data, !data.isEmpty else {
                print("❌ Error: No data received from URL.")
                Task { @MainActor in
                    self.isLoading = false
                    self.errorMessage = "No data received from server."
                }
                return
            }

            // Attempt decoding for debugging (optional)
            // print("Received \(data.count) bytes. Attempting decode...")
            // print("Data snippet: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "Unable to decode")")


            // --- SWITCH TO MAIN ACTOR to perform parsing and final UI updates ---
            Task { @MainActor in
                print("Starting parsing on Main Actor...")
                // If parsing is very slow, consider the alternative approach (parse on background)
                let (parsedItems, parseError) = self.parser.parse(data: data) // Access parser safely
                print("Parsing finished.")

                self.isLoading = false // Stop loading indicator regardless of outcome

                if let parseError = parseError {
                    print("❌ Parse Error: \(parseError)")
                    self.errorMessage = "Error reading feed: \(parseError.localizedDescription)"
                    // Maybe don't clear items on parse error during refresh? User decision.
                    // self.rssItems = []
                } else {
                    print("✅ Parsed and updating \(parsedItems.count) items.")
                    self.errorMessage = nil // Clear error on success
                    // Update items - Diffing could be done here for smoother updates if needed
                    let sortedItems = parsedItems.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }

                    // Only update if the data has actually changed to prevent needless UI refreshes
                     if self.rssItems != sortedItems {
                         self.rssItems = sortedItems
                         print("RSS items updated.")
                     } else {
                         print("Parsed items are the same as current items. No update needed.")
                     }
                }
            }
        }
        dataTask?.resume() // Start the task
    }

    // Function to cancel loading
    func cancelLoading() {
        dataTask?.cancel()
        loadDebounceTimer?.invalidate()
        // Only set isLoading to false if it was true
        if isLoading {
            Task { @MainActor in
                 self.isLoading = false // Ensure UI update happens on main thread
                 print("Loading cancelled by user.")
            }
        }
    }
}

// MARK: - Global Date Formatter for Display

private let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - SwiftUI Views (Redesigned)

// Displays an image asynchronously with placeholder and error states.
struct RSSAsyncImage: View {
    let urlString: String?
    let targetHeight: CGFloat? // Allow specifying height

    var body: some View {
        Group {
            if let urlString = urlString, let url = URL(string: urlString) {
                AsyncImage(url: url, transaction: Transaction(animation: .easeIn(duration: 0.3))) { phase in // Animate phase changes
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle().fill(.ultraThickMaterial) // Slightly visible placeholder bg
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(let error):
                        let _ = print("AsyncImage failed for \(urlString): \(error)")
                        defaultPlaceholder
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                defaultPlaceholder
            }
        }
        .frame(height: targetHeight)
        .clipped() // Clip after frame is set
        .contentShape(Rectangle()) // Define shape for gestures if needed later
    }

    private var defaultPlaceholder: some View {
        ZStack {
            Rectangle().fill(.ultraThickMaterial)
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .foregroundColor(.secondary)
                .padding(targetHeight != nil ? targetHeight! * 0.2 : 40) // Scale padding
        }
    }
}

// Simple tag view for topics
struct TopicTag: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium) // Slightly less bold
            .foregroundColor(.primary) // Adaptable color
            .padding(.vertical, 5) // Fine-tuned padding
            .padding(.horizontal, 10)
             .background(.quaternary.opacity(0.7), in: Capsule()) // Use semantic background color
            //.background(Color.purple.opacity(0.6)) // Old style
            //.clipShape(Capsule()) // Implicit from background modifier
    }
}

// Reusable button for the custom tab bar
struct TabBarButton: View {
    let iconName: String
    let label: String
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) { // Reduced spacing
                Image(systemName: iconName)
                    .font(isActive ? .title3 : .headline) // Adjust emphasis
                    .imageScale(.medium)
                     .symbolVariant(isActive ? .fill : .none) // Use fill variant when active
                Text(label)
                    .font(.caption2) // Smaller caption
            }
            .foregroundColor(isActive ? .accentColor : .secondary) // Use accent/secondary colors
            .frame(maxWidth: .infinity, minHeight: 44) // Ensure min height
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Redesigned RSSItemView (Modern Card)

struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool // Drives the layout change

    @State private var isBookmarked: Bool = false // Local state for demo

    // Constants for geometry
    private let cardCornerRadius: CGFloat = 16
    private let imageMaxHeightFull: CGFloat = 220
    // Compact view image size could be fixed or aspect ratio based
    private let imageMaxHeightCompact: CGFloat? = nil // Let aspect ratio decide in compact? Or set fixed e.g. 80?

    var body: some View {
        NavigationLink(destination: WebViewControllerWrapper(urlString: item.link)) {
             if isCompact {
                 compactLayout
             } else {
                 fullLayout
             }
        }
        .buttonStyle(CardButtonStyle(cornerRadius: cardCornerRadius)) // Apply custom button style for interaction feedback
    }

    // --- Full Card Layout ---
    private var fullLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section (Optional)
             if let url = item.imageURL {
                 RSSAsyncImage(urlString: url, targetHeight: imageMaxHeightFull)
                     // Clip image to top corners slightly less than card to avoid gaps with stroke
                     .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius - 1))
                     .padding(.top, 1) // Offset for stroke
                     .padding(.horizontal, 1)
             }

            // Content Section
            VStack(alignment: .leading, spacing: 10) { // Increased spacing
                Text(item.title)
                    .font(.title3.weight(.semibold)) // Slightly bolder
                    .lineLimit(3)

                metadataView

                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                topicTagsView
                    .padding(.top, 4)
            }
            .padding() // Padding around the text content
        }
        .modifier(CardStyle(cornerRadius: cardCornerRadius))
        .overlay(alignment: .topTrailing) { // Bookmark for full view
             bookmarkButton
                 .padding(12)
         }
    }

    // --- Compact Card Layout ---
    private var compactLayout: some View {
        HStack(spacing: 12) {
             // Optional Image on the left
             if let url = item.imageURL {
                RSSAsyncImage(urlString: url, targetHeight: imageMaxHeightCompact)
                    .frame(width: 80) // Fixed width for compact image
                     .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius / 2)) // Softer corner radius for small image
             }

            // Text Content on the right
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.headline.weight(.medium))
                    .lineLimit(2) // Allow two lines for title

                 metadataView // Reuse metadata view

                 // Optional: Show 1 line of description if space allows
                 // Text(item.itemDescription)
                 //    .font(.caption)
                 //    .foregroundColor(.tertiary)
                 //    .lineLimit(1)

                Spacer() // Pushes content up if Vstack has extra space

                 HStack { // Footer actions/info
                    Text("Source: Law360") // Example
                       .font(.caption2)
                       .foregroundColor(.accentColor)
                       .lineLimit(1)
                    Spacer()
                    bookmarkButton
                }

            }
             // Give text content flexible width
             .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12) // Padding inside the HStack
        .modifier(CardStyle(cornerRadius: cardCornerRadius))
    }


    // --- Reusable Subviews ---

    @ViewBuilder // Use ViewBuilder for conditional logic within view property
    private var metadataView: some View {
         HStack(spacing: 12) { // Increased spacing
             // Date
             HStack(spacing: 4) {
                 Image(systemName: "calendar.circle")
                 if let pubDate = item.pubDate {
                      Text(pubDate, style: .relative) + Text(" ago")
                 } else {
                      Text("Date unknown")
                 }
             }

             // Optional: Reading Time Placeholder?
             // HStack(spacing: 4) {
             //     Image(systemName: "book.circle")
             //     Text("5 min read") // Example
             // }
         }
         .font(.caption)
         .foregroundColor(.secondary)
    }

    // Extracted Bookmark Button View
    private var bookmarkButton: some View {
        Button {
            isBookmarked.toggle()
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            // Add actual bookmark saving logic here...
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.callout)
                .foregroundColor(isBookmarked ? .pink : .secondary)
                .padding(isCompact ? 4 : 8) // Smaller padding in compact
                .background(
                    // Use material background only in full view overlay for better contrast?
                    .ultraThinMaterial.opacity(isCompact ? 0 : 1), // Invisible in compact for now
                    in: Circle())
                .contentShape(Circle()) // Ensure tappable area is circular
        }
        .buttonStyle(.plain)
    }


    // Extracted Tags View
    private var topicTagsView: some View {
        let tags = ["Law", "IP", "Legal Tech", "Litigation", "Compliance", "Regulation"] // Example
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags.prefix(5), id: \.self) { tag in // Limit displayed tags
                    TopicTag(title: tag)
                }
            }
        }
         // Ensure scroll view doesn't take infinite height if empty
         .frame(height: tags.isEmpty ? 0 : 30) // Adjust height based on tag size
          .padding(.top, tags.isEmpty ? 0 : 4)
    }
}


// MARK: - Supporting View Modifiers and Styles

// ViewModifier for common card styling
struct CardStyle: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1 / UIScreen.main.scale) // Use primary color for border adaptability
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// Custom ButtonStyle for visual feedback on card tap
struct CardButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
             // Scale down slightly when pressed
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
             // Optionally add a subtle overlay when pressed
            // .overlay(
            //      RoundedRectangle(cornerRadius: cornerRadius)
            //          .fill(Color.black.opacity(configuration.isPressed ? 0.05 : 0))
            // )
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


// MARK: - Redesigned ForYouView (Container)

struct ForYouView: View {
    @State private var isCompactView = false // Toggle between compact/full item views
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false
    @State private var selectedTab: Int = 0

    enum SortOrder { case newest, oldest }
    @State private var sortOrder: SortOrder = .newest

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Use system background for adaptability
                Color(.systemGroupedBackground) // Or .systemBackground
                    .edgesIgnoringSafeArea(.all)

                // Main Scrollable Content
                ScrollView {
                     // Use standard spacing, adjust card padding if needed
                    LazyVStack(spacing: 18) {
                        headerView

                        filterBar
                           .padding(.bottom, 6) // Less padding after filter

                        contentSection // Feed or Empty/Error state
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 80) // Space for tab bar
                }
                // --- Modifiers for ScrollView ---
                 .scrollDismissesKeyboard(.immediately) // Dismiss keyboard on scroll
                .refreshable { await refreshFeed() } // Keep refreshable
                .navigationBarHidden(true)
                .alert("Error Loading Feed", isPresented: $isShowingAlert, actions: {
                    Button("Retry") { rssViewModel.loadRSS() }
                    Button("OK", role: .cancel) {}
                }, message: {
                    Text(rssViewModel.errorMessage ?? "An unknown error occurred.")
                })

                // Loading Indicator Overlay (conditional)
                if rssViewModel.isLoading && rssViewModel.rssItems.isEmpty {
                    // Only show full overlay when initially loading
                     loadingOverlay
                }

                // Custom Tab Bar
                customTabBar
            }
            .edgesIgnoringSafeArea(.bottom) // Allow tab bar to reach edge
        }
        // --- Modifiers for NavigationView ---
        .onAppear { // Load data when view appears
            if rssViewModel.rssItems.isEmpty && !rssViewModel.isLoading {
                rssViewModel.loadRSS()
            }
        }
        .onChange(of: rssViewModel.errorMessage) { _, newValue in // Show error alert
            // Only show alert if not loading (isLoading check might be redundant if error clears loading state)
            isShowingAlert = newValue != nil && !rssViewModel.isLoading
        }
        .onChange(of: sortOrder) { _, newOrder in // Sort items when order changes
            sortItems(order: newOrder)
        }
         // Removed preferredColorScheme - let system decide or use Appearance setting
    }

    // --- Async Refresh Function ---
    func refreshFeed() async {
         print("🔄 Refreshing feed...")
         rssViewModel.loadRSS(isRefresh: true) // Call load with refresh flag
    }

    // --- Subviews ---

    private var headerView: some View {
        HStack {
            Text("Today's Feed")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.primary)
            Spacer()
            // Optional: Settings/Profile Button
            // Button(action: { /* Settings action */ }) {
            //     Image(systemName: "gearshape.circle")
            //         .font(.title)
            //         .foregroundColor(.secondary)
            // }
        }
        // Padding is handled by LazyVStack's horizontal padding
    }

    private var filterBar: some View {
         HStack {
            // Sorting Menu
            Menu {
                Button { sortOrder = .newest } label: { Label("Newest First", systemImage: sortOrder == .newest ? "checkmark" : "") }
                Button { sortOrder = .oldest } label: { Label("Oldest First", systemImage: sortOrder == .oldest ? "checkmark" : "") }
            } label: {
                 HStack(spacing: 4) {
                    Text(sortOrder == .newest ? "Newest" : "Oldest")
                    Image(systemName: "chevron.down")
                 }
                 .font(.subheadline.weight(.medium))
                 .foregroundColor(.accentColor) // Use accent color for interactive element
                 .padding(.vertical, 8)
                 .padding(.horizontal, 12)
                 // Use capsule shape for background/overlay
                 .background(.ultraThinMaterial, in: Capsule())
                 .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 0.5))
            }

            Spacer()

            // View Toggle Button
             Button {
                 withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                      isCompactView.toggle()
                 }
             } label: {
                Image(systemName: isCompactView ? "list.bullet" : "square.grid.2x2") // Simpler icons
                     .font(.title3)
                     .frame(width: 40, height: 40) // Slightly smaller tappable area
                     .background(.ultraThinMaterial, in: Circle())
                     .foregroundColor(.secondary)
            }
             .buttonStyle(.plain) // Ensure custom background works

         }
    }

    // Dynamically shows feed, empty state, or error hint
    @ViewBuilder
    private var contentSection: some View {
         // Don't show content if initially loading (handled by overlay)
         if !rssViewModel.isLoading || !rssViewModel.rssItems.isEmpty {
             if !rssViewModel.rssItems.isEmpty {
                 // --- Feed Items ---
                 // Using item ID for ForEach stability during sorting/updates
                 ForEach(rssViewModel.rssItems, id: \.id) { item in
                     RSSItemView(item: item, isCompact: isCompactView)
                         // Each card gets its own animation context if needed
                         // .animation(.default, value: isCompactView) // Animate individual card layout changes
                 }
             } else if rssViewModel.errorMessage == nil {
                 // --- Empty State ---
                 emptyStateView
             } else {
                 // --- Error State Hint ---
                  // The main error is shown in the alert.
                  // Optionally show a minimal hint here too.
                   // errorStateView
             }
         }
         // The loading state when rssItems is empty is handled by the overlay
    }

    // Loading Overlay View
    private var loadingOverlay: some View {
         ZStack {
             Rectangle().fill(.ultraThinMaterial).edgesIgnoringSafeArea(.all)
             VStack(spacing: 10) {
                 ProgressView().controlSize(.large)
                 Text("Loading Feed...").foregroundColor(.secondary)
             }
             .padding(30)
             .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 15))
             .shadow(radius: 10)
         }
         .zIndex(10) // Ensure it's on top
    }


    // Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 15) {
             Spacer(minLength: 50) // Adjust spacing
             Image(systemName: "tray.fill")
                 .font(.system(size: 50))
                 .foregroundColor(.secondary).opacity(0.7)
             VStack(spacing: 5) { // Tighter text spacing
                 Text("Nothing Here Yet")
                     .font(.title3.weight(.semibold))
                     .foregroundColor(.primary)
                 Text("Pull down to refresh the feed.")
                     .font(.subheadline)
                     .foregroundColor(.secondary)
                     .multilineTextAlignment(.center)
             }
             Spacer()
         }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    // Example Error view (if needed inline)
    // private var errorStateView: some View { ... }

    // Custom Tab Bar View
    private var customTabBar: some View {
        HStack {
            TabBarButton(iconName: "newspaper", label: "Feed", isActive: selectedTab == 0) { selectedTab = 0 }
            TabBarButton(iconName: "play.square.stack", label: "Episodes", isActive: selectedTab == 1) { selectedTab = 1 }
            TabBarButton(iconName: "bookmark", label: "Saved", isActive: selectedTab == 2) { selectedTab = 2 }
            TabBarButton(iconName: "number.square", label: "Interests", isActive: selectedTab == 3) { selectedTab = 3 }
        }
        .padding(.vertical, 5) // Less vertical padding
        .padding(.horizontal)
        .padding(.bottom, UIApplication.shared.connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                    .first?.safeAreaInsets.bottom ?? 0) // Adjust padding based on safe area
        .background(.ultraThinMaterial)
        .overlay(Divider().background(Color.black.opacity(0.2)), alignment: .top) // Darker divider
    }

    // Helper function to sort items with animation
    private func sortItems(order: SortOrder) {
         withAnimation(.easeInOut(duration: 0.4)) {
              switch order {
              case .newest:
                  rssViewModel.rssItems.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
              case .oldest:
                  rssViewModel.rssItems.sort { ($0.pubDate ?? .distantFuture) < ($1.pubDate ?? .distantFuture) }
              }
         }
    }
}


// MARK: - Web View Controller (UIKit Implementation - Refactored)
// No changes to this section from the previous version


class AnotherCustomWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // --- Properties ---
    var webView: WKWebView!
    var progressView: UIProgressView!
    var toolbar: UIToolbar!

    lazy var backButton: UIBarButtonItem = createToolbarButton(imageName: "arrow.left", action: #selector(goBack))
    lazy var forwardButton: UIBarButtonItem = createToolbarButton(imageName: "arrow.right", action: #selector(goForward))
    lazy var reloadButton: UIBarButtonItem = createToolbarButton(imageName: "arrow.clockwise", action: #selector(reloadPage))
    lazy var shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    lazy var openInSafariButton: UIBarButtonItem = createToolbarButton(imageName: "safari", action: #selector(openInSafariTapped))

    private var initialURLString: String?
    private var observers: [NSKeyValueObservation] = [] // Store KVO observers


    // --- Initialization ---
    convenience init(urlString: String) {
        self.init(nibName: nil, bundle: nil)
        self.initialURLString = urlString
        self.hidesBottomBarWhenPushed = true // Hide tab bar when pushed
    }

    // --- Lifecycle Methods ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        loadInitialContent()
    }

    deinit {
        observers.forEach { $0.invalidate() }
        observers.removeAll()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading() // Ensure loading stops
        print("AnotherCustomWebViewController deinitialized for URL: \(initialURLString ?? "nil")")
    }

    // --- UI Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupWebView()
        setupToolbar()
        setupProgressView() // Call after webview/toolbar are added to view
        configureToolbarItems()
    }

    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.title = "Loading..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        // Use modern appearance API
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground() // Or .configureWithTransparentBackground() etc.
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance // For consistency if needed
    }

    private func setupWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        // Use nonPersistent for better privacy unless logins are required
        configuration.websiteDataStore = .nonPersistent()

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Increase scroll deceleration rate for a slightly 'snappier' feel
        webView.scrollView.decelerationRate = .normal
        view.addSubview(webView)
    }

    private func setupToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        // Use modern appearance API
        let appearance = UIToolbarAppearance()
        appearance.configureWithDefaultBackground()
        toolbar.standardAppearance = appearance
        toolbar.compactAppearance = appearance // For consistency
         if #available(iOS 15.0, *) {
            toolbar.scrollEdgeAppearance = appearance
         }
        view.addSubview(toolbar)
    }

     private func setupProgressView() {
         progressView = UIProgressView(progressViewStyle: .bar)
         progressView.translatesAutoresizingMaskIntoConstraints = false
         progressView.progress = 0.0
         progressView.trackTintColor = .clear
         progressView.progressTintColor = UIColor.systemBlue // Use UIColor for UIKit component
         progressView.isHidden = true
         view.addSubview(progressView) // Add AFTER webview/toolbar

          // --- Auto Layout Constraints ---
          NSLayoutConstraint.activate([
              webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
              webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

              toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

              // Pin progressView to top of safe area guide (below potential nav bar)
              progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
              progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          ])
     }

     private func configureToolbarItems() {
          backButton.isEnabled = false
          forwardButton.isEnabled = false
          // Use flexible space for even distribution
          let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
          toolbar.items = [
              backButton, flexibleSpace,
              forwardButton, flexibleSpace,
              reloadButton, flexibleSpace,
              shareButton, flexibleSpace,
              openInSafariButton
          ]
     }

    // Helper to create toolbar buttons consistently
    private func createToolbarButton(imageName: String, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: action
        )
    }


    // --- KVO Setup ---
    private func setupObservers() {
         // Use modern block-based KVO for safety and conciseness
         observers = [
             webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
                 guard let self = self, let newProgress = change.newValue else { return }
//                 self.progressView.setProgress(Float(newProgress), animated: newProgress > self.progressView.progress) // Animate only forward progress
                 // Debounce hiding slightly to prevent flickering
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      self.progressView.isHidden = self.webView.estimatedProgress >= 1.0 || self.webView.estimatedProgress <= 0.0
                  }
             },
             webView.observe(\.title, options: [.new]) { [weak self] _, change in
                 guard let self = self, let newTitle = change.newValue as? String else { return }
                  self.navigationItem.title = newTitle.isEmpty ? "Loading..." : newTitle
             },
             webView.observe(\.canGoBack, options: [.new]) { [weak self] _, change in
                 self?.backButton.isEnabled = change.newValue ?? false
             },
             webView.observe(\.canGoForward, options: [.new]) { [weak self] _, change in
                 self?.forwardButton.isEnabled = change.newValue ?? false
             }
         ]
    }

    // --- Content Loading ---
    private func loadInitialContent() {
        if let urlString = initialURLString {
            loadRemoteURL(urlString: urlString)
        } else {
            showErrorPage(message: "No URL specified.")
            navigationItem.title = "Error"
        }
    }

    func loadURL(urlString: String) {
         guard webView.url?.absoluteString != urlString else { return }
         loadRemoteURL(urlString: urlString)
    }

    private func loadRemoteURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            showErrorPage(message: "Could not load the page because the URL is invalid.")
             navigationItem.title = "Invalid URL"
            return
        }
        print("Loading URL: \(url)")
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        webView.load(request)
    }

    private func showErrorPage(message: String, detailedError: String? = nil) {
         // Simple HTML error page, ensure viewport is set for mobile
         let html = """
         <!DOCTYPE html><html><head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'><style>body{font-family:-apple-system,sans-serif;display:flex;justify-content:center;align-items:center;height:80vh;text-align:center;padding:20px;color:#555;}.content{max-width:80%;}h1{color:#d32f2f;font-size:1.3em;margin-bottom:10px;}p{font-size:0.9em;margin-bottom:5px;}.details{font-size:0.7em;color:#999;word-break:break-all;}</style></head><body><div class='content'><h1>Load Failed</h1><p>\(message)</p>\(detailedError != nil ? "<p class='details'>(\(detailedError!))</p>" : "")</div></body></html>
         """
         webView.loadHTMLString(html, baseURL: nil)
     }


    // --- Actions ---
    @objc private func closeTapped() {
        if let navController = navigationController, navController.viewControllers.first !== self {
            navController.popViewController(animated: true)
        } else if presentingViewController != nil {
           dismiss(animated: true)
       } else {
           print("Could not determine how to dismiss WebViewController.")
           // Fallback: attempt to dismiss if possible
            dismiss(animated: true, completion: nil)
       }
    }

    @objc private func menuTapped() {
        guard let url = webView.url else { return } // Check URL exists

        let actionSheet = UIAlertController(title: webView.title, message: url.absoluteString, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: .default) { [weak self] _ in self?.openInSafari() })
        actionSheet.addAction(UIAlertAction(title: "Copy URL", style: .default) { _ in UIPasteboard.general.string = url.absoluteString })
        actionSheet.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] _ in self?.shareTapped() })

        if webView.isLoading {
            actionSheet.addAction(UIAlertAction(title: "Stop Loading", style: .destructive) { [weak self] _ in self?.webView?.stopLoading() })
        } else {
             actionSheet.addAction(UIAlertAction(title: "Reload", style: .default) { [weak self] _ in self?.reloadPage() })
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad Popover Anchor
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(actionSheet, animated: true)
    }

    @objc private func goBack() { webView.goBack() }
    @objc private func goForward() { webView.goForward() }
    @objc private func reloadPage() { webView.reload() }

    @objc private func shareTapped() {
        guard let url = webView.url else { return }
        let itemsToShare: [Any] = [url, webView.title ?? ""]
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
             popover.barButtonItem = shareButton
        }
        present(activityVC, animated: true)
    }

     @objc private func openInSafariTapped() { openInSafari() }

    private func openInSafari() {
        guard let url = webView.url, UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL in Safari: \(webView.url?.absoluteString ?? "nil")")
            return
        }
        UIApplication.shared.open(url)
    }

    // --- JavaScript Injection Example ---
    func injectJavaScript(script: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        // Ensure injection happens on main thread if called from elsewhere
        DispatchQueue.main.async {
             self.webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("JS Error: \(error)")
                    completion?(.failure(error))
                } else {
                    print("JS Result: \(result ?? "nil")")
                    completion?(.success(result))
                }
            }
        }
    }

    // --- WKNavigationDelegate Methods ---
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow all navigation by default
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Did Start Provisional Navigation: \(webView.url?.absoluteString ?? "no url")")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Did Commit Navigation: \(webView.url?.absoluteString ?? "no url")")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Did Finish Navigation: \(webView.url?.absoluteString ?? "no url")")
    }

    // Centralized error handling for navigation failures
     private func handleNavigationError(_ error: Error, context: String) {
         let nsError = error as NSError
         // Ignore cancellation and frame load interruptions
         if nsError.domain == "NSURLErrorDomain" && nsError.code == NSURLErrorCancelled {
             print("\(context) Navigation cancelled - ignoring.")
             return
         }
        if nsError.domain == WKError.errorDomain && nsError.code == WKError.webViewInvalidated.rawValue {
             print("\(context) WebView invalidated error - ignoring.")
             return
         }
         // Ignore "Plug-in handled load" errors for certain content types
         if nsError.domain == "WebKitPluginErrorDomain" && nsError.code == 102 {
             print("\(context) Plug-in handled load - ignoring.")
             return
         }

         print("❌ \(context) Navigation failed: \(error.localizedDescription)")
         // Avoid showing error page for minor/ignored errors
         if !(nsError.domain == "NSURLErrorDomain" && nsError.code == NSURLErrorCancelled) {
             showErrorPage(message: "Could not load the page.", detailedError: error.localizedDescription)
              if context == "Provisional" { navigationItem.title = "Failed to Load" }
         }
     }

     func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         handleNavigationError(error, context: "Permanent")
     }

     func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         handleNavigationError(error, context: "Provisional")
     }

     func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
         print("Redirect received for: \(webView.url?.absoluteString ?? "unknown URL")")
     }

     func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
         // Default handling is usually sufficient unless specific auth required
         completionHandler(.performDefaultHandling, nil)
     }

     // Process terminated (e.g., due to memory pressure)
     func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
         print("⚠️ Web Content Process Terminated. Reloading might be needed.")
         // Optionally try reloading the page or show an error message asking the user to reload.
         // You might want to reload automatically only once to avoid reload loops.
         showErrorPage(message: "The page stopped responding. Please try reloading.")
     }


     // --- WKUIDelegate Methods ---
     func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
         presentAlert(message: message, defaultActionTitle: "OK") { _ in completionHandler() }
     }

     func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
         presentAlert(message: message, cancelActionTitle: "Cancel", defaultActionTitle: "OK") { confirmed in
             completionHandler(confirmed)
         }
     }

      func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
          let alertController = UIAlertController(title: webView.url?.host, message: prompt, preferredStyle: .alert)
          alertController.addTextField { textField in
              textField.text = defaultText
          }
          alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
              completionHandler(alertController.textFields?.first?.text)
          })
          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
          safePresent(alertController)
      }

      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
          // Handle target="_blank" or window.open requests
          // Option 1: Load in the same view
          if navigationAction.targetFrame == nil {
              webView.load(navigationAction.request)
          }
          // Option 2: Open externally if possible
          // if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
          //     UIApplication.shared.open(url)
          // }
          // Option 3: Block new window creation
          return nil
      }

     // --- Alert Presentation Helper ---
     private func presentAlert(message: String, cancelActionTitle: String? = nil, defaultActionTitle: String, completion: @escaping (Bool) -> Void) {
         let alertController = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)

         if let cancelTitle = cancelActionTitle {
             alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in completion(false) })
         }
         alertController.addAction(UIAlertAction(title: defaultActionTitle, style: .default) { _ in completion(true) })

         safePresent(alertController)
     }

     // Helper to prevent presenting while another alert/vc is already presented
     private func safePresent(_ viewControllerToPresent: UIViewController) {
         guard self.presentedViewController == nil else {
             print("Alert/VC presentation suppressed: Another view controller is already presented.")
             // If it was an alert needing a completion, call it with a default (e.g., false/nil)
             return
         }
         present(viewControllerToPresent, animated: true)
     }
}


// MARK: - SwiftUI Wrapper for WebViewController

struct WebViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    let urlString: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let webViewController = AnotherCustomWebViewController(urlString: urlString)
        let navigationController = UINavigationController(rootViewController: webViewController)
        // Apply global appearance settings if needed
        // navigationController.navigationBar.tintColor = .systemBlue
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No update logic needed here if URL is immutable after creation
    }
}


// MARK: - PreviewProvider (Updated)

struct CombinedView_Previews: PreviewProvider {

    // Use a nested struct for managing preview state/helpers if it gets complex
    struct PreviewContainer: View {
         var initialCompactState: Bool = false
         var initialItems: [RSSItem] = sampleItems
         var initialIsLoading: Bool = false
         var initialError: String? = nil

         // Use @StateObject for the ViewModel in the preview container
         @StateObject private var previewModel: RSSViewModel

         init(items: [RSSItem] = sampleItems, isLoading: Bool = false, error: String? = nil, compact: Bool = false) {
             self.initialCompactState = compact
             // Create the ViewModel *once* for the preview container instance
              let vm = RSSViewModel()
              vm.rssItems = items.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
              vm.isLoading = isLoading
              vm.errorMessage = error
              _previewModel = StateObject(wrappedValue: vm)
         }

         var body: some View {
             ForYouView(previewInitialCompactState: initialCompactState) // Pass initial state if needed
                  .environmentObject(previewModel) // Provide the ViewModel to the environment
         }
    }

    // Modify ForYouView slightly to accept initial preview state
    struct ForYouView: View {
        @State var isCompactView: Bool
        // Remove @StateObject here, use @EnvironmentObject
        @EnvironmentObject private var rssViewModel: RSSViewModel
        @State private var isShowingAlert = false
        @State private var selectedTab: Int = 0
        @State private var sortOrder: SortOrder = .newest

         enum SortOrder { case newest, oldest } // Define locally or globally

        // Initializer for previews
        init(previewInitialCompactState: Bool = false) {
            self._isCompactView = State(initialValue: previewInitialCompactState)
        }

         // Main initializer (if needed) could differ slightly or just use the preview one

         // --- Paste the entire body and subview content of ForYouView here ---
         // --- Use `rssViewModel` directly (it's EnvironmentObject now) ----
         var body: some View {
             NavigationView {
                 ZStack(alignment: .bottom) {
                     Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                     ScrollView {
                         LazyVStack(spacing: 18) {
                             headerView
                             filterBar.padding(.bottom, 6)
                             contentSection
                         }
                         .padding(.horizontal)
                         .padding(.top)
                         .padding(.bottom, 80)
                     }
                     .scrollDismissesKeyboard(.immediately)
                     .refreshable { await refreshFeed() }
                     .navigationBarHidden(true)
                     .alert("Error Loading Feed", isPresented: $isShowingAlert, actions: {
                         Button("Retry") { rssViewModel.loadRSS() }
                         Button("OK", role: .cancel) {}
                     }, message: { Text(rssViewModel.errorMessage ?? "An unknown error occurred.") })

                     if rssViewModel.isLoading && rssViewModel.rssItems.isEmpty { loadingOverlay }
                     customTabBar
                 }
                 .edgesIgnoringSafeArea(.bottom)
             }
             .onAppear { /* Load data logic */
                 // This might cause issues in previews if loadRSS isn't mocked
                 // Maybe disable onAppear loading specifically for previews if needed
                 #if !DEBUG // Don't auto-load in previews maybe?
                 if rssViewModel.rssItems.isEmpty && !rssViewModel.isLoading {
                     rssViewModel.loadRSS()
                 }
                 #endif
             }
             .onChange(of: rssViewModel.errorMessage) { _, newVal in isShowingAlert = newVal != nil && !rssViewModel.isLoading }
             .onChange(of: sortOrder) { _, newOrder in sortItems(order: newOrder) }
         }

         // --- Copy all subviews (headerView, filterBar, etc.) and helper funcs here ---
         func refreshFeed() async { rssViewModel.loadRSS(isRefresh: true) }
         var headerView: some View { /* ... */ Text("Today's Feed").font(.largeTitle.weight(.bold)) }
         var filterBar: some View { /* ... */ HStack { Text("Filter Placeholder"); Spacer()} }
         @ViewBuilder var contentSection: some View {
             if !rssViewModel.isLoading || !rssViewModel.rssItems.isEmpty {
                   if !rssViewModel.rssItems.isEmpty {
                       ForEach(rssViewModel.rssItems, id: \.id) { item in
                          RSSItemView(item: item, isCompact: isCompactView)
                       }
                   } else if rssViewModel.errorMessage == nil { emptyStateView }
             }
         }
         var loadingOverlay: some View { /* ... */ ZStack { Text("Loading...") } }
         var emptyStateView: some View { /* ... */ Text("Empty") }
         var customTabBar: some View { /* ... */ HStack { Text("Tab Bar") } }
         func sortItems(order: SortOrder) { /* ... */ }
    }


     // --- Static Previews ---
    static var previews: some View {
        Group {
            PreviewContainer(items: sampleItems, isLoading: false, error: nil, compact: false)
                .previewDisplayName("Feed (Full)")

            PreviewContainer(items: sampleItems, isLoading: false, error: nil, compact: true)
               .previewDisplayName("Feed (Compact)")

            PreviewContainer(items: [], isLoading: true, error: nil)
               .previewDisplayName("Loading State")

            PreviewContainer(items: [], isLoading: false, error: "Network connection failed.")
               .previewDisplayName("Error State")

            PreviewContainer(items: [], isLoading: false, error: nil)
               .previewDisplayName("Empty State")

            // Preview individual card states in different contexts
             ScrollView { // Embed in ScrollView for context
                 VStack(spacing: 20) {
                     RSSItemView(item: sampleItems[0], isCompact: false) // Image
                     RSSItemView(item: sampleItems[2], isCompact: false) // No image
                     RSSItemView(item: sampleItems[1], isCompact: true) // Compact w/ Image
                     RSSItemView(item: sampleItems[2], isCompact: true) // Compact w/o Image
                 }
                  .padding()
             }
              .background(Color(.systemGroupedBackground))
              .previewDisplayName("Card Samples")


            // Preview the WebView directly if needed
            // WebViewControllerWrapper(urlString: "https://apple.com")
            //     .previewDisplayName("Web View")

        }
        // Apply environment settings for previews if needed
        // .environment(\.colorScheme, .dark)
    }


    // Sample data used in previews
    @MainActor static let sampleItems: [RSSItem] = [
        RSSItem(title: "Apple Vision Pro: A Developer's First Impressions", link: "https://example.com/1", pubDate: Date().addingTimeInterval(-3600*2), itemDescription: "Exploring the possibilities and challenges of building apps for Apple's new spatial computing platform. What works, what needs improvement?", imageURL: "https://images.unsplash.com/photo-1676158629141-86b369ad2dea?q=80&w=800&auto=format&fit=crop"), // Placeholder image
        RSSItem(title: "Swift 6 Concurrency Deep Dive: Actors, Sendable & Data Races", link: "https://example.com/2", pubDate: Date().addingTimeInterval(-3600*5), itemDescription: "Understanding Actors, Sendable, and the intricate details of Swift's modern concurrency model to prevent data races and build robust asynchronous code.", imageURL: "https://images.unsplash.com/photo-1638208194042-cabdbe9175c9?q=80&w=800&auto=format&fit=crop"), // Placeholder image
        RSSItem(title: "The Rise of Declarative UIs", link: "https://example.com/3", pubDate: Date().addingTimeInterval(-3600*24), itemDescription: "Comparing the developer experience and performance of SwiftUI with modern web frameworks like React and Svelte.", imageURL: nil), // No image
        RSSItem(title: "Optimizing Core Data Performance in Large Scale Apps", link: "https://example.com/4", pubDate: Date().addingTimeInterval(-3600*48), itemDescription: "Techniques for efficient fetching using predicates, batching updates for performance, and managing object graph complexity in Core Data applications.", imageURL: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=800&auto=format&fit=crop") // Placeholder image
    ]
}
