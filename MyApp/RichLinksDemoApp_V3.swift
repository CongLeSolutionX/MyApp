////
////  RichLinksDemoApp_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
////
////  LinkView.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//import LinkPresentation
//import UIKit
//
//// MARK: - Data Model
//
//struct RecipeLink: Identifiable {
//    let id = UUID()
//    let originalURL: URL
//    var metadata: LPLinkMetadata? // Store locally loaded metadata
//    var isManuallyCreated: Bool = false // Flag for demo purposes
//}
//
//// MARK: - Local Metadata Model
//
///*
// Example metadata.json structure:
// [
//   {
//     "originalURL": "https://www.apple.com",
//     "title": "Apple Official Site",
//     "subtitle": "The Official Homepage for Apple",
//     "summary": "Apple is known for its innovative technology…",
//     "iconName": "apple_icon",           // Optional: name of a local asset (for iconProvider)
//     "imageURL": "https://www.apple.com/ac/structured-data/images/open_graph_logo.png?202307141322",
//     "remoteVideoURL": null,
//     "localImageAsset": "apple_local_image"  // Optional: name of a local asset for richer preview
//   },
//   {
//     "originalURL": "https://developer.apple.com/tutorials/swiftui",
//     "title": "SwiftUI Tutorials",
//     "subtitle": null,
//     "summary": null,
//     "iconName": null,
//     "imageURL": null,
//     "remoteVideoURL": null,
//     "localImageAsset": null
//   }
// ]
//*/
//
//private struct LocalMetadata: Codable {
//    let originalURL: String
//    let title: String
//    // Additional optional fields for expansion
//    let subtitle: String?
//    let summary: String?
//    let iconName: String?           // Name of a local asset for the iconProvider
//    let imageURL: String?           // Remote image URL (if any)
//    let remoteVideoURL: String?
//    let localImageAsset: String?    // New field: name of a local image asset to use for the preview
//}
//
//// MARK: - ViewModel
//
//@MainActor
//class LinkViewModel: ObservableObject {
//    @Published var items: [RecipeLink] = []
//    private var metadataCache: [URL: LPLinkMetadata] = [:] // In-memory cache of LPLinkMetadata
//    
//    // Holds local metadata loaded from JSON (keyed by originalURL string)
//    private var localMetadataDictionary: [String: LocalMetadata] = [:]
//    
//    init() {
//        // 1. Populate with placeholder URLs
//        let urls = [
//            URL(string: "https://www.apple.com")!,
//            URL(string: "https://developer.apple.com/tutorials/swiftui")!,
//            URL(string: "https://www.hackingwithswift.com")!,
//            URL(string: "https://example.com/this-page-might-not-exist")!
//            // Add more URLs as needed.
//        ]
//        self.items = urls.map { RecipeLink(originalURL: $0) }
//        
//        // 2. Load local metadata from JSON.
//        loadLocalMetadataFromJSON()
//        
//        // 3. Update each item with loaded metadata if available.
//        updateItemsWithLocalMetadata()
//        
//        // 4. Add an item with manually created metadata.
//        addManualItem()
//    }
//    
//    private func loadLocalMetadataFromJSON() {
//        guard let url = Bundle.main.url(forResource: "metadata", withExtension: "json") else {
//            print("❌ Could not locate metadata.json in bundle.")
//            return
//        }
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = JSONDecoder()
//            let localMetadataArray = try decoder.decode([LocalMetadata].self, from: data)
//            for meta in localMetadataArray {
//                localMetadataDictionary[meta.originalURL] = meta
//            }
//            print("✅ Successfully loaded local metadata from JSON.")
//        } catch {
//            print("❌ Failed to load local metadata: \(error.localizedDescription)")
//        }
//    }
//    
//    private func updateItemsWithLocalMetadata() {
//        for index in items.indices {
//            let urlString = items[index].originalURL.absoluteString
//            if let localMeta = localMetadataDictionary[urlString] {
//                let lpMetadata = createLPLinkMetadata(from: localMeta)
//                items[index].metadata = lpMetadata
//                metadataCache[items[index].originalURL] = lpMetadata
//                print("✅ Assigned local metadata for: \(urlString)")
//            } else {
//                let fallback = createFallbackMetadata(for: items[index].originalURL)
//                items[index].metadata = fallback
//                metadataCache[items[index].originalURL] = fallback
//                print("⚠️ No local metadata found for: \(urlString); fallback applied.")
//            }
//        }
//    }
//    
//    // Converts a LocalMetadata instance into a fully configured LPLinkMetadata.
//    private func createLPLinkMetadata(from localMeta: LocalMetadata) -> LPLinkMetadata {
//        let lpMetadata = LPLinkMetadata()
//        if let url = URL(string: localMeta.originalURL) {
//            lpMetadata.originalURL = url
//            lpMetadata.url = url
//        }
//        lpMetadata.title = localMeta.title
//        
//        // Set iconProvider if a local asset is referenced.
//        if let iconName = localMeta.iconName,
//           let iconImage = UIImage(named: iconName) {
//            lpMetadata.iconProvider = NSItemProvider(object: iconImage)
//        }
//        
//        // Configure imageProvider from remote URL if available.
//        if let imageURLString = localMeta.imageURL, let imageURL = URL(string: imageURLString) {
//            lpMetadata.imageProvider = NSItemProvider(contentsOf: imageURL)
//        }
//        
//        // Use the new localImageAsset field to supply local image content.
//        if let localAssetName = localMeta.localImageAsset,
//           let localImage = UIImage(named: localAssetName) {
//            lpMetadata.imageProvider = NSItemProvider(object: localImage)
//        }
//        
//        // Set remote video URL if present.
//        if let videoURLString = localMeta.remoteVideoURL, let remoteURL = URL(string: videoURLString) {
//            lpMetadata.remoteVideoURL = remoteURL
//        }
//        
//        // Note: subtitle and summary are not part of LPLinkMetadata. They could be stored separately if needed.
//        return lpMetadata
//    }
//    
//    private func createFallbackMetadata(for url: URL) -> LPLinkMetadata {
//        let fallback = LPLinkMetadata()
//        fallback.originalURL = url
//        fallback.url = url
//        fallback.title = url.host ?? url.absoluteString
//        return fallback
//    }
//    
//    private func addManualItem() {
//        let manualURL = URL(string: "https://my-internal-app.com/recipe/pasta-dish")!
//        let manualMetadata = LPLinkMetadata()
//        manualMetadata.originalURL = manualURL
//        manualMetadata.url = manualURL
//        manualMetadata.title = "Grandma's Famous Pasta (Manual)"
//        if let iconImage = UIImage(systemName: "fork.knife.circle.fill") {
//            manualMetadata.iconProvider = NSItemProvider(object: iconImage)
//        }
//        let manualItem = RecipeLink(originalURL: manualURL, metadata: manualMetadata, isManuallyCreated: true)
//        self.items.append(manualItem)
//        metadataCache[manualURL] = manualMetadata
//        print("✅ Added manually created item for: \(manualURL)")
//    }
//    
//    func metadataForSharing(url: URL) -> LPLinkMetadata? {
//        return metadataCache[url] ?? items.first { $0.originalURL == url }?.metadata
//    }
//}
//
//// MARK: - SwiftUI View
//
//struct ContentView: View {
//    @StateObject private var viewModel = LinkViewModel()
//    @State private var itemToShare: RecipeLink? // Activates the share sheet
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(viewModel.items) { item in
//                    VStack(alignment: .leading) {
//                        if let metadata = item.metadata {
//                            LinkViewRepresentable(metadata: metadata)
//                                .frame(minHeight: 50)
//                        } else {
//                            HStack {
//                                ProgressView()
//                                    .padding(.trailing, 5)
//                                Text("Loading: \(item.originalURL.host ?? item.originalURL.absoluteString)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                    .lineLimit(1)
//                            }
//                            .frame(minHeight: 50)
//                        }
//                        
//                        if item.isManuallyCreated {
//                            Text(" (Manually Created Metadata)")
//                                .font(.caption2)
//                                .foregroundColor(.orange)
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .contextMenu {
//                        Button {
//                            itemToShare = item
//                        } label: {
//                            Label("Share Link", systemImage: "square.and.arrow.up")
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Recipe Links")
//            .listStyle(.plain)
//            .sheet(item: $itemToShare) { item in
//                ShareSheetView(linkItem: item)
//                    .environmentObject(viewModel)
//            }
//        }
//    }
//}
//
//// MARK: - LPLinkView Wrapper
//
//struct LinkViewRepresentable: UIViewRepresentable {
//    let metadata: LPLinkMetadata
//    
//    func makeUIView(context: Context) -> LPLinkView {
//        return LPLinkView(metadata: metadata)
//    }
//    
//    func updateUIView(_ uiView: LPLinkView, context: Context) {
//        if uiView.metadata != metadata {
//            uiView.metadata = metadata
//        }
//    }
//}
//
//// MARK: - Share Sheet Implementation
//
//struct ShareSheetView: UIViewControllerRepresentable {
//    let linkItem: RecipeLink
//    @EnvironmentObject var viewModel: LinkViewModel
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let itemSource = ShareActivityItemSource(link: linkItem, viewModel: viewModel)
//        let controller = UIActivityViewController(
//            activityItems: [itemSource],
//            applicationActivities: nil
//        )
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
//}
//
//class ShareActivityItemSource: NSObject, @preconcurrency UIActivityItemSource {
//    let link: RecipeLink
//    weak var viewModel: LinkViewModel?
//    
//    init(link: RecipeLink, viewModel: LinkViewModel) {
//        self.link = link
//        self.viewModel = viewModel
//        super.init()
//    }
//    
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        return link.originalURL
//    }
//    
//    func activityViewController(_ activityViewController: UIActivityViewController,
//                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        return link.originalURL
//    }
//    
//    @MainActor func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//        print("Share Sheet requesting metadata for: \(link.originalURL)")
//        let metadata = viewModel?.metadataForSharing(url: link.originalURL) ?? link.metadata
//        if metadata != nil {
//            print("✅ Providing local metadata to Share Sheet.")
//        } else {
//            print("⚠️ No metadata available; fallback will be used.")
//        }
//        return metadata
//    }
//}
//
//// MARK: - Dummy Metadata Helper (for Previews)
//
//func dummyMetadata(title: String, urlString: String = "https://www.example.com") -> LPLinkMetadata {
//    let metadata = LPLinkMetadata()
//    let url = URL(string: urlString)!
//    metadata.originalURL = url
//    metadata.url = url
//    metadata.title = title
//    return metadata
//}
//
//// MARK: - Previews
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            // Loaded Metadata state preview
//            ContentView()
//                .environmentObject({
//                    let vm = LinkViewModel()
//                    vm.items = [
//                        RecipeLink(originalURL: URL(string: "https://www.apple.com")!,
//                                   metadata: dummyMetadata(title: "Apple", urlString: "https://www.apple.com"),
//                                   isManuallyCreated: false),
//                        RecipeLink(originalURL: URL(string: "https://developer.apple.com")!,
//                                   metadata: dummyMetadata(title: "Developer Site", urlString: "https://developer.apple.com"),
//                                   isManuallyCreated: false)
//                    ]
//                    return vm
//                }())
//                .previewDisplayName("Loaded Metadata State")
//            
//            // Loading state preview (nil metadata)
//            ContentView()
//                .environmentObject({
//                    let vm = LinkViewModel()
//                    vm.items = [
//                        RecipeLink(originalURL: URL(string: "https://www.loading-example.com")!, metadata: nil, isManuallyCreated: false)
//                    ]
//                    return vm
//                }())
//                .previewDisplayName("Loading (Nil Metadata) State")
//            
//            // Manually Created Metadata state preview
//            ContentView()
//                .environmentObject({
//                    let vm = LinkViewModel()
//                    vm.items = [
//                        RecipeLink(originalURL: URL(string: "https://my-internal-app.com/recipe/pasta-dish")!,
//                                   metadata: dummyMetadata(title: "Grandma's Famous Pasta (Manual)", urlString: "https://my-internal-app.com/recipe/pasta-dish"),
//                                   isManuallyCreated: true)
//                    ]
//                    return vm
//                }())
//                .previewDisplayName("Manually Created State")
//        }
//    }
//}
//
//struct LinkViewRepresentable_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            LinkViewRepresentable(metadata: dummyMetadata(title: "Preview LPLinkView"))
//                .previewLayout(.sizeThatFits)
//                .padding()
//                .previewDisplayName("LinkViewRepresentable – Loaded")
//        }
//    }
//}
//    
//// MARK: - App Entry Point
//
//@main
//struct RichLinksApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
