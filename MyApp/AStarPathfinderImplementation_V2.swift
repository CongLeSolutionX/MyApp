//
//  AStarPathfinderImplementation_V2.swift
//  MyApp
//
//  Created by Cong Le on 5/10/25.
//

import Foundation // For sqrt


// MARK: - Core Data Structures

struct Point: Hashable, Equatable {
    let x: Int
    let y: Int
}

class Node: Equatable, Hashable, Comparable {
    let position: Point
    var gScore: Double       // Cost from start to this node
    var hScore: Double       // Heuristic cost from this node to goal (already epsilon-weighted if applicable)
    var parent: Node?        // Parent node in the path

    var fScore: Double {
        // hScore is assumed to be pre-weighted by epsilon by the AStarPathfinder
        return gScore + hScore
    }

    init(position: Point, gScore: Double = Double.infinity, hScore: Double = Double.infinity, parent: Node? = nil) {
        self.position = position
        self.gScore = gScore
        self.hScore = hScore
        self.parent = parent
    }

    // Equatable (based on position for uniqueness in sets/dictionaries)
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.position == rhs.position
    }

    // Hashable (based on position)
    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }

    // Comparable (for Priority Queue, based on fScore, then hScore as tie-breaker)
    static func < (lhs: Node, rhs: Node) -> Bool {
        if lhs.fScore == rhs.fScore {
            return lhs.hScore < rhs.hScore // Tie-breaking prefers lower hScore
        }
        return lhs.fScore < rhs.fScore
    }
}

// MARK: - Priority Queue (Min-Heap)

struct PriorityQueue {
    private var heap: [Node] = []
    // For a production-quality Priority Queue supporting efficient O(log N) decreaseKey,
    // a dictionary mapping Node positions (or unique IDs) to their index in the heap array
    // would be maintained here and updated during heap operations.
    // E.g., private var nodeIndexMap: [Point: Int] = [:]

    var isEmpty: Bool {
        return heap.isEmpty
    }

    var count: Int {
        return heap.count
    }

    mutating func insert(_ node: Node) {
        heap.append(node)
        // If using nodeIndexMap: nodeIndexMap[node.position] = heap.count - 1
        siftUp(from: heap.count - 1)
    }

    mutating func extractMin() -> Node? {
        guard !isEmpty else { return nil }
        if heap.count == 1 {
            let node = heap.removeLast()
            // If using nodeIndexMap: nodeIndexMap.removeValue(forKey: node.position)
            return node
        }

        let minNode = heap[0]
        // If using nodeIndexMap: nodeIndexMap.removeValue(forKey: minNode.position)
        
        heap[0] = heap.removeLast()
        // If using nodeIndexMap: nodeIndexMap[heap[0].position] = 0
        
        siftDown(from: 0)
        return minNode
    }

    // Updates the priority of a node already in the queue.
    // This implementation finds the node by scanning the heap (O(N) operation).
    // An optimized version would use nodeIndexMap for O(1) lookup before sifting.
    mutating func updatePriority(forNodeAt position: Point, newGScore: Double, newParent: Node?) {
        guard let index = heap.firstIndex(where: { $0.position == position }) else {
            // This implies the node (by position) is not currently in the open set (heap).
            // This function assumes it's called for nodes known to be in the heap.
            // If A* logic ensures this, then this path might indicate an issue or
            // a previously extracted node (now in closed set) that shouldn't be updated.
            // For this illustrative example, we'll proceed assuming the caller ensures validity.
            // print("Warning: Attempted to update priority for a node not found in PQ at position \(position).")
            return
        }

        let nodeInHeap = heap[index] // This is a reference to the Node object

        // Only update if the new path is truly better
        if newGScore < nodeInHeap.gScore {
            nodeInHeap.gScore = newGScore
            nodeInHeap.parent = newParent
            // nodeInHeap.hScore is assumed to have been correctly set by AStarPathfinder
            // (including epsilon weighting) before this call.
            siftUp(from: index) // Re-establish heap property if fScore decreased
        }
    }
    
    // Helper methods for heap operations
    private mutating func siftUp(from index: Int) {
        var childIndex = index
        let child = heap[childIndex]
        var parentIdx = parentIndex(of: childIndex)

        while childIndex > 0 && child < heap[parentIdx] {
            heap[childIndex] = heap[parentIdx]
            /* If using nodeIndexMap:
            nodeIndexMap[heap[parentIdx].position] = childIndex
            */
            childIndex = parentIdx
            parentIdx = parentIndex(of: childIndex)
        }
        heap[childIndex] = child
        /* If using nodeIndexMap:
        nodeIndexMap[child.position] = childIndex
        */
    }

