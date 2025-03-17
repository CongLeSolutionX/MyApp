//
//  LoadingRSSArticleWorkflow.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI
import WebKit // Import WebKit for WebView

// MARK: - Data Model

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date?
    var itemDescription: String
    var imageURL: String?
}

// MARK: - XML Parser Delegate

final class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    private var currentImageURL = ""

    private var items: [RSSItem] = []
    private var inItem = false
    private var inImage = false

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let alternativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let alternativeDateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func parse(data: Data) -> [RSSItem] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName

        if elementName == "item" {
            inItem = true
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
            currentImageURL = ""
        }

        if inItem {
            if elementName == "media:content", let urlString = attributeDict["url"] {
                currentImageURL = urlString
                inImage = true
            } else if elementName == "enclosure", let urlString = attributeDict["url"], attributeDict["type"]?.hasPrefix("image") ?? false {
                currentImageURL = urlString
                inImage = true
            } else if elementName == "image", let urlString = attributeDict["href"] {
                currentImageURL = urlString
                inImage = true
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }

        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "pubDate":
            currentPubDate += string
        case "description":
            currentDescription += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false

            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            var parsedDate: Date? = RSSParser.dateFormatter.date(from: trimmedPubDate)

            if parsedDate == nil {
                parsedDate = RSSParser.alternativeDateFormatter.date(from: trimmedPubDate)
            }

            if parsedDate == nil {
                parsedDate = RSSParser.alternativeDateFormatter2.date(from: trimmedPubDate)
            }

            let newItem = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: parsedDate,
                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                imageURL: currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            items.append(newItem)
        }

        if elementName == "media:content" || elementName == "enclosure" || elementName == "image" {
            inImage = false
        }

        currentElement = ""
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parse error occurred: \(parseError)")
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print("Validation error occurred: \(validationError)")
    }
}

// MARK: - View Model

class RSSViewModel: ObservableObject {
    @Published var rssItems: [RSSItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func loadRSS() {
        guard let url = URL(string: "https://www.law360.com/ip/rss") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error fetching RSS feed: \(error.localizedDescription)"
                    print("Error fetching RSS feed: \(error)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self?.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                }
                return
            }

            let parser = RSSParser()
            let parsedItems = parser.parse(data: data)

            DispatchQueue.main.async {
                self?.rssItems = parsedItems
            }
        }.resume()
    }
}

// MARK: - WebView Representable

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set the navigation delegate
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    // Coordinator for handling navigation events
    func makeCoordinator() -> Coordinator {
          Coordinator(self)
      }

      class Coordinator: NSObject, WKNavigationDelegate {
          var parent: WebView

          init(_ parent: WebView) {
              self.parent = parent
          }
          
          //Handle navigation failures
          func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
              print("Navigation failed: \(error.localizedDescription)")
          }
          
          //Handle loading process failures
          func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                print("Loading failed: \(error.localizedDescription)")
            }
      }
}

// MARK: - Detail View (Displays WebView)

struct ArticleDetailView: View {
    let url: URL

    var body: some View {
        WebView(url: url)
            .navigationBarTitleDisplayMode(.inline) // Keep the navigation bar clean
    }
}

// MARK: - SwiftUI View

struct RSSContentView: View {
    @StateObject private var viewModel = RSSViewModel()
    @State private var isShowingAlert = false
    @State private var selectedItemURL: URL? // Store the URL to open
    @State private var isShowingWebView = false // Control the presentation of WebView

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationView {
            ZStack {
                List { // Use List with explicit ForEach
                    ForEach(viewModel.rssItems) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(maxWidth: .infinity, maxHeight: 200)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: 200)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(maxWidth: .infinity, maxHeight: 200)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            Text(item.title)
                                .font(.headline)
                            if let pubDate = item.pubDate {
                                Text(RSSContentView.displayDateFormatter.string(from: pubDate))
                                    .font(.subheadline)
                            } else {
                                Text("No date available")
                                    .font(.subheadline)
                            }

                            Text(item.itemDescription)
                                .font(.body)
                                .lineLimit(4)
                        }
                        .contentShape(Rectangle()) // Make the entire cell tappable
                        .onTapGesture {
                            if let url = URL(string: item.link) {
                                self.selectedItemURL = url
                                self.isShowingWebView = true // Show the sheet
                            }
                        }
                    }
                }
                .navigationTitle("Law360 RSS")
                .refreshable {
                    viewModel.loadRSS()
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                        dismissButton: .default(Text("OK"))
                    )
                }

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                }
            }
            .sheet(isPresented: $isShowingWebView) { // Use sheet for modal presentation
                if let url = selectedItemURL {
                    ArticleDetailView(url: url)
                }
            }
        }
        .onAppear {
            viewModel.loadRSS()
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if newValue != nil {
                isShowingAlert = true
            }
        }
    }
}

