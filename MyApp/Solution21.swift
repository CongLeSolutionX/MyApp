//
//  Solution21.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//

import Foundation

// Represents a point in the compressed coordinate system. Must be Hashable for Set/Dictionary usage.
// Not strictly needed if not using Sets/Dictionaries of points, but good practice.
struct Pair: Hashable {
    let x: Int
    let y: Int
}

/// Helper function to check if a specific 'point' represents the start of a unit segment
/// covered within any interval in a list of `intervals`.
/// `intervals` must be sorted by start time.
/// Checks if there exists an interval `(start, end)` such that `start <= point < end`.
/// Uses binary search for efficient lookup (O(log K)).
func checkUnitSegmentCoverage(point: Int, intervals: [(start: Int, end: Int)]) -> Bool {
    guard !intervals.isEmpty else { return false }

    var low = 0
    var high = intervals.count - 1
    var potentialMatchIndex = -1

    // Binary search to find the index of the rightmost interval whose start time is <= point.
    while low <= high {
        let mid = low + (high - low) / 2
        if intervals[mid].start <= point {
             // This interval starts at or LATER than the point.
             // Move low pointer to potentially find a closer starting point
             potentialMatchIndex = mid // Store the latest candidate found so far
             low = mid + 1          // Try to find a later starting interval that still works
         } else {
             // intervals[mid].start > point. This interval starts too late.
             // Look in the left half.
             high = mid - 1
         }
     }

    // After the loop, potentialMatchIndex holds the index of the rightmost interval
    // whose start time is <= point.
    if potentialMatchIndex != -1 {
        // Check if this interval actually covers the point.
        // The interval is [start, end). We need point to be in this range.
        // Condition: intervals[potentialMatchIndex].start <= point < intervals[potentialMatchIndex].end
        if intervals[potentialMatchIndex].end > point {
            return true
        }
    }

    // If loop finished without finding a candidate or the candidate ended too soon.
    return false
}

