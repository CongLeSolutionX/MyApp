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

struct RSSItem: Identifiable, Sendable { // Mark Sendable if Date were wrapped or not used across actors directly
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date? // Date is conditionally Sendable in Swift 5.7+
    var itemDescription: String
    var imageURL: String?
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
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "EEE, dd MMM yyyy HH:mm:ss zzz", // Added lowercase 'zzz' timezone format
        "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", // ISO8601 format with timezone offset
        "yyyy-MM-dd'T'HH:mm:ssXXX"
    ]

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
        parser.parse()
        // The returned [RSSItem] is Sendable if RSSItem is Sendable.
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
        }
        // Handle common image elements within an item
        if inItem, ["media:content", "enclosure", "image", "media:thumbnail"].contains(elementName) {
            // Determine the attribute key likely holding the URL
            var urlAttributeKey : String?
            switch elementName {
                case "media:content", "enclosure", "media:thumbnail":
                    urlAttributeKey = attributeDict["url"]
                case "image":
                    urlAttributeKey = attributeDict["href"] // RSS <image> tag often uses href inside <channel>, not <item>
                                                            // but some feeds might use it inside <item>
                    // Check parent tag if needed (standard RSS <image> is child of <channel>)
                    // For simplicity, only checking attributes here.
                    // Also consider 'url' attribute for <image> potentially inside item from some conventions
                     if urlAttributeKey == nil { urlAttributeKey = attributeDict["url"] }
                default:
                    urlAttributeKey = nil
            }


            if let urlString = urlAttributeKey, !urlString.isEmpty {
                // Check enclosure type for non-images
                if elementName == "enclosure", let type = attributeDict["type"], !type.hasPrefix("image") {
                   // Skip this enclosure if it's not an image type
                } else {
                    // Only assign if we haven't found one yet in this item
                    if currentImageURL.isEmpty {
                       currentImageURL = urlString
                    }
                    inImage = true // Flag that we are inside an image tag context
                }
            }
             // Additionally check for <image><url>url_here</url></image> pattern inside item (non-standard but seen)
             else if elementName == "image" {
                 // Handled by foundCharacters if currentElement becomes "url" inside "image"
                 inImage = true // Still consider it an image context
             }
        }
         // Handle nested 'url' tag within 'image' tag (non-standard but possible)
         else if inItem && inImage && elementName == "url" {
             currentElement = "imageURLNested" // Use a distinct state
         }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        let newCharacters = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newCharacters.isEmpty else { return }

        // Append characters to the current element's string buffer
        switch currentElement {
        case "title":             currentTitle += newCharacters
        case "link":              currentLink += newCharacters
        case "pubDate":           currentPubDate += newCharacters // Accumulate date string fragments
        case "description":       currentDescription += newCharacters
        case "imageURLNested":    currentImageURL += newCharacters // Append to image URL if nested tag
        // Add cases for other elements you might need to capture text from
        default:                  break
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false // Exiting the item scope
            inImage = false // Reset image context when item ends

            // Process the completed item
            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            var parsedDate: Date? = nil

            // Attempt to parse the date using known formats
            for format in RSSParser.dateFormats {
                RSSParser.dateFormatter.dateFormat = format
                if let date = RSSParser.dateFormatter.date(from: trimmedPubDate) {
                    parsedDate = date
                    break // Stop after the first successful parse
                }
            }
            if parsedDate == nil {
                print("Warning: Failed to parse date string: \(trimmedPubDate)")
            }

            // Prepare imageURL, ensure it's trimmed and nil if empty
            let finalImageURL = currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)

             // Simple HTML cleaning for description (basic example)
             let cleanedDescription = currentDescription
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "&nbsp;", with: " ") // Replace non-breaking spaces
                .replacingOccurrences(of: "&amp;", with: "&") // Replace ampersand
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#39;", with: "'")


            // Create and append the new RSSItem
            let newItem = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: parsedDate,
                itemDescription: cleanedDescription,
                imageURL: finalImageURL.isEmpty ? nil : finalImageURL
            )
            items.append(newItem)
            // Reset for next item is handled in didStartElement("item")

        } else if inItem, ["media:content", "enclosure", "image", "media:thumbnail"].contains(elementName) {
            inImage = false // Exiting an image-related tag
        } else if elementName == "url" && currentElement == "imageURLNested" {
             // Handled - nothing more needed here for this specific case
        }


        // Reset current element *unless* we are exiting item or image context
        // to handle potential nested tags correctly if needed later.
        // This simple reset might still be insufficient for deeply nested unknown structures.
        if elementName != "item" && !["media:content", "enclosure", "image", "media:thumbnail"].contains(elementName) {
             currentElement = ""
        }
    }

    // Error Handling
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
        // Log the error, maybe update UI state
        print("Parse error occurred: \(parseError.localizedDescription)")
        parser.abortParsing() // Stop parsing on critical error
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        // Treat validation errors similarly to parse errors for now
        self.parseError = validationError
        print("Validation error occurred: \(validationError.localizedDescription)")
        // Consider aborting parsing depending on severity
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

    func loadRSS(urlString: String = "https://www.law360.com/ip/rss") { // Default URL
        guard let url = URL(string: urlString) else {
            // No need for Task{} here, already on Main Actor if called from UI
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        // Set loading state immediately (already on Main Actor)
        isLoading = true
        errorMessage = nil

        // Perform the network request on a background thread
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // --- This closure runs on a BACKGROUND THREAD ---

            // Ensure self is still available
            guard let self = self else { return }

            // Check for network errors first
            if let error = error {
                // Switch to Main Actor to update state
                Task { @MainActor in
                    self.isLoading = false // Stop loading indicator
                    self.errorMessage = "Error fetching RSS feed: \(error.localizedDescription)"
                    print("Network Error: \(error)") // Log detailed error
                }
                return
            }

            // Check for HTTP status code errors
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                // Switch to Main Actor to update state
                Task { @MainActor in
                    self.isLoading = false // Stop loading indicator
                    self.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    print("HTTP Error: \(httpResponse.statusCode)") // Log status code
                }
                return
            }

            // Ensure data is present
            guard let data = data else {
                // Switch to Main Actor to update state
                Task { @MainActor in
                    self.isLoading = false // Stop loading indicator
                    self.errorMessage = "No data received"
                    print("Error: No data received from URL.")
                }
                return
            }

             // Optional: Log raw data snippet for debugging parsing issues
             // print("Received data: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "Unable to decode as UTF-8")")


            // --- SWITCH TO MAIN ACTOR to perform parsing and final UI updates ---
            Task { @MainActor in
                // Now we are on the Main Actor, it's safe to access self.parser
                // If parsing is very slow, consider the alternative approach (parse on background)
                print("Starting parsing on Main Actor...")
                let (parsedItems, parseError) = self.parser.parse(data: data)
                print("Parsing finished.")

                // Stop loading indicator *after* parsing is complete
                self.isLoading = false

                // Update the rest of the UI state
                if let parseError = parseError {
                    self.errorMessage = "Error parsing RSS: \(parseError.localizedDescription)"
                    self.rssItems = [] // Clear potentially stale items on error
                    print("Parse Error: \(parseError)") // Log detailed parse error
                } else {
                    self.errorMessage = nil // Clear any previous error
                    self.rssItems = parsedItems.sorted { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) } // Sort by date initially
                    print("Parsed and updated \(parsedItems.count) items.")
                }
            }
        }.resume()
    }
}

