//
//  ScrollFeaturesDemoView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI

// MARK: - Data Model
struct Item: Identifiable, Hashable {
    let id: Int // Using Int for simplicity and Hashable requirement
    let color: Color
    let text: String
}

struct SectionInfo: Identifiable {
    let id: Character // Using Character which is Hashable
    let items: [Item]
    let header: String
    let footer: String
}

// MARK: - Main Demo View
struct ScrollFeaturesDemoView: View {
    // MARK: State Variables

    // Data for the scroll view content
    @State private var sectionData: [SectionInfo] = [
        SectionInfo(id: "A", items: generateItems(prefix: "A", count: 15), header: "Section A", footer: "End of Section A"),
        SectionInfo(id: "B", items: generateItems(prefix: "B", count: 15), header: "Section B", footer: "End of Section B"),
        SectionInfo(id: "C", items: generateItems(prefix: "C", count: 15), header: "Section C", footer: "End of Section C")
    ]

    // Dedicated state for the ID tracked/controlled by .scrollPosition
    @State private var scrolledID: Int? = nil

    // State for displaying current scroll info (Phase and Offset)
    @State private var currentPhase: ScrollPhase = .idle
    @State private var currentOffset: CGPoint = .zero
    // State for controlling scrolls via ScrollPosition methods (Edges/Points)
    @State private var scrollPositionController: ScrollPosition = .init(idType: Int.self)

    // MARK: Body - Broken Down
    var body: some View {
        // Main container VStack
        rootVStack
        .navigationTitle("Scroll Features Demo")
         #if os(macOS)
         .frame(minWidth: 350, minHeight: 500)
         #endif
        // Update scrollPositionController when scrolledID changes (if needed for edge cases)
        // Usually, just setting scrolledID is enough for ID-based scrolling.
        // This syncs the controller state if the user scrolls manually to a new ID.
        .onChange(of: scrolledID) { oldValue, newValue in // Use new signature
            if let newID = newValue, scrollPositionController.viewID(type: Int.self) != newID {
                 // Keep the controller slightly in sync if needed.
                 // It's primary use here is for edge/point scrolls.
                 // A scrollTo might cause animation jumpiness if `scrolledID` is also bound.
                 // Consider if this explicit sync is necessary for your exact use case.
                 // scrollPositionController.scrollTo(id: newID, anchor: .top)
                 // Or just update its internal state without causing a scroll:
                 updateControllerWithoutScrolling(newID: newID)
            }
        }
    }
    
    // Function to update controller state without triggering a scroll action
    private func updateControllerWithoutScrolling(newID: Int) {
        // Recreate the controller focused on the new ID. This avoids
        // triggering a scroll action from the onChange itself.
        scrollPositionController = ScrollPosition(id: newID, anchor: .top)
    }
    

    // MARK: - Computed View Properties (Sub-expressions)

    // Root VStack containing all elements
    private var rootVStack: some View {
         VStack(spacing: 0) {
            // --- Controls ---
            controlsViewContainer

            Divider()

            // --- Information Display ---
            infoDisplayViewContainer

            Divider()

            // --- ScrollView ---
            scrollViewContainer // Extracted ScrollView part
        }
    }

    // Container for the controls section
    private var controlsViewContainer: some View {
        controlsView
            .padding(.bottom, 5)
            .background(.bar) // Use a background material
    }

    // Container for the info display section
    private var infoDisplayViewContainer: some View {
         infoDisplayView
            .padding(.vertical, 5)
            .background(.bar)
    }

    // Container for the main ScrollView and its modifiers
    @ViewBuilder
    private var scrollViewContainer: some View {
         ScrollView() { // Pinning is automatic for Section headers
            scrollViewContent // Extracted inner content of ScrollView
         }
         // Bind $scrolledID for ID-based observation/control
         .scrollPosition(id: $scrolledID.animation(), anchor: .top)
         .onScrollPhaseChange { oldPhase, newPhase, context in
            currentPhase = newPhase
         }
         // CORRECTION: Closure receives ScrollGeometry, extract offset inside
//         .onScrollGeometryChange(for: CGPoint.self) { newGeometry in
             // The closure receives the full ScrollGeometry...
             // ...but is only triggered when the specified value (CGPoint offset) changes.
//             currentOffset = newGeometry.contentOffset // Extract the CGPoint here
//         }
//        coordinateSpace: .local // Keep coordinateSpace parameter
         // Bind $scrollPositionController for edge/point control
//         .scrollPosition(position: $scrollPositionController)
    }


