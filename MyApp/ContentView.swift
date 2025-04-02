//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI
import UniformTypeIdentifiers // Needed for UTType and .fileExporter

// MARK: - Data Models (Examples)

struct Museum: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String

    func matches(_ searchString: String) -> Bool {
        if searchString.isEmpty { return true } // Show all if search is empty in this simple example
        return name.localizedCaseInsensitiveContains(searchString) || address.localizedCaseInsensitiveContains(searchString)
    }

    static let favorites = [
        Museum(name: "Louvre Museum", address: "Paris, France"),
        Museum(name: "Metropolitan Museum of Art", address: "New York, USA")
    ]

    static func allMatching(_ searchString: String) async -> [Museum] {
        // Simulate async search
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds delay
        let all = [
            Museum(name: "British Museum", address: "London, UK"),
            Museum(name: "Prado Museum", address: "Madrid, Spain"),
            Museum(name: "Rijksmuseum", address: "Amsterdam, Netherlands")
        ] + favorites
        return all.filter { $0.matches(searchString) }
    }
}

// Simple document for file exporter example
struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .utf8PlainText] }
    static var writableContentTypes: [UTType] { [.plainText, .png, .jpeg] } // Added image types for demo

    var text: String

    init(initialText: String = "Hello, SwiftUI!") {
        self.text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    // Simplified file wrapper generation
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
         // Normally you'd check configuration.contentType here to save correctly
         // For simplicity, always saving as text
         let data = Data(text.utf8)
         return FileWrapper(regularFileWithContents: data)

         // A more complete version would handle PNG/JPEG based on configuration.contentType
         // if configuration.contentType == .png { /* Create PNG data */ }
         // else if configuration.contentType == .jpeg { /* Create JPEG data */ }
    }
}

enum SortOrder: CaseIterable, Identifiable {
    case name, date
    var id: Self { self }
    var title: String {
        switch self {
        case .name: return "Name"
        case .date: return "Date"
        }
    }
}

// MARK: - Main ContentView

struct ContentView: View {
    // State for various interactive examples
    @State private var useGroups: Bool = false
    @State private var sortOrder: SortOrder = .name
    @State private var isExpanded: Bool = false
    @State private var animateSymbol: Bool = false
    @State private var showSymbolBadge: Bool = false
    @State private var showFileExporter: Bool = false
    @State private var document = TextDocument()
    @State private var searchText: String = ""
    @State private var searchSuggestions: [Museum] = []
    @State private var showDownloadsToolbarItem: Bool = false // Simulates dynamically hidden toolbar item
    @State private var showImagePlaygroundSheet: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // --- System Intelligence Features (Mention) ---
                Section("System Intelligence (Automatic/Adoption Needed)") {
                    Text("Writing Tools (spelling, grammar, structure, tone) are largely automatic in standard text views.")
                        .font(.caption)
                    Text("Genmoji adoption involves handling inline images within text storage and display.")
                        .font(.caption)
                    // Example of Text with inline image (like Genmoji)
                    Text("Express yourself! \(Image(systemName: "face.smiling.inverse")) ") + Text("Here's an AttributedString.").foregroundColor(.blue)

                }

                // --- Image Playground ---
                Section("Image Playground (Concept Demo)") {
                    Button("Create Image with Image Playground") {
                        showImagePlaygroundSheet = true
                    }
                    .sheet(isPresented: $showImagePlaygroundSheet) {
                        ImagePlaygroundPlaceholderView()
                    }
                    Text("This button simulates presenting the Image Playground view controller. On iOS, this might be a custom implementation or a future system feature.")
                        .font(.caption)
                }

                // --- SwiftUI Integration Examples ---
                Section("SwiftUI Integration") {
                    // Simulates NSHostingMenu concept using standard SwiftUI Menu
                    Menu("Actions Menu (SwiftUI)") {
                        Toggle("Use Groups", isOn: $useGroups)
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(SortOrder.allCases) { Text($0.title) }
                        }
                        Button("Customize View…") { /* Action */ }
                    }
                    
