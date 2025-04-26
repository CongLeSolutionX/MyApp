//
//  Solution26.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//

import Foundation

/// Represents a point in the compressed 2D grid.
fileprivate struct Point: Hashable {
    let x: Int // Compressed x-coordinate
    let y: Int // Compressed y-coordinate
}

/// Represents a contiguous horizontal or vertical run of painted cells
/// in the compressed grid. `start` <= `end`. The range is [start, end).
/// Note: 'end' is EXCLUSIVE.
fileprivate struct Run: Comparable {
    let start: Int // Starting coordinate (either x or y)
    let end: Int   // Ending coordinate (either x or y) - EXCLUSIVE

    static func < (lhs: Run, rhs: Run) -> Bool {
        if lhs.start != rhs.start {
            return lhs.start < rhs.start
        }
        return lhs.end < rhs.end
    }
}

/// Merges overlapping or adjacent runs in a sorted array.
fileprivate func mergeRuns(_ runs: [Run]) -> [Run] {
    if runs.isEmpty { return [] }
    // Ensure sorting before merging logic
    let sortedRuns = runs.sorted()
    var merged: [Run] = []
    var currentRun = sortedRuns[0]

    for i in 1..<sortedRuns.count {
        let nextRun = sortedRuns[i]
        // Merge if they overlap or touch
        if currentRun.end >= nextRun.start {
            currentRun = Run(start: currentRun.start, end: max(currentRun.end, nextRun.end))
        } else {
            merged.append(currentRun)
            currentRun = nextRun
        }
    }
    merged.append(currentRun)
    return merged
}

// --- Helper: Generate HCenters ---
fileprivate func generateHCenters(mergedHRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
    var hCenters = Set<Point>()
    // Iterate through rows that have horizontal runs
    for (cy, runs) in mergedHRuns {
        // A center must be internal vertically
        guard cy > 0, cy < compNY - 1 else { continue }

        for run in runs {
            // Potential centers cx are from run.start + 1 up to run.end - 1
            // The range of cx to iterate is [run.start + 1, run.end)
            let startCX = run.start + 1
            let endCX = run.end // Exclusive end

            // Iterate only over valid internal cx coordinates
            let effectiveStartCX = max(1, startCX)
            let effectiveEndCX = min(compNX - 1, endCX) // Ensure cx < compNX - 1

            guard effectiveStartCX < effectiveEndCX else { continue } // Check if range is valid

            for cx in effectiveStartCX..<effectiveEndCX {
                 hCenters.insert(Point(x: cx, y: cy))
            }
        }
    }
    return hCenters
}

// --- Helper: Generate VCenters ---
fileprivate func generateVCenters(mergedVRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
    var vCenters = Set<Point>()
    // Iterate through columns that have vertical runs
    for (cx, runs) in mergedVRuns {
         // A center must be internal horizontally
        guard cx > 0, cx < compNX - 1 else { continue }

        for run in runs {
            // Potential centers cy are from run.start + 1 up to run.end - 1
            // The range of cy to iterate is [run.start + 1, run.end)
            let startCY = run.start + 1
            let endCY = run.end // Exclusive end

             // Iterate only over valid internal cy coordinates
            let effectiveStartCY = max(1, startCY)
            let effectiveEndCY = min(compNY - 1, endCY) // Ensure cy < compNY - 1

            guard effectiveStartCY < effectiveEndCY else { continue } // Check if range is valid

            for cy in effectiveStartCY..<effectiveEndCY {
                 vCenters.insert(Point(x: cx, y: cy))
            }
        }
    }
    return vCenters
}