// MARK: - Combined ForYouView

struct ForYouView: View {
    @State private var searchText: String = ""
    @State private var isCompactView: Bool = false
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false
    @State private var selectedItemURL: URL? // Store the URL to open
    @State private var isShowingWebView = false  // Control the presentation of WebView

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar (Search, Title, Profile)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("For You")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "person.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Filter Bar (Newest First, Compact View, More Options)
                    HStack {
                        Button(action: {
                            rssViewModel.rssItems.sort { (item1, item2) -> Bool in
                                guard let date1 = item1.pubDate, let date2 = item2.pubDate else {
                                    return false
                                }
                                return date1 > date2
                            }
                        }) {
                            HStack {
                                Text("Newest first")
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)

                        Spacer()

                        Button(action: {
                            isCompactView.toggle()
                        }) {
                            Image(systemName: isCompactView ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                        }
                        .foregroundColor(.gray)

                        Button(action: {
                            // Show more options
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Updates Notification
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.red)
                        Text("updates since you last visit")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Dynamic RSS Content Cards
                    if rssViewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let errorMessage = rssViewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(rssViewModel.rssItems) { item in
                            RSSItemView(item: item, isCompact: isCompactView)
                                .contentShape(Rectangle()) // Make entire card tappable
                                .onTapGesture {
                                    if let url = URL(string: item.link) {
                                        self.selectedItemURL = url
                                        self.isShowingWebView = true
                                    }
                                }
                        }
                    }
                }
                .padding(.top)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Error"), message: Text(rssViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            // Tab Bar
            HStack {
                TabBarButton(iconName: "waveform.path.ecg", label: "For you", isActive: true)
                TabBarButton(iconName: "book", label: "Episodes")
                TabBarButton(iconName: "bookmark", label: "Saved")
                TabBarButton(iconName: "number", label: "Interests")
            }
            .padding()
            .background(Color.black)
            .frame(maxWidth: .infinity)
            .border(Color.gray.opacity(0.3), width: 1)
            
            .sheet(isPresented: $isShowingWebView) { // Use sheet for modal presentation
                if let url = selectedItemURL {
                    ArticleDetailView(url: url)
                }
            }
        }
        .onAppear {
            rssViewModel.loadRSS()
        }
        .onChange(of: rssViewModel.errorMessage) { newValue in
            if newValue != nil {
                isShowingAlert = true
            }
        }
    }
}

// MARK: - RSS Item View (Reusable Card)

struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {

                if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                }

                if !isCompact {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                }

                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                    if let pubDate = item.pubDate {
                        Text(RSSContentView.displayDateFormatter.string(from: pubDate))
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("No date available")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 1)

                Text(item.itemDescription)
                    .font(isCompact ? .caption : .body)
                    .foregroundColor(.gray)
                    .lineLimit(isCompact ? 2 : 4)
                    .padding(.top, isCompact ? 1 : 2)

                if !isCompact {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            TopicTag(title: "Law")
                            TopicTag(title: "IP")
                            TopicTag(title: "Legal")
                            Button(action: {
                                // Show more options
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))

            // Bookmark Icon
            Button(action: {
                // Handle bookmark action
            }) {
                Image(systemName: "bookmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(10)
        }
        .padding(.horizontal)
    }
}

// MARK: - Helper Views

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
            .cornerRadius(20)
    }
}

struct TabBarButton: View {
    let iconName: String
    let label: String
    var isActive: Bool = false

    var body: some View {
        Button(action: {
            // Handle tab selection
        }) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? .pink : .gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(isActive ? .pink : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
            .preferredColorScheme(.dark)
    }
}
