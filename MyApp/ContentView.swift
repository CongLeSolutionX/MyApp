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
import Charts // For Charts examples
import WidgetKit // For ControlWidget placeholder
import AppIntents // For AppIntent placeholder

// MARK: - Models (Placeholders)

struct Party: Identifiable {
    var id = UUID()
    var name: String
    var date: Date = Date()
    // Add other relevant properties
    static var example = Party(name: "WWDC Karaoke Bash")
    static var all: [Party] = [
        Party(name: "WWDC Karaoke Bash"),
        Party(name: "Team Celebration"),
        Party(name: "Summer Kickoff")
    ]
}

struct GuestData: Identifiable {
    let id = UUID()
    let name: String
    let songsSung: [Int: Int] // [PartyID: Count]
}

struct PartyData: Identifiable {
    let partyNumber: Int
    let numberGuests: Int
    var id: Int { partyNumber }
    var name: String { "Party \(partyNumber)" }
    static var exampleParties: [PartyData] = (1...5).map { PartyData(partyNumber: $0, numberGuests: Int.random(in: 5...15)) }
}

struct LyricLine: Identifiable {
    let id = UUID()
    var number: Int
    @State var text: String = ""
}

struct LyricCompletion: Identifiable {
    let id = UUID()
    var text: String
    var attributedCompletion: AttributedString { AttributedString(text) } // Simplified
}

struct Song: Identifiable {
    let id = UUID()
    var title: String
    var rating: String? = nil // For accessibility example
}

// MARK: - App Intents (Placeholder)

struct StartPartyIntent: AppIntent {
    static var title: LocalizedStringResource = "Start the Party"
    // Implementation would go here (e.g., interact with a PartyManager)
    func perform() async throws -> some IntentResult {
        print("Starting the party!")
        return .result()
    }
}

// MARK: - View Models / Managers (Placeholders)

class PartyManager: ObservableObject {
    static let shared = PartyManager()
    @Published var nextParty: Party = Party.example
    private init() {}
}

// MARK: - Custom Text Renderer

struct KaraokeRenderer: TextRenderer {
    let purpleColorFilter = ColorMatrixFilter.adjusting(saturation: 2.0) * ColorMatrixFilter.adjustingBrightness(to: 0.8) * ColorMatrixFilter.multipling(.purple)

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        // Simple glow effect example
        for line in layout {
            for run in line {
                var glowContext = context
                // Create a slightly blurred, tinted copy behind the original
                glowContext.addFilter(.blur(radius: 3))
                glowContext.addFilter(purpleColorFilter)
                glowContext.opacity = 0.6
                glowContext.draw(run)

                // Draw the original text on top
                context.draw(run)
            }
        }
    }
}

#Preview("Karaoke Text") {
    Text("SwiftUI Karaoke!")
        .font(.largeTitle)
        .fontWeight(.bold)
        .textRenderer(KaraokeRenderer())
        .padding()
}

// MARK: - Environment / Focus / Transaction / Container Value Extensions

extension EnvironmentValues {
  @Entry var karaokePartyColor: Color = .purple
}

extension FocusValues {
  @Entry var lyricNote: String? = nil // Example custom focus value
}

extension Transaction {
  @Entry var animatePartyIcons: Bool = false // Example custom transaction key
}

extension ContainerValues {
  @Entry var displayBoardCardStyle: DisplayBoardCardStyle = .bordered // For custom container
}

enum DisplayBoardCardStyle { case bordered, plain } // Helper enum

// MARK: - Custom Container View

struct CardView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 3)
    }
}

struct DisplayBoardCardLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Basic implementation: size to fit content vertically, propose width horizontally
        let idealViewSizes = subviews.map { $0.sizeThatFits(.init(width: proposal.width, height: nil)) }
        let totalHeight = idealViewSizes.reduce(0) { $0 + $1.height }
        let spacing = CGFloat(subviews.count - 1) * 10
        return CGSize(width: proposal.width ?? 100, height: totalHeight + spacing)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var yOffset = bounds.minY
        let spacing: CGFloat = 10

        for view in subviews {
            let viewSize = view.sizeThatFits(.init(width: proposal.width, height: nil))
            view.place(at: CGPoint(x: bounds.midX, y: yOffset + viewSize.height / 2),
                       anchor: .center,
                       proposal: ProposedViewSize(viewSize))
            yOffset += viewSize.height + spacing
        }
    }
}

