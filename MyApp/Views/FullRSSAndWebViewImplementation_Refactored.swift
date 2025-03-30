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

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date?
    var itemDescription: String
    var imageURL: String?
}

// MARK: - RSS Parser

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
        "yyyy-MM-dd'T'HH:mm:ssZ"
        // Add other potential date formats if needed
    ]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Essential for fixed-format dates
        return formatter
    }()

    func parse(data: Data) -> (items: [RSSItem], error: Error?) {
        items = []
        parseError = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
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
        if inItem, ["media:content", "enclosure", "image"].contains(elementName) {
            // Determine the attribute key likely holding the URL
            let urlAttributeKey = (elementName == "image") ? "href" : "url" // Common conventions

            if let urlString = attributeDict[urlAttributeKey] {
                // Check enclosure type for non-images
                if elementName == "enclosure", let type = attributeDict["type"], !type.hasPrefix("image") {
                   // Skip this enclosure if it's not an image type
                } else {
                    // Only assign if we haven't found one yet or this is a prioritized tag
                    // Simple logic: assign if we find a URL attribute in these tags.
                    // Could be enhanced to prioritize certain tags if needed.
                    if currentImageURL.isEmpty { // Avoid overwriting if found in a previous tag within the same item
                       currentImageURL = urlString
                    }
                    inImage = true // Flag that we are inside an image tag context
                }
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        // Append characters to the current element's string buffer
        switch currentElement {
        case "title":       currentTitle += string
        case "link":        currentLink += string
        case "pubDate":     currentPubDate += string
        case "description": currentDescription += string
        // Add cases for other elements you might need to capture text from
        default:            break
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false // Exiting the item scope

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

            // Create and append the new RSSItem
            let newItem = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: parsedDate,
                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                // Use the potentially found image URL, ensure it's trimmed
                imageURL: currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            items.append(newItem)

        } else if inItem, ["media:content", "enclosure", "image"].contains(elementName) {
            inImage = false // Exiting an image-related tag
        }

        // Reset current element name after processing the closing tag
        // This helps avoid appending characters to the wrong property if tags are nested unexpectedly
        // Note: This simplistic reset might need adjustment for complex nested structures if required.
         currentElement = ""
    }

    // Error Handling
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
        // Log the error, maybe update UI state
        print("Parse error occurred: \(parseError.localizedDescription)")
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        // Treat validation errors similarly to parse errors for now
        self.parseError = validationError
        print("Validation error occurred: \(validationError.localizedDescription)")
    }
}


// MARK: - View Model

@MainActor // Ensure published properties are updated on the main thread
class RSSViewModel: ObservableObject {
    @Published var rssItems: [RSSItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let parser = RSSParser()

    func loadRSS(urlString: String = "https://www.law360.com/ip/rss") { // Default URL
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false // Ensure loading stops on invalid URL
            return
        }

        isLoading = true
        errorMessage = nil // Clear previous errors

        // Use URLSession for network request
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Ensure weak self is captured and unwrapped safely
            guard let self = self else { return }

            // Defer setting isLoading to false ensures it happens even on early returns
            defer {
                Task { @MainActor in self.isLoading = false }
            }

            // Handle network errors
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Error fetching RSS feed: \(error.localizedDescription)"
                }
                return
            }

            // Handle HTTP status code errors
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                Task { @MainActor in
                    self.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                }
                return
            }

            // Ensure data is present
            guard let data = data else {
                Task { @MainActor in self.errorMessage = "No data received" }
                return
            }

            // Perform parsing (can be intensive, consider background thread if needed, but parser is synchronous)
            // For simplicity here, it runs on the URLSession callback queue.
             let (parsedItems, parseError) = self.parser.parse(data: data)

            // Update UI on the main thread
            Task { @MainActor in
                if let parseError = parseError {
                    self.errorMessage = "Error parsing RSS: \(parseError.localizedDescription)"
                } else {
                    self.rssItems = parsedItems
                     print("Parsed \(parsedItems.count) items.") // Log success
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
                    ProgressView() // Show loading indicator
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        .background(Color.secondary.opacity(0.1)) // Subtle background
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill() // Fill the frame, clipping excess
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        .clipped() // Prevent image overflow
                case .failure:
                    defaultPlaceholder // Show placeholder on failure
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
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray.opacity(0.5))
            .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
            .background(Color.secondary.opacity(0.1))
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
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.purple.opacity(0.5))
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
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isActive ? .pink : .gray) // Apply color to the whole VStack
            .frame(maxWidth: .infinity) // Ensure it takes up available space
        }
        .buttonStyle(PlainButtonStyle()) // Remove default button styling if needed
    }
}

