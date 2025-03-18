//
//  Views.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//
import SwiftUI


// Represents a generic node in our navigation hierarchy.
struct Node: Hashable, Identifiable, Codable {
    enum NodeType: Codable, Hashable, CaseIterable {
        case container  // Represents a grouping, like a folder
        case primitive  // Represents a basic data type (Int, String, Bool)
        case collection // Represents an array or dictionary
        case custom     // Represents a user-defined struct or class
    }

    var id = UUID()
    var name: String
    var type: NodeType
    var children: [Node]? // Only containers can have children
    var details: String? // Additional information (e.g., for primitives, the value)

    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Manages the navigation state.
class NavigationState: ObservableObject, Codable {
    @Published var path: [Node] = [] // For NavigationStack
    @Published var selectedNode: Node? // For NavigationSplitView (sidebar selection)
    @Published var columnVisibility: NavigationSplitViewVisibility = .automatic

    // Implement Codable for persistence (similar to NavigationModel in the original example)
    enum CodingKeys: String, CodingKey {
        case path, selectedNode, columnVisibility
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode([Node].self, forKey: .path)
        selectedNode = try container.decodeIfPresent(Node.self, forKey: .selectedNode)
        columnVisibility = try container.decode(NavigationSplitViewVisibility.self, forKey: .columnVisibility)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(selectedNode, forKey: .selectedNode)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }

    init() {}
}

// Provides sample data.  This replaces the DataModel.
class NodeData: ObservableObject {
    @Published var rootNodes: [Node]

    static let shared = NodeData() // Singleton

    private init() {
        // Create a sample hierarchy
        rootNodes = [
            Node(name: "Primitives", type: .container, children: [
                Node(name: "Integer", type: .primitive, details: "Represents whole numbers."),
                Node(name: "String", type: .primitive, details: "Represents text."),
                Node(name: "Boolean", type: .primitive, details: "Represents true/false values.")
            ]),
            Node(name: "Collections", type: .container, children: [
                Node(name: "Array", type: .collection, details: "An ordered collection of elements."),
                Node(name: "Dictionary", type: .collection, details: "A collection of key-value pairs.")
            ]),
            Node(name: "Custom Types", type: .container, children: [
                Node(name: "Struct", type: .custom, details: "A value type that groups related properties."),
                Node(name: "Class", type: .custom, details: "A reference type that supports inheritance.")
            ])
        ]
    }
    
    func children(of node: Node?) -> [Node] {
        guard let node = node, node.type == .container else {
            return []
        }
        return node.children ?? []
    }
}

// Main app entry point.
@main
struct NavigationNavigatorApp: App {
    @StateObject private var navigationState = NavigationState()
    @StateObject private var nodeData = NodeData.shared
    @SceneStorage("NavigationState") private var navigationData: Data?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
                .environmentObject(nodeData)
                .task {
                    // Restore state
                    if let data = navigationData {
                        do {
                            let decodedState = try JSONDecoder().decode(NavigationState.self, from: data)
                            navigationState.path = decodedState.path
                            navigationState.selectedNode = decodedState.selectedNode
                            navigationState.columnVisibility = decodedState.columnVisibility
                         } catch {
                            print("Decoding error: \(error)")
                         }
                    }

                    // Persist state.  Use .values to get an AsyncSequence.
                    Task { // Create a separate Task for observing changes
                        for await _ in navigationState.$path.values {
                            saveNavigationState()
                        }
                    }
                    Task {
                        for await _ in navigationState.$selectedNode.values {
                            saveNavigationState()
                        }
                    }
                    Task {
                        for await _ in navigationState.$columnVisibility.values {
                           saveNavigationState()
                        }
                    }
                }
        }
    }
    
    private func saveNavigationState() {
        do {
            let encodedData = try JSONEncoder().encode(navigationState)
            navigationData = encodedData
        } catch {
            print("Encoding Error \(error)")
        }
    }
}

// The root view, which chooses the navigation experience.
struct SwiftUINavigationNavigator_ContentView: View {
    @State private var navigationStyle: NavigationStyle = .automatic

    enum NavigationStyle {
        case stack, split, automatic
    }

    var body: some View {
        Group {
            if navigationStyle == .automatic {
                //Start with Split View
                SplitView()

            } else if navigationStyle == .stack {
                StackView()
            } else {
                SplitView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("Navigation Style", selection: $navigationStyle) {
                    Text("Automatic").tag(NavigationStyle.automatic)
                    Text("Stack").tag(NavigationStyle.stack)
                    Text("Split").tag(NavigationStyle.split)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// Demonstrates NavigationStack.
struct StackView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var nodeData: NodeData

    var body: some View {
        NavigationStack(path: $navigationState.path) {
            List {
                ForEach(nodeData.rootNodes) { node in
                    NavigationLink(value: node) {
                        NodeRow(node: node)
                    }
                }
            }
            .navigationTitle("Root Nodes")
            .navigationDestination(for: Node.self) { node in
                NodeDetailView(node: node)
            }
        }
    }
}

// Demonstrates NavigationSplitView.
struct SplitView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var nodeData: NodeData

    var body: some View {
        NavigationSplitView(columnVisibility: $navigationState.columnVisibility) {
            List(nodeData.rootNodes, selection: $navigationState.selectedNode) { node in
                NavigationLink(value: node) {
                    NodeRow(node: node)
                }
            }
            .navigationTitle("Root Nodes")
            .navigationSplitViewStyle(.balanced)
        } detail: {
            if let selectedNode = navigationState.selectedNode {
                NodeDetailView(node: selectedNode)
            } else {
                Text("Select a node")
            }
        }
    }
}

// Displays a single node in a list row.
struct NodeRow: View {
    var node: Node

    var body: some View {
        HStack {
            Image(systemName: iconName(for: node.type))
            Text(node.name)
        }
    }

    func iconName(for type: Node.NodeType) -> String {
        switch type {
        case .container: return "folder"
        case .primitive: return "p.circle"
        case .collection: return "list.bullet"
        case .custom: return "c.circle"
        }
    }
}

// Displays the details of a selected node.
struct NodeDetailView: View {
    var node: Node
    @EnvironmentObject var nodeData: NodeData

    var body: some View {
        VStack {
            Text(node.name)
                .font(.largeTitle)
            Text("Type: \(node.type.self)") //shows the Node type
                .font(.title2)

            if let details = node.details {
                Text("Details: \(details)")
                    .padding()
            }

            if node.type == .container {
                List {
                    ForEach(nodeData.children(of: node)) { childNode in
                        NavigationLink(value: childNode) {
                            NodeRow(node: childNode)
                        }
                    }
                }
                .navigationTitle("Children of \(node.name)")
            }
        }
        .navigationTitle(node.name)
    }
}

struct SwiftUINavigationNavigator_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUINavigationNavigator_ContentView()
            .environmentObject(NavigationState())
            .environmentObject(NodeData.shared)
    }
}
