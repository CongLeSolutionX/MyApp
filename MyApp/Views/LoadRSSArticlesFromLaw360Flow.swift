//
//  LoadRSSArticlesFromLaw360Flow.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//


//
//  CombinedRSSView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI
import SafariServices

// MARK: - Data Models

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date?
    var itemDescription: String
    var imageURL: String?
}

// MARK: - XML Parser

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
    
    // Date formatters (static for performance)
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 822
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let alternativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let alternativeDateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 variant
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
        case "title":            currentTitle += string
        case "link":            currentLink += string
        case "pubDate":            currentPubDate += string
        case "description":            currentDescription += string
        default:            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false
            
            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            var parsedDate: Date? = RSSParser.dateFormatter.date(from: trimmedPubDate)
            
            if parsedDate == nil {                parsedDate = RSSParser.alternativeDateFormatter.date(from: trimmedPubDate)
            }
            if parsedDate == nil {                parsedDate = RSSParser.alternativeDateFormatter2.date(from: trimmedPubDate)
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
        
        if elementName == "media:content" || elementName == "enclosure" || elementName == "image" {            inImage = false
        }
        
        currentElement = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {        print("Parse error: \(parseError)")
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {        print("Validation error: \(validationError)")
    }
}

// MARK: - View Model

class RSSViewModel: ObservableObject {
    @Published var rssItems: [RSSItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let staticRSSItems: [RSSItem] = [ // Static data for demonstration
        RSSItem(title: "Static Article 1", link: "https://www.example.com/1", pubDate: Date(), itemDescription: "Description 1", imageURL: "https://via.placeholder.com/300x200.png?text=Static+1"),
        RSSItem(title: "Static Article 2", link: "https://www.example.com/2", pubDate: Date().addingTimeInterval(-86400), itemDescription: "Description 2", imageURL: "https://via.placeholder.com/300x200.png?text=Static+2")
    ]
    
    func loadRSS() {
        isLoading = true
        errorMessage = nil
        
        // Simulate a network request for dynamic data
        guard let url = URL(string: "https://www.law360.com/ip/rss") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
                self.rssItems = self.staticRSSItems // Fallback to static data
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    self?.rssItems = self?.staticRSSItems ?? [] // Fallback
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self?.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    self?.rssItems = self?.staticRSSItems ?? [] // Fallback
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                    self?.rssItems = self?.staticRSSItems ?? [] // Fallback
                }
                return
            }
            
            let parser = RSSParser()
            let parsedItems = parser.parse(data: data)
            
            DispatchQueue.main.async {
                // Combine static and dynamic data
                self?.rssItems = self?.staticRSSItems ?? []  // Ensure static items are always there
                self?.rssItems.append(contentsOf: parsedItems)  //Append to the static array.
                
                // Sort by date (newest first), handling optional dates.
                self?.rssItems.sort { (item1, item2) -> Bool in
                    guard let date1 = item1.pubDate, let date2 = item2.pubDate else {
                        return false // If dates are nil, don't change order.
                    }
                    return date1 > date2
                }
            }
        }.resume()
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
        Button(action: {}) {
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

// MARK: - Reusable Card View

struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool
    @State private var isImageLoaded = false
    @State private var isSafariViewPresented = false
    
    // Date formatter for display (static for performance)
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                                .onAppear { isImageLoaded = false }
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200).clipped()
                                .onAppear { isImageLoaded = true }
                        case .failure:
                            Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(.gray)
                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                                .background(Color.secondary.opacity(0.3)).onAppear { isImageLoaded = false }
                        @unknown default:                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        .background(Color.secondary.opacity(0.3))
                }
                
                if !isCompact {
                    Text(item.title)
                        .font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.top, 2)
                }
                
                HStack {
                    Image(systemName: "circle.fill").font(.system(size: 8)).foregroundColor(.gray)
                    if let pubDate = item.pubDate {
                        Text(RSSItemView.displayDateFormatter.string(from: pubDate)).font(.caption).foregroundColor(.gray)
                    } else {
                        Text("No date").font(.caption).foregroundColor(.gray)
                    }
                }
                .padding(.top, 1)
                
                Text(item.itemDescription)
                    .font(isCompact ? .caption : .body).foregroundColor(.gray)
                    .lineLimit(isCompact ? 2 : 4).padding(.top, isCompact ? 1 : 2)
                
                if !isCompact {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            TopicTag(title: "Law")
                            TopicTag(title: "IP")
                            TopicTag(title: "Legal")
                            Button(action: {}) { Image(systemName: "ellipsis").foregroundColor(.gray) }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
            .contentShape(RoundedRectangle(cornerRadius: 25)) // Make the entire card tappable
            .onTapGesture {
                if let url = URL(string: item.link) {
                    isSafariViewPresented = true
                    print(url)
                }
            }
            
            // Bookmark Icon (Placeholder)
            Button(action: {}) { Image(systemName: "bookmark").font(.title2).foregroundColor(.white) }
                .padding(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $isSafariViewPresented) {
            if let url = URL(string: item.link) {
                SafariView(url: url)
            }
        }
    }
}