struct DisplayBoard<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\Root.displayBoardCardStyle) var cardStyle // Use the custom value

    var body: some View {
        ScrollView { // Make it scrollable
            DisplayBoardCardLayout {
                // Use ForEach(subviewOf:) to iterate over children *passed to DisplayBoard*
                ForEach(subviewOf: content) { sectionSubview in
                    // Assuming content passed is Sections, iterate subviews *within* each Section
                    // This part requires more nuance depending on exact desired structure,
                    // showing the basic principle here:
                    if let section = sectionSubview.children.first { // Simplified check
                         ForEach(subviewOf: section) { subview in
                            CardView { subview }
                        }
                    } else {
                         // Handle direct children if not Sections
                         CardView { sectionSubview }
                    }
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1)) // Example background
    }
}

struct CustomContainerExampleView: View {
    let songsFromSam = [Song(title: "Cupertino Dreamin'"), Song(title: "Objective-Chi")]
    @State private var cardStyle: DisplayBoardCardStyle = .bordered

    var body: some View {
        VStack {
            Picker("Card Style", selection: $cardStyle) {
                Text("Bordered").tag(DisplayBoardCardStyle.bordered)
                Text("Plain").tag(DisplayBoardCardStyle.plain)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            DisplayBoard {
                Section("Matt's Favorites") {
                    Text("Scrolling in the Deep")
                    Text("Born to Build & Run")
                    Text("Some Body Like View")
                        // .displayBoardCardRejected(true) // Requires custom modifier logic in Container
                }
                Section("Sam's Favorites") {
                    ForEach(songsFromSam) { song in
                        Text(song.title)
                    }
                }
                // Static content alongside sections
                 Text("Encore: Swift Life")
            }
            // Apply the container value
            .containerValue(\.displayBoardCardStyle, cardStyle)
        }
        .navigationTitle("Custom Container")
    }
}

// MARK: - Main App Structure

@main
struct KaraokeAndLyricsApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
            // --- macOS / visionOS Specific Modifiers (Conceptual) ---
            // .windowStyle(.plain) // macOS: removes chrome
            // .windowLevel(.floating) // macOS: keeps window on top
            // .defaultWindowPlacement { content, context in ... } // macOS: initial position
            // .windowStyle(.volumetric) // visionOS: Creates a Volume
            // .defaultWorldScaling(.trueScale) // visionOS
            // .volumeBaseplateVisibility(.hidden) // visionOS
        }

        // --- Document Launch Scene (Conceptual - separate from WindowGroup usually) ---
        // DocumentGroupLaunchScene("Your Lyrics") { ... } background: { ... } ...

        // --- Settings Scene (Standard) ---
        // Settings { SettingsView() }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var customization = TabViewCustomization() // For reordering/hiding
    @State private var partyColor: Color = .purple // Default for Environment

    var body: some View {
        TabView {
            Tab("Parties", systemImage: "list.star") { // Changed icon for variety
                PartiesView()
            }
            .customizationID("tab.parties") // ID for customization

            Tab("Planning", systemImage: "pencil.and.list.clipboard") {
                PlanningView()
            }
            .customizationID("tab.planning")

            Tab("Attendance", systemImage: "chart.bar.xaxis") { // Changed icon
                AttendanceView()
            }
            .customizationID("tab.attendance")

            Tab("Songs", systemImage: "music.note.list") { // Changed name
                SongListView()
            }
            .customizationID("tab.songs")

            Tab("Lyrics Editor", systemImage: "doc.text.magnifyingglass") {
                LyricsEditorView()
            }
            .customizationID("tab.lyrics")

            Tab("Fun Stuff", systemImage: "sparkles") {
               OtherFeaturesView() // View to demo misc features
            }
            .customizationID("tab.misc")

        }
        // The core adaptable style for iPadOS/macOS/tvOS flexibility
        .tabViewStyle(.sidebarAdaptable)
        // Enable user customization on supported platforms
        .tabViewCustomization($customization)
        // Provide the custom environment value
        .environment(\.karaokePartyColor, partyColor)
    }
}

// MARK: - Tab Content Views