/// Calculates the number of plus signs formed by a sequence of axis-aligned brush strokes.
/// Uses enhanced coordinate compression and a sweep-line algorithm.
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {

    // --- Input Validation & Basic Checks ---
    guard N >= 4, L.count == N, D.count == N else { return 0 }
    let directions = Array(D)

    // --- Step 1: Simulate Path, Collect Unique Coordinates & Sweep Events ---
    var currentX: Int = 0
    var currentY: Int = 0
    var endPointsX = Set<Int>([0]) // Collect actual stroke endpoints
    var endPointsY = Set<Int>([0])
    // Store raw events using original coordinates first
    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Events for Horizontal Sweep (Stores x-coord, row y, type)
    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Events for Vertical Sweep (Stores y-coord, col x, type)

    for i in 0..<N {
        let length = L[i]
        guard length > 0 else { continue } // Skip zero-length strokes
        let direction = directions[i]
        let startX = currentX
        let startY = currentY
        var endX = startX
        var endY = startY

        switch direction {
        case "U":
            endY += length
            // Vertical segment from startY to endY at column startX.
            // Sweep event marks start and end points.
            rawVEvents.append((y: startY, x: startX, type: 1)) // Segment starts at startY
            rawVEvents.append((y: endY,   x: startX, type: -1))// Segment ends *just before* endY
        case "D":
            endY -= length
            // Vertical segment from endY to startY at column startX.
            rawVEvents.append((y: endY,   x: startX, type: 1)) // Segment starts at endY
            rawVEvents.append((y: startY, x: startX, type: -1))// Segment ends *just before* startY
        case "L":
            endX -= length
            // Horizontal segment from endX to startX at row startY.
            rawHEvents.append((x: endX,   y: startY, type: 1)) // Segment starts at endX
            rawHEvents.append((x: startX, y: startY, type: -1))// Segment ends *just before* startX
        case "R":
            endX += length
            // Horizontal segment from startX to endX at row startY.
             rawHEvents.append((x: startX, y: startY, type: 1)) // Segment starts at startX
             rawHEvents.append((x: endX,   y: startY, type: -1))// Segment ends *just before* endX
        default:
             continue // Ignore invalid directions
        }

        currentX = endX
        currentY = endY
        endPointsX.insert(startX); endPointsX.insert(endX)
        endPointsY.insert(startY); endPointsY.insert(endY)
    }

    // --- Step 2: ENHANCED Coordinate Compression ---
    // Include neighbors (p-1, p, p+1) for every endpoint p.
    var allX = Set<Int>()
    for x in endPointsX {
        allX.insert(x - 1)
        allX.insert(x)
        allX.insert(x + 1)
    }
    var allY = Set<Int>()
    for y in endPointsY {
        allY.insert(y - 1)
        allY.insert(y)
        allY.insert(y + 1)
    }

    // Create sorted lists and mapping dictionaries
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()

    // Need at least 3 distinct points (e.g., p-1, p, p+1) to form segments around p.
    guard sortedX.count >= 3, sortedY.count >= 3 else { return 0 }

    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))

    let compNX = sortedX.count
    let compNY = sortedY.count

    // --- Step 3 & 4: Group Compressed Sweep Events & Generate Intervals ---

    // Process HORIZONTAL intervals (Sweep vertically across rows)
    var hIntervals = [Int: [(start: Int, end: Int)]]() // Key: compY (row index), Value: List of [compX_start, compX_end) intervals
    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]()
    for event in rawHEvents {
        // Map original coordinates to compressed indices
        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
    }

    // Perform the horizontal sweep for each row
    for (cy, events) in hSweepEventsByRow {
        guard !events.isEmpty else { continue }
        let sortedEvents = events.sorted { $0.cx < $1.cx } // Sort events by compressed X coordinate
        var currentCoverage = 0
        var lastCX = -1 // Use -1 to indicate start
        var rowIntervals: [(start: Int, end: Int)] = []

        for event in sortedEvents {
            let cx = event.cx
            if lastCX == -1 { lastCX = cx } // Initialize on first event only

            // If coverage was active *before* this event AND we moved across grid cells
            if currentCoverage > 0 && cx > lastCX {
                 // Add interval [lastCX, cx) which was covered
                 // Ensure start != end
                 if lastCX < cx {
                      rowIntervals.append((start: lastCX, end: cx))
                 }
            }

            currentCoverage += event.type // Apply current event's change
            lastCX = cx                  // Update position
        }
        // Sort intervals for binary search later. Merging overlaps could optimize space but adds complexity.
        rowIntervals.sort { $0.start < $1.start }
        if !rowIntervals.isEmpty { hIntervals[cy] = rowIntervals }
    }

    // Process VERTICAL intervals (Sweep horizontally across columns)
    var vIntervals = [Int: [(start: Int, end: Int)]]() // Key: compX (col index), Value: List of [compY_start, compY_end) intervals
    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]()
     for event in rawVEvents {
         // Map original coordinates to compressed indices
         guard let cy = yMap[event.y], let cx = xMap[event.x] else { continue }
         vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
     }

     // Perform the vertical sweep for each column
     for (cx, events) in vSweepEventsByCol {
         guard !events.isEmpty else { continue }
         let sortedEvents = events.sorted { $0.cy < $1.cy } // Sort events by compressed Y coordinate
         var currentCoverage = 0
         var lastCY = -1 // Use -1 to indicate start
         var colIntervals: [(start: Int, end: Int)] = []

         for event in sortedEvents {
             let cy = event.cy
             if lastCY == -1 { lastCY = cy } // Initialize

             // If coverage was active *before* this event AND we moved across grid cells
             if currentCoverage > 0 && cy > lastCY {
                 // Add interval [lastCY, cy) which was covered
                 // Ensure start != end
                 if lastCY < cy {
                     colIntervals.append((start: lastCY, end: cy))
                 }
             }

             currentCoverage += event.type // Apply current event
             lastCY = cy                  // Update position
         }
         // Sort intervals for binary search
         colIntervals.sort { $0.start < $1.start }
         if !colIntervals.isEmpty { vIntervals[cx] = colIntervals }
     }

    // --- Step 5: Check ALL Internal Grid Points for Plus Signs ---
    var plusCount = 0
    // Iterate through potential center points (cx, cy) in the compressed grid.
    // Range is [1, compN-2] because a center cx needs neighbors cx-1 and cx+1,
    // and center cy needs neighbors cy-1 and cy+1.
    // These indices correspond to original coordinates sortedX[cx] and sortedY[cy].
    for cx in 1..<(compNX - 1) {
        for cy in 1..<(compNY - 1) {
            // Retrieve the sorted interval lists for the relevant row (cy) and column (cx).
            // Use empty list if no segments were painted on that row/column.
            let horizontalSegments = hIntervals[cy] ?? []
            let verticalSegments = vIntervals[cx] ?? []

            // Check Left arm: cell [cx-1, cx) in row cy
            guard checkUnitSegmentCoverage(point: cx - 1, intervals: horizontalSegments) else { continue }

            // Check Right arm: cell [cx, cx+1) in row cy
            guard checkUnitSegmentCoverage(point: cx,     intervals: horizontalSegments) else { continue }

            // Check Down arm: cell [cy-1, cy) in column cx
            guard checkUnitSegmentCoverage(point: cy - 1, intervals: verticalSegments) else { continue }

            // Check Up arm: cell [cy, cy+1) in column cx
            guard checkUnitSegmentCoverage(point: cy,     intervals: verticalSegments) else { continue }

            // ALL four arms exist, centered at the grid point (cx, cy).
            plusCount += 1
        }
    }

    return plusCount
}
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
