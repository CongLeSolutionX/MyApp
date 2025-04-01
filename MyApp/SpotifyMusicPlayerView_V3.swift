////
////  SpotifyMusicPlayerView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/1/25.
////
//
//import SwiftUI
//import UIKit // Needed for UIImage and UIActivityViewController
//import LinkPresentation // Needed for LPLinkMetadataSource
//
//// MARK: - Custom Result Builder: ItemBuilder
//
//@resultBuilder
//struct ItemBuilder {
//
//    // Combines multiple components (arrays) into a single array
//    static func buildBlock(_ components: [Any]...) -> [Any] {
//        // components is an array of arrays [[Any], [Any], ...], flatten it
//        return components.flatMap { $0 }
//    }
//
//    // Handles individual expressions (String, URL, UIImage, etc.)
//    // Wrap each expression in an array `[Any]` so buildBlock works consistently.
//    static func buildExpression(_ expression: String) -> [Any] {
//        return [expression]
//    }
//
//    static func buildExpression(_ expression: URL) -> [Any] {
//        return [expression]
//    }
//
//    // Add support for UIImages if you plan to share them
//    static func buildExpression(_ expression: UIImage) -> [Any] {
//        return [expression]
//    }
//
//    // Allow passing through existing arrays
//    static func buildExpression(_ expression: [Any]) -> [Any] {
//        return expression
//    }
//
//    // Add more buildExpression overloads for other types you need to share...
//
//    // Handles `if` statements without an `else`
//    static func buildOptional(_ component: [Any]?) -> [Any] {
//        // If the condition is true, component is the array `[Any]`, otherwise it's nil.
//        // Return the array or an empty array.
//        return component ?? []
//    }
//
//    // Handles the `if` part of an `if-else` statement
//    static func buildEither(first component: [Any]) -> [Any] {
//        return component
//    }
//
//    // Handles the `else` part of an `if-else` statement
//    static func buildEither(second component: [Any]) -> [Any] {
//        return component
//    }
//
//    // --- Optional: Add support for ForEach loops ---
//    static func buildArray(_ components: [[Any]]) -> [Any] {
//        // components is an array of arrays, one for each loop iteration. Flatten them.
//        return components.flatMap { $0 }
//    }
//}
//
//// MARK: - Music Player View
//
//struct MusicPlayerView: View {
//    // --- Constants (Replaced Hardcoded Strings/Values) ---
//    private let songTitle = "để tôi ôm em bằng giai điệu này"
//    private let artistName = "CongLeSolutionX"
//    private let songURL: URL? = URL(string: "https://open.spotify.com/track/example-track-id") // Replace with actual URL
//    private let albumArtImageName = "My-meme-microphone" // Define image name once
//    private let totalDurationSeconds: Double = 254 // Consistent duration (e.g., 4:14)
//
//    // --- State Variables ---
//    @State private var isPlaying: Bool = true // Example: Assume playing initially
//    @State private var progressValue: Double = 0.3 // Example: Progress slider value (0.0 to 1.0)
//    @State private var isLiked: Bool = true    // Example: Song is liked
//    @State private var isShuffling: Bool = true // Example: Shuffle is active
//    @State private var repeatMode: Int = 0     // Example: 0 = no repeat, 1 = repeat one, 2 = repeat all
//    @State private var isShowingShareSheet = false // State to control the share sheet
//    // Removed: `@State private var buildItems: [ItemBuilder] = []` - Was unused.
//
//    // --- Computed Display Times ---
//    var currentTime: String {
//        let current = totalDurationSeconds * progressValue
//        let minutes = Int(current) / 60
//        let seconds = Int(current) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//
//    var remainingTime: String {
//        let remaining = totalDurationSeconds * (1.0 - progressValue)
//        let minutes = Int(remaining) / 60
//        let seconds = Int(remaining) % 60
//        return String(format: "-%d:%02d", minutes, seconds)
//    }
//
//    // --- Body ---
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color(red: 0.18, green: 0.20, blue: 0.18) // Approximate dark green/grey
//                .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                Spacer(minLength: 10) // Push content down slightly
//
//                topBar
//                albumArt
//                songInfo
//                progressBar
//                playbackControls
//                bottomControls
//                lyricsSection
//
//                Spacer(minLength: 10) // Push lyrics section up slightly
//            }
//            .padding(.horizontal)
//            .foregroundColor(.white) // Default text/icon color
//        }
//        // --- Share Sheet Modifier ---
//        .sheet(isPresented: $isShowingShareSheet) {
//            // --- Use the Custom ItemBuilder ---
//            // The `buildItems` closure uses the ItemBuilder *type* directly.
//            // No instance variable needed.
//            // Removed: `var itemsToShare: [Any] = []` - Shadowed and unused.
//            let constructedItems = ItemBuilder.buildBlock { // Explicitly call buildBlock for clarity, or use the shorthand syntax below
//                // Each line here becomes an expression handled by ItemBuilder
//                ItemBuilder.buildExpression("\(songTitle) - \(artistName)")
//
//                if let url = songURL {         // buildOptional
//                    ItemBuilder.buildExpression(url) // buildExpression(URL) inside optional
//                }
//
//                // --- Example: Add image based on state ---
//                if let image = UIImage(named: albumArtImageName) { // buildOptional
//                    ItemBuilder.buildExpression(image) // buildExpression(UIImage)
//                }
//
//                // --- Example: Add multiple extra items ---
//                // ItemBuilder.buildExpression(["Extra Item 1", "Another Item"]) // buildExpression([Any])
//
//                // --- Example: Using ForEach (if buildArray implemented) ---
//                // Can't directly use ForEach here. You'd process the array *before* the builder
//                // or implement buildArray processing carefully. A simpler way:
//                // let tags = ["Tag1", "Tag2"]
//                // ItemBuilder.buildExpression(tags) // If buildExpression handles [String] -> [Any]
//
//                // Simpler way to write the builder call using the @resultBuilder syntax:
//                // let constructedItems = { @ItemBuilder () -> [Any] in // Alternative syntax
//                //     "\(songTitle) - \(artistName)"
//                //     if let url = songURL { url }
//                //     if let image = UIImage(named: albumArtImageName) { image }
//                // }() // Immediately execute the closure
//
//                // Let's stick to the clearer variable assignment from the original code structure:
//            }
//
//             // --- Use the result of the builder ---
//             // Let constructedItems = buildItems { ... } // This syntax also works concisely
//             // ... (rest of the original buildItems block logic) ...
//             let itemsToShare = { @ItemBuilder () -> [Any] in
//                 "\(songTitle) - \(artistName)"
//                 if let url = songURL { url }
//                 if let image = UIImage(named: albumArtImageName) { image }
//                 // Add other items as needed following the builder's rules
//             }() // Immediately execute the closure to get the array
//
//            // --- Return the View (Declarative) ---
//            if !itemsToShare.isEmpty {
//                ActivityViewController(activityItems: itemsToShare)
//                    .preferredColorScheme(.dark)
//                // You might want to exclude certain activity types if sharing images/complex data
//                // .excludedActivityTypes([.assignToContact, .markupAsPDF])
//            } else {
//                Text("Nothing available to share")
//                    .padding()
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                            isShowingShareSheet = false
//                        }
//                    }
//            }
//        } // <<< REMOVED Duplicate .sheet modifier block that was here
//        // .statusBar(hidden: true) // Keep commented if status bar should be visible
//    }
//
//    // MARK: - UI Components (No changes needed in these components)
//
//    private var topBar: some View {
//        HStack {
//            Button {} label: { // Placeholder Action
//                Image(systemName: "chevron.down")
//                    .font(.body.weight(.semibold))
//            }
//            Spacer()
//            Text("Liked Songs")
//                .font(.footnote.weight(.bold))
//            Spacer()
//            Button {} label: { // Placeholder Action
//                Image(systemName: "ellipsis")
//                    .font(.body.weight(.semibold))
//            }
//        }
//        .padding(.vertical, 5)
//    }
//
//    private var albumArt: some View {
//        Image(albumArtImageName) // Use defined constant
//            .resizable()
//            .aspectRatio(1.0, contentMode: .fit) // Make it square
//            .cornerRadius(8)
//            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
//            .padding(.vertical) // Add some vertical space around the art
//    }
//
//    private var songInfo: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(songTitle) // Use defined constant
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .lineLimit(1)
//                Text(artistName) // Use defined constant
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//                    .lineLimit(1)
//            }
//            Spacer()
//            Button {
//                isLiked.toggle() // Actual action
//            } label: {
//                Image(systemName: isLiked ? "checkmark.circle.fill" : "plus.circle")
//                    .font(.title2)
//                    .foregroundColor(isLiked ? .green : .white.opacity(0.7))
//            }
//        }
//    }
//
//    private var progressBar: some View {
//        VStack(spacing: 4) {
//            Slider(value: $progressValue, in: 0...1)
//                .accentColor(.white) // Color for the track to the left of the thumb
//            // NOTE: A fully custom slider might be needed for different track/thumb colors
//
//            HStack {
//                Text(currentTime)
//                Spacer()
//                Text(remainingTime)
//            }
//            .font(.caption)
//            .foregroundColor(.white.opacity(0.7))
//        }
//        .padding(.vertical)
//    }
//
//    private var playbackControls: some View {
//        HStack(spacing: 25) {
//            Button {
//                isShuffling.toggle() // Actual action
//            } label: {
//                Image(systemName: "shuffle")
//                    .font(.title2)
//                    .foregroundColor(isShuffling ? .green : .white.opacity(0.7))
//            }
//
//            Button {} label: { // Placeholder Action
//                Image(systemName: "backward.fill")
//                    .font(.title)
//                    .fontWeight(.bold)
//            }
//
//            Button {
//                isPlaying.toggle() // Actual action
//            } label: {
//                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 70, height: 70)
//                    .foregroundColor(.white)
//            }
//
//            Button {} label: { // Placeholder Action
//                Image(systemName: "forward.fill")
//                    .font(.title)
//                    .fontWeight(.bold)
//            }
//
//            Button {
//                // Cycle through repeat modes: 0 -> 1 -> 2 -> 0 (Actual action)
//                repeatMode = (repeatMode + 1) % 3
//            } label: {
//                Image(systemName: repeatMode == 1 ? "repeat.1" : "repeat")
//                    .font(.title2)
//                    .foregroundColor(repeatMode != 0 ? .green : .white.opacity(0.7))
//            }
//        }
//    }
//
//    private var bottomControls: some View {
//        HStack {
//            Button {} label: { // Placeholder Action
//                Image(systemName: "hifispeaker.and.appletv")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            Spacer()
//            Button {
//                isShowingShareSheet = true // Trigger share sheet
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            .padding(.trailing, 5) // Keep padding with share button
//
//            Button {} label: { // Placeholder Placeholder Action (Original had list.bullet here, Lyric section has share now)
//                 // Original Button was list.bullet. The Lyrics section now contains the share button.
//                 // Decide if another button is needed here or remove. Keeping placeholder image.
//                 Image(systemName: "list.bullet") // Placeholder, adjust as needed
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//        }
//        .padding(.top, 10)
//    }
//
//    private var lyricsSection: some View {
//        HStack {
//            Text("Lyrics")
//                .font(.headline)
//                .fontWeight(.bold)
//
//            Spacer()
//
//            // Moved Share button from bottomControls to here for semantics
//            Button {
//                isShowingShareSheet = true // Actual Action
//            } label: {
//                Image(systemName: "square.and.arrow.up")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            .padding(.trailing, 5) // Keep padding
//
//            Button {} label: { // Placeholder Action (Expand lyrics?)
//                Image(systemName: "arrow.up.left.and.arrow.down.right")
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white.opacity(0.1))
//        )
//        .padding(.top)
//    }
//}
//
//// MARK: - Share Sheet Wrapper (ActivityViewController)
//
//struct ActivityViewController: UIViewControllerRepresentable {
//
//    var activityItems: [Any]
//    var applicationActivities: [UIActivity]? = nil
//    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
//
//    // Required: Creates the UIViewController instance
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(
//            activityItems: activityItems,
//            applicationActivities: applicationActivities
//        )
//        controller.excludedActivityTypes = excludedActivityTypes
//        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
//            // Handle completion or errors if needed
//            print("Share sheet completed: \(completed), Activity: \(activityType?.rawValue ?? "none")")
//            if let error = error {
//                print("Error sharing: \(error.localizedDescription)")
//            }
//        }
//        // Set the coordinator to provide link metadata
//        controller.activityItemsConfiguration = context.coordinator
//        return controller
//    }
//
//    // Required: Updates the controller (often not needed for simple cases)
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No update typically needed unless activityItems/excluded types change dynamically.
//    }
//
//    // MARK: - Coordinator for UIActivityItemSource and LPLinkMetadataSource
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // Coordinator now conforms to UIActivityItemsConfigurationReading for modern iOS
//    // and still implements UIActivityItemSource methods for compatibility / explicit control
//    // and LPLinkMetadataSource for rich URL previews.
//    class Coordinator: NSObject, UIActivityItemsConfigurationReading, LPLinkMetadataSource { // Conform to the newer protocol
//
//        var parent: ActivityViewController
//        private var linkMetadata: LPLinkMetadata? // Cache metadata
//
//        init(_ parent: ActivityViewController) {
//            self.parent = parent
//            super.init()
//            self.linkMetadata = self.createLinkMetadata() // Pre-generate metadata
//        }
//
//        // --- UIActivityItemsConfigurationReading ---
//        var itemProvidersForActivityItemsConfiguration: [NSItemProvider] {
//            // Convert activityItems to NSItemProviders
//             return parent.activityItems.compactMap { item -> NSItemProvider? in
//                // Handle specific types if needed for better provider representation
//                if let string = item as? String {
//                    return NSItemProvider(object: string as NSString)
//                } else if let url = item as? URL {
//                    // Provide both URL and potentially pre-fetched metadata
//                    let provider = NSItemProvider(object: url as NSURL)
//                    if #available(iOS 13.0, *) {
//                         provider.registerObject(linkMetadata ?? LPLinkMetadata(), visibility: .all)
//                    }
//                   return provider
//                } else if let image = item as? UIImage {
//                    return NSItemProvider(object: image)
//                }
//                // Add other type conversions as needed
//                return nil // Or a default provider if possible
//            }
//        }
//
//         // Provides metadata directly for the configuration (preferred iOS 13+)
//        @available(iOS 13.0, *)
//        var applicationActivitiesForActivityItemsConfiguration: [UIActivity]? {
//            return parent.applicationActivities
//        }
//
//        // --- LPLinkMetadataSource Implementation ---
//        @available(iOS 13.0, *)
//        func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//            // Return the pre-generated or cached metadata
//            return self.linkMetadata
//         }
//
//        // Helper to create metadata
//        @available(iOS 13.0, *)
//        private func createLinkMetadata() -> LPLinkMetadata? {
//             guard let url = parent.activityItems.first(where: { $0 is URL }) as? URL else {
//                 return nil // Only provide metadata if a URL is being shared
//             }
//
//             let metadata = LPLinkMetadata()
//             metadata.url = url
//             metadata.originalURL = url
//
//             // Attempt to infer title from shared items
//              if let title = parent.activityItems.first(where: { $0 is String }) as? String {
//                  metadata.title = title
//              } else {
//                  metadata.title = "Shared Content" // Generic fallback
//              }
//
//             // Attempt to set icon/image from shared items
//             if let image = parent.activityItems.first(where: { $0 is UIImage }) as? UIImage {
//                  // Use NSItemProvider for the image data
//                  metadata.imageProvider = NSItemProvider(object: image)
//                 // metadata.iconProvider = NSItemProvider(object: image) // Can use same for icon
//             }
//
//             return metadata
//         }
//
//         // --- UIActivityItemSource (Still useful / fallback) ---
//         // Placeholder for the actual data
//         func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//             return parent.activityItems.first ?? "" // Simple placeholder
//         }
//
//         // The actual item data to be shared per activity type
//         func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//             // Default: return the first item. Can customize per activity type.
//             return parent.activityItems.first
//         }
//
//        // Subject line for email
//        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
//            // Try to find a string item to use as a subject
//            return parent.activityItems.first(where: { $0 is String }) as? String ?? "Check this out"
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct MusicPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicPlayerView()
//            .preferredColorScheme(.dark) // Preview in dark mode
//        // NOTE: Add an image named "My-meme-microphone" to your Assets.xcassets
//    }
//}
//
//// NOTE: For the slider styling (thumb color, track color on the right),
//// a fully custom implementation might be needed beyond the standard SwiftUI Slider.