struct PartiesView: View {
    @State private var showAddSheet = false
    @Namespace private var partyNamespace // For zoom transition

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(Party.all) { party in
                        NavigationLink {
                            PartyDetailView(party: party)
                                // Apply the zoom transition for navigation
                                .navigationTransition(.zoom(
                                    sourceID: party.id, in: partyNamespace))
                        } label: {
                            PartyCard(party: party)
                                // Source element for the zoom transition
                                .matchedTransitionSource(id: party.id, in: partyNamespace)
                        }
                        .buttonStyle(.plain) // Use plain style for better grid layout interaction
                    }
                }
                .padding()
            }
            .navigationTitle("Karaoke Parties")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add Party", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPartyView()
                    // Use the unified presentation sizing modifier
                    .presentationSizing(.form)
            }
        }
    }
}

struct PartyCard: View {
    let party: Party
    @Environment(\.karaokePartyColor) var partyColor // Use custom env value

    var body: some View {
        VStack(alignment: .leading) {
            Text(party.name)
                .font(.headline)
            Text(party.date, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "music.mic.circle.fill")
                 .foregroundStyle(partyColor) // Use env value
                 .symbolEffect(.pulse) // Example symbol effect
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        // macOS/iPadOS specific interaction hint
        // .hoverEffect(.lift) // Simple hover effect example
    }
}

struct PartyDetailView: View {
    let party: Party
    @Environment(\.karaokePartyColor) var partyColor

