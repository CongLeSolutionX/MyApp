////
////  Solution11.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
///// Solves the Mathematical Art problem by finding the number of "plus signs" painted.
/////
///// A plus sign exists at a point (x, y) if painted segments extend from it
///// in all four cardinal directions (up, down, left, right).
/////
///// The algorithm uses coordinate compression and a sweep-line approach
///// to build grids representing horizontal and vertical segments,
///// then efficiently checks for the plus sign pattern at internal grid vertices.
/////
///// - Parameters:
/////   - N: The number of brush strokes.
/////   - L: An array of integers representing the length of each stroke.
/////   - D: A string representing the direction of each stroke ('U', 'D', 'L', 'R').
///// - Returns: The total number of positions where a plus sign is present.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    // Need at least 2 segments to potentially form intersections,
//    // and L and D arrays must match N.
//    guard N >= 2, L.count == N, D.count == N else {
//        // Cannot form a plus sign with insufficient data or mismatched inputs.
//        return 0
//    }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path, Collect Coordinates & Raw Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    // Use Sets for efficient unique coordinate collection. Start at origin.
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//
//    // Store raw sweep-line events: (coordinate_of_event, constant_coordinate, type: +1 start, -1 end)
//    // The first element is the coordinate along the sweep direction.
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Event at x, on row y (Horizontal sweep)
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Event at y, on column x (Vertical sweep)
//
//    var startX = 0 // Track the starting point of the current segment
//    var startY = 0
//
//    for i in 0..<N {
//        let length = L[i]
//        // Skip zero-length segments as they don't paint anything.
//        guard length > 0 else { continue }
//        let direction = directions[i]
//
//        // Record the start point of the segment
//        startX = currentX
//        startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            // Add vertical segment events: start (lower y) and end (higher y)
//            rawVEvents.append((y: startY, x: startX, type: 1))
//            rawVEvents.append((y: endY,   x: startX, type: -1))
//        case "D":
//            endY -= length
//            // Add vertical segment events: start (lower y) and end (higher y)
//            rawVEvents.append((y: endY,   x: startX, type: 1))
//            rawVEvents.append((y: startY, x: startX, type: -1))
//        case "L":
//            endX -= length
//            // Add horizontal segment events: start (left x) and end (right x)
//            rawHEvents.append((x: endX,   y: startY, type: 1))
//            rawHEvents.append((x: startX, y: startY, type: -1))
//        case "R":
//            endX += length
//            // Add horizontal segment events: start (left x) and end (right x)
//            rawHEvents.append((x: startX, y: startY, type: 1))
//            rawHEvents.append((x: endX,   y: startY, type: -1))
//        default:
//             // Fail fast for invalid input, although constraints might guarantee valid directions.
//             fatalError("Invalid direction encountered: \(direction)")
//        }
//
//        // Update current position for the next stroke
//        currentX = endX
//        currentY = endY
//
//        // Add the coordinates of segment endpoints to the sets
//        allX.insert(startX)
//        allX.insert(endX)
//        allY.insert(startY)
//        allY.insert(endY)
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    // Sort the unique coordinates to create the compressed grid mapping.
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Create dictionaries mapping real coordinates to compressed indices.
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    // Get the dimensions of the compressed grid.
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // Check if the grid is large enough to contain an internal vertex.
//    // A plus sign requires segments centered around an internal grid point (cx, cy).
//    // This requires cx >= 1, cx <= compNX-2, cy >= 1, cy <= compNY-2.
//    // Thus, we need at least 3 unique x and 3 unique y coordinates.
//    if compNX < 3 || compNY < 3 {
//        return 0 // Cannot form a plus sign without internal grid points.
//    }
//
//    // --- Step 3: Create Compressed & Grouped Sweep Events ---
//    // Group horizontal events by their COMPRESSED row (cy).
//    // Store events as (compressed_coordinate, type).
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]() // Key: cy
//    for event in rawHEvents {
//        // Map real coordinates to compressed coordinates. Use guard for safety.
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
//    }
//
//    // Group vertical events by their COMPRESSED column (cx).
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]() // Key: cx
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 4: Build hGrid and vGrid using Optimized Sweep-Line ---
//    // hGrid stores horizontal segments present between compressed coordinates.
//    // Key: cy (compressed row index)
//    // Value: Set<Int> containing starting cx of each unit segment [cx, cx+1] existing in that row.
//    var hGrid = [Int: Set<Int>]()
//    for (cy, events) in hSweepEventsByRow { // Iterate only over rows that have events
//        guard !events.isEmpty else { continue }
//        // Sort events by compressed x-coordinate (cx) for the horizontal sweep.
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//
//        var currentCoverage = 0
//        // Initialize lastCX safely using the first event's cx.
//        var lastCX = sortedEvents.first!.cx
//
//        for event in sortedEvents {
//            let cx = event.cx
//            let type = event.type
//
//            // If coverage was positive (>0) between the last event and the current one,
//            // it means segments existed in the interval [lastCX, cx).
//            // Add all unit segments starting from lastCX up to cx-1.
//            if currentCoverage > 0 && cx > lastCX {
//                for segmentStartIndex in lastCX..<cx {
//                    hGrid[cy, default: Set<Int>()].insert(segmentStartIndex)
//                }
//            }
//            // Update coverage level AT the current event point cx.
//            currentCoverage += type
//            // Update the position of the last processed event point.
//            lastCX = cx
//        }
//        // Optional sanity check: final coverage should ideally be 0 if starts/ends balance.
//        // assert(currentCoverage == 0, "Coverage unbalanced for cy=\(cy)")
//    }
//
//    // vGrid stores vertical segments present between compressed coordinates.
//    // Key: cx (compressed column index)
//    // Value: Set<Int> containing starting cy of each unit segment [cy, cy+1] existing in that column.
//    var vGrid = [Int: Set<Int>]()
//    for (cx, events) in vSweepEventsByCol { // Iterate only over columns that have events
//         guard !events.isEmpty else { continue }
//         // Sort events by compressed y-coordinate (cy) for the vertical sweep.
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//
//         var currentCoverage = 0
//         var lastCY = sortedEvents.first!.cy
//
//         for event in sortedEvents {
//             let cy = event.cy
//             let type = event.type
//
//             // If coverage was positive (>0) between lastCY and cy,
//             // add all unit vertical segments [scy, scy+1] for scy from lastCY to cy-1.
//             if currentCoverage > 0 && cy > lastCY {
//                for segmentStartIndex in lastCY..<cy {
//                    vGrid[cx, default: Set<Int>()].insert(segmentStartIndex)
//                 }
//             }
//             currentCoverage += type
//             lastCY = cy
//         }
//         // assert(currentCoverage == 0, "Coverage unbalanced for cx=\(cx)")
//    }
//
//    // --- Step 5: Optimized Check for Plus Signs (O(N)) ---
//    var plusCount = 0
//
//    // Iterate through compressed rows 'cy' that potentially contain horizontal segments
//    // AND are internal rows (not the top or bottom boundary of the compressed grid).
//    for cy in hGrid.keys where cy >= 1 && cy < compNY - 1 {
//        // Retrieve the set of horizontal segments for this row. Should exist since we iterate keys.
//        guard let hSegments = hGrid[cy] else { continue } // Safety check
//
//        // Iterate through the starting points 'cx' of horizontal segments [cx, cx+1] in this row.
//        // Only consider 'cx' values that correspond to internal columns
//        // and represent the start of the *right* segment of a potential plus sign center.
//        for cx in hSegments where cx >= 1 && cx < compNX - 1 {
//            // At this point, (cx, cy) is a potential center vertex in the compressed grid.
//            // We already know the RIGHT horizontal segment [cx, cx+1] exists at row cy
//            // because 'cx' is present in hSegments.
//
//            // 1. Check for the LEFT horizontal segment [cx-1, cx] at row cy.
//            guard hSegments.contains(cx - 1) else {
//                // If no left segment, (cx, cy) cannot be a center. Move to the next potential cx.
//                continue
//            }
//
//            // 2. Check for the required Vertical segments at column cx.
//            // First, check if column 'cx' exists in vGrid (i.e., has any vertical segments).
//            guard let vSegments = vGrid[cx] else {
//                // If column cx has no vertical segments, (cx, cy) cannot be a center.
//                continue
//            }
//            // Now check for the DOWN segment [cy-1, cy] starting at cy-1 in column cx.
//            guard vSegments.contains(cy - 1) else {
//                continue // No down segment.
//            }
//            // Finally, check for the UP segment [cy, cy+1] starting at cy in column cx.
//            guard vSegments.contains(cy) else {
//                continue // No up segment.
//            }
//
//            // If all four checks passed (Right implied, Left checked, Down checked, Up checked),
//            // then we have found a valid plus sign centered at the internal grid vertex (cx, cy).
//            plusCount += 1
//        }
//    }
//
//    return plusCount
//}
//
////// --- Testing with Examples ---
////print("--- Running Sample Test Cases ---")
////
////let N1 = 9
////let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
////let D1 = "ULDRULURD"
////let result1 = getPlusSignCount(N1, L1, D1)
////print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////
////let N2 = 8
////let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
////let D2 = "RDLUULDR"
////let result2 = getPlusSignCount(N2, L2, D2)
////print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////let N3 = 8
////let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
////let D3 = "UDUDLRLR"
////let result3 = getPlusSignCount(N3, L3, D3)
////print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////// --- Test Cases potentially failing the O(N^2) check ---
////print("\n--- Running Boundary/Edge Test Cases ---")
////
////let N4 = 4
////let L4 = [5, 2, 5, 2] // Rectangle R_5, D_2, L_5, U_2
////let D4 = "RDLU"
////// Expected 0 based on the logic: no internal vertices are formed after compression.
////let result4 = getPlusSignCount(N4, L4, D4)
////print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected based on logic: 0)")
////
////let N5 = 4
////let L5 = [3, 3, 3, 3] // Square R_3, U_3, L_3, D_3
////let D5 = "RULD"
////// Expected 0 based on the logic.
////let result5 = getPlusSignCount(N5, L5, D5)
////print("Sample 5 (Square) Result: \(result5) (\(result5 == 0 ? "Correct" : "Incorrect"), Expected based on logic: 0)")
////
////print("\n--- Running Intersection Test Cases ---")
////
////// Test Case: Intersection creating an internal vertex
////let N6 = 4
////let L6 = [5, 2, 3, 4] // R 5, D 2, L 3, U 4 -> Path (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
////let D6 = "RDLU"
////// Expect 1 plus sign, centered at real (2,0) -> compressed (1,1)
////let result6 = getPlusSignCount(N6, L6, D6)
////print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////// Test Case: No plus sign possible
////let N7 = 2
////let L7 = [5, 5]
////let D7 = "RU" // Just two segments, cannot form a crossing
////let result7 = getPlusSignCount(N7, L7, D7)
////print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////
////print("\n--- Testing Complete ---")
//
