////
////  Solution17.swift
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
/////   - N: The number of brush strokes. Checks if N >= 2.
/////   - L: An array of integers representing the length of each stroke. Must match N.
/////   - D: A string representing the direction of each stroke ('U', 'D', 'L', 'R'). Must match N.
///// - Returns: The total number of positions where a plus sign is present. Returns 0 if N < 2 or input arrays mismatch N.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    // Need at least 2 segments to potentially form intersections.
//    // L and D arrays must have count N.
//    guard N >= 2, L.count == N, D.count == N else {
//        return 0 // Cannot form a plus sign with insufficient or mismatched data.
//    }
//    let directions = Array(D) // Convert String to Array for easier access
//
//    // --- Step 1: Simulate Path, Collect Unique Coordinates & Raw Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    // Use Sets for efficient unique coordinate collection. Start with origin (0,0).
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//
//    // Store raw sweep-line events: (coordinate_of_event, constant_coordinate, type: +1 start, -1 end)
//    // First element is the coordinate along the sweep direction.
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Horizontal sweep: event at x, on line y
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Vertical sweep: event at y, on line x
//
//    var startX = 0
//    var startY = 0
//
//    for i in 0..<N {
//        let length = L[i]
//        // Skip zero-length segments as they don't paint anything.
//        guard length > 0 else { continue }
//        let direction = directions[i]
//
//        startX = currentX
//        startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            // Add vertical segment events: start (lower y) and end (higher y).
//            // Event is at 'y', occurring on column 'x'. Type +1 for start, -1 for end.
//            rawVEvents.append((y: startY, x: startX, type: 1)) // Start segment at (startX, startY)
//            rawVEvents.append((y: endY,   x: startX, type: -1)) // End segment at (startX, endY)
//        case "D":
//            endY -= length
//           // Add vertical segment events: event at 'y', on column 'x'.
//           // Ensure start event always has the smaller y.
//            rawVEvents.append((y: endY,   x: startX, type: 1)) // Start at (startX, endY)
//            rawVEvents.append((y: startY, x: startX, type: -1)) // End at (startX, startY)
//        case "L":
//            endX -= length
//            // Add horizontal segment events: event at 'x', on row 'y'.
//             // Ensure start event always has the smaller x.
//            rawHEvents.append((x: endX,   y: startY, type: 1)) // Start at (endX, startY)
//            rawHEvents.append((x: startX, y: startY, type: -1)) // End at (startX, startY)
//        case "R":
//            endX += length
//            // Add horizontal segment events: event at 'x', on row 'y'.
//            rawHEvents.append((x: startX, y: startY, type: 1)) // Start at (startX, startY)
//            rawHEvents.append((x: endX,   y: startY, type: -1)) // End at (endX, startY)
//        default:
//             // Constraints likely guarantee valid directions, but can add error handling if needed.
//             print("Warning: Invalid direction encountered: \(direction)") // Or fatalError
//             continue // Skip invalid direction
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
//    // Sort the unique coordinates to establish the compressed grid mapping.
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Create dictionaries mapping original coordinates to compressed indices. O(N) build time.
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    // Get the dimensions of the compressed grid.
//    let compNX = sortedX.count // Number of unique x-coordinates
//    let compNY = sortedY.count // Number of unique y-coordinates
//
//    // A plus sign requires a central vertex with neighbors in all 4 directions.
//    // This implies the compressed grid must have at least 3 rows and 3 columns
//    // to contain an *internal* vertex (cx, cy) where 1 <= cx < compNX-1 and 1 <= cy < compNY-1.
//    if compNX < 3 || compNY < 3 {
//        return 0 // Cannot form a plus sign without internal grid points.
//    }
//
//    // --- Step 3: Create Compressed & Grouped Sweep Events ---
//    // Group horizontal events by their COMPRESSED row index (cy).
//    // Store events as (compressed_x_coordinate, type).
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]() // Key: cy
//    for event in rawHEvents {
//        // Safely unwrap mapped coordinates.
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
//    }
//
//    // Group vertical events by their COMPRESSED column index (cx).
//    // Store events as (compressed_y_coordinate, type).
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]() // Key: cx
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 4: Build hGrid and vGrid using Optimized Sweep-Line ---
//    // hGrid stores the starting cx of horizontal *unit* segments present between compressed coordinates.
//    // Key: cy (compressed row index)
//    // Value: Set<Int> containing cx such that the segment [(cx, cy), (cx+1, cy)] is painted.
//    var hGrid = [Int: Set<Int>]()
//    for (cy, events) in hSweepEventsByRow { // Iterate only over rows that have horizontal segments
//        guard !events.isEmpty else { continue }
//        // Sort horizontal events by compressed x-coordinate (cx) for the sweep-line. O(k log k) per row.
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//
//        var currentCoverage = 0
//        // Initialize lastCX safely using the first event's cx (guaranteed to exist).
//        var lastCX = sortedEvents.first!.cx
//
//        for event in sortedEvents {
//            let cx = event.cx
//            let type = event.type
//
//            // If coverage was positive (>0) in the interval [lastCX, cx),
//            // it means segments existed. Add all unit segments starting from lastCX up to cx-1.
//            if currentCoverage > 0 && cx > lastCX {
//                // This loop adds the indices of the *starting* points of the unit segments.
//                for segmentStartX in lastCX..<cx {
//                     hGrid[cy, default: Set<Int>()].insert(segmentStartX)
//                }
//            }
//            // Update coverage level AT the current event point cx.
//            currentCoverage += type
//            // Update the position of the last processed event point.
//            lastCX = cx
//        }
//         // Note: Final coverage check (should be 0) omitted for brevity, assumed correct input pairing.
//    }
//
//    // vGrid stores the starting cy of vertical *unit* segments present between compressed coordinates.
//    // Key: cx (compressed column index)
//    // Value: Set<Int> containing cy such that the segment [(cx, cy), (cx, cy+1)] is painted.
//    var vGrid = [Int: Set<Int>]()
//    for (cx, events) in vSweepEventsByCol { // Iterate only over columns that have vertical segments
//         guard !events.isEmpty else { continue }
//         // Sort vertical events by compressed y-coordinate (cy) for the sweep-line. O(k log k) per column.
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
//             // add all unit vertical segments starting from lastCY up to cy-1.
//             if currentCoverage > 0 && cy > lastCY {
//                 for segmentStartY in lastCY..<cy {
//                    vGrid[cx, default: Set<Int>()].insert(segmentStartY)
//                 }
//             }
//             currentCoverage += type
//             lastCY = cy
//         }
//         // Note: Final coverage check omitted.
//    }
//
//    // --- Step 5: Optimized Check for Plus Signs ---
//    // Iterate through potential centers (cx, cy) efficiently.
//    // Start by checking rows (cy) that are internal and contain horizontal segments.
//    var plusCount = 0
//
//    // Iterate through compressed rows 'cy' that are internal (1 to compNY-2)
//    // AND actually contain horizontal segments (are keys in hGrid).
//    for cy in hGrid.keys where cy >= 1 && cy < compNY - 1 {
//        // Retrieve the set of horizontal segments start points (cx) for this row.
//        guard let hSegments = hGrid[cy] else { continue } // Should exist, but safe check
//
//        // Iterate through the starting points 'cx' of horizontal segments [(cx, cx+1)] in this row.
//        // Only consider 'cx' values that correspond to internal columns (1 to compNX-2).
//        // This 'cx' represents the starting point of the RIGHT arm of a potential plus sign centered at (cx, cy).
//        for cx in hSegments where cx >= 1 && cx < compNX - 1 {
//            // At this point, (cx, cy) is an internal grid vertex, and we know the
//            // RIGHT horizontal segment [(cx, cy), (cx+1, cy)] exists because 'cx' is in hSegments[cy].
//
//            // 1. Check for the LEFT horizontal segment [(cx-1, cy), (cx, cy)].
//            //    This requires the segment starting at 'cx-1' to be present in the current row 'cy'.
//            guard hSegments.contains(cx - 1) else {
//                continue // No left segment, cannot be a plus center.
//            }
//
//            // 2. Check for the required Vertical segments centered at column 'cx'.
//            //    First, verify that column 'cx' even exists in vGrid (i.e., has *any* vertical segments).
//            guard let vSegments = vGrid[cx] else {
//                continue // Column cx has no vertical segments, cannot be a plus center.
//            }
//            // 3. Check for the DOWN vertical segment [(cx, cy-1), (cx, cy)].
//            //    This requires the segment starting at 'cy-1' to be present in column 'cx'.
//            guard vSegments.contains(cy - 1) else {
//                continue // No down segment.
//            }
//            // 4. Check for the UP vertical segment [(cx, cy), (cx, cy+1)].
//            //    This requires the segment starting at 'cy' to be present in column 'cx'.
//            guard vSegments.contains(cy) else {
//                continue // No up segment.
//            }
//
//            // If all checks passed (Right implied, Left checked, Down checked, Up checked),
//            // then (cx, cy) is the center of a valid plus sign in the compressed grid.
//            plusCount += 1
//        }
//    }
//
//    return plusCount
//}
////
////// --- Testing with Examples (Same as previous tests) ---
////print("--- Running Sample Test Cases ---")
////let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
////print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1))")
////let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
////print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2))")
////let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
////print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3))")
////
////print("\n--- Running Boundary/Edge Test Cases ---")
////let N4 = 4, L4 = [5, 2, 5, 2], D4 = "RDLU" // Rectangle, Expected: 0
////print("Sample 4 (Rectangle) Result: \(getPlusSignCount(N4, L4, D4))")
////let N5 = 4, L5 = [3, 3, 3, 3], D5 = "RULD" // Square, Expected: 0
////print("Sample 5 (Square) Result: \(getPlusSignCount(N5, L5, D5))")
////
////print("\n--- Running Intersection Test Cases ---")
////let N6 = 4, L6 = [5, 2, 3, 4], D6 = "RDLU" // Intersection, Expected: 1
////print("Sample 6 (Intersection) Result: \(getPlusSignCount(N6, L6, D6))")
////let N7 = 2, L7 = [5, 5], D7 = "RU" // No plus possible, Expected: 0
////print("Sample 7 (No Plus) Result: \(getPlusSignCount(N7, L7, D7))")
////
////print("\n--- Testing Complete ---")