    var body: some View {
        VStack {
            Text(party.name)
                .font(.largeTitle)
            Image(systemName: "party.popper.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(partyColor)
                // macOS/visionOS window dragging concept
                // .gesture(WindowDragGesture()) // Concept: Attach to draggable part
            Text("Details about the party...")
                // Demonstrate Color Mixing
                .foregroundStyle(Color.blue.mix(with: .green, by: 0.5))

            // macOS Alternate Menu Item Concept
            Button("Show Details") { /* ... */ }
            // .modifierKeyAlternate(.option) { Button("Show MORE Details") { /* ... */ } }
            // .keyboardShortcut("d", modifiers: [.command])

            Spacer()
        }
        .padding()
        .navigationTitle(party.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddPartyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var partyName: String = ""

    var body: some View {
        NavigationView { // Often used in sheets for title/buttons
            Form {
                TextField("Party Name", text: $partyName)
                // ... other fields
            }
            .navigationTitle("New Party")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save logic here
                        dismiss()
                    }
                    .disabled(partyName.isEmpty)
                }
            }
        }
    }
}

struct PlanningView: View {
    var body: some View {
        NavigationStack {
            VStack {
                 Text("Plan your next karaoke event!")
                 CustomContainerExampleView() // Show the custom container here
            }
            .navigationTitle("Planning")
        }
    }
}

struct AttendanceView: View {
    @State private var guestData = (1...8).map { i in
        GuestData(name: "Guest \(i)", songsSung: PartyData.exampleParties.reduce(into: [:]) { $0[$1.id] = Int.random(in: 0...5) })
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Attendance & Song Counts")
                    .font(.title2)
                    .padding(.bottom)

                // Swift Charts Example with Function Plot
                Chart {
                    // Function plot for goal
                    LinePlot(x: .value("Party Number", 1...10), y: .value("Target Guests", { Double($0 * $0) * 0.5 + 5 })) // Example function
                        .foregroundStyle(.purple)
                        .lineStyle(StrokeStyle(dash: [5]))

                    // Actual attendance (example)
                    ForEach(PartyData.exampleParties) { party in
                        PointMark(
                            x: .value("Party Number", party.partyNumber),
                            y: .value("Actual Guests", party.numberGuests)
                        )
                        .foregroundStyle(.blue)
                        .symbol(.circle)
                        LineMark(
                             x: .value("Party Number", party.partyNumber),
                             y: .value("Actual Guests", party.numberGuests)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXScale(domain: 0...(PartyData.exampleParties.count + 1))
                .chartYScale(domain: 0...50) // Adjust domain as needed
                .frame(height: 200)
                .padding()

                // Dynamic Table Columns Example
                Table(guestData) {
                    TableColumn("Name", value: \.name)
                        .width(min: 100) // Give name column some space

                    // Use TableColumnForEach for dynamic party columns
                    TableColumnForEach(PartyData.exampleParties) { partyData in
                        TableColumn(partyData.name) { guest in
                            Text(guest.songsSung[partyData.id] ?? 0, format: .number)
                        }
                        .width(60) // Fixed width for number columns
                    }
                }
            }
            .navigationTitle("Attendance")
        }
    }
}

struct SongListView: View {
    var body: some View {
        NavigationStack {
            List {
                SongView(Song(title: "Swift Reflections", rating: "5 Stars"))
                SongView(Song(title: "Don't Stop Believin' (in Type Safety)"))
                SongView(Song(title: "Protocol Witness Blues"))
            }
            .navigationTitle("Song List")
            // Mesh Gradient Example as Background
            .background(
                MeshGradient(
                    width: 3, height: 3,
                    points: [ [0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1] ],
                    colors: [.cyan.opacity(0.5), .indigo.opacity(0.5), .purple.opacity(0.8),
                             .blue.opacity(0.4), .mint.opacity(0.6), .teal.opacity(0.7),
                             .green.opacity(0.5), .yellow.opacity(0.4), .orange.opacity(0.6)]
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct SongView: View {
    let song: Song

    init(_ song: Song) {
        self.song = song
    }

    var body: some View {
         HStack {
            Image(systemName: "music.note")
            Text(song.title)
            Spacer()
            if song.rating != nil {
                Image(systemName: "star.fill")
            }
        }
        // Example of augmenting default accessibility label
        .accessibilityElement(children: .combine) // Combine children first
        .accessibilityLabel { label in // Then augment the combined label
            if let rating = song.rating {
                Text("\(rating).") // Add rating info
            }
             label // Append the original combined label (e.g., "music.note, Song Title, star.fill")
        }
    }
}

struct LyricsEditorView: View {
    @State private var lyricLine = LyricLine(number: 1, text: "A whole new view")
    @State private var textSelection: TextSelection?
    @State private var suggestedCompletions: [LyricCompletion] = [
        LyricCompletion(text: "world of code we knew"),
        LyricCompletion(text: "world, a dazzling UI so new")
    ]
    @FocusState private var isSearchFieldFocused: Bool // Example focus state
    @State private var searchText: String = ""
    @State private var isSearchPresented: Bool = false // For .searchable

    // State for platform-specific interaction concepts
    @State private var showBouncingBallAlignment = false
    @State private var lyricDoodlePalettePresented = false
    @State private var lyricDoodlePaletteAnchor: UnitPoint? = nil

    #if os(visionOS)
    @Environment(\.pushWindow) private var pushWindow // Only available on visionOS
    #endif

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                // Text Field with Programmatic Selection and Suggestions
                TextField("Line \(lyricLine.number)", text: $lyricLine.text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...)
                    // Bind selection
                    .textSelection($textSelection)
                    // Add suggestions
                    .textInputSuggestions {
                        ForEach(suggestedCompletions) { completion in
                            Text(completion.attributedCompletion) // Show formatted text
                                .textInputCompletion(completion.text) // Provide plain text for insertion
                        }
                    }
                    // Conceptual: Respond to modifier keys (e.g., show alignment guide)
                    .overlay(alignment: .topLeading) {
                        if showBouncingBallAlignment {
                            Rectangle().fill(.red).frame(width: 5, height: 5).offset(x: 5, y: -10)
                        }
                    }
                    .onModifierKeysChanged(mask: .option) { event in
                         // Need to check event phase for press/release on macOS/iPadOS for accurate toggle
                         // Simplified: just toggles on any change
                         showBouncingBallAlignment = !event.modifiers.isEmpty
                    }

                // Displaying Selection Info
                if let selection = textSelection, !selection.ranges.isEmpty {
                     Text("Selection: \(selection.description)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                         // In a real app, use selection.ranges to get indices/text
                }

                 // Search Field Focus Example
                HStack {
                    Text("Search conceptually:")
                    Spacer()
                     Button(isSearchFieldFocused ? "Dismiss Search" : "Focus Search") {
                         isSearchFieldFocused.toggle()
                     }
                }
                // Apply searchable and focus binding
                .searchable(text: $searchText, isPresented: $isSearchPresented) // Standard searchable
                .searchFocused($isSearchFieldFocused) // NEW: Bind focus state

                // Custom Text Renderer Example
                Text(lyricLine.text.isEmpty ? "Your lyrics appear here..." : lyricLine.text)
                    .font(.title2)
                    .padding(.vertical)
                    .textRenderer(KaraokeRenderer()) // Apply custom renderer

                // SF Symbol Effects
                HStack {
                    Label("Wiggle", systemImage: "music.note")
                        .symbolEffect(.wiggle(.rotational), options: .repeating)
                    Label("Breathe", systemImage: "waveform.path")
                         .symbolEffect(.breathe, options: .speed(0.5).repeating)
                    Label("Rotate", systemImage: "speaker.wave.2.fill")
                         .symbolEffect(.rotate, options: .repeating)
                     Label("Replace", systemImage: "mic.fill.badge.plus")
                         .symbolEffect(.replace.magic) // Implicit "magic" usually
                         .onTapGesture { /* Toggle state to see replace */ }
                }
                .padding(.top)

                // Placeholder for Platform Specific Interactions
                VStack(alignment: .leading) {
                     Text("Platform Features (Conceptual):")
                         .font(.headline)
                         .padding(.bottom, 2)

                     // visionOS Push Window
                     #if os(visionOS)
                     Button("Push to Lyric Preview") {
                         pushWindow(id: "lyric-preview") // Example ID
                     }
                     #else
                     Text("• Push Window (visionOS)")
                         .foregroundStyle(.gray)
                     #endif

                     // visionOS Hover Effect (can also be used on iPadOS/macOS)
                     Button("Hover Me") { }
                         .padding(5)
                         .background(.blue.opacity(0.2))
                         .clipShape(Capsule())
                         // .hoverEffect(.highlight) // Basic hover
                         // Custom hover effect concept:
                         // .hoverEffect { effect, isActive, _ in
                         //     effect.scaleEffect(isActive ? 1.1 : 1.0).blur(radius: isActive ? 0 : 2)
                         // }

                     // macOS/iPadOS Pointer Style
                     HStack {
                         Text("Resize Handle")
                             .padding(8)
                             .background(.yellow.opacity(0.3))
                             // .pointerStyle(.frameResize(edges: .bottomTrailing)) // Example
                         Spacer()
                     }

                     // iPadOS Pencil Squeeze
                     Button("Tap or Squeeze") { lyricDoodlePalettePresented.toggle() }
                         // .onPencilSqueeze { phase in // Phase has info like hoverPose
                         //     if case .ended(let value) = phase {
                         //           // Check preferredAction, maybe show palette
                         //           lyricDoodlePaletteAnchor = value.hoverPose?.anchor
                         //           lyricDoodlePalettePresented = true
                         //     }
                         // }
                         .popover(isPresented: $lyricDoodlePalettePresented, attachmentAnchor: .point(lyricDoodlePaletteAnchor ?? .center)) {
                             Text("Doodle Palette!").padding()
                         }

                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top)

            }
            .padding()
            .navigationTitle("Lyrics Editor")
        }
    }
}

struct OtherFeaturesView: View {
    @State private var showPreviewable = false
    @State private var scrollPosition: ScrollPosition = .init(idType: Int.self)
    @State private var showBackButton = false
    @State private var isVideoVisible = false // For scroll visibility

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Previewable Macro Example
                    Button("Toggle Previewable Example") { showPreviewable.toggle() }
                    if showPreviewable {
                         PreviewableExample()
                            .frame(height: 100)
                            .border(Color.gray)
                    }

                    // Scroll View Enhancements Section
                    Text("Scroll View Features").font(.title2)

                    // Back to Top Button (using onScrollGeometryChange)
                     Button("Scroll To Top") {
                         withAnimation {
                              // Use the new edge parameter
                              scrollPosition.scrollTo(edge: .top)
                         }
                     }
                     .buttonStyle(.bordered)
                     .opacity(showBackButton ? 1 : 0) // Show/hide based on state

                    // Content for Scrolling
                    ForEach(0..<30) { i in
                        Text("Scroll Content Item \(i)")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.2))
                            .id(i) // ID for scroll position targeting (optional here)
                            .onTapGesture {
                                // Example: Scroll to a specific item ID
                                // scrollPosition.scrollTo(id: 15)
                            }
                    }

                    // Scroll Visibility Change Example (Conceptual Video Player)
                    VStack {
                         Text("Video Player Placeholder")
                              .frame(height: 150)
                              .frame(maxWidth: .infinity)
                              .background(Color.blue.opacity(0.3))
                         Text(isVideoVisible ? "Playing..." : "Paused")
                              .font(.caption)
                    }
                    .onScrollVisibilityChange(threshold: 0.5) { isNowVisible in // e.g., 50% visible
                         print("Video visibility changed: \(isNowVisible)")
                         isVideoVisible = isNowVisible
                         // In real code: player.play() or player.pause()
                    }

                 }
                 .padding()
            }
             // Bind scroll position
            .scrollPosition($scrollPosition)
             // Detect scroll geometry to show/hide "back to top"
            .onScrollGeometryChange(for: Bool.self) { geometry in
                // Check if scrolled past the top inset (content offset is negative)
                 geometry.contentOffset.y < geometry.contentInsets.top
            } action: { wasScrolledPastTop, isScrolledPastTop in
                 withAnimation(.easeInOut) {
                     showBackButton = isScrolledPastTop
                 }
            }
            // Other Scroll View Knobs (Conceptual Comments)
            // .scrollBounceBehavior(.basedOnSize, axes: .vertical) // e.g., disable horizontal bounce
            // .scrollDismissesKeyboard(.interactively)
            // .scrollIndicators(.hidden)
            // .contentMargins(.horizontal, 20, for: .scrollContent) // Add margins inside scroll view

