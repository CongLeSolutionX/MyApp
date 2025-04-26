////
////  Solution24.swift
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
///// Represents a contiguous horizontal or vertical run of painted cells
///// in the compressed grid. `start` <= `end`. The range is [start, end).
///// Note: 'end' is EXCLUSIVE, making range checks cleaner.
//fileprivate struct Run: Comparable {
//    let start: Int // Starting coordinate (either x or y)
//    let end: Int   // Ending coordinate (either x or y) - EXCLUSIVE
//
//    // Conformance to Comparable for sorting and merging
//    static func < (lhs: Run, rhs: Run) -> Bool {
//        if lhs.start != rhs.start {
//            return lhs.start < rhs.start
//        }
//        // If starts are equal, shorter runs come first (though arbitrary order is fine)
//        return lhs.end < rhs.end
//    }
//
//    /// Checks if this run covers the single unit segment starting at `coord`.
//    /// The unit segment is the interval [coord, coord + 1).
//    func coversUnitSegment(from coord: Int) -> Bool {
//        // Check if the coordinate `coord` falls within the run's interval [start, end)
//        return self.start <= coord && self.end > coord
//    }
//}
//
///// Merges overlapping or adjacent runs in a sorted array.
///// Assumes input runs are sorted primarily by start coordinate.
//fileprivate func mergeRuns(_ runs: [Run]) -> [Run] {
//    if runs.isEmpty { return [] }
//
//    // Sort runs primarily by start coordinate.
//    let sortedRuns = runs.sorted()
//    var merged: [Run] = []
//    var currentRun = sortedRuns[0]
//
//    for i in 1..<sortedRuns.count {
//        let nextRun = sortedRuns[i]
//        // Merge if they overlap or are adjacent (currentRun.end >= nextRun.start)
//        if currentRun.end >= nextRun.start {
//            // Merge: extend the end of the current run if necessary
//            currentRun = Run(start: currentRun.start, end: max(currentRun.end, nextRun.end))
//        } else {
//            // No overlap, finish the current run and start a new one
//            merged.append(currentRun)
//            currentRun = nextRun
//        }
//    }
//    // Add the last processed run
//    merged.append(currentRun)
//    return merged
//}
//
///// Helper function to perform binary search on sorted, non-overlapping runs.
///// Checks if any run in the array covers the unit segment [coord, coord + 1).
//fileprivate func hasRunCoveringUnitSegment(runs: [Run], from coord: Int) -> Bool {
//    var low = 0
//    var high = runs.count - 1
//
//    while low <= high {
//        let mid = low + (high - low) / 2
//        let run = runs[mid]
//
//        if run.start <= coord {
//            // This run starts at or before our desired unit segment start.
//            // Check if it extends far enough to cover coord AND coord+1.
//            if run.end > coord {
//                // Found a run that starts <= coord and ends > coord,
//                // meaning it covers the interval [coord, coord+1).
//                return true
//            } else {
//                // This run ends at or before our segment starts (`run.end <= coord`),
//                // so we need to look for runs that start *later*.
//                low = mid + 1
//            }
//        } else { // run.start > coord
//             // This run starts too late. We need to look at runs starting *earlier*.
//            high = mid - 1
//        }
//    }
//
//    return false // No covering run found
//}
//
///// Solves the Mathematical Art problem using coordinate compression and run merging.
///// Finds "plus signs" by checking for required unit segments around internal grid
///// points using binary search on merged C++ data structures library or create implementations.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Coordinates ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    var pathVertices = [Point(x: 0, y: 0)]
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue } // Skip zero-length segments
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: fatalError("Invalid direction")
//        }
//        allX.insert(nextX)
//        allY.insert(nextY)
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append(Point(x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//    // Use dictionaries for efficient coordinate lookup
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count // Number of unique x-coordinates + vertical grid lines
//    let compNY = sortedY.count // Number of unique y-coordinates + horizontal grid lines
//
//    // A plus sign requires a center point with neighbors in all 4 directions.
//    // This means we need at least 3 distinct x and 3 distinct y coordinates.
//    guard compNX >= 3 && compNY >= 3 else { return 0 } // Need internal grid points
//
//    // --- Step 3: Create Initial Runs (Before Merging) ---
//    // Store runs for each row/column before merging
//    var hRunsByRow = [Int: [Run]]() // y -> [Run(x1, x2), ...]
//    var vRunsByCol = [Int: [Run]]() // x -> [Run(y1, y2), ...]
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOriginal = pathVertices[i]
//        let endOriginal = pathVertices[i+1]
//        // Safely unwrap mapped coordinates - they must exist
//        let cx1 = xMap[startOriginal.x]!
//        let cy1 = yMap[startOriginal.y]!
//        let cx2 = xMap[endOriginal.x]!
//        let cy2 = yMap[endOriginal.y]!
//
//        if cx1 == cx2 { // Vertical movement
//            let x = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2) // Make 'end' exclusive
//            if startY < endY { // Ensure non-zero length run
//                vRunsByCol[x, default: []].append(Run(start: startY, end: endY))
//            }
//        } else { // Horizontal movement (cy1 == cy2)
//            let y = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2) // Make 'end' exclusive
//             if startX < endX { // Ensure non-zero length run
//                hRunsByRow[y, default: []].append(Run(start: startX, end: endX))
//            }
//        }
//    }
//
//    // --- Step 4: Merge Runs for Each Row/Column ---
//    // Use mapValues for potentially cleaner transformation
//    let mergedHRuns = hRunsByRow.mapValues { mergeRuns($0) }
//    let mergedVRuns = vRunsByCol.mapValues { mergeRuns($0) }
//
//    // --- Step 5: Check for Plus Signs using Merged Runs (with Binary Search) ---
//    var plusCount = 0
//
//    // Iterate through internal grid points (potential centers of plus signs)
//    // cx and cy represent the indices in the compressed grid.
//    // An internal point requires 1 <= cx < compNX-1 and 1 <= cy < compNY-1
//    for cy in 1..<(compNY - 1) {
//        // Get the horizontal runs for the current row y=cy. If none exist, cannot form plus here.
//        guard let horizontalRuns = mergedHRuns[cy], !horizontalRuns.isEmpty else { continue }
//
//        for cx in 1..<(compNX - 1) {
//            // Get the vertical runs for the current column x=cx. If none exist, cannot form plus here.
//            guard let verticalRuns = mergedVRuns[cx], !verticalRuns.isEmpty else { continue }
//
//            // Check if the necessary *unit segments* around (cx, cy) are covered by runs
//            // Check left horizontal unit segment: [cx-1, cx)
//            let hasLeftH = hasRunCoveringUnitSegment(runs: horizontalRuns, from: cx - 1)
//            // Check right horizontal unit segment: [cx, cx+1)
//            let hasRightH = hasRunCoveringUnitSegment(runs: horizontalRuns, from: cx)
//            // Check down vertical unit segment: [cy-1, cy)
//            let hasDownV = hasRunCoveringUnitSegment(runs: verticalRuns, from: cy - 1)
//            // Check up vertical unit segment: [cy, cy+1)
//            let hasUpV = hasRunCoveringUnitSegment(runs: verticalRuns, from: cy)
//
//            // If all four unit segments around (cx, cy) are covered by existing runs...
//            if hasLeftH && hasRightH && hasDownV && hasUpV {
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
////let D6 = "RDLU"        // Creates a plus at (2, 0) -> Compresses to some internal point (cx, cy)
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
////let N11 = 4
////let L11 = [1, 2, 1, 2]
////let D11 = "RLUD" // Path: (0,0)->(1,0)->(-1,0)->(-1,1)->(-1,-1). Paints [-1,0] to [1,0] horizontally, [-1,-1] to [-1,1] vertically. Plus sign at (-1,0).
////let result11 = getPlusSignCount(N11, L11, D11)
////print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////print("\n--- Testing Complete ---")
