//
//  LinkView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

//
//  LinkView.swift
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
    var metadata: LPLinkMetadata? // Store fetched/created metadata
    var isManuallyCreated: Bool = false // Flag for demo purposes
}

// MARK: - ViewModel

@MainActor // Ensures that @Published updates and UI changes happen on the main thread
class LinkViewModel: ObservableObject {
    @Published var items: [RecipeLink] = []
    private var metadataCache: [URL: LPLinkMetadata] = [:] // Simple in-memory cache
    private let metadataProvider = LPMetadataProvider()
    
    init() {
        // 1. Populate with placeholder URLs
        let urls = [
            URL(string: "https://www.apple.com")!,
            URL(string: "https://developer.apple.com/tutorials/swiftui")!,
            URL(string: "https://www.hackingwithswift.com")!,
            URL(string: "https://example.com/this-page-might-not-exist")! // To test potential failure
            // Placeholder for local file - replace with a valid path on your simulator/device if testing
            // URL(fileURLWithPath: Bundle.main.path(forResource: "YourDocument", ofType: "pdf") ?? "/invalid/path")
        ]
        self.items = urls.map { RecipeLink(originalURL: $0) }
        
        // 2. Fetch metadata for initial items
        fetchAllMetadata()
        
        // 3. Add an item with manually created metadata
        addManualItem()
    }
    
    // MARK: - Metadata Fetching
    
    func fetchAllMetadata() {
        for index in items.indices {
            // Check cache before fetching
            if let cachedMetadata = metadataCache[items[index].originalURL] {
                print("Cache hit for: \(items[index].originalURL)")
                items[index].metadata = cachedMetadata
                continue // Skip fetching if cached
            }
            // Fetch metadata if not in cache
            fetchMetadata(for: items[index].originalURL, at: index)
        }
    }
    
    private func fetchMetadata(for url: URL, at index: Int) {
        print("Starting fetch for: \(url)")
        
        // LPMetadataProvider handles both web URLs and local file URLs
        metadataProvider.startFetchingMetadata(for: url) { [weak self] fetchedMetadata, error in
            // Ensure UI updates run on main thread
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Check that the item still exists at the same index
                guard self.items.indices.contains(index), self.items[index].originalURL == url else {
                    print("Item at index \(index) changed before fetch completed for \(url)")
                    return
                }
                
                if let error = error {
                    print("❌ Failed to fetch metadata for \(url): \(error.localizedDescription)")
                    let fallback = self.createFallbackMetadata(for: url)
                    self.items[index].metadata = fallback
                    self.metadataCache[url] = fallback // Cache fallback metadata too
                    return
                }
                
                if let metadata = fetchedMetadata {
                    print("✅ Successfully fetched metadata for \(url)")
                    self.items[index].metadata = metadata
                    self.metadataCache[url] = metadata // Cache result
                } else {
                    print("⚠️ Fetch completed but no metadata returned for \(url)")
                    let fallback = self.createFallbackMetadata(for: url)
                    self.items[index].metadata = fallback
                    self.metadataCache[url] = fallback
                }
            }
        }
    }
    
    // Create basic fallback metadata in case fetching fails
    private func createFallbackMetadata(for url: URL) -> LPLinkMetadata {
        let fallbackMetadata = LPLinkMetadata()
        fallbackMetadata.originalURL = url
        fallbackMetadata.url = url
        fallbackMetadata.title = url.host ?? url.absoluteString // Use host or full URL as title
        // Optionally, add a placeholder icon here.
        return fallbackMetadata
    }
    
    // MARK: - Manual Metadata Creation
    
    private func addManualItem() {
        let manualURL = URL(string: "https://my-internal-app.com/recipe/pasta-dish")!
        let manualMetadata = LPLinkMetadata()
        
        // Essential: Set originalURL and url
        manualMetadata.originalURL = manualURL
        manualMetadata.url = manualURL
        
        // Populate with existing data
        manualMetadata.title = "Grandma's Famous Pasta (Manual)"
        
        // Example: Adding an icon (using an SF Symbol)
        if let iconImage = UIImage(systemName: "fork.knife.circle.fill") {
            manualMetadata.iconProvider = NSItemProvider(object: iconImage)
            // Optionally, also set imageProvider:
            // manualMetadata.imageProvider = NSItemProvider(object: iconImage)
        }
        
        // Create the RecipeLink item and append it
        let manualItem = RecipeLink(originalURL: manualURL, metadata: manualMetadata, isManuallyCreated: true)
        self.items.append(manualItem)
        self.metadataCache[manualURL] = manualMetadata // Also cache manually created metadata
        print("Added manually created item for: \(manualURL)")
    }
    
    // MARK: - Helper for Sharing
    
    func metadataForSharing(url: URL) -> LPLinkMetadata? {
        // Prioritize cache; otherwise, check the items array
        return metadataCache[url] ?? items.first { $0.originalURL == url }?.metadata
    }
}

