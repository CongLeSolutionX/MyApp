////
////  Solution28.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
///// Represents a point in the compressed 2D grid. Uses Int for compressed coordinates.
//fileprivate struct Point: Hashable {
//    let x: Int
//    let y: Int
//}
//
///// Represents a contiguous horizontal or vertical run [start, end) in the compressed grid.
//fileprivate struct Run: Comparable {
//    let start: Int // Inclusive start
//    let end: Int   // Exclusive end
//
//    var length: Int { max(0, end - start) } // Length in compressed units
//
//    static func < (lhs: Run, rhs: Run) -> Bool {
//        if lhs.start != rhs.start {
//            return lhs.start < rhs.start
//        }
//        return lhs.end < rhs.end // Shorter runs first if starts are equal
//    }
//}
//
///// Merges overlapping or adjacent runs in a pre-sorted array.
//fileprivate func mergeSortedRuns(_ sortedRuns: [Run]) -> [Run] {
//    if sortedRuns.isEmpty { return [] }
//    var merged: [Run] = []
//    var currentRun = sortedRuns[0]
//
//    for i in 1..<sortedRuns.count {
//        let nextRun = sortedRuns[i]
//        // Merge if they overlap or touch (currentRun.end >= nextRun.start)
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
///// Generates potential plus-sign centers based *only* on horizontal coverage.
///// A point (cx, cy) is included if rows cy and horizontal segments [..., cx-1, cx, cx+1, ...] exist.
//fileprivate func generateHCenters(mergedHRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
//    var hCenters = Set<Point>()
//    // Reserve capacity if we expect many centers? Might not help TLE significantly.
//    // hCenters.reserveCapacity(compNX * compNY / 10) // Heuristic guess
//
//    for (cy, runs) in mergedHRuns {
//        // Center y must be internal
//        guard cy > 0, cy < compNY - 1 else { continue }
//        // Runs are already merged for this row cy
//        for run in runs {
//            // Potential center cx range: [run.start + 1, run.end - 1] inclusive
//            // run.start + 1 <= cx <= run.end - 1
//            // Needs cx >= 1 and cx <= compNX - 2 for center x to be internal
//            let startCX = max(1, run.start + 1)
//            let endCX = min(compNX - 2, run.end - 1) // Inclusive end for the loop
//
//            guard startCX <= endCX else { continue } // Check if range is valid
//
//            for cx in startCX...endCX { // Inclusive range
//                 hCenters.insert(Point(x: cx, y: cy))
//            }
//        }
//    }
//    return hCenters
//}
//
///// Generates potential plus-sign centers based *only* on vertical coverage.
///// A point (cx, cy) is included if column cx and vertical segments [..., cy-1, cy, cy+1, ...] exist.
//fileprivate func generateVCenters(mergedVRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
//    var vCenters = Set<Point>()
//     // vCenters.reserveCapacity(compNX * compNY / 10) // Heuristic guess
//
//    for (cx, runs) in mergedVRuns {
//         // Center x must be internal
//        guard cx > 0, cx < compNX - 1 else { continue }
//        // Runs are already merged for this column cx
//        for run in runs {
//            // Potential center cy range: [run.start + 1, run.end - 1] inclusive
//            // run.start + 1 <= cy <= run.end - 1
//            // Needs cy >= 1 and cy <= compNY - 2 for center y to be internal
//            let startCY = max(1, run.start + 1)
//            let endCY = min(compNY - 2, run.end - 1) // Inclusive end for the loop
//
//            guard startCY <= endCY else { continue } // Check if range is valid
//
//            for cy in startCY...endCY { // Inclusive range
//                 vCenters.insert(Point(x: cx, y: cy))
//            }
//        }
//    }
//    return vCenters
//}
//
///// Solves the Mathematical Art problem using coordinate compression, run merging,
///// and set intersection. Optimized structure and checks.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Unique Coordinates ---
//    // Use Int64 for original coordinates to prevent overflow
//    var currentX: Int64 = 0
//    var currentY: Int64 = 0
//    var allX = Set<Int64>([0])
//    var allY = Set<Int64>([0])
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i])
//        guard length > 0 else { continue } // Ignore zero-length strokes
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: return 0 // Invalid direction
//        }
//        // Add both start and end points of the relevant axis range
//        // Although just endpoints might suffice if we only care about grid lines
//        allX.insert(nextX)
//        allY.insert(nextY)
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//    // Map original Int64 coordinate to compressed Int index
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count // Number of distinct vertical grid lines
//    let compNY = sortedY.count // Number of distinct horizontal grid lines
//
//    // A plus sign requires at least a 3x3 area in the compressed grid
//    guard compNX >= 3 && compNY >= 3 else { return 0 }
//
//    // --- Step 3: Create Initial Horizontal and Vertical Runs (Compressed) ---
//    // Group runs by row (cy) or column (cx)
//    // Using arrays initially then converting to dictionary later might be slightly faster
//    // if dictionary creation/resizing is slow, but likely negligible.
//    var hRunsByRow = [Int: [Run]]() // [cy: [Run(startX, endX)]]
//    var vRunsByCol = [Int: [Run]]() // [cx: [Run(startY, endY)]]
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//        // Map coordinates - force unwrap should be safe if collection was done correctly
//        guard let cx1 = xMap[startOrig.x], let cy1 = yMap[startOrig.y],
//              let cx2 = xMap[endOrig.x], let cy2 = yMap[endOrig.y] else {
//            fatalError("Coordinate mapping failed - logic error in collection")
//        }
//
//        if cx1 == cx2 { // Vertical stroke
//            let cx = cx1
//            // Ensure start < end for Run constructor
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            if startY < endY { // Only add runs with positive length
//                 vRunsByCol[cx, default: []].append(Run(start: startY, end: endY))
//            }
//        } else { // Horizontal stroke (cy1 should == cy2)
//            let cy = cy1
//            // Ensure start < end for Run constructor
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//             if startX < endX { // Only add runs with positive length
//                 hRunsByRow[cy, default: []].append(Run(start: startX, end: endX))
//            }
//        }
//    }
//
//    // --- Step 4: Sort and Merge Runs ---
//    let mergedHRuns = hRunsByRow.mapValues { mergeSortedRuns($0.sorted()) }
//    let mergedVRuns = vRunsByCol.mapValues { mergeSortedRuns($0.sorted()) }
//
//    // --- Step 5: Generate Potential Center Sets ---
//    let hCenters = generateHCenters(mergedHRuns: mergedHRuns, compNX: compNX, compNY: compNY)
//    let vCenters = generateVCenters(mergedVRuns: mergedVRuns, compNX: compNX, compNY: compNY)
//
//    // --- Step 6: Calculate Intersection Size ---
//    // Use the built-in Set intersection method (likely optimized C code)
//    let intersection = hCenters.intersection(vCenters)
//    return intersection.count
//
//    /* Alternative intersection counting (manual iteration)
//    var plusCount = 0
//    // Iterate through the smaller set for potential efficiency gain
//    if hCenters.count < vCenters.count {
//        for point in hCenters {
//            if vCenters.contains(point) { // O(1) average lookup
//                plusCount += 1
//            }
//        }
//    } else {
//        for point in vCenters {
//            if hCenters.contains(point) { // O(1) average lookup
//                plusCount += 1
//            }
//        }
//    }
//    return plusCount
//    */
//}
//
////// --- Sample Tests (Re-run with refined code) ---
////print("--- Running Sample Test Cases (Refined Set Intersection) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////// ... (add other edge cases if needed)
////print("\n--- Testing Complete ---")