// Displays a single RSS item, adapting layout based on `isCompact`.
struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool
    var showImage = true // Control image visibility

    var body: some View {
        // Use NavigationLink to navigate to the web view
        NavigationLink(destination: WebViewControllerWrapper(urlString: item.link)) {
            ZStack(alignment: .topTrailing) { // For bookmark button overlay
                VStack(alignment: .leading, spacing: isCompact ? 4 : 8) { // Adjust spacing
                    // Conditionally show image
                    if showImage {
                        RSSAsyncImage(urlString: item.imageURL, isCompact: isCompact)
                    }

                    // Title - always shown, adjust font
                    Text(item.title)
                        .font(isCompact ? .headline : .title2) // Adjust font based on context
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2) // Limit title lines
                        .padding(.top, showImage ? (isCompact ? 4 : 8) : 0) // Add padding only if image shown

                    // Date display
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6)) // Smaller dot
                            .foregroundColor(.gray)
                        if let pubDate = item.pubDate {
                            Text(displayDateFormatter.string(from: pubDate))
                        } else {
                            Text("Date unknown")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)

                    // Description - Adjust line limit
                    Text(item.itemDescription)
                        .font(isCompact ? .caption : .body)
                        .foregroundColor(.gray.opacity(0.8))
                        .lineLimit(isCompact ? 2 : 4)

                    // Topic Tags - Show only in non-compact view
                    if !isCompact {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Example tags - could be dynamic based on item data
                                TopicTag(title: "Law")
                                TopicTag(title: "IP")
                                TopicTag(title: "Legal Tech")
                                // More button could trigger actions if needed
                                Button(action: {}) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            // .padding(.top, 8) // Add padding if needed after description
                        }
                    }
                }
                .padding() // Padding around the content
                .background(
                    RoundedRectangle(cornerRadius: 15) // Slightly less rounded corners
                        .fill(Color.black.opacity(0.9)) // Slightly transparent background
                )

                // Bookmark Button
                Button(action: { /* Add bookmark logic here */ }) {
                    Image(systemName: "bookmark") // Use "bookmark.fill" if bookmarked
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8) // Add padding inside the button hit area
                        .background(Color.black.opacity(0.3).clipShape(Circle())) // Subtle background
                }
                .padding([.top, .trailing], 12) // Padding outside the button
            }
            .padding(.horizontal) // Horizontal padding for the whole card
        }
        .buttonStyle(PlainButtonStyle()) // Prevent list row selection style interference
    }
}


// Main view for the "For You" tab, displaying the RSS feed.
struct ForYouView: View {
    // Removed unused searchText State variable

    @State private var isCompactView = false // Toggle between compact/full item views
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false // Controls the error alert
    @State private var selectedTab: Int = 0 // Example state for tab selection

