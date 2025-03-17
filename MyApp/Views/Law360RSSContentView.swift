////
////  Law360RSSContentView.swift
////  MyApp
////
////  Created by Cong Le on 3/17/25.
////
//
//import SwiftUI
//import SafariServices
//
//// MARK: - Data Model
//struct Law360RSSItem: Identifiable {
//    let id = UUID()
//    var title: String
//    var link: String
//    var pubDate: String
//    var itemDescription: String
//}
//
//// MARK: - XML Parser Delegate
//
//final class Law360RSSParser: NSObject, XMLParserDelegate {
//    private var currentElement = ""
//    private var currentTitle = ""
//    private var currentLink = ""
//    private var currentPubDate = ""
//    private var currentDescription = ""
//    
//    private var items: [Law360RSSItem] = []
//    private var inItem = false
//    
//    func parse(data: Data) -> [Law360RSSItem] {
//        let parser = XMLParser(data: data)
//        parser.delegate = self
//        parser.parse()
//        return items
//    }
//    
//    // Parser Callbacks
//    func parser(_ parser: XMLParser, didStartElement elementName: String,
//                namespaceURI: String?, qualifiedName qName: String?,
//                attributes attributeDict: [String : String] = [:]) {
//        
//        currentElement = elementName
//        
//        if elementName == "item" {
//            inItem = true
//            currentTitle = ""
//            currentLink = ""
//            currentPubDate = ""
//            currentDescription = ""
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
//    func parser(_ parser: XMLParser, didEndElement elementName: String,
//                namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "item" {
//            inItem = false
//            let newItem = Law360RSSItem(
//                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
//                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
//                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines),
//                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
//            )
//            items.append(newItem)
//        }
//        currentElement = ""
//    }
//}
//
//// MARK: - View Model
//
//class Law360RSSViewModel: ObservableObject {
//    @Published var rssItems: [Law360RSSItem] = []
//    
//    func loadRSS() {
//        guard let url = URL(string: "https://www.law360.com/ip/rss") else { return }
//        
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            if let error = error {
//                print("Error fetching RSS feed: \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                return
//            }
//            
//            let parser = Law360RSSParser()
//            let parsedItems = parser.parse(data: data)
//            
//            DispatchQueue.main.async {
//                self?.rssItems = parsedItems
//            }
//        }.resume()
//    }
//}
//
//// MARK: - Reusable Card View
//
//struct RSSCardView: View {
//    let item: Law360RSSItem
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(item.title)
//                .font(.headline)
//                .lineLimit(2)
//            Text(item.pubDate)
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            Text(item.itemDescription)
//                .font(.body)
//                .lineLimit(3)
//                .padding(.top, 4)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(10)
//        .shadow(radius: 3)
//    }
//}
//
//
//// MARK: - SwiftUI Content View
//struct Law360RSSContentView: View {
//    @StateObject private var viewModel = Law360RSSViewModel()
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
//                    ForEach(viewModel.rssItems) { item in
//                        NavigationLink(destination: Law360RSSDetailView(item: item)) {
//                            RSSCardView(item: item)
//                        }
//                        .buttonStyle(PlainButtonStyle()) // Make entire card tappable
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Law360 RSS Feed")
//            .onAppear {
//                viewModel.loadRSS()
//            }
//        }
//    }
//}
//
//// MARK: - SafariView
//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//    
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//    
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        // No updates needed
//    }
//}
//
//// MARK: - Law360RSSDetailView
//struct Law360RSSDetailView: View {
//    let item: Law360RSSItem
//    @State private var isSafariViewPresented = false // State to control SafariView presentation
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                Text(item.title)
//                    .font(.title)
//                    .padding(.bottom, 8)
//                
//                Text(item.pubDate)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.bottom, 16)
//                
//                Text(item.itemDescription)
//                    .font(.body)
//                
//                Spacer() // Push content to top and allow scroll
//                
//                Button("Read Full Article") {
//                    if let url = URL(string: item.link) {
//                        UIApplication.shared.open(url) // Open in default browser (Safari App)
//                        
//                        // Optional: Present SFSafariViewController in-app
//                        isSafariViewPresented = true
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.vertical, 20)
//                .sheet(isPresented: $isSafariViewPresented) {  // Present SFSafariViewController as a sheet
//                    if let url = URL(string: item.link) {
//                        SafariView(url: url) // Custom SafariView struct below
//                    }
//                    
//                }
//                .padding()
//            }
//            .navigationTitle("Article Detail")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    Law360RSSContentView()
//}
