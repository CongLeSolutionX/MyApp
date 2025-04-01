//
//  RichLinksDemoApp.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI
import LinkPresentation
import UIKit // Needed for UIActivityItemSource, UIImage, UIActivityViewController

// MARK: - Data Model

struct RecipeLink: Identifiable {
    let id = UUID()
    let originalURL: URL
    var metadata: LPLinkMetadata? // Store locally loaded metadata
    var isManuallyCreated: Bool = false // Flag for demo purposes
}

// MARK: - Local Metadata Model

// Represents the metadata stored locally in JSON.
private struct LocalMetadata: Codable {
    let originalURL: String
    let title: String
    // You can add additional properties (e.g., subtitle, iconName, etc.) if desired.
}

// MARK: - ViewModel

@MainActor // Ensures that @Published updates and UI changes happen on the main thread
class LinkViewModel: ObservableObject {
    @Published var items: [RecipeLink] = []
    private var metadataCache: [URL: LPLinkMetadata] = [:] // In-memory cache of LPLinkMetadata
    
    // Holds the local metadata loaded from JSON, keyed by URL string.
    private var localMetadataDictionary: [String: LocalMetadata] = [:]
    
    init() {
        // 1. Populate with placeholder URLs
        let urls = [
            URL(string: "https://www.apple.com")!,
            URL(string: "https://developer.apple.com/tutorials/swiftui")!,
            URL(string: "https://www.hackingwithswift.com")!,
            URL(string: "https://example.com/this-page-might-not-exist")! // To test potential mismatch
            // For testing local file links, adjust as needed.
        ]
        self.items = urls.map { RecipeLink(originalURL: $0) }
        
        // 2. Load local metadata from JSON file.
        loadLocalMetadataFromJSON()
        
        // 3. Update each item with local metadata if available.
        updateItemsWithLocalMetadata()
        
        // 4. Add an item with manually created metadata.
        addManualItem()
    }
    
    // Loads local metadata from 'metadata.json' in the bundle.
    private func loadLocalMetadataFromJSON() {
        guard let url = Bundle.main.url(forResource: "metadata", withExtension: "json") else {
            print("❌ Could not locate metadata.json in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let localMetadataArray = try decoder.decode([LocalMetadata].self, from: data)
            // Create dictionary keyed by originalURL string.
            for metadata in localMetadataArray {
                localMetadataDictionary[metadata.originalURL] = metadata
            }
            print("✅ Successfully loaded local metadata from JSON.")
        } catch {
            print("❌ Failed to load local metadata: \(error.localizedDescription)")
        }
    }
    
    // Updates each RecipeLink in items with the locally loaded metadata if available.
    private func updateItemsWithLocalMetadata() {
        for index in items.indices {
            let urlString = items[index].originalURL.absoluteString
            if let localMeta = localMetadataDictionary[urlString] {
                let lpMetadata = createLPLinkMetadata(from: localMeta)
                items[index].metadata = lpMetadata
                metadataCache[items[index].originalURL] = lpMetadata
                print("✅ Assigned local metadata for: \(urlString)")
            } else {
                // If not found in JSON, assign fallback metadata.
                items[index].metadata = createFallbackMetadata(for: items[index].originalURL)
                metadataCache[items[index].originalURL] = items[index].metadata
                print("⚠️ No local metadata found for: \(urlString); fallback applied.")
            }
        }
    }
    
    // Converts a LocalMetadata instance to LPLinkMetadata.
    private func createLPLinkMetadata(from localMeta: LocalMetadata) -> LPLinkMetadata {
        let lpMetadata = LPLinkMetadata()
        if let url = URL(string: localMeta.originalURL) {
            lpMetadata.originalURL = url
            lpMetadata.url = url
        }
        lpMetadata.title = localMeta.title
        return lpMetadata
    }
    
    // Creates basic fallback metadata in case no local data is available.
    private func createFallbackMetadata(for url: URL) -> LPLinkMetadata {
        let fallbackMetadata = LPLinkMetadata()
        fallbackMetadata.originalURL = url
        fallbackMetadata.url = url
        fallbackMetadata.title = url.host ?? url.absoluteString
        return fallbackMetadata
    }
    
    // Adds a manually created item to items.
    private func addManualItem() {
        let manualURL = URL(string: "https://my-internal-app.com/recipe/pasta-dish")!
        let manualMetadata = LPLinkMetadata()
        manualMetadata.originalURL = manualURL
        manualMetadata.url = manualURL
        manualMetadata.title = "Grandma's Famous Pasta (Manual)"
        if let iconImage = UIImage(systemName: "fork.knife.circle.fill") {
            manualMetadata.iconProvider = NSItemProvider(object: iconImage)
        }
        let manualItem = RecipeLink(originalURL: manualURL, metadata: manualMetadata, isManuallyCreated: true)
        self.items.append(manualItem)
        metadataCache[manualURL] = manualMetadata
        print("✅ Added manually created item for: \(manualURL)")
    }
    
    // Helper for sharing: returns cached metadata if present.
    func metadataForSharing(url: URL) -> LPLinkMetadata? {
        return metadataCache[url] ?? items.first { $0.originalURL == url }?.metadata
    }
}

// MARK: - SwiftUI View

struct ContentView: View {
    @StateObject private var viewModel = LinkViewModel() // View model is created internally
    