// MARK: - SafariView

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Main View

struct ForYouView: View {
    @State private var searchText: String = ""
    @State private var isCompactView: Bool = false
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack { // Use ZStack for loading indicator and error handling
                ScrollView {
                    VStack(alignment: .leading) {
                        // Top Bar
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            Text("For You").font(.largeTitle).fontWeight(.bold)
                            Spacer()
                            Image(systemName: "person.circle").font(.largeTitle).foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // Filter Bar
                        HStack {
                            Button(action: {
                                rssViewModel.rssItems.sort { (item1, item2) -> Bool in
                                    guard let date1 = item1.pubDate, let date2 = item2.pubDate else { return false }
                                    return date1 > date2
                                }
                            }) {
                                HStack { Text("Newest first"); Image(systemName: "arrow.up.arrow.down") }
                            }
                            .foregroundColor(.white).padding(.vertical, 8).padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.3)).cornerRadius(20)
                            
                            Spacer()
                            
                            Button(action: { isCompactView.toggle() }) {
                                Image(systemName: isCompactView ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                            }.foregroundColor(.gray)
                            
                            Button(action: {}) { Image(systemName: "ellipsis").foregroundColor(.gray) }
                        }
                        .padding(.horizontal)
                        
                        // Updates Notification (Placeholder)
                        HStack {
                            Image(systemName: "3.circle.fill").foregroundColor(.red)
                            Text("updates since you last visit").font(.caption).foregroundColor(.gray)
                            Spacer()
                            Button(action: {}) { Image(systemName: "xmark").foregroundColor(.gray) }
                        }
                        .padding(.horizontal)
                        
                        // RSS Content Cards
                        if rssViewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            ForEach(rssViewModel.rssItems) { item in
                                RSSItemView(item: item, isCompact: isCompactView)
                            }
                        }
                    }
                    .padding(.top)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true)
                .alert(isPresented: $isShowingAlert) { // Alert for errors
                    Alert(title: Text("Error"), message: Text(rssViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }
//                // Tab Bar
//                HStack {
//                    TabBarButton(iconName: "waveform.path.ecg", label: "For you", isActive: true)
//                    TabBarButton(iconName: "book", label: "Episodes")
//                    TabBarButton(iconName: "bookmark", label: "Saved")
//                    TabBarButton(iconName: "number", label: "Interests")
//                }
//                .padding().background(Color.black).frame(maxWidth: .infinity).border(Color.gray.opacity(0.3), width: 1)
            }
        }
        .onAppear {
            rssViewModel.loadRSS()
        }
        .onChange(of: rssViewModel.errorMessage) { newValue in
            isShowingAlert = newValue != nil
        }
    }
}

// MARK: - Preview

struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView().preferredColorScheme(.dark)
    }
}
