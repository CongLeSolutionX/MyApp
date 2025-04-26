////
////  Solution18.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//
//import Foundation
//
//// --- Phase 4: Agent Role and Technical Guidance (iOS Development) ---
//// This code adheres to Swift best practices, using clear naming, struct for pairs,
//// and leveraging standard library functions like sorted() and dictionaries.
//
//// --- Phase 1: Research Methodology (Applying Algo Concepts) ---
//// Problem: Count "+" signs formed by axis-aligned strokes.
//// Core Idea: Use Coordinate Compression + Sweep Line + Interval Storage.
//// Complexity Goal: Aim for O(N log N) complexity due to constraints.
//
//// --- Phase 6: Content Style - Avoiding Clichés ---
//// Using clear, direct variable names and comments.
//
//// Represents a point in the compressed coordinate system. Must be Hashable for Set usage.
//struct Pair: Hashable {
//    let x: Int
//    let y: Int
//}
//
//// --- Phase 5: Diagramming Guidelines (Conceptual - Binary Search) ---
///// Helper function to check if a specific 'point' is contained within any interval
///// in a list of `intervals`. The intervals are represented as `(start: Int, end: Int)`,
///// meaning `[start, end)` (inclusive start, exclusive end).
///// The function assumes the `intervals` list is already sorted by `start` coordinate.
///// It uses binary search for efficient lookup (O(log K) where K is the number of intervals).
/////
///// - Parameters:
/////   - point: The coordinate value (e.g., cx or cy) to check for.
/////   - intervals: A sorted list of `(start: Int, end: Int)` tuples representing segments.
///// - Returns: `true` if the point falls within any interval in the list, `false` otherwise.
//func checkPointInIntervals(point: Int, intervals: [(start: Int, end: Int)]) -> Bool {
//    // An empty list cannot contain the point.
//    guard !intervals.isEmpty else { return false }
//
//    var low = 0
//    var high = intervals.count - 1
//    var potentialMatchIndex = -1
//
//    // Perform binary search to find the rightmost interval whose start <= point.
//    // This interval is the *only* one that could possibly contain the point if
//    // intervals were correctly merged (though we don't strictly require merging here).
//    while low <= high {
//        let mid = low + (high - low) / 2
//        if intervals[mid].start <= point {
//            // This interval starts at or before the point. It's a candidate.
//            potentialMatchIndex = mid
//            // Keep searching to the right for potentially better matches
//            // (intervals starting closer to, but still <=, the point).
//            low = mid + 1
//        } else {
//            // This interval starts after the point. Search to the left.
//            high = mid - 1
//        }
//    }
//
//    // If we found a candidate interval (potentialMatchIndex >= 0),
//    // check if the point is actually within its bounds [start, end).
//    if potentialMatchIndex != -1, // Ensure a candidate was found
//       intervals[potentialMatchIndex].start <= point, // Redundant check, but safe
//       point < intervals[potentialMatchIndex].end // Crucial check: point must be *before* the end
//    {
//        return true
//    }
//
//    // The point was not found within any interval.
//    return false
//}
//
//
///// Calculates the number of plus signs formed by a sequence of axis-aligned brush strokes.
///// Uses coordinate compression and a sweep-line algorithm storing intervals to handle large coordinates and constraints efficiently.
/////
///// - Parameters:
/////   - N: The number of brush strokes.
/////   - L: An array of integers representing the length of each stroke.
/////   - D: A string representing the direction of each stroke ('U', 'D', 'L', 'R').
///// - Returns: The total count of plus signs found in the painting.
///// - Complexity: O(N log N) primarily due to sorting unique coordinates and sweep events.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int { // Renamed back to expected function name
//
//    // --- Input Validation & Basic Checks ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    // A plus sign requires at least 4 segments.
//    guard N >= 4 else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path, Collect Unique Coordinates & Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    // Using Sets ensures uniqueness automatically. Add origin.
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    // Store raw sweep events: (coordinate, cross_coordinate, type)
//    // type: +1 for start of segment parallel to sweep line, -1 for end.
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // For horizontal sweep -> Events at x-coords
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // For vertical sweep   -> Events at y-coords
//    // Keep track of all endpoints in the original coordinate system.
//    var segmentEndpoints = Set<Pair>([Pair(x: 0, y: 0)])
//
//    for i in 0..<N {
//        let length = L[i]
//        // Ignore zero-length strokes as they don't paint anything.
//        guard length > 0 else { continue }
//        let direction = directions[i]
//        let startX = currentX
//        let startY = currentY
//        var endX = startX
//        var endY = startY
//
//        // Update coordinates and create sweep events based on direction.
//        switch direction {
//        case "U":
//            endY += length
//            // Vertical segment: Events occur at startY and endY, at position startX.
//            rawVEvents.append((y: startY, x: startX, type: 1)) // Start of upward segment
//            rawVEvents.append((y: endY,   x: startX, type: -1)) // End of upward segment
//        case "D":
//            endY -= length
//            // Vertical segment: Events occur at startY and endY, at position startX.
//            // Note: For downward, the interval starts at endY.
//            rawVEvents.append((y: endY,   x: startX, type: 1)) // Start of downward segment
//            rawVEvents.append((y: startY, x: startX, type: -1)) // End of downward segment
//        case "L":
//            endX -= length
//            // Horizontal segment: Events occur at startX and endX, at position startY.
//            // Note: For leftward, the interval starts at endX.
//            rawHEvents.append((x: endX,   y: startY, type: 1)) // Start of leftward segment
//            rawHEvents.append((x: startX, y: startY, type: -1)) // End of leftward segment
//        case "R":
//            endX += length
//            // Horizontal segment: Events occur at startX and endX, at position startY.
//            rawHEvents.append((x: startX, y: startY, type: 1)) // Start of rightward segment
//            rawHEvents.append((x: endX,   y: startY, type: -1)) // End of rightward segment
//        default:
//             // Handle unexpected directions if necessary, or ignore.
//             // print("Warning: Invalid direction encountered: \(direction)")
//             continue // Skip invalid directions
//        }
//
//        // Update current position for the next stroke.
//        currentX = endX
//        currentY = endY
//        // Add involved coordinates to the sets for compression later.
//        allX.insert(startX); allX.insert(endX)
//        allY.insert(startY); allY.insert(endY)
//        // Add the new endpoint.
//        segmentEndpoints.insert(Pair(x: endX, y: endY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    // Sort the unique coordinates to establish the mapping.
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // If there's no movement (only origin point), no plus signs possible.
//    guard sortedX.count > 1, sortedY.count > 1 else { return 0 }
//
//    // Create dictionaries mapping original coordinates to compressed indices (0-based).
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    // Dimensions of the compressed grid.
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // A plus sign requires at least 3x3 points (2x2 cells) in the compressed grid.
//    // Center point (cx, cy) needs cx-1, cx+1 and cy-1, cy+1 to exist.
//    if compNX < 3 || compNY < 3 { return 0 }
//
//    // --- Step 3: Collect Potential Centers (Internal Endpoints in Compressed Grid) ---
//    // Potential centers for a plus sign can only be points that are endpoints
//    // of strokes *and* are not on the boundary of the compressed grid.
//    var potentialCenters = Set<Pair>()
//    for point in segmentEndpoints {
//        // Map original endpoint coordinates to compressed coordinates.
//        // Use guard let for safety, although keys should exist if simulation was correct.
//        guard let cx = xMap[point.x], let cy = yMap[point.y] else { continue }
//
//        // Check if the compressed point (cx, cy) is strictly internal.
//        // Need space for arms: cx needs cx-1 & cx+1; cy needs cy-1 & cy+1.
//        if cx >= 1 && cx < compNX - 1 && cy >= 1 && cy < compNY - 1 {
//             potentialCenters.insert(Pair(x: cx, y: cy))
//        }
//    }
//    // If there are no internal endpoints, no plus signs can be centered.
//    if potentialCenters.isEmpty { return 0 }
//
//
//    // --- Step 4: Group Compressed Sweep Events by Row/Column ---
//    // Group horizontal events by their compressed y-coordinate (row).
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]()
//    for event in rawHEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
//    }
//    // Group vertical events by their compressed x-coordinate (column).
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]() // Event stores compressed cy
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 5: Build Interval Storage using Sweep-Line ---
//    // Stores the painted *segments* in the compressed grid.
//    // Key: Compressed row/column index. Value: List of painted intervals [start, end).
//    var hIntervals = [Int: [(start: Int, end: Int)]]() // Key: cy, Val: List of [cx_start, cx_end)
//    for (cy, events) in hSweepEventsByRow {
//        // Skip rows if no horizontal segments occurred there.
//        guard !events.isEmpty else { continue }
//        // Sort events by their compressed x-coordinate to process the sweep line correctly.
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//
//        var currentCoverage = 0 // Tracks how many active segments cover the current point.
//        var lastCX = sortedEvents.first!.cx // The cx where the previous event occurred.
//        var rowIntervals: [(start: Int, end: Int)] = [] // Intervals for this specific row
//
//        for event in sortedEvents {
//            let cx = event.cx // Current event's compressed x-coordinate.
//
//            // If the sweep line moved (cx > lastCX) and the region between lastCX and cx
//            // was covered (currentCoverage > 0), then record this painted interval.
//            if currentCoverage > 0 && cx > lastCX {
//                // Add the interval [lastCX, cx) to the list for this row.
//                rowIntervals.append((start: lastCX, end: cx))
//            }
//            // Update coverage based on event type (+1 for start, -1 for end).
//            currentCoverage += event.type
//            // Update the position of the last event.
//            lastCX = cx
//        }
//
//        // After processing all events for the row, sort the collected intervals by start point.
//        // This is crucial for the binary search check later.
//        rowIntervals.sort { $0.start < $1.start }
//        // Optional but recommended: Merge overlapping/adjacent intervals here.
//        // For simplicity/speed, we'll skip merging for now. Binary search handles overlaps.
//
//        // Store the sorted (and potentially merged) intervals for this row.
//        if !rowIntervals.isEmpty {
//             hIntervals[cy] = rowIntervals
//        }
//    }
//
//    // --- Vertical Sweep (Analogous to Horizontal) ---
//    var vIntervals = [Int: [(start: Int, end: Int)]]() // Key: cx, Val: List of [cy_start, cy_end)
//    for (cx, events) in vSweepEventsByCol {
//         guard !events.isEmpty else { continue }
//         // Sort events by compressed y-coordinate.
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//
//         var currentCoverage = 0
//         var lastCY = sortedEvents.first!.cy // Start sweep at the first event's cy.
//         var colIntervals: [(start: Int, end: Int)] = [] // Intervals for this column
//
//         for event in sortedEvents {
//             let cy = event.cy // Current event's compressed y-coordinate.
//             // If covered and sweep line moved, record the interval.
//             if currentCoverage > 0 && cy > lastCY {
//                  colIntervals.append((start: lastCY, end: cy)) // Record [lastCY, cy)
//             }
//             currentCoverage += event.type
//             lastCY = cy // Update last event position.
//         }
//         // Sort intervals for this column.
//         colIntervals.sort { $0.start < $1.start }
//         // Store the sorted intervals.
//         if !colIntervals.isEmpty {
//              vIntervals[cx] = colIntervals
//         }
//    }
//
//
//    // --- Step 6: Optimized Check for Plus Signs using Intervals ---
//    var plusCount = 0
//    // Iterate ONLY through the points identified as potential centers.
//    for center in potentialCenters {
//        let cx = center.x // Compressed x of the potential center
//        let cy = center.y // Compressed y of the potential center
//
//        // Retrieve the sorted interval lists for the relevant row and column.
//        // Use nil-coalescing operator to provide an empty list if no intervals exist.
//        let horizontalSegments = hIntervals[cy] ?? []
//        let verticalSegments = vIntervals[cx] ?? []
//
//        // --- Check for the 4 required arms around the center (cx, cy) ---
//        // Check Right arm: segment [(cx, cy), (cx+1, cy)] must exist.
//        // This corresponds to checking if point 'cx' is covered by any horizontal interval in row 'cy'.
//        guard checkPointInIntervals(point: cx,     intervals: horizontalSegments) else { continue }
//
//        // Check Left arm: segment [(cx-1, cy), (cx, cy)] must exist.
//        // Check if point 'cx - 1' is covered by any horizontal interval in row 'cy'.
//        guard checkPointInIntervals(point: cx - 1, intervals: horizontalSegments) else { continue }
//
//        // Check Up arm: segment [(cx, cy), (cx, cy+1)] must exist.
//        // Check if point 'cy' is covered by any vertical interval in column 'cx'.
//        guard checkPointInIntervals(point: cy,     intervals: verticalSegments) else { continue }
//
//        // Check Down arm: segment [(cx, cy-1), (cx, cy)] must exist.
//        // Check if point 'cy - 1' is covered by any vertical interval in column 'cx'.
//        guard checkPointInIntervals(point: cy - 1, intervals: verticalSegments) else { continue }
//
//        // If all four 'guard' checks passed, then all necessary arms exist.
//        plusCount += 1
//    }
//
//    return plusCount
//}
//
////
////// --- Testing with Provided Examples ---
////print("--- Running Sample Test Cases (Interval Sweep) ---")
////let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
////print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1))")
////let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
////print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2))")
////let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
////print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3))")
////
////print("\n--- Testing Custom Cases ---")
////// Case 4: Simple Intersection
////let N4 = 4, L4 = [5, 2, 3, 4], D4 = "RDLU" // Expected: 1 (at (2, 0))
////print("Sample 4 (Intersection) Result: \(getPlusSignCount(N4, L4, D4))")
////// Case 5: Rectangle - No plus signs
////let N5 = 4, L5 = [5, 2, 5, 2], D5 = "RDLU" // Expected: 0
////print("Sample 5 (Rectangle) Result: \(getPlusSignCount(N5, L5, D5))")
////// Case 6: Minimal valid input N=4 forming a plus
////let N6 = 4, L6 = [1, 1, 1, 1], D6 = "RULD" // Creates a 1x1 square centered at (0.5, 0.5), no integer center plus. Expected: 0
////// Actually, let's make a plus explicitly: R D L U -> goes (0,0)->(1,0)->(1,-1)->(0,-1)->(0,0)
////// Now add arms: U R D L
////let N7 = 8, L7 = [1, 1, 1, 1, 1, 1, 1, 1], D7 = "RULDURDL" // R(1,0) U(1,1) L(0,1) D(0,0) | U(0,1) R(1,1) D(1,0) L(0,0) - Center is (0.5, 0.5), no plus. Expected: 0
////let N8 = 8, L8 = [1, 1, 1, 1, 1, 1, 1, 1], D8 = "RURDRDRD" // Example that might create overlaps. Let's trace R(1,0) U(1,1) R(2,1) D(2,0) R(3,0) D(3,-1) R(4,-1) D(4,-2). No obvious plus. Expected: 0.
////// Minimal plus: (0,0) -> R 1 -> (1,0) -> U 1 -> (1,1) -> L 2 -> (-1,1) -> D 2 -> (-1,-1) -> R 2 -> (1,-1) -> U 1 -> (1,0) - now check center (0,0)
////// R1 -> (1,0) h=[(0,1)@0]
////// U1 -> (1,1) v=[(0,1)@1] ep=(1,1)
////// L2 -> (-1,1) h=[(-1,1)@1] ep=(-1,1)
////// D2 -> (-1,-1) v=[(-1,1)@-1] ep=(-1,-1)
////// R2 -> (1,-1) h=[(-1,1)@-1] ep=(1,-1)
////// U1 -> (1,0) v=[(-1,0)@1] ep=(1,0)
////let N9 = 6, L9 = [1, 1, 2, 2, 2, 1], D9 = "RULD RU" // Expected: 1 (at (0,0))
////print("Sample 9 (Minimal Plus) Result: \(getPlusSignCount(N9, L9, D9))")
////
////print("\n--- Testing Complete ---")
//
