////
////  LinkView.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//import LinkPresentation
//import UIKit // Needed for UIActivityItemSource, UIImage, UIActivityViewController
//
//// --- Data Model ---
//struct RecipeLink: Identifiable {
//    let id = UUID()
//    let originalURL: URL
//    var metadata: LPLinkMetadata? // Store fetched/created metadata
//    var isManuallyCreated: Bool = false // Flag for demo purposes
//}
//
//// --- ViewModel ---
//@MainActor // Ensures @Published updates happen on the main thread
//class LinkViewModel: ObservableObject {
//    @Published var items: [RecipeLink] = []
//    private var metadataCache: [URL: LPLinkMetadata] = [:] // Simple in-memory cache
//    private let metadataProvider = LPMetadataProvider()
//
//    init() {
//        // 1. Populate with placeholder URLs
//        let urls = [
//            URL(string: "https://www.apple.com")!,
//            URL(string: "https://developer.apple.com/tutorials/swiftui")!,
//            URL(string: "https://www.hackingwithswift.com")!,
//            URL(string: "https://example.com/this-page-might-not-exist")!, // To test potential failure
//            // Placeholder for local file - replace with a valid path on your simulator/device if testing
//            // URL(fileURLWithPath: Bundle.main.path(forResource: "YourDocument", ofType: "pdf") ?? "/invalid/path")
//        ]
//        self.items = urls.map { RecipeLink(originalURL: $0) }
//
//        // 2. Fetch metadata for initial items
//        fetchAllMetadata()
//
//        // 3. Add an item with manually created metadata
//        addManualItem()
//    }
//
//    // --- Metadata Fetching ---
//    func fetchAllMetadata() {
//        for index in items.indices {
//            // Check cache before fetching
//            if let cachedMetadata = metadataCache[items[index].originalURL] {
//                print("Cache hit for: \(items[index].originalURL)")
//                items[index].metadata = cachedMetadata
//                continue // Skip fetching if cached
//            }
//
//            // Fetch metadata if not in cache
//            fetchMetadata(for: items[index].originalURL, at: index)
//        }
//    }
//
//    private func fetchMetadata(for url: URL, at index: Int) {
//        print("Starting fetch for: \(url)")
//
//        // LPMetadataProvider handles both web URLs and local file URLs
//        metadataProvider.startFetchingMetadata(for: url) { [weak self] fetchedMetadata, error in
//            // Ensure updates happen on the main thread
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//
//                // Check if the item still exists at the index (list might have changed)
//                guard self.items.indices.contains(index), self.items[index].originalURL == url else {
//                    print("Item at index \(index) changed before fetch completed for \(url)")
//                    return
//                }
//
//                if let error = error {
//                    print("❌ Failed to fetch metadata for \(url): \(error.localizedDescription)")
//                    // Optionally create basic fallback metadata here
//                    self.items[index].metadata = self.createFallbackMetadata(for: url)
//                    self.metadataCache[url] = self.items[index].metadata // Cache fallback too
//                    return
//                }
//
//                if let metadata = fetchedMetadata {
//                    print("✅ Successfully fetched metadata for \(url)")
//                    self.items[index].metadata = metadata
//                    self.metadataCache[url] = metadata // Cache the successful result
//                } else {
//                     print("⚠️ Fetch completed but no metadata returned for \(url)")
//                     self.items[index].metadata = self.createFallbackMetadata(for: url)
//                     self.metadataCache[url] = self.items[index].metadata
//                }
//            }
//        }
//    }
//
//    // Simple fallback metadata if fetch fails
//    private func createFallbackMetadata(for url: URL) -> LPLinkMetadata {
//         let fallbackMetadata = LPLinkMetadata()
//         fallbackMetadata.originalURL = url
//         fallbackMetadata.url = url
//         fallbackMetadata.title = url.host ?? url.absoluteString // Use host or full URL as title
//         // You could add a placeholder icon here too
//         return fallbackMetadata
//    }
//
//    // --- Manual Metadata Creation ---
//    private func addManualItem() {
//        let manualURL = URL(string: "https://my-internal-app.com/recipe/pasta-dish")!
//        let manualMetadata = LPLinkMetadata()
//
//        // ** Essential: Set originalURL and url **
//        manualMetadata.originalURL = manualURL
//        manualMetadata.url = manualURL
//
//        // *** Populate with your existing data ***
//        manualMetadata.title = "Grandma's Famous Pasta (Manual)"
//
//        // Example: Adding an icon (using an SF Symbol)
//        if let iconImage = UIImage(systemName: "fork.knife.circle.fill") {
//            manualMetadata.iconProvider = NSItemProvider(object: iconImage)
//            // To provide an image instead (or also):
//            // manualMetadata.imageProvider = NSItemProvider(object: iconImage)
//        }
//
//        // Create the RecipeLink item and add it
//        let manualItem = RecipeLink(originalURL: manualURL, metadata: manualMetadata, isManuallyCreated: true)
//        self.items.append(manualItem)
//        self.metadataCache[manualURL] = manualMetadata // Also cache manually created items
//        print("Added manually created item for: \(manualURL)")
//    }
//
//    // --- Helper for Sharing ---
//    func metadataForSharing(url: URL) -> LPLinkMetadata? {
//        // Prioritize cache, then check the items array
//        return metadataCache[url] ?? items.first { $0.originalURL == url }?.metadata
//    }
//}
//
//// --- SwiftUI View ---
//struct ContentView: View {
//    @StateObject private var viewModel = LinkViewModel()
//    @State private var itemToShare: RecipeLink? // Track item for activating share sheet
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(viewModel.items) { item in
//                    VStack(alignment: .leading) {
//                        if item.metadata != nil {
//                            // Use the UIViewRepresentable wrapper
//                            LinkViewRepresentable(metadata: item.metadata)
//                                // Give it a minimum height, LPLinkView usually sizes itself well
//                                .frame(minHeight: 50)
//
//                        } else {
//                            // --- Placeholder View while loading ---
//                            HStack {
//                                ProgressView()
//                                    .padding(.trailing, 5)
//                                Text("Fetching: \(item.originalURL.host ?? item.originalURL.absoluteString)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                    .lineLimit(1)
//                            }
//                            .frame(minHeight: 50) // Maintain similar height
//                        }
//
//                        // Optional: Add a small note for manually created items
//                        if item.isManuallyCreated {
//                            Text(" (Manually Created Metadata)")
//                                .font(.caption2)
//                                .foregroundColor(.orange)
//                        }
//                    }
//                    .contentShape(Rectangle()) // Make list row tappable for context menu
//                    .contextMenu {
//                         Button {
//                             itemToShare = item // Set the item to share
//                         } label: {
//                             Label("Share Link", systemImage: "square.and.arrow.up")
//                         }
//                     }
//                }
//            }
//            .navigationTitle("Recipe Links")
//            .listStyle(.plain)
//             // --- Share Sheet Presentation ---
//            .sheet(item: $itemToShare) { item in
//                 // Pass necessary data to the share sheet representable
//                 ShareSheetView(linkItem: item, viewModel: viewModel)
//             }
//        }
//        // On iOS 16+ you can use NavigationStack for better programmatic control
//    }
//}
//
//// --- LPLinkView Wrapper ---
//struct LinkViewRepresentable: UIViewRepresentable {
//    var metadata: LPLinkMetadata? // Accepts optional metadata
//
//    func makeUIView(context: Context) -> LPLinkView {
//        guard let metadata = metadata else {
//             // If metadata is nil (e.g., during initial load before fetch completes),
//             // return an empty view. The viewModel should provide metadata eventually.
//            return LPLinkView()
//        }
//        // Create the view with the provided metadata
//        return LPLinkView(metadata: metadata)
//    }
//
//    func updateUIView(_ uiView: LPLinkView, context: Context) {
//        // Update the metadata if it changes. This ensures the view reflects
//        // the latest state if the representable is reused or state changes.
//        if let newMetadata = metadata, uiView.metadata != newMetadata {
//            uiView.metadata = newMetadata
//        }
//        // If metadata becomes nil after being set, you might want to clear the view,
//        // but often the ViewModel manages the presence of the view itself.
//    }
//}
//
//// --- Share Sheet Implementation ---
//
//// 1. UIViewControllerRepresentable to present the UIActivityViewController
//struct ShareSheetView: UIViewControllerRepresentable {
//    let linkItem: RecipeLink
//    let viewModel: LinkViewModel // Needed to fetch metadata via ItemSource
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        // Create the custom ItemSource
//        let itemSource = ShareActivityItemSource(link: linkItem, viewModel: viewModel)
//
//        // Pass the ItemSource itself as the activity item.
//        // The system will then query it using the protocol methods.
//        let controller = UIActivityViewController(
//            activityItems: [itemSource], // Crucial: Pass the ItemSource object
//            applicationActivities: nil
//        )
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No update typically needed here
//    }
//}
//
//// 2. Custom UIActivityItemSource
//class ShareActivityItemSource: NSObject, @preconcurrency UIActivityItemSource {
//    let link: RecipeLink
//    // Keep a reference to the ViewModel to get the potentially updated metadata
//    weak var viewModel: LinkViewModel?
//
//    init(link: RecipeLink, viewModel: LinkViewModel) {
//        self.link = link
//        self.viewModel = viewModel
//        super.init()
//    }
//
//    // --- Required UIActivityItemSource Methods ---
//
//    // Provides a placeholder while the actual data loads (or for certain previews)
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        // Return the URL or a simple string. URL is often best.
//        return link.originalURL
//    }
//
//    // Provides the actual data item to be shared for a specific activity type
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        // Usually, you return the primary piece of data, which is the URL.
//        // You *could* customize this (e.g., return just text for SMS), but
//        // returning the URL is generally the most versatile.
//        return link.originalURL
//    }
//
//    // --- The Key Method for Rich Link Previews ---
//    // Provides the LPLinkMetadata to the Share Sheet
//    @MainActor func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//        print("Share Sheet requesting metadata for: \(link.originalURL)")
//        // Fetch the *latest* metadata from the ViewModel's cache or the item itself
//        guard let vm = viewModel else {
//             print("ViewModel reference lost, cannot provide metadata.")
//             return link.metadata // Fallback to potentially stale item metadata
//        }
//
//        let metadata = vm.metadataForSharing(url: link.originalURL)
//
//        if metadata != nil {
//            print("✅ Providing pre-fetched/manual metadata to Share Sheet.")
//        } else {
//            print("⚠️ No metadata available for Share Sheet; it will fetch default preview.")
//        }
//        return metadata
//    }
//}
//
//// --- App Entry Point ---
//@main
//struct RichLinksApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