            .navigationTitle("Other Features")
        }
    }
}

#Preview("Other Features View") {
     OtherFeaturesView()
}

// MARK: - Previewable Macro Usage

#Preview("Previewable Demo") {
   @Previewable @State var isToggled = true // Use @State directly in Preview
   VStack {
     Toggle("Direct State Toggle", isOn: $isToggled)
     Text("Value: \(isToggled.description)")
   }
   .padding()
}

// MARK: - Widget / Control / Live Activity Placeholders

// --- Control Widget ---
struct StartPartyControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.example.KaraokeApp.StartPartyControl" // Unique Kind
        ) {
            // ControlWidgetButton defined in documentation snippet
            ControlWidgetButton(action: StartPartyIntent()) {
                Label("Start Party", systemImage: "music.mic")
                Text(PartyManager.shared.nextParty.name) // Access shared manager
            }
            // Could add more buttons or toggles here
             // ControlWidgetToggle(...)
        }
        .displayName("Karaoke Control")
        .description("Start the next karaoke party.")
    }
}
// Note: Requires setup in App Target's Extensions

// --- Live Activity Widget (Conceptual View Structure) ---
// Needs actual LiveActivityAttributes struct defined elsewhere
struct KaraokeLyricsActivityWidgetView: View {
    // let context: ActivityViewContext<KaraokeLyricsAttributes> // Passed by system

