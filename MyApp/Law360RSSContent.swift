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
    
    // Track when we are inside an <item> element
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
            // Reset item-level strings
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
            // Add the fully collected item to the list
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
        // Convert the XML string to Data (in a real app, you might fetch from a URL)
        guard let data = sampleXML.data(using: .utf8) else { return }
        
        let parser = Law360RSSParser()
        let parsedItems = parser.parse(data: data)
        
        DispatchQueue.main.async {
            self.rssItems = parsedItems
        }
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
                        .lineLimit(2)
                }
            }
            .navigationTitle("RSS Feed")
        }
        .onAppear {
            viewModel.loadRSS()
        }
    }
}

// MARK: - Sample XML

fileprivate let sampleXML = """
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Law360: Intellectual Property</title>
    <link>https://www.law360.com/ip?utm_source=rss&amp;utm_medium=rss&amp;utm_campaign=section</link>
    <description>Latest articles for: Intellectual Property</description>
    <language>en-US</language>
    <item>
      <pubDate>Fri, 14 Feb 2025 23:01:48 +0000</pubDate>
      <title>ITC Bans Some Power Converter Devices In Vicor Patent Case</title>
      <link>https://www.law360.com/ip/articles/2298548?utm_source=rss&amp;utm_medium=rss&amp;utm_campaign=section</link>
      <description>The U.S. International Trade Commission has issued a limited order...</description>
    </item>
    <!-- Additional <item> blocks truncated for brevity in this snippet -->
  </channel>
</rss>
"""



// MARK: - Preview
#Preview {
    Law360RSSContentView()
}