// MARK: - Global Date Formatter for Display

private let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - SwiftUI Views

// Displays an image asynchronously with placeholder and error states.
struct RSSAsyncImage: View {
    let urlString: String?
    let isCompact: Bool // Determines the frame size

    var body: some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack { // Use ZStack to overlay ProgressView
                        Rectangle().fill(Color.secondary.opacity(0.1)) // Placeholder background
                        ProgressView() // Show loading indicator
                    }
                    .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill() // Fill the frame, clipping excess
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        .clipped() // Prevent image overflow
//                        .transition(.opacity.animation(. RssItemView.animation(.easeIn))) // Added fade-in transition

                case .failure(let error):
                    // Log error and show placeholder
                    let _ = print("AsyncImage failed for \(urlString): \(error)")
                    defaultPlaceholder
                @unknown default:
                    EmptyView() // Handle future cases
                }
            }
        } else {
            defaultPlaceholder // Show placeholder if URL is nil or invalid
        }
    }

    // Standard placeholder view
    private var defaultPlaceholder: some View {
        ZStack {
            Rectangle().fill(Color.secondary.opacity(0.1))
            Image(systemName: "photo.on.rectangle.angled") // Use a different icon
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray.opacity(0.5))
                .padding(isCompact ? 20 : 40) // Add padding to the icon
        }
        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
        .clipped()
    }
}