    @State private var itemToShare: RecipeLink? // Tracks item for share sheet activation
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading) {
                        if let metadata = item.metadata {
                            // Display the local metadata using our LPLinkView wrapper.
                            LinkViewRepresentable(metadata: metadata)
                                .frame(minHeight: 50)
                        } else {
                            // Placeholder view if metadata is nil.
                            HStack {
                                ProgressView()
                                    .padding(.trailing, 5)
                                Text("Loading: \(item.originalURL.host ?? item.originalURL.absoluteString)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            .frame(minHeight: 50)
                        }
                        
                        if item.isManuallyCreated {
                            Text(" (Manually Created Metadata)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button {
                            itemToShare = item
                        } label: {
                            Label("Share Link", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .navigationTitle("Recipe Links")
            .listStyle(.plain)
            .sheet(item: $itemToShare) { item in
                ShareSheetView(linkItem: item)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - LPLinkView Wrapper

struct LinkViewRepresentable: UIViewRepresentable {
    let metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> LPLinkView {
        return LPLinkView(metadata: metadata)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        if uiView.metadata != metadata {
            uiView.metadata = metadata
        }
    }
}

// MARK: - Share Sheet Implementation

struct ShareSheetView: UIViewControllerRepresentable {
    let linkItem: RecipeLink
    @EnvironmentObject var viewModel: LinkViewModel
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let itemSource = ShareActivityItemSource(link: linkItem, viewModel: viewModel)
        let controller = UIActivityViewController(
            activityItems: [itemSource],
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    let link: RecipeLink
    weak var viewModel: LinkViewModel?
    
    init(link: RecipeLink, viewModel: LinkViewModel) {
        self.link = link
        self.viewModel = viewModel
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return link.originalURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return link.originalURL
    }
    
    @MainActor func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        print("Share Sheet requesting metadata for: \(link.originalURL)")
        let metadata = viewModel?.metadataForSharing(url: link.originalURL) ?? link.metadata
        if metadata != nil {
            print("✅ Providing local metadata to Share Sheet.")
        } else {
            print("⚠️ No metadata available; fallback will be used.")
        }
        return metadata
    }
}

// MARK: - Dummy Metadata Helper (for Previews)

func dummyMetadata(title: String, urlString: String = "https://www.example.com") -> LPLinkMetadata {
    let metadata = LPLinkMetadata()
    let url = URL(string: urlString)!
    metadata.originalURL = url
    metadata.url = url
    metadata.title = title
    return metadata
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Loaded Metadata state preview
            ContentView()
                .environmentObject({
                    let vm = LinkViewModel()
                    vm.items = [
                        RecipeLink(originalURL: URL(string: "https://www.apple.com")!,
                                   metadata: dummyMetadata(title: "Apple", urlString: "https://www.apple.com"),
                                   isManuallyCreated: false),
                        RecipeLink(originalURL: URL(string: "https://developer.apple.com")!,
                                   metadata: dummyMetadata(title: "Developer Site", urlString: "https://developer.apple.com"),
                                   isManuallyCreated: false)
                    ]
                    return vm
                }())
                .previewDisplayName("Loaded Metadata State")
            
            // Loading state preview (nil metadata)
            ContentView()
                .environmentObject({
                    let vm = LinkViewModel()
                    vm.items = [
                        RecipeLink(originalURL: URL(string: "https://www.loading-example.com")!, metadata: nil, isManuallyCreated: false)
                    ]
                    return vm
                }())
                .previewDisplayName("Loading (Nil Metadata) State")
                
            // Manually Created Metadata state preview
            ContentView()
                .environmentObject({
                    let vm = LinkViewModel()
                    vm.items = [
                        RecipeLink(originalURL: URL(string: "https://my-internal-app.com/recipe/pasta-dish")!,
                                   metadata: dummyMetadata(title: "Grandma's Famous Pasta (Manual)",
                                                           urlString: "https://my-internal-app.com/recipe/pasta-dish"),
                                   isManuallyCreated: true)
                    ]
                    return vm
                }())
                .previewDisplayName("Manually Created State")
        }
    }
}

struct LinkViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LinkViewRepresentable(metadata: dummyMetadata(title: "Preview LPLinkView"))
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("LinkViewRepresentable – Loaded")
        }
    }
}
    
// MARK: - App Entry Point

@main
struct RichLinksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
