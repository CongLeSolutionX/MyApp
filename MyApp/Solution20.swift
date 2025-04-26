////
////  Solution20.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Represents a point in the compressed coordinate system. Must be Hashable for Set/Dictionary usage.
//struct Pair: Hashable {
//    let x: Int
//    let y: Int
//}
//
///// Helper function to check if a specific 'point' represents the start of a unit segment
///// covered within any interval in a list of `intervals`.
///// Uses binary search for efficient lookup (O(log K)).
//func checkUnitSegmentCoverage(point: Int, intervals: [(start: Int, end: Int)]) -> Bool {
//    guard !intervals.isEmpty else { return false }
//
//    var low = 0
//    var high = intervals.count - 1
//    var potentialMatchIndex = -1
//
//    // Binary search for the rightmost interval starting at or before the point.
//    while low <= high {
//        let mid = low + (high - low) / 2
//        if intervals[mid].start <= point {
//             potentialMatchIndex = mid
//             low = mid + 1
//         } else {
//             high = mid - 1
//         }
//     }
//
//    // Check if this interval covers the required segment [point, point + 1)
//    if potentialMatchIndex != -1,
//       intervals[potentialMatchIndex].start <= point, // Interval starts at or before the unit segment
//       intervals[potentialMatchIndex].end > point    // Interval ends *after* the start of the unit segment
//    {
//        return true
//    }
//
//    return false
//}
//
///// Calculates the number of plus signs formed by a sequence of axis-aligned brush strokes.
///// Uses enhanced coordinate compression and a sweep-line algorithm.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//
//    // --- Input Validation & Basic Checks ---
//    guard N >= 4, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path, Collect Unique Coordinates & Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    var endPointsX = Set<Int>([0]) // Collect only actual endpoints for now
//    var endPointsY = Set<Int>([0])
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Events for Horizontal Sweep
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Events for Vertical Sweep
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue } // Skip zero-length strokes
//        let direction = directions[i]
//        let startX = currentX
//        let startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            rawVEvents.append((y: startY, x: startX, type: 1))
//            rawVEvents.append((y: endY,   x: startX, type: -1))
//        case "D":
//            endY -= length
//            rawVEvents.append((y: endY,   x: startX, type: 1))
//            rawVEvents.append((y: startY, x: startX, type: -1))
//        case "L":
//            endX -= length
//            rawHEvents.append((x: endX,   y: startY, type: 1))
//            rawHEvents.append((x: startX, y: startY, type: -1))
//        case "R":
//            endX += length
//             rawHEvents.append((x: startX, y: startY, type: 1))
//             rawHEvents.append((x: endX,   y: startY, type: -1))
//        default:
//             continue // Ignore invalid directions
//        }
//
//        currentX = endX
//        currentY = endY
//        endPointsX.insert(startX); endPointsX.insert(endX)
//        endPointsY.insert(startY); endPointsY.insert(endY)
//    }
//
//    // --- Step 2: ENHANCED Coordinate Compression ---
//    // Include neighbors (x-1, x+1) for every endpoint x, and (y-1, y+1) for y.
//    var allX = Set<Int>()
//    for x in endPointsX {
//        allX.insert(x - 1)
//        allX.insert(x)
//        allX.insert(x + 1)
//    }
//    var allY = Set<Int>()
//    for y in endPointsY {
//        allY.insert(y - 1)
//        allY.insert(y)
//        allY.insert(y + 1)
//    }
//
//    // Remove duplicates and sort
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Need at least 3 distinct points (e.g., x-1, x, x+1) to form segments around x.
//    guard sortedX.count >= 3, sortedY.count >= 3 else { return 0 }
//
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // Internal check loop requires indices 1 to CompN-2, so need at least 3 points.
//    guard compNX >= 3, compNY >= 3 else { return 0 }
//
//    // --- Step 3 & 4: Group Compressed Sweep Events & Build Interval Storage ---
//    // (This part remains the same, using the new xMap/yMap)
//    var hIntervals = [Int: [(start: Int, end: Int)]]()
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]()
//    for event in rawHEvents {
//        // Critical: Map original coordinates to the NEW compressed map
//        guard let cxStart = xMap[event.x], let cy = yMap[event.y] else { continue }
//        // We must map both start and end x coordinates of the *original* segment
//        // The raw event types are associated with the *start* x coordinate of the segment.
//        // Let's recalculate the end cx based on the event type.
//        // No, the events store the boundary points. Mapping them directly is correct.
//        hSweepEventsByRow[cy, default: []].append((cx: cxStart, type: event.type))
//    }
//
//    // Horizontal Sweep processing...
//    for (cy, events) in hSweepEventsByRow {
//        guard !events.isEmpty else { continue }
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//        var currentCoverage = 0
//        var lastCX = -1 // Initialize safely
//        var rowIntervals: [(start: Int, end: Int)] = []
//
//        for event in sortedEvents {
//            let cx = event.cx
//            if lastCX == -1 { lastCX = cx } // Initialize on first event only
//
//            // If coverage exists *before* this event AND the sweep line moved across cells
//            if currentCoverage > 0 && cx > lastCX {
//                // Interval [lastCX, cx) was covered
//                rowIntervals.append((start: lastCX, end: cx))
//            }
//
//            currentCoverage += event.type // Apply current event's change
//            lastCX = cx                  // Update position
//        }
//        // Sort for binary search later. Merging overlaps could optimize but adds complexity.
//        rowIntervals.sort { $0.start < $1.start }
//        if !rowIntervals.isEmpty { hIntervals[cy] = rowIntervals }
//    }
//
//    // Vertical Sweep processing...
//    var vIntervals = [Int: [(start: Int, end: Int)]]()
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]()
//     for event in rawVEvents {
//         guard let cyStart = yMap[event.y], let cx = xMap[event.x] else { continue }
//         vSweepEventsByCol[cx, default: []].append((cy: cyStart, type: event.type))
//     }
//
//     for (cx, events) in vSweepEventsByCol {
//         guard !events.isEmpty else { continue }
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//         var currentCoverage = 0
//         var lastCY = -1
//         var colIntervals: [(start: Int, end: Int)] = []
//
//         for event in sortedEvents {
//             let cy = event.cy
//             if lastCY == -1 { lastCY = cy }
//
//             if currentCoverage > 0 && cy > lastCY {
//                 colIntervals.append((start: lastCY, end: cy))
//             }
//
//             currentCoverage += event.type
//             lastCY = cy
//         }
//         colIntervals.sort { $0.start < $1.start }
//         if !colIntervals.isEmpty { vIntervals[cx] = colIntervals }
//     }
//
//    // --- Step 5: Check ALL Internal Grid Points for Plus Signs ---
//    var plusCount = 0
//    // Iterate through all potential center points (cx, cy) in the *new* compressed grid.
//    // Range is [1, compN-2] because a center needs neighbors cx-1 and cx+1 (and cy equiv).
//    for cx in 1..<(compNX - 1) {
//        for cy in 1..<(compNY - 1) {
//            // Retrieve the sorted interval lists for the relevant row and column.
//            // Use empty list if no segments were painted on that row/column.
//            let horizontalSegments = hIntervals[cy] ?? []
//            let verticalSegments = vIntervals[cx] ?? []
//
//            // Check Left arm: cell [cx-1, cx) in row cy
//            guard checkUnitSegmentCoverage(point: cx - 1, intervals: horizontalSegments) else { continue }
//
//            // Check Right arm: cell [cx, cx+1) in row cy
//            guard checkUnitSegmentCoverage(point: cx,     intervals: horizontalSegments) else { continue }
//
//            // Check Down arm: cell [cy-1, cy) in column cx
//            guard checkUnitSegmentCoverage(point: cy - 1, intervals: verticalSegments) else { continue }
//
//            // Check Up arm: cell [cy, cy+1) in column cx
//            guard checkUnitSegmentCoverage(point: cy,     intervals: verticalSegments) else { continue }
//
//            // ALL four arms exist, centered at the grid point (cx, cy).
//            plusCount += 1
//        }
//    }
//
//    return plusCount
//}
////
////// --- Testing with Provided Examples ---
////print("--- Running Sample Test Cases (Enhanced Compression) ---")
////let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
////print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1)), Expected: 4")
////let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
////print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2)), Expected: 1")
////let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
////print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3)), Expected: 1")
////
////print("\n--- Testing Custom Cases ---")
////// Case 4: Simple Intersection forming a plus
////let N4 = 4, L4 = [2, 2, 2, 2], D4 = "RDLU" // Expected: 1 at (1, -1)
////print("Sample 4 (Intersection) Result: \(getPlusSignCount(N4, L4, D4)), Expected: 1")
////// Case 5: Rectangle - No plus signs
////let N5 = 4, L5 = [5, 2, 5, 2], D5 = "RDLU" // Expected: 0
////print("Sample 5 (Rectangle) Result: \(getPlusSignCount(N5, L5, D5)), Expected: 0")
////
////// Case 9: Minimal plus centered at (0,0) - Using the sequence from thinking phase
////let N9 = 6, L9 = [1, 1, 2, 2, 2, 1], D9 = "RULDRU" // Center (0,0) should be valid.
////print("Sample 9 (Minimal Plus) Result: \(getPlusSignCount(N9, L9, D9)), Expected: 1")
////
////// Case 11: Tricky Center
////let N11 = 7, L11 = [2, 1, 1, 2, 1, 1, 1], D11 = "RULDLUR" // Center (1,0)
////print("Sample 11 (Tricky Center) Result: \(getPlusSignCount(N11, L11, D11)), Expected: 1")
////
////// Case 12: Empty input edge case
////print("Sample 12 (N=0) Result: \(getPlusSignCount(0, [], "")), Expected: 0")
////// Case 13: Less than 4 strokes
////print("Sample 13 (N=3) Result: \(getPlusSignCount(3, [1,1,1], "RDR")), Expected: 0")
////
////// Case 14: Coincident segments (retracing) - should still form plus
////let N14 = 8, L14 = [1, 1, 1, 1, 1, 1, 1, 1], D14 = "RULDDRUL" // Center (0,0)? R(1,0)U(1,1)L(0,1)D(0,0) D(0,-1)R(1,-1)U(1,0)L(0,0)
////print("Sample 14 (Retracing) Result: \(getPlusSignCount(N14, L14, D14)), Expected: 1")
////
////print("\n--- Testing Complete ---")