    var body: some View {
         VStack {
             // --- Lock Screen / Banner View ---
             Text("Live Activity: Lyrics") // Placeholder
             // ... Display current lyric line from context.state ...

             // --- Dynamic Island Views ---
             // context.isStale ? ... : ...
             // Define compactLeading, compactTrailing, minimal views...

             // --- watchOS Supplemental View ---
             // if context.family == .supplemental { ... } // Use new supplemental family
             // Display tailored content for watchOS small view
             // .handGestureShortcut() // Apply double tap shortcut if needed
         }
    }
}

// --- Standard Widget Example (Countdown) ---
struct CountdownWidgetView: View {
    // let entry: CountdownTimelineEntry // Provided by timeline provider

    var body: some View {
        VStack {
             Text("Karaoke O'Clock!")
             // Use new Text formats
             // Text(entry.date, style: .relative) // e.g., "in 5 minutes"
             // Text(entry.date, style: .offset) // e.g., "+5 minutes"
             Text(Date().addingTimeInterval(300), style: .timer) // e.g., "5:00" counting down
                 .font(.title)
                 .monospacedDigit() // Good for timers
        }
        // --- Contextual Relevance (Configuration) ---
        // In the StaticConfiguration:
        // .supportedFamilies([...])
        // .relevantIntent(...) // If widget is configurable
        // .relevantTimestamps(...) // Show around specific times
        // .relevantLocations(...) // Show near specific places
    }
}

// MARK: - Interoperability Placeholders

// --- UIGestureRecognizerRepresentable ---
struct VideoThumbnailScrubGesture: UIGestureRecognizerRepresentable {
    // Typealias UIGestureRecognizerType = VideoThumbnailScrubGestureRecognizer
    @Binding var progress: Double

    func makeUIGestureRecognizer(context: Context) -> UIGestureRecognizer { // Return base type
        // let recognizer = VideoThumbnailScrubGestureRecognizer()
         // Setup target/action or use coordinator
        let recognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        return recognizer
    }