    private mutating func siftDown(from index: Int) {
        var parentIdx = index
        while true {
            let leftChildIdx = leftChildIndex(of: parentIdx)
            let rightChildIdx = rightChildIndex(of: parentIdx)
            var candidateIndex = parentIdx

            if leftChildIdx < count && heap[leftChildIdx] < heap[candidateIndex] {
                candidateIndex = leftChildIdx
            }
            if rightChildIdx < count && heap[rightChildIdx] < heap[candidateIndex] {
                candidateIndex = rightChildIdx
            }
            if candidateIndex == parentIdx {
                return // Heap property satisfied
            }
            
            /* If using nodeIndexMap:
            nodeIndexMap[heap[parentIdx].position] = candidateIndex
            nodeIndexMap[heap[candidateIndex].position] = parentIdx
            */
            heap.swapAt(parentIdx, candidateIndex)
            parentIdx = candidateIndex
        }
    }

    // Index calculation helpers
    private func parentIndex(of index: Int) -> Int { (index - 1) / 2 }
    private func leftChildIndex(of index: Int) -> Int { 2 * index + 1 }
    private func rightChildIndex(of index: Int) -> Int { 2 * index + 2 }
}

// MARK: - Heuristic Functions

enum HeuristicType {
    case manhattan
    case euclidean
    // Could add: .octile(diagonal), .chebyshev

    // D is the cost of moving one square horizontally/vertically
    // D2 is the cost of moving diagonally
    func calculate(from: Point, to: Point, D1: Double = 1.0, D2: Double = 1.414) -> Double {
        let dx = Double(abs(from.x - to.x))
        let dy = Double(abs(from.y - to.y))

        switch self {
        case .manhattan:
            return D1 * (dx + dy)
        case .euclidean:
            return D1 * sqrt(dx * dx + dy * dy)
        // Example Octile: return D1 * (dx + dy) + (D2 - 2 * D1) * min(dx, dy)
        // Example Chebyshev: return D1 * max(dx, dy)
        }
    }
}

// MARK: - A* Pathfinding Algorithm

class AStarPathfinder {
    let grid: [[Bool]] // True for obstacle, false for walkable
    let heuristic: HeuristicType
    let epsilon: Double // For Weighted A*: f(n) = g(n) + epsilon * h(n). Applied to hScore.
    let allowDiagonalMovement: Bool
    let D1: Double = 1.0 // Cost for cardinal movement
    let D2: Double = 1.414 // Cost for diagonal movement (sqrt(2) * D1)

    init(grid: [[Bool]], heuristic: HeuristicType = .manhattan, epsilon: Double = 1.0, allowDiagonalMovement: Bool = true) {
        self.grid = grid
        self.heuristic = heuristic
        self.epsilon = epsilon
        self.allowDiagonalMovement = allowDiagonalMovement
    }

