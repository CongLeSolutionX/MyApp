//
//  USCISRSSView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import Foundation

// Represents a single item from the USCIS Developer Portal RSS feed.
struct FeedItem: Identifiable, Hashable {
    let id: String // Use the GUID as a unique identifier
    let title: String
    let link: URL? // Store the link as a URL
    let publishDate: Date? // Store the publication date
    let creator: String
    let description: String // Store the raw HTML description for now

    // Note: In a real app, you'd have robust XML parsing logic
    // to extract and format this data, including parsing the pubDate string
    // into a Date object and potentially cleaning the description HTML.
    // For this design, we assume this parsing happens elsewhere.

    // Example Initializer (if creating manually, otherwise done by parser)
    init(id: String, title: String, linkString: String, pubDateString: String, creator: String, description: String) {
        self.id = id
        self.title = title
        self.link = URL(string: linkString)
        self.creator = creator
        self.description = description

        // Basic Date Parsing Example (improve with proper formatters in production)
        let formatter = DateFormatter()
        // RSS Date Format: "EEE, dd MMM yyyy HH:mm:ss Z"
        // e.g., "Wed, 06 Mar 2024 20:32:25 +0000"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Important for fixed formats
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        self.publishDate = formatter.date(from: pubDateString)
    }

    // Conformance to Hashable (needed for ForEach with non-constant data)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conformance to Equatable (part of Hashable)
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        lhs.id == rhs.id
    }

    // Static Sample Data for Previewing
    static let sampleData: [FeedItem] = [
        FeedItem(id: "114", title: "Developer Teams & Developer Apps", linkString: "https://developer.uscis.gov/article/developer-teams-developer-apps", pubDateString: "Wed, 06 Mar 2024 20:32:25 +0000", creator: "dev-portal-admin", description: "<span...>...</span>"),
        FeedItem(id: "126", title: "Managing Client Credentials", linkString: "https://developer.uscis.gov/article/managing-client-credentials", pubDateString: "Thu, 22 Aug 2024 21:37:11 +0000", creator: "dev-portal-admin", description: "<span...>...</span>"),
        FeedItem(id: "125", title: "Recent Changes: Updates to the API library documentation and site appearance.", linkString: "https://developer.uscis.gov/article/portal-updates", pubDateString: "Tue, 20 Aug 2024 15:48:55 +0000", creator: "dev-portal-admin", description: "<span...>...</span>"),
         FeedItem(id: "102", title: "How do I Create an App?", linkString: "https://developer.uscis.gov/article/how-do-i-create-app", pubDateString: "Wed, 18 Jan 2023 01:47:34 +0000", creator: "dev-portal-admin", description: "<span...>...</span>")
    ]
}

// A simple view model to hold and potentially fetch the feed items
// In a real app, this would contain networking logic to fetch and parse the RSS feed.
class FeedViewModel: ObservableObject {
    @Published var items: [FeedItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchFeed() {
        isLoading = true
        errorMessage = nil
        // Simulate network fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real app, replace sampleData with parsed data from the network
             // Implement actual RSS fetching and XML parsing here using URLSession and XMLParser
            self.items = FeedItem.sampleData // Use sample data for design purposes
            self.isLoading = false
        }
        // Example error handling
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        //     self.errorMessage = "Failed to load feed."
        //     self.isLoading = false
        // }
    }
}



import SwiftUI
import WebKit // Needed for WebView

// Represents a single row in the feed list
struct FeedItemRow: View {
    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(.headline)
                .lineLimit(2) // Limit title lines

            Text("By: \(item.creator)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let date = item.publishDate {
                Text(date, style: .date) // Format the date
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4) // Add some vertical padding
    }
}

// Displays the list of feed items
struct FeedListView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                // NavigationLink makes the row tappable and navigates
                NavigationLink(destination: FeedDetailView(item: item)) {
                    FeedItemRow(item: item)
                }
            }
        }
        .navigationTitle("USCIS Dev Portal")
        .overlay {
           if viewModel.isLoading {
               ProgressView("Loading Feed...")
           } else if let errorMessage = viewModel.errorMessage {
               VStack {
                   Text("Error")
                       .font(.headline)
                   Text(errorMessage)
                       .foregroundColor(.red)
                   Button("Retry") {
                       viewModel.fetchFeed()
                   }
                   .buttonStyle(.borderedProminent)
               }
           }
        }
        .onAppear {
            // Fetch feed only if items are empty
            if viewModel.items.isEmpty {
                 viewModel.fetchFeed()
            }
        }
        // Add pull-to-refresh if desired
        // .refreshable {
        //     viewModel.fetchFeed()
        // }
    }
}

// Displays the details of a selected feed item
struct FeedDetailView: View {
    let item: FeedItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(item.title)
                    .font(.title)
                    .bold()

                HStack {
                   Text("By: \(item.creator)")
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                    Spacer()
                   if let date = item.publishDate {
                       Text(date, style: .date)
                           .font(.caption)
                           .foregroundColor(.gray)
                   }
                }

                // Option 1: Simple Text view (HTML tags visible)
                 Text("Raw Description:")
                    .font(.headline)
                 Text(item.description)
                     .font(.body)
                     .padding(.vertical)

                // Option 2: Basic WebView to render HTML (More robust)
                 // Need to wrap WKWebView for SwiftUI
                 // HTMLWebView(htmlString: item.description)
                 //    .frame(height: 300) // Adjust height as needed

                if let url = item.link {
                    // Link to open the original article in Safari
                    Link("Read Full Article", destination: url)
                        .font(.headline)
                         .padding(.top)
                }
            }
            .padding() // Add padding around the content
        }
        .navigationTitle("Article Details") // Use a generic title or part of the item title
        .navigationBarTitleDisplayMode(.inline) // Smaller title bar
    }
}

// --- WKWebView Wrapper (Optional - for HTML rendering) ---
// A simple wrapper to use WKWebView within SwiftUI
struct HTMLWebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// --- Main Content View ---
// Sets up the navigation structure
struct USCISRSSView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationView {
            FeedListView(viewModel: viewModel)
        }
         // Use stack navigation style for standard iOS behavior
        .navigationViewStyle(.stack)
    }
}

//// --- App Entry Point ---
//@main
//struct USCISFeedApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// --- SwiftUI Previews ---
struct FeedItemRow_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemRow(item: FeedItem.sampleData[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct FeedListView_Previews: PreviewProvider {
    static var previews: some View {
         NavigationView { // Wrap in NavigationView for preview context
             FeedListView(viewModel: {
                 let vm = FeedViewModel()
                 vm.items = FeedItem.sampleData // Preload sample data
                 return vm
             }())
         }
    }
}

struct FeedDetailView_Previews: PreviewProvider {
    static var previews: some View {
         NavigationView { // Wrap in NavigationView for preview context
            FeedDetailView(item: FeedItem.sampleData[1])
         }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        USCISRSSView()
    }
}