    func updateUIGestureRecognizer(_ uiGestureRecognizer: UIGestureRecognizer, context: Context) {
        // Update recognizer settings if needed
    }

     func makeCoordinator() -> Coordinator {
         Coordinator(self)
     }

     class Coordinator: NSObject {
         var parent: VideoThumbnailScrubGesture
         init(_ parent: VideoThumbnailScrubGesture) { self.parent = parent }

         @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
             // Calculate progress based on gesture state/location
             // parent.progress = calculatedProgress
             let location = gesture.location(in: gesture.view)
             let width = gesture.view?.bounds.width ?? 1
             parent.progress = max(0, min(1, location.x / width))
             print("Gesture Updated Progress: \(parent.progress)")
         }
     }

     // Required function from original snippet (may be simplified or handled by Coordinator)
     func handleUIGestureRecognizerAction(_ recognizer: UIGestureRecognizer, context: Context) {
         // This might not be needed if using Coordinator with target/action
         print("Handle Action Called (might be redundant with Coordinator)")
     }
}

struct InteroperabilityExampleView: View {
     @State private var scrubProgress: Double = 0.0
     @State private var boxIsOpen: Bool = false // For representable animation bridging

     var body: some View {
         VStack(alignment: .leading) {
             Text("Gesture Interop").font(.title2)
             Text("Scrub Progress: \(scrubProgress, specifier: "%.2f")")
             Rectangle() // Placeholder for video thumbnail
                 .fill(.blue.opacity(0.4))
                 .frame(height: 50)
                 // Apply the representable gesture
                 .gesture(VideoThumbnailScrubGesture(progress: $scrubProgress))

             Divider().padding(.vertical)

             Text("Animation Interop").font(.title2)
             // Placeholder for UIViewRepresentable needing animation bridging
             BeadBoxWrapper(isOpen: $boxIsOpen)
                 .frame(width: 100, height: 100)
                 .border(Color.gray)
                 .onTapGesture {
                     // External state change triggers updateUIView with animation
                     boxIsOpen.toggle()
                 }

             Text("Trigger UIKit/AppKit Animation from SwiftUI Context (Conceptual)")
                 .font(.caption)
                 .foregroundStyle(.gray)
             Button("Animate UIKit View") {
                 animateExternalView()
             }

             Spacer()
         }
         .padding()
         .navigationTitle("Interop Features")
     }

     func animateExternalView() {
         // Conceptual: Get reference to an external UIKit/AppKit view
         // guard let externalView = getMyExternalUIView() else { return }

         // Define the SwiftUI Animation
         let swiftUIAnimation = Animation.spring(duration: 0.8, bounce: 0.3)

         // Use the new UIView.animate / NSAnimationContext.animate
         #if canImport(UIKit)
         // UIView.animate(swiftUIAnimation) {
         //     externalView.center = CGPoint(x: externalView.center.x + 50, y: externalView.center.y)
         //     externalView.transform = CGAffineTransform(rotationAngle: .pi / 4)
         // }
         print("Conceptual UIKit Animation with \(swiftUIAnimation)")
         #elseif canImport(AppKit)
         // NSAnimationContext.runAnimationGroup { context in
         //     NSAnimationContext.animate(swiftUIAnimation, using: context) {
         //         externalView.animator().frame.origin.x += 50
         //     }
         // }
         print("Conceptual AppKit Animation with \(swiftUIAnimation)")
         #endif
     }
}

// Placeholder UIViewRepresentable demonstrating animation bridging
struct BeadBoxWrapper: UIViewRepresentable {
    @Binding var isOpen: Bool

    func makeUIView(context: Context) -> UIView { // Simple placeholder view
        let view = UIView()
        view.backgroundColor = .orange
        // Create a "lid" subview
        let lid = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        lid.backgroundColor = .brown
        lid.tag = 101 // Tag to find it later
        view.addSubview(lid)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let lid = uiView.viewWithTag(101) else { return }

        // Use context.animate to bridge SwiftUI animation properties
        context.animate {
             // Animate properties of the UIKit view (the lid)
             lid.center.y = isOpen ? -10 : 5 // Move lid up when open
             lid.alpha = isOpen ? 0.5 : 1.0
        }
        // This animation will run in sync with any SwiftUI animations
        // happening concurrently in the same transaction.
    }
}