    var body: some View {
        // Use NavigationView for the title bar and potential navigation
        NavigationView {
            ZStack(alignment: .bottom) { // Align ProgressView centrally, TabBar at bottom
                // Main Content ScrollView
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) { // Add spacing between sections
                        headerView
                        filterBar
                        updatesNotification // This could be conditionally shown
                        rssFeedContent // Renamed for clarity
                    }
                    .padding(.top) // Add padding at the top of the ScrollView content
                    .padding(.bottom, 80) // Add padding at the bottom to avoid tab bar overlap
                }
                .background(Color.black.edgesIgnoringSafeArea(.all)) // Background stretches edge-to-edge
                .navigationBarHidden(true) // Hide default navigation bar
                .alert("Error", isPresented: $isShowingAlert) { // Use newer alert syntax
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(rssViewModel.errorMessage ?? "An unknown error occurred.")
                }

                // Loading Indicator
                if rssViewModel.isLoading {
                    ProgressView("Loading Feed...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black.opacity(0.5).cornerRadius(10))
                }

                // Custom Tab Bar - Overlay at the bottom
                 customTabBar
            }
            .edgesIgnoringSafeArea(.bottom) // Allow content/tabbar to go to screen bottom
        }
        .onAppear {
            // Load RSS feed when the view appears, if not already loaded
            if rssViewModel.rssItems.isEmpty {
                rssViewModel.loadRSS()
            }
        }
        .onChange(of: rssViewModel.errorMessage) { _, newValue in
            // Show alert whenever an error message is set
            isShowingAlert = newValue != nil
        }
        .preferredColorScheme(.dark) // Enforce dark mode for this view
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Image(systemName: "waveform.path.ecg") // Changed icon for visual interest
                .foregroundColor(.pink) // Use theme color
                .font(.title) // Adjust size if needed
            Text("For You")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white) // Ensure text is visible
            Spacer() // Pushes profile icon to the right
            Button(action: { /* Add profile action */ }) {
                Image(systemName: "person.circle.fill") // Use filled icon
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }

    private var filterBar: some View {
         HStack {
            // Sorting Button
            Menu { // Use a Menu for sorting options
                Button("Newest First") {
                    rssViewModel.rssItems.sort { ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast) }
                }
                Button("Oldest First") {
                    rssViewModel.rssItems.sort { ($0.pubDate ?? .distantFuture) < ($1.pubDate ?? .distantFuture) }
                }
                // Add more sorting options if needed (e.g., by title)
            } label: {
                 HStack(spacing: 4) {
                    Text("Sort") // Simplified label
                    Image(systemName: "arrow.up.arrow.down.circle") // Use a different icon
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
            Button(action: { isCompactView.toggle() }) {
                Image(systemName: isCompactView ? "list.bullet.rectangle.portrait" : "square.grid.2x2") // More descriptive icons
                     .font(.title3) // Adjust size
            }
            .foregroundColor(.gray)

            // More Options Button (Could be a Menu)
            Button(action: { /* Add more filter/view options */ }) {
                Image(systemName: "slider.horizontal.3") // Filter icon
                    .font(.title3)
            }
            .foregroundColor(.gray)
         }
         .padding(.horizontal)
    }

    // Example notification banner
    private var updatesNotification: some View {
        // Conditionally display if there are updates (logic needed)
        // if hasUpdates {
            HStack {
                Image(systemName: "3.circle.fill") // Example badge number
                    .foregroundColor(.pink) // Use theme color
                Text("updates since you last visit")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { /* Dismiss action */ }) {
                    Image(systemName: "xmark.circle.fill") // Use filled dismiss icon
                         .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8) // Add some vertical padding
            .background(Color.gray.opacity(0.15)) // Subtle background
            .cornerRadius(8)
            .padding(.horizontal) // Padding around the banner background
        // }
    }


    // Renamed view for clarity
    private var rssFeedContent: some View {
         Group {
             // Check for error *first* before checking isLoading or items
             if let errorMessage = rssViewModel.errorMessage, !rssViewModel.isLoading {
                VStack { // Center the error message
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Failed to load feed")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        rssViewModel.loadRSS()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .padding(.top)
                    Spacer()
                }
                .frame(maxWidth: .infinity) // Ensure VStack takes width
                .padding()

            } else if !rssViewModel.isLoading && rssViewModel.rssItems.isEmpty {
                 VStack { // Center empty state message
                     Spacer()
                     Image(systemName: "newspaper")
                         .font(.largeTitle)
                         .foregroundColor(.gray)
                     Text("No articles found")
                         .font(.headline)
                         .foregroundColor(.white)
                         .padding(.top, 5)
                     Text("The feed might be empty or check your connection.")
                         .font(.caption)
                         .foregroundColor(.gray)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
                     Spacer()
                 }
                 .frame(maxWidth: .infinity)
                 .padding()

             } else if !rssViewModel.isLoading { // Only show items if not loading and no error
                 // Display the list of RSS items using the custom view
                 ForEach(rssViewModel.rssItems) { item in
                     RSSItemView(item: item, isCompact: isCompactView)
                 }
             }
             // Implicitly handles the case where isLoading is true (ProgressView shown outside this Group)
         }
    }

     private var customTabBar: some View {
        HStack {
            TabBarButton(iconName: "waveform.path.ecg", label: "For You", isActive: selectedTab == 0) {
                selectedTab = 0
                // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "book.closed", label: "Episodes", isActive: selectedTab == 1) { // Changed icon
                 selectedTab = 1
                 // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "bookmark", label: "Saved", isActive: selectedTab == 2) {
                 selectedTab = 2
                 // Add navigation or content switching logic here
            }
            TabBarButton(iconName: "number.square", label: "Interests", isActive: selectedTab == 3) { // Changed icon
                 selectedTab = 3
                 // Add navigation or content switching logic here
            }
        }
        .padding(.vertical, 8) // Adjusted padding
        .padding(.horizontal)
        .background(
             Material.bar // Use a blurred background material
             // Color.black // Or a solid color
        )
        // Add a subtle top border if desired
        // .overlay(Divider().background(Color.gray.opacity(0.3)), alignment: .top)
    }
}