    // Extracted content FOR the ScrollView (LazyVStack part)
    private var scrollViewContent: some View {
         LazyVStack(spacing: 5) {
            ForEach(sectionData) { section in
                Section {
                    ForEach(section.items) { item in
                        ItemRow(item: item)
                            .id(item.id) // Make items identifiable for scrollPosition
                    }
                } header: {
                    sectionHeader(section.header)
                } footer: {
                    sectionFooter(section.footer)
                }
            }
        }
        .padding(.horizontal)
        .scrollTargetLayout() // Define the layout containing scroll targets
    }

    // View for the top control buttons
    @ViewBuilder
    private var controlsView: some View {
        HStack {
            Button("Top") {
                withAnimation {
                    scrollPositionController.scrollTo(edge: .top)
                }
            }
            Button("Bottom") {
                withAnimation {
                    scrollPositionController.scrollTo(edge: .bottom)
                }
            }
            Button("Item A5") {
                withAnimation {
                     if let targetID = findItemID(prefix: "A", index: 5) {
                           scrolledID = targetID
                     }
                }
            }
            Button("Item C10") {
                withAnimation {
                     if let targetID = findItemID(prefix: "C", index: 10) {
                           scrolledID = targetID
                    }
                }
            }
            Button("Offset 500") {
                 withAnimation {
                      scrollPositionController.scrollTo(y: 500)
                 }
            }
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
    }

    // View for displaying scroll information
    @ViewBuilder
    private var infoDisplayView: some View {
        VStack(alignment: .leading) {
            Text("Phase: \(currentPhase.description)")
            Text("Offset: \(formattedOffset(currentOffset))")
            Text("Current ID: \(scrolledID.map(String.init) ?? "N/A")")
            Text("User Positioned: \(scrollPositionController.isPositionedByUser ? "Yes" : "No (or programmatic)")")
             if scrolledID == nil { // Show edge/point only if not ID-focused
                 if let edge = scrollPositionController.edge {
                     Text("At Edge: \(edgeDescription(edge))")
                 } else if let point = scrollPositionController.point {
                     Text("At Point: \(formattedOffset(point))")
                 }
             }
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }


    // View for section headers
    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.quaternary) // Use system adaptive colors/materials
            .cornerRadius(5)
    }

    // View for section footers
    @ViewBuilder
    private func sectionFooter(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.quinary) // Use system adaptive colors/materials
            .cornerRadius(5)
    }

    // MARK: Helper Functions

    // Helper to generate sample data
    static private func generateItems(prefix: Character, count: Int) -> [Item] {
        (1...count).map { i in
            let uniqueID = Int(prefix.asciiValue ?? 0) * 100 + i
            return Item(id: uniqueID,
                        color: Color(hue: Double(i) / Double(count), saturation: 0.8, brightness: 0.9),
                        text: "\(prefix)\(i)")
        }
    }

     // Helper to find item ID based on human-readable name (like "A5")
     private func findItemID(prefix: Character, index: Int) -> Int? {
         let targetText = "\(prefix)\(index)"
         for section in sectionData {
             if let item = section.items.first(where: { $0.text == targetText }) {
                 return item.id
             }
         }
         return nil
     }

    // Helper to format CGPoint
    private func formattedOffset(_ point: CGPoint) -> String {
        String(format: "(x: %.1f, y: %.1f)", point.x, point.y)
    }

    // Helper to describe Edge
     private func edgeDescription(_ edge: Edge) -> String {
         switch edge {
         case .top: return "Top"
         case .leading: return "Leading"
         case .bottom: return "Bottom"
         case .trailing: return "Trailing"
         @unknown default: return "Unknown"
         }
     }
}

// MARK: - Row View
struct ItemRow: View {
    let item: Item

    var body: some View {
        HStack {
            Text(item.text)
                .font(.body)
            Spacer()
            Image(systemName: "\(item.id % 5 + 1).circle.fill") // Use 1-5 for system names
        }
        .padding()
        .background(item.color.opacity(0.3))
        .cornerRadius(8)
        // Add a minimum height to ensure rows are easily tappable/visible
        .frame(minHeight: 44)
    }
}

// MARK: - ScrollPhase Extension for Description
extension ScrollPhase {
    // Added a computed property for better description formatting
    var description: String {
        switch self {
        case .idle: return "Idle"
        case .tracking: return "Tracking"
        case .interacting: return "Interacting"
        case .decelerating: return "Decelerating"
        case .animating: return "Animating"
        @unknown default: return "Unknown"
        }
    }
}


// MARK: - Preview
#Preview {
   NavigationStack { // Added for better preview display and title visibility
      ScrollFeaturesDemoView()
   }
}
