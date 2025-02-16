//
//  ParsingXML.swift
//  MyApp
//
//  Created by Cong Le on 2/16/25.
//
import SwiftUI
import Foundation

// MARK: - Data Models

struct RSSChannel {
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var year: String = ""
    var month: String = ""
    var items: [RSSItem] = []
}

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var pubDate: String = ""
    var volume: String = ""
    var issue: String = ""
    var startPage: String = ""
    var endPage: String = ""
    var fileSize: String = ""
    var authors: String = ""
    var imageURL: String? // Add image URL property
}

// MARK: - RSS Parser

class RSSParser: NSObject, XMLParserDelegate, ObservableObject {
    @Published var channel = RSSChannel()

    private var currentElement = ""
    private var currentValue = ""
    private var currentItem: RSSItem?
    private var isInsideChannel = false
    private var isInsideItem = false

    // Fetch and parse RSS from a URL
    func fetchRSS(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }

    // XMLParserDelegate Methods

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes: [String : String] = [:]) {
        currentElement = elementName.trimmingCharacters(in: .whitespacesAndNewlines)

        switch currentElement {
        case "channel":
            isInsideChannel = true
        case "item":
            isInsideItem = true
            currentItem = RSSItem()
        case "enclosure": // Check for enclosure tag, common for images
            if isInsideItem, let urlString = attributes["url"], attributes["type"]?.starts(with: "image") == true {
                // Assuming enclosure URL is image if type starts with "image"
                currentItem?.imageURL = urlString
            }
        default:
            break
        }

        currentValue = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {

        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if isInsideItem {
            switch elementName {
            case "title":
                currentItem?.title = trimmedValue
            case "link":
                currentItem?.link = trimmedValue
            case "description":
                currentItem?.description = trimmedValue
            case "pubDate":
                currentItem?.pubDate = trimmedValue
            case "volume":
                currentItem?.volume = trimmedValue
            case "issue":
                currentItem?.issue = trimmedValue
            case "startPage":
                currentItem?.startPage = trimmedValue
            case "endPage":
                currentItem?.endPage = trimmedValue
            case "fileSize":
                currentItem?.fileSize = trimmedValue
            case "authors":
                currentItem?.authors = trimmedValue
            case "item":
                if let item = currentItem {
                    DispatchQueue.main.async {
                        self.channel.items.append(item)
                    }
                }
                currentItem = nil
                isInsideItem = false
            default:
                break
            }
        } else if isInsideChannel {
            switch elementName {
            case "title":
                DispatchQueue.main.async {
                    self.channel.title = trimmedValue
                }
            case "link":
                DispatchQueue.main.async {
                    self.channel.link = trimmedValue
                }
            case "description":
                DispatchQueue.main.async {
                    self.channel.description = trimmedValue
                }
            case "year":
                DispatchQueue.main.async {
                    self.channel.year = trimmedValue
                }
            case "month":
                DispatchQueue.main.async {
                    self.channel.month = trimmedValue
                }
            case "channel":
                isInsideChannel = false
            default:
                break
            }
        }

        currentElement = ""
        currentValue = ""
    }
}

// MARK: - Card View for RSS Item with Image

struct RSSItemCardView: View {
    let item: RSSItem

    var body: some View {
        HStack(spacing: 12) { // Horizontal layout for image and text
            if let imageURLString = item.imageURL, let imageURL = URL(string: imageURLString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Placeholder while loading
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80) // Fixed size for image
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo") // Placeholder on error
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo.on.rectangle.angled") // Default image if no URL
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

// MARK: - ContentView

struct RSSContentView: View {
    @StateObject private var parser = RSSParser()

    // Provide the RSS URL here
    private let rssURL = "https://ieeexplore.ieee.org/rss/POP34.XML"

    var body: some View {
        NavigationView {
            List {
                // Channel Info
                Section(header: Text("Channel Info")) {
                    Text("Title: \(parser.channel.title)")
                    Text("Link: \(parser.channel.link)")
                    Text("Description: \(parser.channel.description)")
                    Text("Year: \(parser.channel.year)")
                    Text("Month: \(parser.channel.month)")
                }

                // Items
                Section(header: Text("Items")) {
                    ForEach(parser.channel.items) { item in
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            RSSItemCardView(item: item) // Using Card View with Image
                        }
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("RSS Feed")
            .listStyle(.plain)
        }
        .onAppear {
            parser.fetchRSS(from: rssURL)
        }
    }
}

// MARK: - Item Detail View

struct ItemDetailView: View {
    let item: RSSItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Title: \(item.title)")
                    .font(.headline)

                // Display image in detail view as well, if URL exists
                if let imageURLString = item.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity) // Make image take full width
                    .padding(.bottom) // Add some space below image
                }


                Text("Link: \(item.link)")
                Text("Publication Date: \(item.pubDate)")
                Text("Volume: \(item.volume)")
                Text("Issue: \(item.issue)")
                Text("Pages: \(item.startPage) - \(item.endPage)")
                Text("File Size: \(item.fileSize)")
                Text("Authors: \(item.authors)")

                Text("Description:")
                    .fontWeight(.semibold)

                Text(item.description)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle("Item Details")
    }
}

// MARK: - Preview
#Preview {
    RSSContentView()
}