// MARK: - SwiftUI View

struct ContentView: View {
    // Allow dependency injection for previews by exposing an initializer.
    @StateObject private var viewModel: LinkViewModel
    @State private var itemToShare: RecipeLink? // Tracks item for share sheet activation
    
    init(viewModel: LinkViewModel = LinkViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading) {
                        if let metadata = item.metadata {
                            // Use the UIViewRepresentable wrapper for LPLinkView
                            LinkViewRepresentable(metadata: metadata)
                                .frame(minHeight: 50)
                        } else {
                            // Placeholder view while metadata is loading
                            HStack {
                                ProgressView()
                                    .padding(.trailing, 5)
                                Text("Fetching: \(item.originalURL.host ?? item.originalURL.absoluteString)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            .frame(minHeight: 50)
                        }
                        
                        // Display a small note for manually created items
                        if item.isManuallyCreated {
                            Text(" (Manually Created Metadata)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .contextMenu {
                        Button {
                            itemToShare = item // Set item to share
                        } label: {
                            Label("Share Link", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .navigationTitle("Recipe Links")
            .listStyle(.plain)
            .sheet(item: $itemToShare) { item in
                // Present the share sheet with required data
                ShareSheetView(linkItem: item, viewModel: viewModel)
            }
        }
    }
}

// MARK: - LPLinkView Wrapper

struct LinkViewRepresentable: UIViewRepresentable {
    let metadata: LPLinkMetadata // Expects valid metadata
    
    func makeUIView(context: Context) -> LPLinkView {
        // Create LPLinkView with the provided metadata.
        return LPLinkView(metadata: metadata)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        // Update LPLinkView if metadata changes.
        if uiView.metadata != metadata {
            uiView.metadata = metadata
        }
    }
}

// MARK: - Share Sheet Implementation

struct ShareSheetView: UIViewControllerRepresentable {
    let linkItem: RecipeLink
    let viewModel: LinkViewModel
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create a custom item source for sharing.
        let itemSource = ShareActivityItemSource(link: linkItem, viewModel: viewModel)
        let controller = UIActivityViewController(
            activityItems: [itemSource],
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No dynamic updates required.
    }
}

// Custom UIActivityItemSource to provide rich link metadata to the share sheet.
class ShareActivityItemSource: NSObject, @preconcurrency UIActivityItemSource {
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
            print("✅ Providing pre-fetched/manual metadata to Share Sheet.")
        } else {
            print("⚠️ No metadata available for Share Sheet; default preview will be used.")
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
            // 1. Preview for Loaded Metadata State
            ContentView(viewModel: {
                let vm = LinkViewModel()
                // Override items with dummy data where metadata is available
                vm.items = [
                    RecipeLink(originalURL: URL(string: "https://www.apple.com")!,
                               metadata: dummyMetadata(title: "Apple", urlString: "https://www.apple.com"),
                               isManuallyCreated: false),
                    RecipeLink(originalURL: URL(string: "https://www.developer.apple.com")!,
                               metadata: dummyMetadata(title: "Developer Site", urlString: "https://developer.apple.com"),
                               isManuallyCreated: false)
                ]
                return vm
            }())
            .previewDisplayName("Loaded Metadata State")
            
            // 2. Preview for Loading State (metadata is nil)
            ContentView(viewModel: {
                let vm = LinkViewModel()
                vm.items = [
                    RecipeLink(originalURL: URL(string: "https://www.loading-example.com")!, metadata: nil, isManuallyCreated: false)
                ]
                return vm
            }())
            .previewDisplayName("Loading (Nil Metadata) State")
            
            // 3. Preview for Manually Created Metadata State
            ContentView(viewModel: {
                let vm = LinkViewModel()
                vm.items = [
                    RecipeLink(originalURL: URL(string: "https://my-internal-app.com/recipe/pasta-dish")!,
                               metadata: dummyMetadata(title: "Grandma's Famous Pasta (Manual)", urlString: "https://my-internal-app.com/recipe/pasta-dish"),
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
            // Preview with valid dummy metadata
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
