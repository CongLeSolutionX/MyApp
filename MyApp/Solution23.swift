////
////  Solution23.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
///// Represents a point in the compressed 2D grid.
//fileprivate struct Point: Hashable {
//    let x: Int // Compressed x-coordinate
//    let y: Int // Compressed y-coordinate
//}
//
///// Represents a directed unit edge/segment between two adjacent points
///// in the compressed grid. Hashable for use in Sets.
///// We store it directed from `a` to `b` based on the painting direction.
//fileprivate struct Edge: Hashable {
//    let a: Point
//    let b: Point
//
//    // Note: Initialization maintains directionality as painted.
//    // The checking logic later constructs canonical edges for lookups.
//}
//
///// Solves the Mathematical Art problem by finding the number of "plus signs" painted.
/////
///// A plus sign exists at a point (x, y) if painted segments extend from it
///// in all four cardinal directions (up, down, left, right).
/////
///// The algorithm uses coordinate compression to map the potentially vast drawing area
///// onto a smaller grid. It then records all painted unit segments on this compressed
///// grid and checks each internal grid vertex for the plus sign pattern.
/////
///// - Parameters:
/////   - N: The number of brush strokes.
/////   - L: An array of integers representing the length of each stroke.
/////   - D: A string representing the direction of each stroke ('U', 'D', 'L', 'R').
///// - Returns: The total number of positions (internal vertices in the compressed grid)
/////            where a plus sign is present.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else {
//        // Need at least 2 segments to potentially form intersections.
//        // Mismatched input lengths are invalid.
//        return 0
//    }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Coordinates ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    // Use Sets for efficient unique coordinate collection. Start at origin.
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    // Store the sequence of vertices in the original coordinate space.
//    var pathVertices = [Point(x: 0, y: 0)] // Start at the origin
//
//    for i in 0..<N {
//        let length = L[i]
//        let direction = directions[i]
//
//        // Skip zero-length segments as they don't paint anything.
//        guard length > 0 else {
//            // Ensure the current point is recorded even if the segment has length 0
//            // Although the problem statement implies L >= 1, this is safer.
//            // If the last point isn't the same as the current, add it.
//            // This check is likely redundant if L >= 1 is guaranteed.
//             if pathVertices.last?.x != currentX || pathVertices.last?.y != currentY {
//                 pathVertices.append(Point(x: currentX, y: currentY))
//             }
//             continue
//        }
//
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default:
//            // Should not happen based on constraints, but handle defensively.
//             fatalError("Invalid direction encountered: \(direction)")
//        }
//
//        // Add end coordinates to the sets for compression
//        allX.insert(nextX)
//        allY.insert(nextY)
//
//        // Update current position and add the new vertex to the path
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append(Point(x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Create dictionaries mapping original coordinates to compressed indices.
//    // Using enumerated().map is efficient for creating these lookup maps.
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//
//    // Get the dimensions of the compressed grid.
//    let compNX = sortedX.count // Number of unique x-coordinates
//    let compNY = sortedY.count // Number of unique y-coordinates
//
//    // A plus sign requires segments centered around an internal grid vertex.
//    // This requires at least 3 unique x and 3 unique y coordinates.
//    guard compNX >= 3 && compNY >= 3 else {
//        return 0 // Cannot form a plus sign without internal grid points.
//    }
//
//    // --- Step 3: Populate Compressed Edge Sets ---
//    // Store all UNIT LENGTH painted segments in the compressed grid.
//    var hEdges = Set<Edge>() // Stores horizontal unit edges
//    var vEdges = Set<Edge>() // Stores vertical unit edges
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOriginal = pathVertices[i]
//        let endOriginal = pathVertices[i+1]
//
//        // Map original segment ends to compressed coordinates. Force-unwrap is safe
//        // because all path vertices' coordinates were added to allX/allY.
//        let cx1 = xMap[startOriginal.x]!
//        let cy1 = yMap[startOriginal.y]!
//        let cx2 = xMap[endOriginal.x]!
//        let cy2 = yMap[endOriginal.y]!
//
//        if cx1 == cx2 { // Vertical movement
//            // Determine the range of compressed y-indices to iterate over.
//            let startCY = min(cy1, cy2)
//            let endCY = max(cy1, cy2)
//            // Add all unit vertical segments along this path.
//            for cy in startCY..<endCY {
//                let fromPoint = Point(x: cx1, y: cy)
//                let toPoint = Point(x: cx1, y: cy + 1)
//                // Insert the edge; direction matches the canonical check later.
//                // We store (lower_y_point, higher_y_point) for vertical edges.
//                vEdges.insert(Edge(a: fromPoint, b: toPoint))
//            }
//        } else { // Horizontal movement (cy1 == cy2)
//            // Determine the range of compressed x-indices to iterate over.
//            let startCX = min(cx1, cx2)
//            let endCX = max(cx1, cx2)
//            // Add all unit horizontal segments along this path.
//            for cx in startCX..<endCX {
//                let fromPoint = Point(x: cx, y: cy1)
//                let toPoint = Point(x: cx + 1, y: cy1)
//                // Insert the edge; direction matches the canonical check later.
//                // We store (left_x_point, right_x_point) for horizontal edges.
//                hEdges.insert(Edge(a: fromPoint, b: toPoint))
//            }
//        }
//    }
//
//    // --- Step 4: Check for Plus Signs at Internal Grid Points ---
//    var plusCount = 0
//    // Iterate through all *internal* vertices of the compressed grid.
//    // A center (cx, cy) must be at indices 1 <= cx < compNX-1 and 1 <= cy < compNY-1.
//    for cy in 1..<(compNY - 1) {
//        for cx in 1..<(compNX - 1) {
//            // Define the four *canonical* unit edges required around the center (cx, cy):
//            // Edge points are defined relative to the potential center 'centerPoint'.
//            // For lookups, we construct edges in a consistent way (e.g., left-to-right, bottom-to-top).
//
//            // Left horizontal edge: from (cx-1, cy) to (cx, cy)
//            let leftEdge = Edge(a: Point(x: cx - 1, y: cy), b: Point(x: cx, y: cy))
//
//            // Right horizontal edge: from (cx, cy) to (cx+1, cy)
//            let rightEdge = Edge(a: Point(x: cx, y: cy), b: Point(x: cx + 1, y: cy))
//
//            // Down vertical edge: from (cx, cy-1) to (cx, cy)
//            let downEdge = Edge(a: Point(x: cx, y: cy - 1), b: Point(x: cx, y: cy))
//
//            // Up vertical edge: from (cx, cy) to (cx, cy+1)
//            let upEdge = Edge(a: Point(x: cx, y: cy), b: Point(x: cx, y: cy + 1))
//
//            // Check if all four canonical edges exist in the corresponding sets.
//            if hEdges.contains(leftEdge) &&
//               hEdges.contains(rightEdge) &&
//               vEdges.contains(downEdge) &&
//               vEdges.contains(upEdge) {
//                // If all four are present, we found a plus sign centered at (cx, cy).
//                plusCount += 1
//            }
//        }
//    }
//
//    return plusCount
//}
////
////// --- Testing with Examples ---
////print("--- Running Sample Test Cases ---")
////
////let N1 = 9
////let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
////let D1 = "ULDRULURD"
////let result1 = getPlusSignCount(N1, L1, D1)
////print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)") // Expected: 4
////
////let N2 = 8
////let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
////let D2 = "RDLUULDR"
////let result2 = getPlusSignCount(N2, L2, D2)
////print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Expected: 1
////
////let N3 = 8
////let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
////let D3 = "UDUDLRLR"
////let result3 = getPlusSignCount(N3, L3, D3)
////print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Expected: 1
////
////print("\n--- Running Boundary/Edge Test Cases ---")
////// Test Case: Rectangle - No interior crossing points
////let N4 = 4
////let L4 = [5, 2, 5, 2]
////let D4 = "RDLU"
////let result4 = getPlusSignCount(N4, L4, D4)
////print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////
////// Test Case: Intersection creating an internal vertex needed for a plus
////let N6 = 4
////let L6 = [5, 2, 3, 4] // R 5, D 2, L 3, U 4 -> Path (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
////let D6 = "RDLU"        // Creates a plus at (2, 0) in original coords.
////let result6 = getPlusSignCount(N6, L6, D6)
////print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////// Test Case: No plus sign possible with only two segments
////let N7 = 2
////let L7 = [5, 5]
////let D7 = "RU"
////let result7 = getPlusSignCount(N7, L7, D7)
////print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////
////// Test Case: Single long horizontal line - No vertical segments
////let N8 = 1
////let L8 = [100]
////let D8 = "R"
////let result8 = getPlusSignCount(N8, L8, D8)
////print("Sample 8 (Single Line) Result: \(result8) (\(result8 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////
////// Test Case: Four segments forming a cross but not closing
////let N9 = 4
////let L9 = [2, 2, 2, 2]
////let D9 = "RULD" // Forms a cross centered at (0,0) essentially -> (0,0)->(2,0)->(2,2)->(0,2)->(0,0) Correct paths -> RDLU (0,0)->(2,0)->(2,-2)->(-1,-2)->(-1,0) This DOES NOT form a plus sign as required.
////// Let's make one that *does* center at (0,0)
////// R 2 -> (2,0)
////// L 4 -> (-2,0)
////// U 2 -> (-2,2)
////// D 4 -> (-2,-2)
////let N10 = 4
////let L10 = [2, 4, 2, 4]
////let D10 = "RLUD" // Path: (0,0)->(2,0) -> (-2,0) -> (-2,2) -> (-2,-2) ... this still doesn't make a clean plus centered anywhere easily.
////// Better example: Center at (0,0) requires segments passing *through* it.
////// R 1 -> (1,0) ; L 2 -> (-1,0) ; U 1 -> (-1,1); D 2 -> (-1,-1)
////let N11 = 4
////let L11 = [1, 2, 1, 2]
////let D11 = "RLUD" // Path: (0,0)->(1,0)->(-1,0)->(-1,1)->(-1,-1). Paints [-1,0] to [1,0] horizontally, [-1,-1] to [-1,1] vertically. Plus sign at (-1,0).
////let result11 = getPlusSignCount(N11, L11, D11)
////print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////print("\n--- Testing Complete ---")