// MARK: - Web View Controller (UIKit Implementation - Refactored)

class AnotherCustomWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    // --- Properties ---
    // No longer lazy, initialized in setup methods
    var webView: WKWebView!
    var progressView: UIProgressView!
    var toolbar: UIToolbar!

    // Toolbar Buttons (kept lazy for clarity and setup order simplicity)
    lazy var backButton: UIBarButtonItem = { /* ... same as before ... */
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        btn.isEnabled = false
        return btn
    }()
    lazy var forwardButton: UIBarButtonItem = { /* ... same as before ... */
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right"),
            style: .plain,
            target: self,
            action: #selector(goForward)
        )
        btn.isEnabled = false
        return btn
    }()
    lazy var reloadButton: UIBarButtonItem = { /* ... same as before ... */
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(reloadPage)
        )
        return btn
    }()
    lazy var shareButton: UIBarButtonItem = { /* ... same as before ... */
        let btn = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        return btn
    }()
    lazy var openInSafariButton: UIBarButtonItem = { /* ... same as before ... */
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInSafariTapped)
        )
        return btn
    }()

    private var initialURLString: String? // To store the URL passed during init

    // --- Initialization ---
    // Convenience initializer to accept the URL string directly
    convenience init(urlString: String) {
        self.init(nibName: nil, bundle: nil)
        self.initialURLString = urlString
    }

    // --- Lifecycle Methods ---
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        // Load initial content passed via initializer
        loadInitialContent()
    }

    // Adjust web view frame when layout changes (e.g., rotation)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard webView != nil, toolbar != nil else { return } // Ensure views are initialized
        webView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.bounds.width,
            height: view.bounds.height - view.safeAreaInsets.top - toolbar.frame.height // Use actual toolbar height
        )
    }

    deinit {
        // Clean up observers to prevent crashes
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.title), context: nil)
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), context: nil)
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), context: nil)
        print("AnotherCustomWebViewController deinitialized") // For debugging
    }

    // --- UI Setup ---
    private func setupUI() {
        view.backgroundColor = .systemBackground // Use system background color
        setupNavigationBar()
        setupWebView() // Must be called before progressView and toolbar that might depend on it
        setupToolbar()
        setupProgressView() // Progress view sits above webview/toolbar
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.title = "Loading..." // Initial title
        // Optional: Add a menu button if more actions are needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"), // Use circle variant
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        // Style the navigation bar if needed
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationController?.navigationBar.isTranslucent = false
    }

    private func setupWebView() {
        // Centralized configuration
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        // Removed unused UserContentController setup for WKScriptMessageHandler

        webView = WKWebView(frame: .zero, configuration: configuration) // Initialize here
        webView.navigationDelegate = self
        webView.uiDelegate = self // Keep if using UI delegate methods (like alerts from JS)
        webView.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        view.addSubview(webView)

        // Add constraints relative to safe area and toolbar
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Bottom constraint will be set relative to toolbar later or handled by viewDidLayoutSubviews
        ])
    }

    private func setupToolbar() {
        toolbar = UIToolbar() // Initialize here
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isTranslucent = false // Optional: style
        toolbar.barStyle = .default   // Optional: style
        view.addSubview(toolbar)

        // Constraints for toolbar at the bottom
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Add a constraint connecting webView bottom to toolbar top
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])

        // Configure toolbar items
        toolbar.items = [
            backButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            forwardButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            reloadButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            shareButton,
             UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
             openInSafariButton // Keep Safari button if desired
        ]
    }

     private func setupProgressView() {
         progressView = UIProgressView(progressViewStyle: .bar) // Use .bar style
         progressView.translatesAutoresizingMaskIntoConstraints = false
         progressView.progress = 0.0
         progressView.trackTintColor = .clear
         progressView.progressTintColor = .systemBlue // Or theme color
         progressView.isHidden = true // Start hidden
         view.addSubview(progressView)

         // Constraints for progress view pinned below navigation bar / top safe area
         NSLayoutConstraint.activate([
             // Pin to the top of the webView
             progressView.topAnchor.constraint(equalTo: webView.topAnchor),
             progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              progressView.heightAnchor.constraint(equalToConstant: 2) // Give it a small height
         ])
     }

    // --- KVO Setup ---
    private func setupObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }

    // --- KVO Handling ---
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }

        switch keyPath {
        case #keyPath(WKWebView.estimatedProgress):
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            // Hide when done or starting, show during loading
            progressView.isHidden = webView.estimatedProgress >= 1.0 || webView.estimatedProgress <= 0.0
        case #keyPath(WKWebView.title):
            navigationItem.title = webView.title?.isEmpty ?? true ? "Loading..." : webView.title
        case #keyPath(WKWebView.canGoBack):
            backButton.isEnabled = webView.canGoBack
        case #keyPath(WKWebView.canGoForward):
            forwardButton.isEnabled = webView.canGoForward
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context) // Pass to super if not handled
        }
    }

    // --- Content Loading ---
    private func loadInitialContent() {
        if let urlString = initialURLString {
            loadRemoteURL(urlString: urlString)
        } else {
            // Load a default page or show an error if no URL was provided
            print("No initial URL provided to WebViewController")
            // webView.loadHTMLString("<html><body><h1>Error</h1><p>No URL specified.</p></body></html>", baseURL: nil)
             navigationItem.title = "Error"
        }
    }

    // Public function to load a URL (if needed after initialization)
    func loadURL(urlString: String) {
        loadRemoteURL(urlString: urlString)
    }

    private func loadRemoteURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            // Optionally show an error message to the user
            webView.loadHTMLString("<html><body><h1>Invalid URL</h1><p>Could not load \(urlString).</p></body></html>", baseURL: nil)
             navigationItem.title = "Invalid URL"
            return
        }
        print("Loading URL: \(url)")
        webView.load(URLRequest(url: url))
    }

    // --- Actions ---
    @objc private func closeTapped() {
        // Decide whether to dismiss or pop based on presentation context
        if let navController = navigationController, navController.viewControllers.first !== self {
            navController.popViewController(animated: true)
        } else {
             dismiss(animated: true)
        }
    }

    @objc private func menuTapped() {
        let actionSheet = UIAlertController(title: nil, message: webView.url?.absoluteString, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: .default) { [weak self] _ in
            self?.openInSafari()
        })
        actionSheet.addAction(UIAlertAction(title: "Copy URL", style: .default) { [weak self] _ in
            if let urlString = self?.webView.url?.absoluteString {
                UIPasteboard.general.string = urlString
            }
        })
         actionSheet.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.shareTapped() // Reuse share logic
        })
        actionSheet.addAction(UIAlertAction(title: "Reload", style: .default) { [weak self] _ in
            self?.reloadPage()
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad support
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(actionSheet, animated: true)
    }

    @objc private func goBack() {
        if webView.canGoBack { webView.goBack() }
    }

    @objc private func goForward() {
        if webView.canGoForward { webView.goForward() }
    }

    @objc private func reloadPage() {
        webView.reload()
    }

    @objc private func shareTapped() {
        guard let url = webView.url else { return }
        let activityVC = UIActivityViewController(activityItems: [url, webView.title ?? ""], applicationActivities: nil)

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
             // Anchor to the share button itself for better positioning
             popover.barButtonItem = shareButton // Assumes shareButton is correctly assigned in setupToolbar
        }
        present(activityVC, animated: true)
    }

     @objc private func openInSafariTapped() {
         openInSafari()
     }

    private func openInSafari() {
        guard let url = webView.url else { return }
        // Check if the URL can be opened before attempting
        guard UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL: \(url)")
            // Optionally show an alert to the user
            return
        }
        UIApplication.shared.open(url)
    }

    // --- JavaScript Injection (Example) ---
    func injectJavaScript(script: String) {
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript Injection Error: \(error)")
            } else if let result = result {
                print("JavaScript executed. Result: \(result)")
            } else {
                 print("JavaScript executed with no result.")
            }
        }
    }

    // --- WKNavigationDelegate Methods ---
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Example: Allow all navigation requests by default
        // Add specific logic here if needed (e.g., checking URL schemes)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Page loading started for: \(webView.url?.absoluteString ?? "unknown URL")")
         // Progress view visibility is handled by KVO
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loading finished for: \(webView.url?.absoluteString ?? "unknown URL")")
         // Progress view visibility is handled by KVO
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Permanent navigation failed: \(error.localizedDescription)")
         // Progress view visibility is handled by KVO
         // Consider showing an error page
         // webView.loadHTMLString("<html><body><h1>Load Failed</h1><p>\(error.localizedDescription)</p></body></html>", baseURL: webView.url)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional navigation failed: \(error.localizedDescription)")
         // Progress view visibility is handled by KVO
         // Show error message or potentially retry logic
         navigationItem.title = "Failed to Load"
    }

     // --- WKUIDelegate Methods (Optional) ---
     // Implement methods here if you need to handle JavaScript alerts, confirms, prompts,
     // or creating new web views (popups). Example:
     func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
         let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
             completionHandler()
         })
         present(alertController, animated: true)
     }

     // Add other WKUIDelegate methods as needed...
}

// MARK: - SwiftUI Wrapper for WebViewController

struct WebViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController // Wrap in a Nav Controller
    var urlString: String

    func makeUIViewController(context: Context) -> UINavigationController {
        // Create the web view controller instance with the URL
        let webViewController = AnotherCustomWebViewController(urlString: urlString)

        // Embed it within a UINavigationController for the top bar (close button, title)
        let navigationController = UINavigationController(rootViewController: webViewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update the view controller if needed, e.g., if the urlString changes
        // For this simple case, we load the URL during creation (`makeUIViewController`).
        // If the `urlString` could change dynamically *after* the view appears,
        // you might need logic here to tell the existing webViewController to load the new URL.
        // Example (if urlString could change):
         if let webVC = uiViewController.viewControllers.first as? AnotherCustomWebViewController {
             // This check prevents reloading the same URL unnecessarily on every view update
             if webVC.webView?.url?.absoluteString != urlString {
                 webVC.loadURL(urlString: urlString)
             }
         }
    }
}

// MARK: - Preview

struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
            // No need to force dark mode here unless specifically required by design
            // .preferredColorScheme(.dark)
    }
}
