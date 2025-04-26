////
////  Solution19.swift
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
///// The intervals are represented as `(start: Int, end: Int)`, meaning `[start, end)`
///// (inclusive start, exclusive end). The check verifies if the segment `[point, point + 1)`
///// is covered by any existing interval `[start, end)` in the `intervals` list.
///// The function assumes the `intervals` list is already sorted by `start` coordinate.
///// It uses binary search for efficient lookup (O(log K) where K is the number of intervals).
/////
///// - Parameters:
/////   - point: The coordinate value (e.g., cx or cy) marking the *start* of the unit segment to check for.
/////   - intervals: A sorted list of `(start: Int, end: Int)` tuples representing painted segments.
///// - Returns: `true` if the unit segment starting at `point` is covered by any interval, `false` otherwise.
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
//    // Check if the found candidate interval actually covers the required segment [point, point + 1).
//    // This means the interval must start at or before 'point' and end *after* 'point'.
//    // Since intervals represent [start, end), ending at 'point + 1' or later means ending > 'point'.
//    if potentialMatchIndex != -1,
//       intervals[potentialMatchIndex].start <= point, // Interval starts at or before the unit segment
//       intervals[potentialMatchIndex].end > point    // Interval ends *after* the start of the unit segment
//       // Equivalently: intervals[potentialMatchIndex].end >= point + 1
//    {
//        return true
//    }
//
//    return false
//}
//
///// Calculates the number of plus signs formed by a sequence of axis-aligned brush strokes.
///// Uses coordinate compression and a sweep-line algorithm storing intervals.
///// Checks all internal grid points in the compressed space as potential centers.
/////
///// - Parameters:
/////   - N: The number of brush strokes.
/////   - L: An array of integers representing the length of each stroke.
/////   - D: A string representing the direction of each stroke ('U', 'D', 'L', 'R').
///// - Returns: The total count of plus signs found in the painting.
///// - Complexity: O(N log N) + O(NX * NY * log N) in worst case if checking all grid points,
/////             but practically faster as log factor applies to interval list size K << N.
/////             Dominated by O(N log N) from sorting coordinates and events.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//
//    // --- Input Validation & Basic Checks ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    guard N >= 4 else { return 0 } // Need at least 4 segments for a plus
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path, Collect Unique Coordinates & Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Events for Horizontal Sweep
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Events for Vertical Sweep
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue }
//        let direction = directions[i]
//        let startX = currentX
//        let startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            // Vertical segment [startY, endY) at startX
//            rawVEvents.append((y: startY, x: startX, type: 1))
//            rawVEvents.append((y: endY,   x: startX, type: -1))
//        case "D":
//            endY -= length
//            // Vertical segment [endY, startY) at startX
//            rawVEvents.append((y: endY,   x: startX, type: 1))
//            rawVEvents.append((y: startY, x: startX, type: -1))
//        case "L":
//            endX -= length
//            // Horizontal segment [endX, startX) at startY
//            rawHEvents.append((x: endX,   y: startY, type: 1))
//            rawHEvents.append((x: startX, y: startY, type: -1))
//        case "R":
//            endX += length
//             // Horizontal segment [startX, endX) at startY
//            rawHEvents.append((x: startX, y: startY, type: 1))
//            rawHEvents.append((x: endX,   y: startY, type: -1))
//        default:
//             continue // Ignore invalid directions
//        }
//
//        currentX = endX
//        currentY = endY
//        allX.insert(startX); allX.insert(endX)
//        allY.insert(startY); allY.insert(endY)
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    guard sortedX.count > 1 || sortedY.count > 1 else { return 0 } // Check if any movement occurred
//
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // Plus center (cx,cy) needs neighbors cx-1, cx+1, cy-1, cy+1.
//    // Requires grid to be at least 3x3 points (2x2 cells internally).
//    guard compNX >= 3, compNY >= 3 else { return 0 }
//
//    // --- Step 3 & 4: Group Compressed Sweep Events & Build Interval Storage ---
//    // Horizontal Sweep -> Store intervals per row (cy)
//    var hIntervals = [Int: [(start: Int, end: Int)]]() // Key: cy, Val: List of [cx_start, cx_end)
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]()
//    for event in rawHEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
//    }
//
//    for (cy, events) in hSweepEventsByRow {
//        guard !events.isEmpty else { continue }
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//        var currentCoverage = 0
//        var lastCX = -1 // Initialize safely
//        var rowIntervals: [(start: Int, end: Int)] = []
//
//        for event in sortedEvents {
//            let cx = event.cx
//            // If coverage exists *before* this event and the sweep line moved
//            if currentCoverage > 0 && cx > lastCX {
//                // Interval [lastCX, cx) was covered
//                rowIntervals.append((start: lastCX, end: cx))
//            }
//             // Initialize lastCX on the first event
//            if lastCX == -1 { lastCX = cx }
//
//            currentCoverage += event.type // Apply current event's change
//            lastCX = cx              // Update position
//        }
//        rowIntervals.sort { $0.start < $1.start } // Sort for binary search later
//        // Optional: Merge overlapping intervals here for potentially faster checks
//        if !rowIntervals.isEmpty { hIntervals[cy] = rowIntervals }
//    }
//
//    // Vertical Sweep -> Store intervals per column (cx)
//    var vIntervals = [Int: [(start: Int, end: Int)]]() // Key: cx, Val: List of [cy_start, cy_end)
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]()
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//     for (cx, events) in vSweepEventsByCol {
//         guard !events.isEmpty else { continue }
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//         var currentCoverage = 0
//         var lastCY = -1 // Initialize safely
//         var colIntervals: [(start: Int, end: Int)] = []
//
//         for event in sortedEvents {
//             let cy = event.cy
//             if currentCoverage > 0 && cy > lastCY {
//                 colIntervals.append((start: lastCY, end: cy))
//             }
//             if lastCY == -1 { lastCY = cy }
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
//    // Iterate through all points (cx, cy) that could be a center.
//    // A center must have space for 4 arms, so cx is in [1, compNX-2] and cy in [1, compNY-2].
//    for cx in 1..<(compNX - 1) {
//        for cy in 1..<(compNY - 1) {
//            // Retrieve the sorted interval lists for the relevant row and column.
//            let horizontalSegments = hIntervals[cy] ?? []
//            let verticalSegments = vIntervals[cx] ?? []
//
//            // Check Right arm: segment [(cx, cy), (cx+1, cy)] exists?
//            // -> Is compressed unit segment [cx, cx+1) covered in row cy?
//            guard checkUnitSegmentCoverage(point: cx,     intervals: horizontalSegments) else { continue }
//
//            // Check Left arm: segment [(cx-1, cy), (cx, cy)] exists?
//            // -> Is compressed unit segment [cx-1, cx) covered in row cy?
//            guard checkUnitSegmentCoverage(point: cx - 1, intervals: horizontalSegments) else { continue }
//
//            // Check Up arm: segment [(cx, cy), (cx, cy+1)] exists?
//            // -> Is compressed unit segment [cy, cy+1) covered in column cx?
//            guard checkUnitSegmentCoverage(point: cy,     intervals: verticalSegments) else { continue }
//
//            // Check Down arm: segment [(cx, cy-1), (cx, cy)] exists?
//            // -> Is compressed unit segment [cy-1, cy) covered in column cx?
//            guard checkUnitSegmentCoverage(point: cy - 1, intervals: verticalSegments) else { continue }
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
////print("--- Running Sample Test Cases (Corrected Sweep + All Points Check) ---")
////let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
////print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1)), Expected: 4")
////let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
////print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2)), Expected: 1")
////let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
////print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3)), Expected: 1")
////
////print("\n--- Testing Custom Cases ---")
////// Case 4: Simple Intersection forming a plus
////let N4 = 4, L4 = [2, 2, 2, 2], D4 = "RDLU" // Path: (0,0)->R2(2,0)->D2(2,-2)->L2(0,-2)->U2(0,0) - Center (1,-1)
////// Expected: 1 at (1, -1) after tracing.
////print("Sample 4 (Intersection) Result: \(getPlusSignCount(N4, L4, D4)), Expected: 1")
////// Case 5: Rectangle - No plus signs
////let N5 = 4, L5 = [5, 2, 5, 2], D5 = "RDLU" // Expected: 0
////print("Sample 5 (Rectangle) Result: \(getPlusSignCount(N5, L5, D5)), Expected: 0")
////
////// Case 9: Minimal plus centered at (0,0)
////// Path: (0,0) R1 (1,0) U1 (1,1) L2 (-1,1) D2 (-1,-1) R2 (1,-1) U1 (1,0)
////let N9 = 6, L9 = [1, 1, 2, 2, 2, 1], D9 = "RULD RU" // Center (0,0) should be valid.
////print("Sample 9 (Minimal Plus) Result: \(getPlusSignCount(N9, L9, D9)), Expected: 1")
////
////// Case 10: Adjacent plus signs
////// Path: R1 U1 L1 D1 (box 0,0 to 1,1) | R1 U1 L1 D1 (shift R1 -> box 1,0 to 2,1)
////// Should give plus at (1,0) and (1,1) maybe? Let's trace RULD RULD starting from (0,0)
////// (0,0)->R1(1,0)->U1(1,1)->L1(0,1)->D1(0,0) | R1(1,0)->U1(1,1)->L1(0,1)->D1(0,0) - retraces
////// Try R1 U1 L1 D1 | R1 | U1 L1 D1 - Needs careful construction
////// Path: (0,0) R2 (2,0) D1 (2,-1) L2 (0,-1) U2 (0,1) R2 (2,1) D1 (2,0) -> Forms two centers? (1,-1) and (1,0)
////let N10 = 7, L10 = [2, 1, 2, 2, 2, 1, 1], D10 = "RDLUURD" // Added L1 at end
////// R2(2,0) D1(2,-1) L2(0,-1) U2(0,1) R2(2,1) D1(2,0) L1(1,0)
////// Centers might be (1,0), (1,-1)
////// Let's trace expected intervals:
////// Horz: y=0: [0,2), [1,2) -> merged [0,2) ; y=-1: [0,2) ; y=1: [0,2)
////// Vert: x=0: [-1,1) ; x=1: ? ; x=2: [-1,0), [0,1) -> merged [-1,1)
////// Center (1,0): H arms check cx=1, cx-1=0 in y=0? [0,2) covers both. YES.
////// Center (1,0): V arms check cy=0, cy-1=-1 in x=1? Need vertical segment at x=1. NO Vert segment at x=1. Expected: 0
////// Reconstruct test case 10 for 2 adjacent pluses.
////// Path: R1 U1 L1 D1 | R1 U1 L1 D1 starting at (1,0) -> R1(1,0) U1(1,1) L1(0,1) D1(0,0) | R1(1,0) U1(1,1) L1(0,1) D1(0,0) - no, need distinct path
////// Path: (0,0) R2(2,0) U1(2,1) L1(1,1) D2(1,-1) L1(0,-1) U1(0,0) | Now add center bar R1(1,0)
////// Path: R2 U1 L1 D2 L1 U1 R1
////let N11 = 7, L11 = [2, 1, 1, 2, 1, 1, 1], D11 = "RULDLUR" // Center (1,0)
////// R2(2,0) U1(2,1) L1(1,1) D2(1,-1) L1(0,-1) U1(0,0) R1(1,0)
////// Centers (1,0)? H neighbors 0,1 in y=0 -> segments [0,2) cover 0,1 yes. V neighbors 0,-1 in x=1 -> segments [0,1),[-1,0) yes. Expected: 1
////print("Sample 11 (Tricky Center) Result: \(getPlusSignCount(N11, L11, D11)), Expected: 1")
////
////print("\n--- Testing Complete ---")
