//
//  Views.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//
import SwiftUI
import Combine

// MARK: - Data Models

struct Node: Hashable, Identifiable, Codable {
    enum NodeType: String, Codable, Hashable, CaseIterable {
        case container
        case primitive
        case collection
        case custom
    }
    
    var id = UUID()
    var name: String
    var type: NodeType
    var children: [Node]?
    var details: String?
    var creationDate: Date? // Added for "More Complex Data"
    var size: Int?          // Added for "More Complex Data"
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class NavigationState: ObservableObject, Codable {
    @Published var path: [Node] = []
    @Published var selectedNode: Node?
    @Published var selectedSecondaryNode: Node? // For ThreeColumnView
    @Published var columnVisibility: NavigationSplitViewVisibility = .automatic
    
    enum CodingKeys: String, CodingKey {
        case path, selectedNode, columnVisibility, selectedSecondaryNode
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode([Node].self, forKey: .path)
        selectedNode = try container.decodeIfPresent(Node.self, forKey: .selectedNode)
        selectedSecondaryNode = try container.decodeIfPresent(Node.self, forKey: .selectedSecondaryNode)
        columnVisibility = try container.decode(NavigationSplitViewVisibility.self, forKey: .columnVisibility)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(selectedNode, forKey: .selectedNode)
        try container.encode(selectedSecondaryNode, forKey: .selectedSecondaryNode)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }
    
    init() {}
}

class NodeData: ObservableObject {
    @Published var rootNodes: [Node]
    
    static let shared = NodeData()
    
    private init() {
        rootNodes = [
            Node(name: "Primitives", type: .container, children: [
                Node(name: "Integer", type: .primitive, details: "Represents whole numbers.", creationDate: Date(), size: 4),
                Node(name: "String", type: .primitive, details: "Represents text.", creationDate: Date(), size: 16),
                Node(name: "Boolean", type: .primitive, details: "Represents true/false values.", creationDate: Date(), size: 1)
            ]),
            Node(name: "Collections", type: .container, children: [
                Node(name: "Array", type: .collection, details: "An ordered collection of elements.", creationDate: Date()),
                Node(name: "Dictionary", type: .collection, details: "A collection of key-value pairs.", creationDate: Date())
            ]),
            Node(name: "Custom Types", type: .container, children: [
                Node(name: "Struct", type: .custom, details: "A value type that groups related properties.", creationDate: Date()),
                Node(name: "Class", type: .custom, details: "A reference type that supports inheritance.", creationDate: Date())
            ])
        ]
    }
    
    func children(of node: Node?) -> [Node] {
        guard let node = node, node.type == .container else {
            return []
        }
        return node.children ?? []
    }
    
    func subChildren(of node: Node) -> [Node] {
        if node.name == "Array" {
            return [
                Node(name: "Element 1", type: .primitive, details: "Value: 10", creationDate: Date(), size: 4),
                Node(name: "Element 2", type: .primitive, details: "Value: 20", creationDate: Date(), size: 4),
                Node(name: "Element 3", type: .primitive, details: "Value: 30", creationDate: Date(), size: 4)
            ]
        }
        return []
    }
}

// MARK: - App Entry Point

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
                .onOpenURL { url in // Deeplinking
                    handleDeepLink(url: url)
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
    
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "navigationnavigator" else { // Replace 'navigationnavigator'
            return
        }
        
        if components.host == "node" {
            let pathComponents = components.path.split(separator: "/").map(String.init)
            var currentNode: Node?
            var currentChildren = nodeData.rootNodes
            
            for component in pathComponents {
                if let foundNode = currentChildren.first(where: { $0.name == component }) {
                    currentNode = foundNode
                    if let children = currentNode?.children {
                        currentChildren = children
                    }
                } else {
                    return // Invalid path
                }
            }
            
            if let targetNode = currentNode {
                navigationState.path = [targetNode] // For simplicity, use path for all
                navigationState.selectedNode = targetNode // Also set for Split/ThreeColumn
                // If navigating to a sub-child, set selectedSecondaryNode appropriately
            }
        }
    }
}

// MARK: - Views