// Simple tag view for topics.
struct TopicTag: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 6) // Slightly reduced padding
            .padding(.horizontal, 10)
            .background(Color.purple.opacity(0.6)) // Slightly darker
            .clipShape(Capsule()) // Use Capsule for rounded corners
    }
}

// Reusable button for the custom tab bar.
struct TabBarButton: View {
    let iconName: String
    let label: String
    var isActive: Bool = false

    // Add action closure
    let action: () -> Void

    var body: some View {
        Button(action: action) { // Use the provided action
            VStack(spacing: 4) { // Adjust spacing
                Image(systemName: iconName)
                    .font(isActive ? .title3 : .headline) // Slightly larger when active
                    .imageScale(.medium)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isActive ? .pink : .gray) // Apply color to the whole VStack
            .frame(maxWidth: .infinity) // Ensure it takes up available space
            .contentShape(Rectangle()) // Make the whole area tappable
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling
    }
}

// Displays a single RSS item, adapting layout based on `isCompact`.
struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool
    var showImage = true // Control image visibility

    @State private var isBookmarked: Bool = false // Example state

    var body: some View {
        // Use NavigationLink to navigate to the web view
        NavigationLink(destination: WebViewControllerWrapper(urlString: item.link)) {
            ZStack(alignment: .topTrailing) { // For bookmark button overlay
                VStack(alignment: .leading, spacing: isCompact ? 6 : 10) { // Adjust spacing
                    // Conditionally show image
                    if showImage && item.imageURL != nil { // Check if image URL exists
                        RSSAsyncImage(urlString: item.imageURL, isCompact: isCompact)
                             .cornerRadius(isCompact ? 8 : 0) // Only round corners in compact mode for aesthetics
                    } else if showImage {
                        // Optional: Show a placeholder even if URL is nil, if design requires
                        // RSSAsyncImage(urlString: nil, isCompact: isCompact)
                        //  .cornerRadius(isCompact ? 8 : 0)
                    }

                    // Content Padding applied selectively
                    VStack(alignment: .leading, spacing: isCompact ? 4: 8) {
                        // Title - always shown, adjust font
                        Text(item.title)
                            .font(isCompact ? .headline : .title3) // Slightly adjusted sizes
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(isCompact ? 2 : 3) // Limit title lines

                        // Date display
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.circle") // Use a calendar icon
                                .font(.caption)
                                .foregroundColor(.gray)
                            if let pubDate = item.pubDate {
                                Text(pubDate, style: .relative) + Text(" ago") // Relative date formatting
                            } else {
                                Text("Date unknown")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.gray)

                        // Description - Adjust line limit
                        if !item.itemDescription.isEmpty {
                             Text(item.itemDescription)
                                 .font(isCompact ? .caption : .subheadline) // Adjusted font
                                 .foregroundColor(.gray.opacity(0.9)) // Slightly less transparent
                                 .lineLimit(isCompact ? 2 : 4)
                                 .padding(.top, 2) // Small padding above description
                        }


                        // Topic Tags - Show only in non-compact view
                        if !isCompact {
                            // Example tags - could be dynamic based on item data later
                            let tags = ["Law", "IP", "Legal Tech", "Litigation", "Compliance"] // Example
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags.prefix(4), id: \.self) { tag in // Limit displayed tags
                                        TopicTag(title: tag)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.horizontal) // Horizontal padding for text content
                    .padding(.bottom) // Bottom padding for text content
                    .padding(.top, (showImage && item.imageURL != nil) ? 0 : 8) // Add top padding only if no image shown


                }
                // .padding() // Original Padding around the content - removed, applied selectively
                .background(
                    RoundedRectangle(cornerRadius: 12) // Unified corner radius
                        .fill(Color(.systemGray6).opacity(0.2)) // Use system secondary background color
                )
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip the entire Vstack


                // Bookmark Button
                Button {
                    isBookmarked.toggle() // Toggle bookmark state
                    // Add actual bookmark saving logic here
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3) // Slightly smaller
                        .foregroundColor(isBookmarked ? .pink : .white) // Use theme color when active
                        .padding(8)
                        .background(.thinMaterial, in: Circle()) // Use material background
                }
                 .padding([.top, .trailing], 10) // Padding outside the button

            }
            .padding(.horizontal) // Horizontal padding for the whole card
            .padding(.vertical, 6) // Vertical padding between cards
        }
        .buttonStyle(PlainButtonStyle()) // Prevent list row selection style interference
    }
}


