////
////  LoadingRSSArticleWorkflow.swift
////  MyApp
////
////  Created by Cong Le on 3/17/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model
//
//struct RSSItem: Identifiable {
//    let id = UUID()
//    var title: String
//    var link: String
//    var pubDate: Date? // Changed to Date?
//    var itemDescription: String
//    var imageURL: String? // Added for potential image
//}
//
//// MARK: - XML Parser Delegate
//
//final class RSSParser: NSObject, XMLParserDelegate {
//    private var currentElement = ""
//    private var currentTitle = ""
//    private var currentLink = ""
//    private var currentPubDate = ""
//    private var currentDescription = ""
//    private var currentImageURL = ""
//
//    private var items: [RSSItem] = []
//    private var inItem = false
//    private var inImage = false // Flag to check if we are in an image tag.
//
//    // Date formatter (static for performance)
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" //RFC 822 format
//        formatter.locale = Locale(identifier: "en_US_POSIX") // Important for consistent parsing
//        return formatter
//    }()
//    
//    // Alternative date formatter, added more formats.
//    static let alternativeDateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // ISO 8601
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        return formatter
//    }()
//    
//    static let alternativeDateFormatter2: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        return formatter
//    }()
//
//    func parse(data: Data) -> [RSSItem] {
//        items = [] // Clear previous items
//        let parser = XMLParser(data: data)
//        parser.delegate = self
//        parser.parse()
//        return items
//    }
//
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        currentElement = elementName
//
//        if elementName == "item" {
//            inItem = true
//            currentTitle = ""
//            currentLink = ""
//            currentPubDate = ""
//            currentDescription = ""
//            currentImageURL = ""
//        }
//
//        // Check for image URL in different possible tags.
//        if inItem {
//            if elementName == "media:content", let urlString = attributeDict["url"] {
//                currentImageURL = urlString
//                inImage = true
//            } else if elementName == "enclosure", let urlString = attributeDict["url"], attributeDict["type"]?.hasPrefix("image") ?? false {
//                currentImageURL = urlString
//                inImage = true
//            } else if elementName == "image", let urlString = attributeDict["href"] {
//                // Check the "href" attribute, commonly used in <image> tags.
//                currentImageURL = urlString;
//                inImage = true
//            }
//        }
//    }
//
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        guard inItem else { return }
//
//        switch currentElement {
//        case "title":
//            currentTitle += string
//        case "link":
//            currentLink += string
//        case "pubDate":
//            currentPubDate += string
//        case "description":
//            currentDescription += string
//        default:
//            break
//        }
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "item" {
//            inItem = false
//
//            // Trim and parse date
//            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
//            var parsedDate: Date? = RSSParser.dateFormatter.date(from: trimmedPubDate)
//            
//            // Try the alternative format if the first one fails.
//            if parsedDate == nil {
//                parsedDate = RSSParser.alternativeDateFormatter.date(from: trimmedPubDate)
//            }
//            
//            //Try the alternative format 2 if the previous one fails.
//            if parsedDate == nil {
//                parsedDate = RSSParser.alternativeDateFormatter2.date(from: trimmedPubDate)
//            }
//
//            let newItem = RSSItem(
//                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
//                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
//                pubDate: parsedDate, // Store the Date object
//                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
//                imageURL: currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
//            )
//            items.append(newItem)
//        }
//        
//        if elementName == "media:content" || elementName == "enclosure" || elementName == "image"{
//            inImage = false
//        }
//
//        currentElement = ""
//    }
//    
//    // Error Handling
//      func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//          print("Parse error occurred: \(parseError)")
//      }
//
//      func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
//          print("Validation error occurred: \(validationError)")
//      }
//}
//
//// MARK: - View Model
//
//class RSSViewModel: ObservableObject {
//    @Published var rssItems: [RSSItem] = []
//    @Published var isLoading = false // Loading indicator
//    @Published var errorMessage: String? = nil  // Error Message
//
//    func loadRSS() {
//        guard let url = URL(string: "https://www.law360.com/ip/rss") else {
//            errorMessage = "Invalid URL" // Set error message
//            return
//        }
//
//        isLoading = true  // Start loading
//        errorMessage = nil // Reset error message
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            defer {
//                DispatchQueue.main.async {
//                    self?.isLoading = false // Ensure loading is set to false.
//                }
//            }
//
//            if let error = error {
//                DispatchQueue.main.async {
//                    self?.errorMessage = "Error fetching RSS feed: \(error.localizedDescription)"
//                    print("Error fetching RSS feed: \(error)")
//                }
//                return
//            }
//            
//            //Check for HTTP errors.
//            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
//                DispatchQueue.main.async {
//                    self?.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
//                }
//                return
//            }
//
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    self?.errorMessage = "No data received"
//                }
//                return
//            }
//            
//            //Added print statement for debugging data received.
//            //print("Received data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
//
//            let parser = RSSParser()
//            let parsedItems = parser.parse(data: data)
//
//            DispatchQueue.main.async {
//                self?.rssItems = parsedItems
//            }
//        }.resume()
//    }
//}
//
//// MARK: - SwiftUI View
//
//struct RSSContentView: View {
//    @StateObject private var viewModel = RSSViewModel()
//    @State private var isShowingAlert = false // State for showing the alert
//    
//    // Date formatter for display (static for performance)
//       static let displayDateFormatter: DateFormatter = {
//           let formatter = DateFormatter()
//           formatter.dateStyle = .medium
//           formatter.timeStyle = .short
//           return formatter
//       }()
//
//    var body: some View {
//        NavigationView {
//            ZStack { // Use ZStack to overlay loading indicator and list
//                List(viewModel.rssItems) { item in
//                    VStack(alignment: .leading, spacing: 5) {
//                        if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
//                            AsyncImage(url: url) { phase in  //Use AsyncImage
//                                switch phase {
//                                case .empty:
//                                    ProgressView() // Show a loader while loading
//                                        .frame(maxWidth: .infinity, maxHeight: 200)
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(maxWidth: .infinity, maxHeight: 200)
//                                case .failure:
//                                    Image(systemName: "photo") // Placeholder for failed image
//                                        .frame(maxWidth: .infinity, maxHeight: 200)
//                                @unknown default:
//                                    EmptyView()
//                                }
//                            }
//                        }
//                        Text(item.title)
//                            .font(.headline)
//                        if let pubDate = item.pubDate { // Safely unwrap the optional Date
//                            Text(RSSContentView.displayDateFormatter.string(from: pubDate)) // Use the display formatter
//                                .font(.subheadline)
//                        } else {
//                            Text("No date available")
//                                .font(.subheadline)
//                        }
//                        
//                        Text(item.itemDescription)
//                            .font(.body)
//                            .lineLimit(4)
//                    }
//                }
//                .navigationTitle("Law360 RSS")
//                .refreshable { // Add pull-to-refresh
//                    viewModel.loadRSS()
//                }
//                .alert(isPresented: $isShowingAlert) { // Alert for error
//                    Alert(
//                        title: Text("Error"),
//                        message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
//                        dismissButton: .default(Text("OK"))
//                    )
//                }
//
//                if viewModel.isLoading { // Conditional loading indicator
//                    ProgressView("Loading...")
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                        .scaleEffect(1.5)
//                }
//            }
//        }
//        .onAppear {
//            viewModel.loadRSS()
//        }
//        .onChange(of: viewModel.errorMessage) { newValue in
//            if newValue != nil {
//                isShowingAlert = true // Show alert when there's an error
//            }
//        }
//    }
//}
//
//
//// MARK: - Combined ForYouView
//
//struct ForYouView: View {
//    @State private var searchText: String = ""
//    @State private var isCompactView: Bool = false
//    @StateObject private var rssViewModel = RSSViewModel() // ViewModel for RSS data
//    @State private var isShowingAlert = false
//
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading) {
//                    // Top Bar (Search, Title, Profile)
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                        Text("For You")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                        Spacer()
//                        Image(systemName: "person.circle")
//                            .font(.largeTitle)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.horizontal)
//
//                    // Filter Bar (Newest First, Compact View, More Options)
//                    HStack {
//                        Button(action: {
//                            // Handle sorting.  Sort by date, newest first.
//                            rssViewModel.rssItems.sort { (item1, item2) -> Bool in
//                                guard let date1 = item1.pubDate, let date2 = item2.pubDate else {
//                                    return false // If dates are nil, don't change order
//                                }
//                                return date1 > date2
//                            }
//                        }) {
//                            HStack {
//                                Text("Newest first")
//                                Image(systemName: "arrow.up.arrow.down")
//                            }
//                        }
//                        .foregroundColor(.white)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 12)
//                        .background(Color.gray.opacity(0.3))
//                        .cornerRadius(20)
//
//                        Spacer()
//
//                        Button(action: {
//                            isCompactView.toggle()
//                        }) {
//                            Image(systemName: isCompactView ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
//                        }
//                        .foregroundColor(.gray)
//
//                        Button(action: {
//                            // Show more options
//                        }) {
//                            Image(systemName: "ellipsis")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    // Updates Notification (Placeholder - You can customize this)
//                    HStack {
//                        Image(systemName: "3.circle.fill") // Example notification
//                            .foregroundColor(.red)
//                        Text("updates since you last visit")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        Spacer()
//                        Button(action: {}) {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    // Dynamic RSS Content Cards
//                   if rssViewModel.isLoading {
//                       ProgressView()
//                           .padding()
//                   } else if let errorMessage = rssViewModel.errorMessage {
//                       Text("Error: \(errorMessage)")
//                           .foregroundColor(.red)
//                           .padding()
//                   } else {
//                       ForEach(rssViewModel.rssItems) { item in
//                           RSSItemView(item: item, isCompact: isCompactView)
//                       }
//                   }
//
//                }
//                .padding(.top)
//            }
//            .background(Color.black.edgesIgnoringSafeArea(.all))
//            .navigationBarHidden(true)
//             //Alert for errors.
//            .alert(isPresented: $isShowingAlert) {
//                Alert(title: Text("Error"), message: Text(rssViewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
//            }
//            // Tab Bar (Remains the same)
//            HStack {
//                TabBarButton(iconName: "waveform.path.ecg", label: "For you", isActive: true)
//                TabBarButton(iconName: "book", label: "Episodes")
//                TabBarButton(iconName: "bookmark", label: "Saved")
//                TabBarButton(iconName: "number", label: "Interests")
//            }
//            .padding()
//            .background(Color.black)
//            .frame(maxWidth: .infinity)
//            .border(Color.gray.opacity(0.3), width: 1)
//        }
//        .onAppear {
//            rssViewModel.loadRSS()
//        }
//        .onChange(of: rssViewModel.errorMessage) { newValue in
//            if newValue != nil {
//                isShowingAlert = true // Show alert when there's an error
//            }
//        }
//    }
//}
//
//// MARK: - RSS Item View (Reusable Card)
//
//struct RSSItemView: View {
//    let item: RSSItem
//    var isCompact: Bool
//    @State private var isImageLoaded = false // Track image loading state
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(alignment: .leading) {
//                
//                // Display image if available
//                if let imageURLString = item.imageURL, let url = URL(string: imageURLString) {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
//                                .onAppear {
//                                    isImageLoaded = false // Reset on appearance
//                                }
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill() // Use scaledToFill for better image display
//                                .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
//                                .clipped() // Clip the image to the frame
//                                .onAppear {
//                                    isImageLoaded = true
//                                }
//                        case .failure:
//                            //Placeholder with default image
//                            Image(systemName: "photo.fill")
//                               .resizable()
//                               .scaledToFit()
//                               .foregroundColor(.gray)
//                               .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
//                                .background(Color.secondary.opacity(0.3)) // Use a subtle background
//                                .onAppear {
//                                    isImageLoaded = false
//                                }
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                } else {
//                    // Placeholder if no image URL is provided
//                    Image(systemName: "photo.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
//                        .background(Color.secondary.opacity(0.3))
//                }
//
//                if !isCompact{
//                    Text(item.title)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(.top, 2)
//                }
//
//                HStack {
//                    Image(systemName: "circle.fill")
//                        .font(.system(size: 8))
//                        .foregroundColor(.gray)
//                    if let pubDate = item.pubDate {
//                        Text(RSSContentView.displayDateFormatter.string(from: pubDate)) //Consistent date format
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    } else {
//                        Text("No date available")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding(.top, 1)
//
//                Text(item.itemDescription)
//                    .font(isCompact ? .caption : .body)
//                    .foregroundColor(.gray)
//                    .lineLimit(isCompact ? 2 : 4)
//                    .padding(.top, isCompact ? 1 : 2)
//
//                // Topic Tags (Placeholder - Adapt as needed)
//                if !isCompact {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            TopicTag(title: "Law")
//                            TopicTag(title: "IP")
//                            TopicTag(title: "Legal")
//                            Button(action: {
//                                // Show more options
//                            }) {
//                                Image(systemName: "ellipsis")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding(.top, 8)
//                    }
//                }
//            }
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
//
//            // Bookmark Icon (Placeholder - Implement bookmark functionality)
//            Button(action: {
//                // Handle bookmark action
//            }) {
//                Image(systemName: "bookmark")
//                    .font(.title2)
//                    .foregroundColor(.white)
//            }
//            .padding(10)
//        }
//        .padding(.horizontal)
//    }
//}
//
//
//// MARK: - Helper Views (Remain the same, but made accessible)
//
//struct TopicTag: View {
//    let title: String
//
//    var body: some View {
//        Text(title)
//            .font(.caption)
//            .fontWeight(.bold)
//            .foregroundColor(.white)
//            .padding(.vertical, 8)
//            .padding(.horizontal, 12)
//            .background(Color.purple.opacity(0.5))
//            .cornerRadius(20)
//    }
//}
//
//struct TabBarButton: View {
//    let iconName: String
//    let label: String
//    var isActive: Bool = false
//
//    var body: some View {
//        Button(action: {
//            // Handle tab selection
//        }) {
//            VStack {
//                Image(systemName: iconName)
//                    .font(.title2)
//                    .foregroundColor(isActive ? .pink : .gray)
//                Text(label)
//                    .font(.caption)
//                    .foregroundColor(isActive ? .pink : .gray)
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct CombinedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouView()
//            .preferredColorScheme(.dark)
//    }
//}