                    // Simulates NSAnimationContext + NSView using SwiftUI Animation
                    VStack {
                        Text("SwiftUI Animations")
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.blue)
                            .frame(width: isExpanded ? 150 : 100, height: 50)
                            // Apply animation modifier - equivalent to NSAnimationContext usage
                            .animation(.spring(duration: 0.4), value: isExpanded)
                        Button(isExpanded ? "Shrink" : "Expand") {
                            isExpanded.toggle()
                        }
                    }
                    .padding(.vertical)
                }

                // --- AppKit API Refinements (iOS/SwiftUI Equivalents) ---
                Section("API Refinements (iOS/SwiftUI Style)") {

                    // Context Menus (iOS Long Press)
                    Text("Long press for Context Menu")
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .contextMenu {
                            Button { /* Action */ } label: {
                                Label("Share Item", systemImage: "square.and.arrow.up")
                            }
                            Button { /* Action */ } label: {
                                Label("Edit Item", systemImage: "pencil")
                            }
                            Button(role: .destructive) { /* Action */ } label: {
                                Label("Delete Item", systemImage: "trash")
                            }
                        }

                    // Text Highlighting (Display using AttributedString)
                     Text(highlightedText())
                        .padding(.vertical)

                    // SF Symbols 6 Features
                    VStack(alignment: .leading) {
                        Text("SF Symbols Effects & Playback")
                        HStack {
                            Image(systemName: "bell.fill")
                                .symbolEffect(.wiggle, isActive: animateSymbol)
                            Image(systemName: "arrow.clockwise.heart.fill")
                                .symbolEffect(.rotate, isActive: animateSymbol)
                            Image(systemName: "wifi")
                                // Repeating effect example
                                .symbolEffect(.breathe, options: .repeat(3).speed(0.5), isActive: animateSymbol)
                             Image(systemName: "mic.fill")
                                // Continuous effect example
                                .symbolEffect(.pulse, options: .repeat(.continuous), isActive: animateSymbol)

                        }
                        // Magic Replace Example
                         VStack {
                             Text("Magic Replace (Badge)")
                             Image(systemName: showSymbolBadge ? "person.fill.badge.plus" : "person.fill")
                                 .contentTransition(.symbolEffect(.replace)) // Magic Replace Transition
                         }
                         .padding(.top)

                        HStack {
                            Button(animateSymbol ? "Stop Effects" : "Play Effects") {
                                animateSymbol.toggle()
                            }
                             Button(showSymbolBadge ? "Hide Badge" : "Show Badge") {
                                showSymbolBadge.toggle()
                            }
                        }
                    }.padding(.vertical)

                    // Save Panel -> File Exporter
                    Button("Export Document...") {
                        // Prepare document if needed
                        document.text = "Exported content at \(Date())"
                        showFileExporter = true
                    }
                    .fileExporter(
                        isPresented: $showFileExporter,
                        document: document,
                        contentType: .plainText, // Default type
                        // Can offer multiple types viaUTType array and customize UI elsewhere
                        // Example: defaultFilename: "MyExportedData"
                        onCompletion: { result in
                            switch result {
                            case .success(let url):
                                print("Saved to \(url)")
                            case .failure(let error):
                                print("Failed to save: \(error.localizedDescription)")
                            }
                        }
                    )
                    Text("Uses .fileExporter, the SwiftUI equivalent for saving/exporting user data. Format selection (like PNG/JPG in the example) would typically happen *before* triggering the exporter or within a custom document type.")
                        .font(.caption)

                    // Text Entry Suggestions -> .searchable
                    // Note: .searchable goes on NavigationStack/NavigationView
                }
            }
            .navigationTitle("AppKit Features (iOS Style)")
            // Toolbar Example (NSToolbar -> SwiftUI Toolbar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Simulates a toolbar item that can be hidden
                    if showDownloadsToolbarItem {
                        Button {
                            // Action for downloads
                        } label: {
                            Label("Downloads", systemImage: "arrow.down.circle")
                        }
                         .transition(.opacity.animation(.easeInOut)) // Nice fade
                    }

                    Button {
                        showDownloadsToolbarItem.toggle() // Toggle visibility
                    } label: {
                        Label(showDownloadsToolbarItem ? "Hide Downloads" : "Show Downloads",
                              systemImage: showDownloadsToolbarItem ? "eye.slash" : "eye")
                    }

                    Button {
                        // Regular action
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    // Simulates allowsDisplayModeCustomization = true by default nature of toolbars
                 }
            }
            // Text Entry Suggestions (NSTextField Delegate -> .searchable)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Museums") {
                // Suggestions View
                ForEach(searchSuggestions) { museum in
                    VStack(alignment: .leading) {
                        Text(museum.name).bold()
                        Text(museum.address).font(.caption)
                    }
                    // On tap/selection, you'd typically navigate or update state
                    .searchCompletion(museum.name) // Fill search bar on tap
                }
            }
            .onChange(of: searchText) { oldValue, newValue in
                // Trigger suggestion loading (sync/async)
                // Simulating the delegate `provideUpdatedSuggestions`
                Task {
                    await updateSearchSuggestions(for: newValue)
                }
            }
        }
    }

    // Helper for Text Highlighting Example
    func highlightedText() -> AttributedString {
        var attributedString = AttributedString("This text demonstrates highlighting using AttributedString background color.")
        if let range = attributedString.range(of: "highlighting") {
            // Equivalent to .textHighlight + .textHighlightColorScheme
            attributedString[range].backgroundColor = .systemPink // .opacity(0.4)
            attributedString[range].foregroundColor = .black // Ensure contrast
        }
         if let range = attributedString.range(of: "background color") {
            // Equivalent to .textHighlight using default accent color (simulated)
            attributedString[range].backgroundColor = Color.accentColor.opacity(0.3)
        }
        return attributedString
    }

    // Helper for Search Suggestions
    func updateSearchSuggestions(for query: String) async {
        // Simulates the delegate's sync/async response logic
        let favorites = Museum.favorites.filter { $0.matches(query) }
        // Set intermediate results immediately (like sync response)
        // In SwiftUI, we often just update the state directly
        searchSuggestions = favorites

        // Fetch remaining results (like async response)
        let others = await Museum.allMatching(query).filter { fav in !favorites.contains(where: { $0.id == fav.id}) }

        // Combine and set final results
        searchSuggestions = favorites + others
    }
}

// MARK: - Placeholder View for Image Playground

struct ImagePlaygroundPlaceholderView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Optional: Provides a title bar
            VStack(spacing: 20) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Image Playground Simulation")
                    .font(.title)
                Text("This view simulates where the system's Image Playground experience would appear if available on iOS.")
                    .multilineTextAlignment(.center)
                    .padding()
                Text("You could seed concepts or images here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button("Simulate Image Creation") {
                    // Here you would call the delegate method in a real scenario
                    print("Simulating image creation and dismissal")
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
