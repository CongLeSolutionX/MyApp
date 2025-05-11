////
////  AStarPathfinderImplementation.swift
////  MyApp
////
////  Created by Cong Le on 5/10/25.
////
//
//import Foundation
//
//struct Point: Hashable, Equatable {
//    let x: Int
//    let y: Int
//
//    // Conformance to Hashable and Equatable is implicit if members are Hashable/Equatable
//}
//
//
//class Node: Equatable, Hashable, Comparable {
//    let position: Point
//    var gScore: Double       // Cost from start to this node
//    var hScore: Double       // Heuristic cost from this node to goal
//    var parent: Node?        // Parent node in the path
//
//    var fScore: Double {
//        return gScore + hScore
//    }
//
//    init(position: Point, gScore: Double = Double.infinity, hScore: Double = Double.infinity, parent: Node? = nil) {
//        self.position = position
//        self.gScore = gScore
//        self.hScore = hScore
//        self.parent = parent
//    }
//
//    // Equatable (based on position for uniqueness in sets/dictionaries)
//    static func == (lhs: Node, rhs: Node) -> Bool {
//        return lhs.position == rhs.position
//    }
//
//    // Hashable (based on position)
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(position)
//    }
//
//    // Comparable (for Priority Queue, based on fScore, then hScore as tie-breaker)
//    static func < (lhs: Node, rhs: Node) -> Bool {
//        if lhs.fScore == rhs.fScore {
//            return lhs.hScore < rhs.hScore // Tie-breaking prefers lower hScore
//        }
//        return lhs.fScore < rhs.fScore
//    }
//}
//
//struct PriorityQueue {
//    private var heap: [Node] = []
//    // Optional: For more efficient decreaseKey, map Point to heap index
//    // private var nodeIndexMap: [Point: Int] = [:]
//
//    var isEmpty: Bool {
//        return heap.isEmpty
//    }
//
//    var count: Int {
//        return heap.count
//    }
//
//    mutating func insert(_ node: Node) {
//        heap.append(node)
//        // update nodeIndexMap[node.position] = heap.count - 1
//        siftUp(from: heap.count - 1)
//    }
//
//    mutating func extractMin() -> Node? {
//        guard !isEmpty else { return nil }
//        if heap.count == 1 {
//            // let node = heap.removeLast()
//            // nodeIndexMap.removeValue(forKey: node.position)
//            // return node
//            return heap.removeLast()
//        }
//
//        let minNode = heap[0]
//        // nodeIndexMap.removeValue(forKey: minNode.position)
//        heap[0] = heap.removeLast()
//        // nodeIndexMap[heap[0].position] = 0
//        siftDown(from: 0)
//        return minNode
//    }
//
//    // Simplified update: If a node with the same position exists,
//    // this method would find it, update its scores/parent if the new path is better,
//    // and then reheapify. A common alternative for A* if not implementing full decreaseKey
//    // is to allow duplicates in the PQ and check if a node is already in closedSet upon extraction.
//    // For this illustrative plan, we'll assume re-insertion or a check upon extraction is sufficient
//    // if a full decreaseKey with index mapping is too verbose for a single file "illustration".
//    // However, true A* benefits from efficient decreaseKey.
//    // Let's plan for an explicit `update` or `decreaseKey` method that can handle this.
//    // A more robust decreaseKey needs to find the node and sift up.
//    // For simplicity in an illustrative example, we might rely on inserting a "better" version
//    // of the node and letting the PQ sort it out, then handling duplicates upon extraction.
//    // However, the research stressed decrease-key, so let's indicate its presence.
//
//    mutating func updatePriority(for nodeToUpdate: Node, newParent: Node?, newGScore: Double, newHScore: Double) {
//        // Find the node in the heap (e.g., by position if using nodeIndexMap, or iterate)
//        // This is the tricky part without an index map.
//        // For now, let's assume we might re-insert and handle redundancy
//        // or implement a find and update if nodeIndexMap is used.
//        // Conceptual plan:
//        if let index = heap.firstIndex(where: { $0.position == nodeToUpdate.position }) {
//            // Only update if the new path is truly better
//            if newGScore < heap[index].gScore {
//                heap[index].gScore = newGScore
//                heap[index].hScore = newHScore // hScore usually doesn't change for a node, but gScore does.
//                heap[index].parent = newParent
//                siftUp(from: index) // Re-establish heap property if fScore decreased
//                // No need to siftDown because we are decreasing the key (making it "lighter")
//            }
//        } else {
//            // This case should ideally not happen if updatePriority is called for an existing node.
//            // If it's a new node, `insert` should be used.
//            // However, some A* variants might add to open set if not present during consideration.
//            // For robustness:
//            // nodeToUpdate.gScore = newGScore
//            // nodeToUpdate.hScore = newHScore
//            // nodeToUpdate.parent = newParent
//            // insert(nodeToUpdate)
//        }
//    }
//    
//    // Helper methods for heap operations (siftUp, siftDown)
//    private mutating func siftUp(from index: Int) {
//        var childIndex = index
//        let child = heap[childIndex]
//        var parentIndex = self.parentIndex(of: childIndex)
//
//        while childIndex > 0 && child < heap[parentIndex] {
//            heap[childIndex] = heap[parentIndex]
//            // if nodeIndexMap is used: nodeIndexMap[heap[parentIndex].position] = childIndex
//            childIndex = parentIndex
//            parentIndex = self.parentIndex(of: childIndex)
//        }
//        heap[childIndex] = child
//        // if nodeIndexMap is used: nodeIndexMap[child.position] = childIndex
//    }
//
//    private mutating func siftDown(from index: Int) {
//        var parentIndex = index
//        while true {
//            let leftChildIdx = leftChildIndex(of: parentIndex)
//            let rightChildIdx = rightChildIndex(of: parentIndex)
//            var candidateIndex = parentIndex
//
//            if leftChildIdx < count && heap[leftChildIdx] < heap[candidateIndex] {
//                candidateIndex = leftChildIdx
//            }
//            if rightChildIdx < count && heap[rightChildIdx] < heap[candidateIndex] {
//                candidateIndex = rightChildIdx
//            }
//            if candidateIndex == parentIndex {
//                return
//            }
//            // if nodeIndexMap is used:
//            // nodeIndexMap[heap[parentIndex].position] = candidateIndex
//            // nodeIndexMap[heap[candidateIndex].position] = parentIndex
//            heap.swapAt(parentIndex, candidateIndex)
//            parentIndex = candidateIndex
//        }
//    }
//
//    // Index calculation helpers
//    private func parentIndex(of index: Int) -> Int { (index - 1) / 2 }
//    private func leftChildIndex(of index: Int) -> Int { 2 * index + 1 }
//    private func rightChildIndex(of index: Int) -> Int { 2 * index + 2 }
//}
//
//enum HeuristicType {
//    case manhattan
//    case euclidean
//    // Could add: .octile, .chebyshev
//
//    func calculate(from: Point, to: Point) -> Double {
//        let dx = Double(abs(from.x - to.x))
//        let dy = Double(abs(from.y - to.y))
//
//        switch self {
//        case .manhattan:
//            return dx + dy // Assuming D1 = 1
//        case .euclidean:
//            return sqrt(dx * dx + dy * dy) // Assuming D1 = 1
//        }
//    }
//}
//
//
//class AStarPathfinder {
//    let grid: [[Bool]] // True for obstacle, false for walkable
//    let heuristic: HeuristicType
//    let epsilon: Double // For Weighted A*: f(n) = g(n) + epsilon * h(n)
//    let allowDiagonalMovement: Bool
//
//    init(grid: [[Bool]], heuristic: HeuristicType = .manhattan, epsilon: Double = 1.0, allowDiagonalMovement: Bool = true) {
//        self.grid = grid
//        self.heuristic = heuristic
//        self.epsilon = epsilon
//        self.allowDiagonalMovement = allowDiagonalMovement
//    }
//
//    func findPath(start: Point, goal: Point) -> [Point]? {
//        guard isValidAndWalkable(start) && isValidAndWalkable(goal) else {
//            // print("Start or Goal is invalid or not walkable.")
//            return nil
//        }
//
//        var openSet = PriorityQueue()
//        var closedSet = Set<Point>() // Store positions of nodes already processed
//
//        // Store Node objects by their Point for efficient lookup and updates
//        var allNodes = [Point: Node]()
//
//        let startNode = Node(position: start, gScore: 0, hScore: heuristic.calculate(from: start, to: goal))
//        allNodes[start] = startNode
//        openSet.insert(startNode)
//        
//        // gScores could also be stored in the Node objects within allNodes
//        // var gScores = [Point: Double]()
//        // gScores[start] = 0
//        
//        // cameFrom for path reconstruction
//        // This can also be achieved by `node.parent`
//        // var cameFrom = [Point: Point]()
//
//        while !openSet.isEmpty {
//            guard let currentNode = openSet.extractMin() else { break }
//
//            if currentNode.position == goal {
//                return reconstructPath(from: currentNode)
//            }
//
//            // If a node with same position but worse fScore was extracted later, ignore it
//            // This check is important if PQ doesn't perfectly handle decreaseKey or allows duplicates.
//            // Or, if currentNode is already in closedSet and consistent heuristic is used, skip.
//            // With a good PQ and decreaseKey, this might not be strictly necessary,
//            // but safe for illustrative code.
//            if closedSet.contains(currentNode.position) {
//                continue
//            }
//            closedSet.insert(currentNode.position)
//
//            for neighborPosition in getNeighbors(for: currentNode.position) {
//                if closedSet.contains(neighborPosition) { // Already processed this neighbor optimally
//                    continue
//                }
//                
//                let costToNeighbor = (neighborPosition.x != currentNode.position.x && neighborPosition.y != currentNode.position.y) ? 1.414 : 1.0 // Diagonal vs. Cardinal cost
//                let tentativeGScore = currentNode.gScore + costToNeighbor
//
//                // Retrieve or create neighbor node
//                let neighborNode = allNodes[neighborPosition] ?? Node(position: neighborPosition)
//                if allNodes[neighborPosition] == nil { allNodes[neighborPosition] = neighborNode }
//
//                if tentativeGScore < neighborNode.gScore {
//                    neighborNode.parent = currentNode
//                    neighborNode.gScore = tentativeGScore
//                    neighborNode.hScore = heuristic.calculate(from: neighborPosition, to: goal) * self.epsilon // Apply epsilon for Weighted A*
//                    
//                    // Check if neighbor is in openSet (conceptually)
//                    // Our PriorityQueue.updatePriority will attempt to find it and update or insert if totally new based on Point
//                    // A more direct way to check if it was already added is needed if not using `allNodes`
//                    // For this plan: we assume updatePriority handles finding existing or adding if necessary.
//                    // More typically, you'd check if it's in openSet using a separate Set<Point> or by looking up in `allNodes` and seeing if its gScore was infinity.
//                    
//                    // Let's refine the update logic:
//                    let wasAlreadyInOpenSet = neighborNode.gScore != Double.infinity // A simple proxy
//                    
//                    if !wasAlreadyInOpenSet { // If it wasn't "discovered" before with a finite gScore
//                         openSet.insert(neighborNode) // This will also update its position in `nodeIndexMap` for the PQ
//                    } else {
//                        // If it was discovered and is in openSet, and we found a better path
//                        // Our current PQ.updatePriority() tries to find and update.
//                        // An alternative without complex decreaseKey is to just insert the "better" node version
//                        // openSet.insert(neighborNode)
//                        // And rely on the PQ to extract lower fScore first, and closedSet to skip re-processing
//                        // For explicit decreaseKey demonstration:
//                        openSet.updatePriority(for: neighborNode, newParent: currentNode, newGScore: tentativeGScore, newHScore: neighborNode.hScore / self.epsilon) // reverse epsilon for storage
//                    }
//                }
//            }
//        }
//        return nil // No path found
//    }
//
//    private func isValidAndWalkable(_ point: Point) -> Bool {
//        guard point.x >= 0 && point.x < grid[0].count && point.y >= 0 && point.y < grid.count else {
//            return false // Out of bounds
//        }
//        return !grid[point.y][point.x] // Not an obstacle
//    }
//
//    private func getNeighbors(for point: Point) -> [Point] {
//        var neighbors: [Point] = []
//        let directions = [
//            (0, 1), (0, -1), (1, 0), (-1, 0), // Cardinal
//        ]
//        let diagonalDirections = [
//            (1, 1), (1, -1), (-1, 1), (-1, -1) // Diagonal
//        ]
//
//        for dir in directions {
//            let neighbor = Point(x: point.x + dir.0, y: point.y + dir.1)
//            if isValidAndWalkable(neighbor) {
//                neighbors.append(neighbor)
//            }
//        }
//        
//        if allowDiagonalMovement {
//            for dir in diagonalDirections {
//                let neighbor = Point(x: point.x + dir.0, y: point.y + dir.1)
//                 // Optional: Add check to prevent cutting corners if obstacles are present
//                 // e.g., if grid[point.y + dir.1][point.x] is obstacle AND grid[point.y][point.x + dir.0] is obstacle
//                if isValidAndWalkable(neighbor) {
//                    neighbors.append(neighbor)
//                }
//            }
//        }
//        return neighbors
//    }
//
//    private func reconstructPath(from node: Node) -> [Point] {
//        var path: [Point] = []
//        var current: Node? = node
//        while let c = current {
//            path.append(c.position)
//            current = c.parent
//        }
//        return path.reversed()
//    }
//}
//
//
//// ---- Example Usage ----
//func runAStarExample() {
//    // Define a simple grid (false = walkable, true = obstacle)
//    //  S . . .
//    //  # # # .
//    //  . . . G
//    let grid: [[Bool]] = [
//        [false, false, false, false],
//        [true,  true,  true,  false],
//        [false, false, false, false]
//    ]
//
//    let startPoint = Point(x: 0, y: 0)
//    let goalPoint = Point(x: 3, y: 2)
//
//    // Using Manhattan Heuristic
//    print("--- A* with Manhattan Heuristic ---")
//    let pathfinderManhattan = AStarPathfinder(grid: grid, heuristic: .manhattan, allowDiagonalMovement: false)
//    if let path = pathfinderManhattan.findPath(start: startPoint, goal: goalPoint) {
//        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
//        visualizePath(grid: grid, path: path)
//    } else {
//        print("No path found.")
//    }
//
//    // Using Euclidean Heuristic with diagonal movement
//    print("\n--- A* with Euclidean Heuristic (Diagonal Allowed) ---")
//    let pathfinderEuclidean = AStarPathfinder(grid: grid, heuristic: .euclidean, allowDiagonalMovement: true)
//    if let path = pathfinderEuclidean.findPath(start: startPoint, goal: goalPoint) {
//        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
//        visualizePath(grid: grid, path: path)
//    } else {
//        print("No path found.")
//    }
//    
//    // Example of Weighted A* (faster, possibly suboptimal)
//    print("\n--- Weighted A* (epsilon=2.0) with Euclidean Heuristic ---")
//    let pathfinderWeighted = AStarPathfinder(grid: grid, heuristic: .euclidean, epsilon: 2.0, allowDiagonalMovement: true)
//    if let path = pathfinderWeighted.findPath(start: startPoint, goal: goalPoint) {
//        print("Path found: \(path.map { "(\($0.x),\($0.y))" })")
//        visualizePath(grid: grid, path: path)
//    } else {
//        print("No path found.")
//    }
//}
//
//func visualizePath(grid: [[Bool]], path: [Point]) {
//    var displayGrid = grid.map { row in row.map { $0 ? "#" : "." } }
//    for point in path {
//        if point == path.first! {
//            displayGrid[point.y][point.x] = "S"
//        } else if point == path.last! {
//            displayGrid[point.y][point.x] = "G"
//        } else {
//            displayGrid[point.y][point.x] = "*"
//        }
//    }
//    for row in displayGrid {
//        print(row.joined(separator: " "))
//    }
//}
//
//// To run the example:
//// runAStarExample()