// Main view for the "For You" tab, displaying the RSS feed.
struct ForYouView: View {
    @State private var isCompactView = false // Toggle between compact/full item views
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false // Controls the error alert
    @State private var selectedTab: Int = 0 // Example state for tab selection

    // State for sorting
    enum SortOrder { case newest, oldest }
    @State private var sortOrder: SortOrder = .newest

    var body: some View {
        // Use NavigationView for potential future navigation within tabs
        NavigationView {
            ZStack(alignment: .bottom) { // Align ProgressView centrally, TabBar at bottom
                // Main Content ScrollView
                ScrollView {
                    // LazyVStack for performance with many items
                    LazyVStack(alignment: .leading, spacing: 0) { // Remove default spacing
                        headerView
                            .padding(.bottom) // Padding after header

                        filterBar
                            .padding(.bottom) // Padding after filter

                        // updatesNotification // This could be conditionally shown

                        // Feed Content Section
                        rssFeedContent
                    }
                    .padding(.top) // Add padding at the top of the ScrollView content
                    .padding(.bottom, 80) // Add padding at the bottom to avoid tab bar overlap
                }
                .refreshable { // Pull-to-refresh action
                     print("Refreshing feed...")
                     await refreshFeed()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Background stretches edge-to-edge
                .navigationBarHidden(true) // Hide default navigation bar
                .alert("Error Loading Feed", isPresented: $isShowingAlert) { // Use newer alert syntax
                    Button("Retry") {
                        rssViewModel.loadRSS() // Retry loading on button tap
                    }
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(rssViewModel.errorMessage ?? "An unknown error occurred.")
                }

                // Loading Indicator centered (only shown when loading)
                 if rssViewModel.isLoading {
                     ZStack {
                         Color.black.opacity(0.4).edgesIgnoringSafeArea(.all) // Dim background
                         ProgressView("Loading Feed...")
                             .progressViewStyle(CircularProgressViewStyle(tint: .white))
                             .padding()
                             .background(Color.black.opacity(0.7).cornerRadius(10))
                     }
                 }


                // Custom Tab Bar - Overlay at the bottom
                 customTabBar
            }
            .edgesIgnoringSafeArea(.bottom) // Allow content/tabbar to go to screen bottom
        }
        .onAppear {
            // Load RSS feed when the view appears, if not already loaded
            if rssViewModel.rssItems.isEmpty && !rssViewModel.isLoading {
                print("ForYouView appeared, loading initial RSS feed.")
                rssViewModel.loadRSS()
            }
        }
        .onChange(of: rssViewModel.errorMessage) { _, newValue in
            // Show alert whenever an error message is set and we are not loading
            isShowingAlert = newValue != nil && !rssViewModel.isLoading
        }
         .onChange(of: sortOrder) { _, newOrder in // React to sort order changes
             sortItems(order: newOrder)
         }
        .preferredColorScheme(.dark) // Enforce dark mode for this view
    }

     // Async function for refreshable
     func refreshFeed() async {
         // Use the existing load function. @MainActor ensures UI updates happen correctly.
         rssViewModel.loadRSS()
         // Since loadRSS handles its own async/await and MainActor updates,
         // no explicit Task or await needed here unless loadRSS returned something awaitable.
     }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Image(systemName: "newspaper") // News icon
                .foregroundColor(.pink) // Use theme color
                .font(.title) // Adjust size if needed
            Text("Feed") // Simplified Title
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white) // Ensure text is visible
            Spacer() // Pushes profile icon to the right
            Button(action: { /* Add profile action */ }) {
                Image(systemName: "person.crop.circle") // Standard profile icon
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }

    private var filterBar: some View {
         HStack {
            // Sorting Menu
            Menu {
                Button { sortOrder = .newest } label: {
                    Label("Newest First", systemImage: sortOrder == .newest ? "checkmark" : "")
                }
                Button { sortOrder = .oldest } label: {
                    Label("Oldest First", systemImage: sortOrder == .oldest ? "checkmark" : "")
                }
                // Add more sorting options if needed
            } label: {
                 HStack(spacing: 4) {
                    Text(sortOrder == .newest ? "Newest" : "Oldest") // Dynamic label
                    Image(systemName: "chevron.down.circle") // Indicate dropdown
                 }
                 .font(.caption)
                 .foregroundColor(.white)
                 .padding(.vertical, 8)
                 .padding(.horizontal, 12)
                 .background(Color.gray.opacity(0.3))
                 .clipShape(Capsule())
            }

            Spacer() // Pushes view options to the right

            // View Toggle Button
            Button { isCompactView.toggle() } label: {
                Image(systemName: isCompactView ? "list.bullet.rectangle.portrait" : "square.grid.2x2")
                     .font(.title3)
                     .frame(width: 44, height: 44) // Ensure tappable area
                     .contentShape(Rectangle())
            }
            .foregroundColor(.gray)

            // More Options Button placeholder
            Button { /* Add more filter/view options */ } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .foregroundColor(.gray)
         }
         .padding(.horizontal)
    }

    // Placeholder for potential future notification banner
    // private var updatesNotification: some View { ... }


    // Renamed view for clarity
    private var rssFeedContent: some View {
         Group {
             // Use computed property or function for sorted items to avoid sorting in body
             // ForEach(sortedRssItems) { item in ... }

             // Only show items if not loading, no error, and items exist
             if !rssViewModel.isLoading && rssViewModel.errorMessage == nil && !rssViewModel.rssItems.isEmpty {
                 // Display the list of RSS items using the custom view
                 ForEach(rssViewModel.rssItems) { item in
                     RSSItemView(item: item, isCompact: isCompactView)
                         .id(item.id) // Ensure ForEach identifies items correctly
                 }
             }
             // Handle empty state (after loading, no error, but no items)
             else if !rssViewModel.isLoading && rssViewModel.errorMessage == nil && rssViewModel.rssItems.isEmpty {
                  emptyStateView
             }
             // Error state is handled by the alert and potentially implicitly if loading hides content
             // The ProgressView overlay handles the loading state visually
         }
    }

    // View for empty state
    private var emptyStateView: some View {
        VStack(spacing: 10) {
             Spacer(minLength: 100) // Push content down a bit
             Image(systemName: "tray.fill") // Empty tray icon
                 .font(.system(size: 50))
                 .foregroundColor(.gray)
             Text("No Articles Found")
                 .font(.headline)
                 .foregroundColor(.white)
             Text("The feed is currently empty.\nPull down to refresh.")
                 .font(.caption)
                 .foregroundColor(.gray)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal)
              Spacer()
         }
         .frame(maxWidth: .infinity)
         .padding()
    }

    // Tab Bar View
    private var customTabBar: some View {
        HStack {
            TabBarButton(iconName: "newspaper", label: "Feed", isActive: selectedTab == 0) { // Changed icon
                selectedTab = 0
                // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "play.square.stack", label: "Episodes", isActive: selectedTab == 1) { // Changed icon
                 selectedTab = 1
                 // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "bookmark", label: "Saved", isActive: selectedTab == 2) {
                 selectedTab = 2
                 // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "number.square", label: "Interests", isActive: selectedTab == 3) {
                 selectedTab = 3
                 // Add navigation or content switching logic here
            }
        }
        .padding(.vertical, 8) // Adjusted padding
        .padding(.horizontal)
        .background(.ultraThinMaterial) // Use material background
        .overlay(Divider(), alignment: .top) // Add a subtle top divider
    }

    // Helper function to sort items based on state
    private func sortItems(order: SortOrder) {
        switch order {
            case .newest:
                rssViewModel.rssItems.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
            case .oldest:
                rssViewModel.rssItems.sort { ($0.pubDate ?? .distantFuture) < ($1.pubDate ?? .distantFuture) }
        }
    }

}