    func findPath(start: Point, goal: Point) -> [Point]? {
        guard isValidAndWalkable(start) && isValidAndWalkable(goal) else {
            print("Start or Goal is invalid, out of bounds, or an obstacle.")
            return nil
        }

        var openSet = PriorityQueue()
        var closedSet = Set<Point>() // Stores positions of nodes already processed (expanded)
        
        // Stores all Node objects ever created/considered for easy access and update.
        // The gScore in these nodes also implicitly tells us if they've been "discovered"
        // with a finite path from start (if gScore != Double.infinity).
        var allNodes = [Point: Node]()

        let rawHStart = heuristic.calculate(from: start, to: goal, D1: D1, D2: D2)
        let startNode = Node(position: start, gScore: 0, hScore: rawHStart * self.epsilon, parent: nil)
        allNodes[start] = startNode
        openSet.insert(startNode)
        
        while !openSet.isEmpty {
            guard let currentNode = openSet.extractMin() else { break } // Should not happen if !isEmpty

            if currentNode.position == goal {
                return reconstructPath(from: currentNode)
            }

            // If already processed (i.e., expanded and neighbors considered), skip.
            // This handles cases where a node might be re-added to openSet with a higher fScore
            // or if using a non-consistent heuristic that requires reopening (though
            // typical A* with consistent heuristic doesn't need to re-expand from closedSet).
            if closedSet.contains(currentNode.position) {
                continue
            }
            closedSet.insert(currentNode.position)

            for neighborPosition in getNeighbors(for: currentNode.position) {
                if closedSet.contains(neighborPosition) { // Already processed this neighbor optimally
                    continue
                }
                
                let costToNeighbor = (neighborPosition.x != currentNode.position.x && neighborPosition.y != currentNode.position.y) ? D2 : D1
                let tentativeGScore = currentNode.gScore + costToNeighbor

                let neighborNode = allNodes[neighborPosition, default: Node(position: neighborPosition)]
                if allNodes[neighborPosition] == nil { // First time we're considering this point in graph
                    allNodes[neighborPosition] = neighborNode
                }
                
                // Check if this path to neighbor is better than any previously found
                if tentativeGScore < neighborNode.gScore {
                    neighborNode.parent = currentNode
                    neighborNode.gScore = tentativeGScore
                    let rawHNeighbor = heuristic.calculate(from: neighborPosition, to: goal, D1: D1, D2: D2)
                    neighborNode.hScore = rawHNeighbor * self.epsilon // Apply epsilon weighting
                    
                    // Determine if neighborNode was already in openSet (conceptually)
                    // This is a proxy: if its gScore was infinity, it wasn't added with a valid path yet.
                    // A more direct way might be a separate Set<Point> for nodes *currently* in openSet.
                    // Or, reliance on PriorityQueue's update/insert logic.
                    let wasEffectivelyNew = (neighborNode.gScore == tentativeGScore) && (heap.firstIndex(where: {$0.position == neighborNode.position}) == nil) // A bit heuristic, check if it just got updated


                    // If it's the first time we're setting a finite gScore, or if it's not in the heap currently.
                    // A more robust check for "is in open set" might involve another data structure
                    // or checking if the node's fScore before this update was not infinity.
                    // For simplicity, we rely on PQ trying to update; if not found, it means it wasn't in.
                    // Better: Check if `allNodes[neighborPosition]` was just created or had gScore = infinity prior to update
                    
                    // Simplified logic: if we found a better path to neighborNode,
                    // it needs to be in the openSet with its new, better fScore.
                    // If it's already in openSet, its priority needs update.
                    // If it's not, it needs to be inserted.
                    
                    // Let's find if it exists in the current heap. This is O(N) without map.
                    if let _ = heap.firstIndex(where: { $0.position == neighborNode.position }) {
                         openSet.updatePriority(forNodeAt: neighborPosition, newGScore: tentativeGScore, newParent: currentNode)
                    } else {
                        // Not currently in OpenSet (heap), so insert.
                        // This also covers the case where it was never discovered before.
                        openSet.insert(neighborNode)
                    }
                }
            }
        }
        return nil // No path found
    }

    private func isValidAndWalkable(_ point: Point) -> Bool {
        guard point.y >= 0 && point.y < grid.count && point.x >= 0 && point.x < grid[0].count else {
            return false // Out of bounds
        }
        return !grid[point.y][point.x] // Not an obstacle (false means walkable)
    }

    private func getNeighbors(for point: Point) -> [Point] {
        var neighbors: [Point] = []
        
        var directions: [(Int, Int)] = []
        // Cardinal directions
        directions.append(contentsOf: [(0, 1), (0, -1), (1, 0), (-1, 0)])
        
        if allowDiagonalMovement {
            // Diagonal directions
            directions.append(contentsOf: [(1, 1), (1, -1), (-1, 1), (-1, -1)])
        }

        for dir in directions {
            let neighbor = Point(x: point.x + dir.0, y: point.y + dir.1)
            if isValidAndWalkable(neighbor) {
                // Optional: Add sophisticated check to prevent cutting corners if obstacles are present for diagonal moves
                // e.g., if moving from (x,y) to (x+1,y+1), check (x+1,y) and (x,y+1) are not both obstacles,
                // or specific rules depending on how "corner cutting" is defined.
                // For this example, simple walkability is sufficient.
                neighbors.append(neighbor)
            }
        }
        return neighbors
    }