struct SwiftUINavigationNavigator_ContentView: View {
    @State private var navigationStyle: NavigationStyle = .automatic
    @EnvironmentObject var navigationState: NavigationState
    enum NavigationStyle: String, CaseIterable, Identifiable { // Make it Identifiable
        case automatic, stack, split, threeColumn
        var id: String { self.rawValue } // Implement id
    }
    
    
    var body: some View {
        Group {
            if navigationStyle == .automatic {
                SplitView()
            } else if navigationStyle == .stack {
                StackView()
            } else if navigationStyle == .split{
                SplitView()
            } else {
                ThreeColumnView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Picker("Navigation Style", selection: $navigationStyle) {
                    ForEach(NavigationStyle.allCases) { style in // Use ForEach with Identifiable
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct StackView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var nodeData: NodeData
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            List {
                ForEach(nodeData.rootNodes) { node in
                    NavigationLink(value: node) {
                        withAnimation {
                            NodeRow(node: node)
                        }
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

struct SplitView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var nodeData: NodeData
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationState.columnVisibility) {
            List(nodeData.rootNodes, selection: $navigationState.selectedNode) { node in
                NavigationLink(value: node) {
                    withAnimation {
                        NodeRow(node: node)
                    }
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

struct ThreeColumnView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var nodeData: NodeData
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationState.columnVisibility) {
            List(nodeData.rootNodes, selection: $navigationState.selectedNode) { node in
                NavigationLink(value: node) {
                    withAnimation {
                        NodeRow(node: node)
                    }
                }
            }
            .navigationTitle("Root Nodes")
        } content: {
            if let selectedNode = navigationState.selectedNode {
                List(nodeData.children(of: selectedNode), selection: $navigationState.selectedSecondaryNode) { childNode in
                    NavigationLink(value: childNode) {
                        withAnimation{
                            NodeRow(node: childNode)
                        }
                    }
                }
                .navigationTitle(selectedNode.name)
            } else {
                Text("Select a root node")
            }
        } detail: {
            if let selectedSecondaryNode = navigationState.selectedSecondaryNode {
                NodeDetailView(node: selectedSecondaryNode, isSubDetail: true)
            } else {
                Text("Select a child node")
            }
        }
    }
}

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

struct NodeDetailView: View {
    var node: Node
    @EnvironmentObject var nodeData: NodeData
    var isSubDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode // For programmatic navigation
    @EnvironmentObject var navigationState: NavigationState // Access navigationStyle
    var navigationStyle: SwiftUINavigationNavigator_ContentView.NavigationStyle = .automatic
    
    var body: some View {
        VStack {
            Text(node.name)
                .font(isSubDetail ? .title2 : .largeTitle)
            
            Text("Type: \(node.type.rawValue)")
                .font(.title3)
            
            if let details = node.details {
                Text("Details: \(details)")
                    .padding()
                    .transition(.slideAndFade) // Custom Transition
            }
            
            if let creationDate = node.creationDate {
                Text("Created: \(creationDate, formatter: DateFormatter.localizedDateTime)")
                    .font(.caption)
            }
            
            if let size = node.size {
                Text("Size: \(size) bytes")
                    .font(.caption)
            }
            
            if node.type == .container && !isSubDetail {
                List {
                    ForEach(nodeData.children(of: node)) { childNode in
                        NavigationLink(value: childNode) {
                            NodeRow(node: childNode)
                        }
                    }
                }
                .navigationTitle("Children of \(node.name)")
                .transition(.slideAndFade)
            }
            
            if node.name == "Array" && !isSubDetail {
                List {
                    ForEach(nodeData.subChildren(of: node)) { subChildNode in
                        NavigationLink(value: subChildNode){
                            NodeRow(node: subChildNode)
                        }
                    }
                }
                .navigationTitle("Sub Children of \(node.name)")
            }
            
            //Programmatic Navigation Buttons
            if !isSubDetail {
                HStack {
                    Button("Go to Root") {
                        withAnimation{
                            navigationState.path = []
                            navigationState.selectedNode = nil
                            navigationState.selectedSecondaryNode = nil
                        }
                    }
                    if node.type == .container, let firstChild = nodeData.children(of: node).first {
                        Button("Go to First Child") {
                            if navigationStyle == .stack {
                                withAnimation {
                                    navigationState.path.append(firstChild)
                                }
                            } else {
                                withAnimation {
                                    navigationState.selectedNode = node
                                    navigationState.selectedSecondaryNode = firstChild
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(node.name)
    }
}

// MARK: - Extensions
//Custom transition
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

extension DateFormatter {
    static let localizedDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Previews

struct SwiftUINavigationNavigator_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUINavigationNavigator_ContentView()
            .environmentObject(NavigationState())
            .environmentObject(NodeData.shared)
    }
}
