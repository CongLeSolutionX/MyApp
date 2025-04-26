////
////  Solution25.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Point and Run structs remain the same as the previous version
//// mergeRuns and hasRunCoveringUnitSegment functions remain the same
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
//        return lhs.end < rhs.end
//    }
//
//    /// Checks if this run covers the single unit segment starting at `coord`.
//    /// The unit segment is the interval [coord, coord + 1).
//    func coversUnitSegment(from coord: Int) -> Bool {
//        return self.start <= coord && self.end > coord
//    }
//}
//
///// Merges overlapping or adjacent runs in a sorted array.
///// Assumes input runs are sorted primarily by start coordinate.
//fileprivate func mergeRuns(_ runs: [Run]) -> [Run] {
//    if runs.isEmpty { return [] }
//    let sortedRuns = runs.sorted()
//    var merged: [Run] = []
//    var currentRun = sortedRuns[0]
//    for i in 1..<sortedRuns.count {
//        let nextRun = sortedRuns[i]
//        if currentRun.end >= nextRun.start {
//            currentRun = Run(start: currentRun.start, end: max(currentRun.end, nextRun.end))
//        } else {
//            merged.append(currentRun)
//            currentRun = nextRun
//        }
//    }
//    merged.append(currentRun)
//    return merged
//}
//
///// Helper function to perform binary search on sorted, non-overlapping runs.
///// Checks if any run in the array covers the unit segment [coord, coord + 1).
//fileprivate func hasRunCoveringUnitSegment(runs: [Run], from coord: Int) -> Bool {
//    var low = 0
//    var high = runs.count - 1
//    while low <= high {
//        let mid = low + (high - low) / 2
//        let run = runs[mid]
//        if run.start <= coord {
//            if run.end > coord { return true }
//            else { low = mid + 1 }
//        } else { // run.start > coord
//            high = mid - 1
//        }
//    }
//    return false
//}
//
///// Solves the Mathematical Art problem using coordinate compression and run merging.
///// Optimized checking loop.
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
//    var pathVertices = [Point(x: 0, y: 0)] // Store original coordinates first
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue }
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
//        // Use original coordinates here, map later
//        pathVertices.append(Point(x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    guard compNX >= 3 && compNY >= 3 else { return 0 }
//
//    // --- Step 3: Create Initial Runs (Compressed) ---
//    var hRunsByRow = [Int: [Run]]()
//    var vRunsByCol = [Int: [Run]]()
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//        let cx1 = xMap[startOrig.x]!
//        let cy1 = yMap[startOrig.y]!
//        let cx2 = xMap[endOrig.x]!
//        let cy2 = yMap[endOrig.y]!
//
//        if cx1 == cx2 { // Vertical
//            let x = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            if startY < endY {
//                vRunsByCol[x, default: []].append(Run(start: startY, end: endY))
//            }
//        } else { // Horizontal cy1 == cy2
//            let y = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//             if startX < endX {
//                hRunsByRow[y, default: []].append(Run(start: startX, end: endX))
//            }
//        }
//    }
//
//    // --- Step 4: Merge Runs ---
//    let mergedHRuns = hRunsByRow.mapValues { mergeRuns($0) }
//    let mergedVRuns = vRunsByCol.mapValues { mergeRuns($0) }
//
//    // --- Step 5: Check for Plus Signs (Optimized Loop) ---
//    var plusCount = 0
//    let verticalRunsByX = mergedVRuns // Keep for efficient lookup
//
//    // Iterate through rows 'cy' that actually contain horizontal segments
//    for cy in mergedHRuns.keys {
//        // Check if this row 'cy' can support the vertical part of a plus sign
//        guard cy > 0, cy < compNY - 1 else { continue }
//
//        // Get the merged horizontal runs for this row
//        let horizontalRuns = mergedHRuns[cy]! // Should exist because we are iterating keys
//
//        // Iterate through each horizontal run in this row
//        for hRun in horizontalRuns {
//            // Determine the range of potential centers 'cx' covered by this run
//            // A center cx requires the run to cover [cx-1, cx+1)
//            // This means cx must be within [hRun.start + 1, hRun.end - 1] inclusive
//            // Loop range is [hRun.start + 1, hRun.end) exclusive for end
//            let startCX = hRun.start + 1
//            let endCX = hRun.end // Use exclusive end
//
//            for cx in startCX..<endCX {
//                // Check if this column 'cx' can support the horizontal part of a plus sign
//                guard cx > 0, cx < compNX - 1 else { continue }
//
//                // At this point, we know (cx, cy) is internal, and
//                // horizontal segments [cx-1, cx) and [cx, cx+1) EXIST at row cy.
//
//                // Now, check for the vertical segments using the pre-computed vertical runs.
//                // Get vertical runs for column 'cx'. If none exist, no plus sign here.
//                guard let verticalRuns = verticalRunsByX[cx], !verticalRuns.isEmpty else {
//                    continue
//                }
//
//                // Check only vertical segments: [cy-1, cy) and [cy, cy+1)
//                let hasDownV = hasRunCoveringUnitSegment(runs: verticalRuns, from: cy - 1)
//                let hasUpV = hasRunCoveringUnitSegment(runs: verticalRuns, from: cy)
//
//                // If both vertical segments exist, we found a plus sign
//                if hasDownV && hasUpV {
//                    plusCount += 1
//                }
//            }
//        }
//    }
//
//    return plusCount
//}
//
////// --- Testing with Examples (Including Sample 11 again) ---
////print("--- Running Sample Test Cases ---")
////// (Keep the same test cases as before)
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("(optimized) Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("(optimized) Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("(optimized) Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////print("\n--- Running Boundary/Edge Test Cases ---")
////let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("(optimized) Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("(optimized) Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("(optimized) Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N8 = 1; let L8 = [100]; let D8 = "R"; let result8 = getPlusSignCount(N8, L8, D8); print("(optimized) Sample 8 (Single Line) Result: \(result8) (\(result8 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("(optimized) Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct" : "Incorrect"), Expected: 0 -- Assuming strict definition)") // Expecting 0 based on logic, despite sample explanation might differ
////print("\n--- Testing Complete ---")