    private func reconstructPath(from node: Node) -> [Point] {
        var path: [Point] = []
        var current: Node? = node
        while let c = current {
            path.append(c.position)
            current = c.parent
        }
        return path.reversed() // Path from start to goal
    }
}

// MARK: - Example Usage and Visualization

func runAStarExample() {
    // Define a simple grid (false = walkable, true = obstacle)
    //  S . . .
    //  # # # .
    //  . . . G
    let grid: [[Bool]] = [
        [false, false, false, false], // Row 0
        [true,  true,  true,  false], // Row 1
        [false, false, false, false]  // Row 2
    ]
    let gridHeight = grid.count
    let gridWidth = grid[0].count

    print("Grid Dimensions: \(gridWidth)x\(gridHeight)")
    print("Legend: S=Start, G=Goal, #=Obstacle, .=Walkable, *=Path")

    let startPoint = Point(x: 0, y: 0)
    let goalPoint = Point(x: 3, y: 2)
    
    print("\n--- A* with Manhattan Heuristic (No Diagonal) ---")
    let pathfinderManhattan = AStarPathfinder(grid: grid, heuristic: .manhattan, epsilon: 1.0, allowDiagonalMovement: false)
    if let path = pathfinderManhattan.findPath(start: startPoint, goal: goalPoint) {
        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
        visualizePath(grid: grid, path: path, start: startPoint, goal: goalPoint)
    } else {
        print("No path found.")
    }

    print("\n--- A* with Euclidean Heuristic (Diagonal Allowed) ---")
    let pathfinderEuclidean = AStarPathfinder(grid: grid, heuristic: .euclidean, epsilon: 1.0, allowDiagonalMovement: true)
    if let path = pathfinderEuclidean.findPath(start: startPoint, goal: goalPoint) {
        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
        visualizePath(grid: grid, path: path, start: startPoint, goal: goalPoint)
    } else {
        print("No path found.")
    }
    
    print("\n--- Weighted A* (epsilon=2.0) with Euclidean Heuristic (Diagonal Allowed) ---")
    let pathfinderWeighted = AStarPathfinder(grid: grid, heuristic: .euclidean, epsilon: 2.0, allowDiagonalMovement: true)
    if let path = pathfinderWeighted.findPath(start: startPoint, goal: goalPoint) {
        print("Path found (Weighted A*): \(path.map { "(\($0.x),\($0.y))" })")
        print("Note: Weighted A* finds paths faster but may not be optimal (cost bound by epsilon * optimal_cost).")
        visualizePath(grid: grid, path: path, start: startPoint, goal: goalPoint)
    } else {
        print("No path found (Weighted A*).")
    }

    let impossibleGrid: [[Bool]] = [
        [false, true, false],
        [false, true, false],
        [false, true, false]
    ]
    let startImpossible = Point(x:0, y:0)
    let goalImpossible = Point(x:2, y:0)
    print("\n--- A* Impossible Path Example ---")
    let pathfinderImpossible = AStarPathfinder(grid: impossibleGrid, heuristic: .manhattan)
    if let path = pathfinderImpossible.findPath(start: startImpossible, goal: goalImpossible) {
        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
        visualizePath(grid: impossibleGrid, path: path, start: startImpossible, goal: goalImpossible)
    } else {
        print("No path found, as expected.")
        visualizePath(grid: impossibleGrid, path: [], start: startImpossible, goal: goalImpossible)
    }
}

func visualizePath(grid: [[Bool]], path: [Point], start: Point, goal: Point) {
    var displayGrid = grid.map { row in row.map { $0 ? "#" : "." } }
    
    for p in path {
        // Ensure point is within bounds before trying to mark it
        if p.y >= 0 && p.y < displayGrid.count && p.x >= 0 && p.x < displayGrid[0].count {
            if p == start {
                displayGrid[p.y][p.x] = "S"
            } else if p == goal {
                displayGrid[p.y][p.x] = "G"
            } else {
                displayGrid[p.y][p.x] = "*"
            }
        }
    }
    // Ensure start and goal are marked even if path is empty (e.g. no path found)
    if displayGrid[start.y][start.x] != "*" { displayGrid[start.y][start.x] = "S" }
    if displayGrid[goal.y][goal.x] != "*" { displayGrid[goal.y][goal.x] = "G" }


    for row in displayGrid {
        print(row.joined(separator: " "))
    }
}

// To run the example (e.g., in a Swift Playground or command-line app):
// runAStarExample()

