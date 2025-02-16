//
//  Law360RSSContent.swift
//  MyApp
//
//  Created by Cong Le on 2/16/25.
//

import SwiftUI

// MARK: - Data Model

struct Law360RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var pubDate: String
    var itemDescription: String
}

// MARK: - XML Parser Delegate

final class Law360RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    
    private var items: [Law360RSSItem] = []
    private var inItem = false

    func parse(data: Data) -> [Law360RSSItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }
    
    // Parser Callbacks
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        if elementName == "item" {
            inItem = true
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
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
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false
            let newItem = Law360RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines),
                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            items.append(newItem)
        }
        currentElement = ""
    }
}

// MARK: - View Model

class Law360RSSViewModel: ObservableObject {
    @Published var rssItems: [Law360RSSItem] = []
    
    func loadRSS() {
        guard let url = URL(string: "https://www.law360.com/ip/rss") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching RSS feed: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            let parser = Law360RSSParser()
            let parsedItems = parser.parse(data: data)
            
            DispatchQueue.main.async {
                self?.rssItems = parsedItems
            }
        }.resume()
    }
}

// MARK: - SwiftUI View

struct Law360RSSContentView: View {
    @StateObject private var viewModel = Law360RSSViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.rssItems) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.pubDate)
                        .font(.subheadline)
                    Text(item.itemDescription)
                        .font(.body)
                        .lineLimit(4)
                }
            }
            .navigationTitle("Law360 RSS")
        }
        .onAppear {
            viewModel.loadRSS()
        }
    }
}

// MARK: - Preview
#Preview {
    Law360RSSContentView()
}