// MARK: - Web View Controller (UIKit Implementation - Refactored)

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
        // Invalidate KVO observers explicitly
        observers.forEach { $0.invalidate() }
        observers.removeAll()
        // WKWebView's delegate properties are weak, no need to nil them out manually usually,
        // but setting them to nil can help ensure no lingering delegate calls attempt to happen.
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        print("AnotherCustomWebViewController deinitialized for URL: \(initialURLString ?? "nil")")
    }

    // --- UI Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupWebView()
        setupToolbar()
        setupProgressView()
        configureToolbarItems() // Configure items after toolbar creation
    }

    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never // Prefer small title in webview
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.title = "Loading..."
        // Optional Menu Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        // Style navigation bar appearance if needed
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false // Security enhancement

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.websiteDataStore = .nonPersistent() // Enhance privacy, clear cache/cookies on dismiss - adjust if login needed

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true // Enable swipe gestures
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }

    private func setupToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        // Use appearance for styling
        let appearance = UIToolbarAppearance()
        appearance.configureWithDefaultBackground()
        toolbar.standardAppearance = appearance
         if #available(iOS 15.0, *) {
            toolbar.scrollEdgeAppearance = appearance // For consistency
         }
        view.addSubview(toolbar)
    }

     private func setupProgressView() {
         progressView = UIProgressView(progressViewStyle: .bar)
         progressView.translatesAutoresizingMaskIntoConstraints = false
         progressView.progress = 0.0
         progressView.trackTintColor = .clear
         progressView.progressTintColor = .systemBlue // Use theme color
         progressView.isHidden = true
         view.addSubview(progressView) // Add AFTER webview/toolbar potentially

          // --- Auto Layout Constraints ---
          NSLayoutConstraint.activate([
              // WebView Constraints
              webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
              webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor), // Connect webView bottom to toolbar top

              // Toolbar Constraints
              toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

              // ProgressView Constraints
              progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // Pin below nav bar
              progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          ])
     }

     private func configureToolbarItems() {
          // Enable/Disable buttons initially based on webView state (which is initially nothing)
          backButton.isEnabled = false
          forwardButton.isEnabled = false

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
        let button = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: action
        )
        // Optionally disable initially
        // button.isEnabled = false
        return button
    }


    // --- KVO Setup ---
    private func setupObservers() {
         observers = [
             webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, change in
                 guard let self = self, let newProgress = change.newValue else { return }
                 self.progressView.setProgress(Float(newProgress), animated: true)
                 self.progressView.isHidden = newProgress >= 1.0 || newProgress <= 0.0
             },
             webView.observe(\.title, options: .new) { [weak self] webView, change in
                 guard let self = self, let newTitle = change.newValue else { return }
                  self.navigationItem.title = newTitle?.isEmpty ?? true ? "Loading..." : newTitle
             },
             webView.observe(\.canGoBack, options: .new) { [weak self] webView, change in
                 guard let self = self, let canGoBack = change.newValue else { return }
                 self.backButton.isEnabled = canGoBack
             },
             webView.observe(\.canGoForward, options: .new) { [weak self] webView, change in
                 guard let self = self, let canGoForward = change.newValue else { return }
                 self.forwardButton.isEnabled = canGoForward
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

    // Public function to load potentially different URL later
    func loadURL(urlString: String) {
         // Prevent reloading same URL if called unnecessarily
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
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30) // Set timeout
        webView.load(request)
    }

    private func showErrorPage(message: String, detailedError: String? = nil) {
         let html = """
         <html>
         <head>
             <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
             <style>
                 body { font-family: -apple-system, sans-serif; display: flex; justify-content: center; align-items: center; height: 80vh; text-align: center; padding: 20px; color: #555; }
                 .content { max-width: 80%; }
                 h1 { color: #E57373; font-size: 1.5em; margin-bottom: 10px; } /* Reddish error color */
                 p { font-size: 0.9em; margin-bottom: 5px; }
                 .details { font-size: 0.7em; color: #999; }
             </style>
         </head>
         <body>
             <div class="content">
                 <h1>Load Failed</h1>
                 <p>\(message)</p>
                 \(detailedError != nil ? "<p class='details'>(\(detailedError!))</p>" : "")
             </div>
         </body>
         </html>
         """
         webView.loadHTMLString(html, baseURL: nil)
     }


    // --- Actions ---
    @objc private func closeTapped() {
        // Check if presented modally or pushed onto navigation stack
        if presentingViewController != nil {
           dismiss(animated: true)
       } else if let navController = navigationController, navController.viewControllers.count > 1 {
           navController.popViewController(animated: true)
       } else {
           // Fallback for unexpected scenarios, maybe just dismiss
           dismiss(animated: true, completion: nil)
       }
    }

    @objc private func menuTapped() {
         guard let url = webView.url else { // Ensure there's a URL to act upon
             // Maybe show a limited menu or disable the button if no URL
             return
         }

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

        // For iPad support
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem // Anchor to the menu button
        }
        present(actionSheet, animated: true)
    }

    @objc private func goBack() {
        webView.goBack()
    }

    @objc private func goForward() {
        webView.goForward()
    }

    @objc private func reloadPage() {
         // Use reload() for standard reload, reloadFromOrigin() to bypass cache
        webView.reload()
    }

    @objc private func shareTapped() {
        guard let url = webView.url else { return }
        let itemsToShare: [Any] = [url, webView.title ?? ""] // Share URL and Title
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
             popover.barButtonItem = shareButton // Anchor to the share button
        }
        present(activityVC, animated: true)
    }

     @objc private func openInSafariTapped() {
         openInSafari()
     }

    private func openInSafari() {
        guard let url = webView.url, UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL: \(webView.url?.absoluteString ?? "nil")")
            // Optionally show an alert
            return
        }
        UIApplication.shared.open(url)
    }

    // --- JavaScript Injection Example ---
    func injectJavaScript(script: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript Injection Error: \(error)")
                completion?(.failure(error))
            } else {
                print("JavaScript executed. Result: \(result ?? "nil")")
                completion?(.success(result))
            }
        }
    }

    // --- WKNavigationDelegate Methods ---
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         // Example: Prevent navigating away from the initial domain if needed
         // if let requestUrl = navigationAction.request.url,
         //    let initialHost = URL(string: initialURLString ?? "")?.host,
         //    requestUrl.host != initialHost {
         //    decisionHandler(.cancel) // Cancel navigation
         //    if UIApplication.shared.canOpenURL(requestUrl) {
         //        UIApplication.shared.open(requestUrl) // Offer to open in Safari
         //    }
         //    return
         // }

        // Allow links intended to be opened in new tabs/windows to just load here
        // (target="_blank"). WKUIDelegate handles actual window creation requests.
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Page loading started for: \(webView.url?.absoluteString ?? "unknown URL")")
        // Progress bar updates via KVO
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Page content starts arriving
         print("Page commit for: \(webView.url?.absoluteString ?? "unknown URL")")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loading finished for: \(webView.url?.absoluteString ?? "unknown URL")")
        // Progress bar updates via KVO
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        // Ignore "Frame load interrupted" errors which often happen during normal navigation
        if nsError.domain == WKError.errorDomain && nsError.code == WKError.webViewInvalidated.rawValue {
            print("WebView invalidated error - ignoring.")
            return
        }
         if nsError.domain == "NSURLErrorDomain" && nsError.code == NSURLErrorCancelled {
            print("URL Loading cancelled - ignoring.")
            return // Often happens when user navigates away quickly
         }

        print("Permanent navigation failed: \(error.localizedDescription)")
        // Progress bar updates via KVO
        showErrorPage(message: "Could not load the page.", detailedError: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         let nsError = error as NSError
         // Ignore cancellation errors
         if nsError.domain == "NSURLErrorDomain" && nsError.code == NSURLErrorCancelled {
             print("Provisional navigation cancelled - ignoring.")
             return
         }
        print("Provisional navigation failed: \(error.localizedDescription)")
        // Progress bar updates via KVO
        navigationItem.title = "Failed to Load"
        showErrorPage(message: "Could not start loading the page.", detailedError: error.localizedDescription)
    }

     // Handle redirects
     func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
         print("Redirect received for: \(webView.url?.absoluteString ?? "unknown URL")")
     }

     // Handle Authentication Challenges (example: basic auth) - requires research for specific needs
     func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
         // Handle specific authentication methods if needed, e.g., HTTP Basic/Digest
         // For default handling (like system prompts for certificates):
         completionHandler(.performDefaultHandling, nil)
     }


     // --- WKUIDelegate Methods ---
     // Handle JavaScript alerts
     func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
         let alertController = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
             completionHandler()
         })
         // Ensure it's presented from the correct view controller
          guard self.presentedViewController == nil else {
              print("Alert suppressed: Another view controller is already presented.")
              completionHandler() // Must call completion handler even if not shown
              return
          }
         present(alertController, animated: true)
     }
     // Handle JavaScript confirm panels
     func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
          let alertController = UIAlertController(title: webView.url?.host, message: message, preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
          guard self.presentedViewController == nil else {
              print("Confirm suppressed: Another view controller is already presented.")
              completionHandler(false)
              return
          }
          present(alertController, animated: true)
     }
     // Handle JavaScript prompt panels
      func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
          let alertController = UIAlertController(title: webView.url?.host, message: prompt, preferredStyle: .alert)
          alertController.addTextField { textField in
              textField.text = defaultText
          }
          alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
              completionHandler(alertController.textFields?.first?.text)
          })
          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
           guard self.presentedViewController == nil else {
              print("Prompt suppressed: Another view controller is already presented.")
              completionHandler(nil)
              return
          }
          present(alertController, animated: true)
      }

     // Handle requests to open new windows (e.g., target="_blank")
     // Decide whether to load in the same webview, open externally, or block.
      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
          // If the request is a user click (not programmatic)
          if navigationAction.targetFrame == nil {
              // Open target="_blank" links in the same WKWebView
              webView.load(navigationAction.request)
          }
           // Prevent opening new WKWebView instances window
          return nil
      }
}