/// Solves the Mathematical Art problem using coordinate compression, run merging,
/// and set intersection.
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation ---
    guard N >= 2, L.count == N, D.count == N else { return 0 }
    let directions = Array(D)

    // --- Step 1: Simulate Path and Collect Coordinates ---
    var currentX: Int64 = 0 // Use Int64 for coordinates due to large L_i
    var currentY: Int64 = 0
    var allX = Set<Int64>([0])
    var allY = Set<Int64>([0])
    var pathVertices = [(x: Int64, y: Int64)]() // Store original coordinates first
    pathVertices.append((x: 0, y: 0))

    for i in 0..<N {
        let length = Int64(L[i]) // Use Int64
        guard length > 0 else { continue }
        let direction = directions[i]
        var nextX = currentX
        var nextY = currentY

        switch direction {
        case "U": nextY += length
        case "D": nextY -= length
        case "L": nextX -= length
        case "R": nextX += length
        default: fatalError("Invalid direction") // Or return 0 for invalid input
        }
        allX.insert(nextX)
        allY.insert(nextY)
        currentX = nextX
        currentY = nextY
        pathVertices.append((x: currentX, y: currentY))
    }

    // --- Step 2: Coordinate Compression ---
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()
    // Ensure map values fit in Int
    guard sortedX.count <= Int.max, sortedY.count <= Int.max else { return 0 }
    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
    let compNX = sortedX.count
    let compNY = sortedY.count

    // Need at least 3x3 compressed grid to form a plus sign
    guard compNX >= 3 && compNY >= 3 else { return 0 }

    // --- Step 3: Create Initial Runs (Compressed) ---
    var hRunsByRow = [Int: [Run]]() // [cy: [Run(startX, endX)]]
    var vRunsByCol = [Int: [Run]]() // [cx: [Run(startY, endY)]]

    for i in 0..<(pathVertices.count - 1) {
        let startOrig = pathVertices[i]
        let endOrig = pathVertices[i+1]
        // Force unwrap is safe because all path vertices were added to allX/allY
        let cx1 = xMap[startOrig.x]!
        let cy1 = yMap[startOrig.y]!
        let cx2 = xMap[endOrig.x]!
        let cy2 = yMap[endOrig.y]!

        if cx1 == cx2 { // Vertical stroke
            let x = cx1
            let startY = min(cy1, cy2)
            let endY = max(cy1, cy2) // end coordinate is exclusive in Run
            if startY < endY { // Only add if length > 0
                 vRunsByCol[x, default: []].append(Run(start: startY, end: endY))
            }
        } else { // Horizontal stroke (cy1 == cy2)
            let y = cy1
            let startX = min(cx1, cx2)
            let endX = max(cx1, cx2) // end coordinate is exclusive in Run
             if startX < endX { // Only add if length > 0
                 hRunsByRow[y, default: []].append(Run(start: startX, end: endX))
            }
        }
    }

    // --- Step 4: Merge Runs ---
    // Use mapValues for transformation, creates new dictionaries
    let mergedHRuns = hRunsByRow.mapValues { mergeRuns($0) }
    let mergedVRuns = vRunsByCol.mapValues { mergeRuns($0) }

    // --- Step 5: Generate Center Sets ---
    // Pass grid dimensions for boundary checks
    let hCenters = generateHCenters(mergedHRuns: mergedHRuns, compNX: compNX, compNY: compNY)
    let vCenters = generateVCenters(mergedVRuns: mergedVRuns, compNX: compNX, compNY: compNY)

    // --- Step 6: Calculate Intersection Size ---
    var plusCount = 0
    // Iterate through the smaller set for efficiency
    if hCenters.count < vCenters.count {
        for point in hCenters {
            if vCenters.contains(point) {
                plusCount += 1
            }
        }
    } else {
        for point in vCenters {
            if hCenters.contains(point) {
                plusCount += 1
            }
        }
    }
    // Swift 5 specific intersection (potentially cleaner?)
    // let intersection = hCenters.intersection(vCenters)
    // return intersection.count

    return plusCount
}

//// --- Sample Tests ---
//print("--- Running Sample Test Cases (Set Intersection) ---")
//let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
//let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//print("\n--- Running Boundary/Edge Test Cases (Set Intersection) ---")
//let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//print("\n--- Testing Complete ---")