// MARK: - SwiftUI Wrapper for WebViewController

struct WebViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController // Wrap in a Nav Controller for title/buttons
    let urlString: String // Use let if URL doesn't change after creation

    func makeUIViewController(context: Context) -> UINavigationController {
        // Create the web view controller instance with the URL
        let webViewController = AnotherCustomWebViewController(urlString: urlString)

        // Embed it within a UINavigationController
        let navigationController = UINavigationController(rootViewController: webViewController)
        // Customize navigation bar appearance if needed here or in the VC itself
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // If the urlString could potentially change *after* this view is created
        // and you want the WebView to react, you'd add logic here.
        // Getting the existing webVC:
        // if let webVC = uiViewController.viewControllers.first as? AnotherCustomWebViewController {
        //     webVC.loadURL(urlString: urlString) // Call your public load method
        // }
    }
}

// MARK: - Preview

struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the main entry point of your UI
        ForYouView()
            // Optionally add mock data to the view model for previewing states:
            .environmentObject(previewViewModel(items: sampleItems, isLoading: false, error: nil)) // Example: Populated
            .previewDisplayName("Populated Feed")

         ForYouView()
            .environmentObject(previewViewModel(items: [], isLoading: true, error: nil))
            .previewDisplayName("Loading State")

         ForYouView()
            .environmentObject(previewViewModel(items: [], isLoading: false, error: "Network connection failed."))
            .previewDisplayName("Error State")

        ForYouView()
            .environmentObject(previewViewModel(items: [], isLoading: false, error: nil))
            .previewDisplayName("Empty State")


        // Preview the WebView Wrapper directly if needed
         WebViewControllerWrapper(urlString: "https://apple.com")
             .previewDisplayName("Web View")
    }

    // Helper function for creating preview view models
    @MainActor static func previewViewModel(items: [RSSItem], isLoading: Bool, error: String?) -> RSSViewModel {
        let vm = RSSViewModel()
        vm.rssItems = items
        vm.isLoading = isLoading
        vm.errorMessage = error
        return vm
    }

    // Sample data for previews
    static let sampleItems: [RSSItem] = [
        RSSItem(title: "Sample Article 1: The Future of Swift", link: "https://example.com/1", pubDate: Date().addingTimeInterval(-3600), itemDescription: "A look into the upcoming features and directions for the Swift programming language. Performance, concurrency, and more.", imageURL: "https://via.placeholder.com/600x400/FFA07A/ffffff?text=Swift+Future"),
        RSSItem(title: "Sample Article 2: Mastering SwiftUI Layout", link: "https://example.com/2", pubDate: Date().addingTimeInterval(-7200), itemDescription: "Deep dive into stacks, grids, and alignment guides in SwiftUI to create complex and responsive user interfaces.", imageURL: "https://via.placeholder.com/600x400/20B2AA/ffffff?text=SwiftUI+Layout"),
        RSSItem(title: "Sample Article 3: What's New in Combine", link: "https://example.com/3", pubDate: Date().addingTimeInterval(-10800), itemDescription: "Exploring the latest operators and techniques for reactive programming with Apple's Combine framework.", imageURL: nil) // Example with no image
    ]
}
