////
////  Solution30.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//// Returning the refined (but potentially too slow) Set Intersection code
//// as it most accurately reflects the problem *definition*, even if it causes TLE.
//// The O(N log N) sweep-line requires a more complex Segment Tree implementation
//// that wasn't correctly developed previously.
//
//import Foundation
//
//// Point struct (same as before)
//fileprivate struct Point: Hashable { let x: Int; let y: Int }
//
//// Run struct (same as before)
//fileprivate struct Run: Comparable {
//    let start: Int; let end: Int
//    var length: Int { max(0, end - start) }
//    static func < (lhs: Run, rhs: Run) -> Bool {
//        if lhs.start != rhs.start { return lhs.start < rhs.start }
//        return lhs.end < rhs.end
//    }
//}
//
//// mergeSortedRuns function (same as before)
//fileprivate func mergeSortedRuns(_ sortedRuns: [Run]) -> [Run] {
//    // ... (implementation from the working Set Intersection code) ...
//     if sortedRuns.isEmpty { return [] }
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
//// generateHCenters function (same as before)
//// Identifies points (cx, cy) where horizontal runs cover cx-1, cx, and cx+1
//fileprivate func generateHCenters(mergedHRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
//    var hCenters = Set<Point>()
//    for (cy, runs) in mergedHRuns {
//        // Center y must allow for up/down arms (cy-1, cy+1)
//        guard cy > 0, cy < compNY - 1 else { continue }
//        for run in runs {
//            // Potential center cx requires run to cover [cx-1, cx+1), meaning run is at least length 2.
//            // Center cx must be in range [1, compNX-2]
//            // Loop range check: needs run.start <= cx-1 and run.end >= cx+2
//            // Effective loop for cx: max(1, run.start + 1) to min(compNX - 2, run.end - 1)
//            let startCX = max(1, run.start + 1)
//            let endCX = min(compNX - 2, run.end - 1) // Inclusive end for loop
//            guard startCX <= endCX else { continue }
//            for cx in startCX...endCX {
//                 hCenters.insert(Point(x: cx, y: cy))
//            }
//        }
//    }
//    return hCenters
//}
//
//// generateVCenters function (same as before)
//// Identifies points (cx, cy) where vertical runs cover cy-1, cy, and cy+1
//fileprivate func generateVCenters(mergedVRuns: [Int: [Run]], compNX: Int, compNY: Int) -> Set<Point> {
//    var vCenters = Set<Point>()
//    for (cx, runs) in mergedVRuns {
//        // Center x must allow for left/right arms (cx-1, cx+1)
//        guard cx > 0, cx < compNX - 1 else { continue }
//        for run in runs {
//           // Potential center cy requires run to cover [cy-1, cy+1), meaning run is at least length 2.
//           // Center cy must be in range [1, compNY-2]
//           // Loop range check: needs run.start <= cy-1 and run.end >= cy+2
//           // Effective loop for cy: max(1, run.start + 1) to min(compNY - 2, run.end - 1)
//            let startCY = max(1, run.start + 1)
//            let endCY = min(compNY - 2, run.end - 1) // Inclusive end for loop
//            guard startCY <= endCY else { continue }
//            for cy in startCY...endCY {
//                 vCenters.insert(Point(x: cx, y: cy))
//            }
//        }
//    }
//    return vCenters
//}
//
///// Solves the Mathematical Art problem using coordinate compression, run merging,
///// and set intersection. Correct logic but may TLE on large/dense inputs.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Unique Coordinates ---
//    var currentX: Int64 = 0; var currentY: Int64 = 0
//    var allXSet = Set<Int64>([0]); var allYSet = Set<Int64>([0])
//    var pathVertices = [(x: Int64, y: Int64)](); pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i]); guard length > 0 else { continue }
//        let direction = directions[i]
//        var nextX = currentX; var nextY = currentY
//        switch direction {
//        case "U": nextY += length; case "D": nextY -= length
//        case "L": nextX -= length; case "R": nextX += length
//        default: print("Error: Invalid direction"); return 0
//        }
//        allXSet.insert(nextX); allYSet.insert(nextY) // Collect only endpoints
//        currentX = nextX; currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allXSet.sorted(); let sortedY = allYSet.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count; let compNY = sortedY.count
//    guard compNX >= 3 && compNY >= 3 else { return 0 } // Need at least 3x3 compressed grid
//
//    // --- Step 3: Create Initial Horizontal and Vertical Runs (Compressed) ---
//    var hRunsByRow = [Int: [Run]](); var vRunsByCol = [Int: [Run]]()
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]; let endOrig = pathVertices[i+1]
//        guard let cx1 = xMap[startOrig.x], let cy1 = yMap[startOrig.y],
//              let cx2 = xMap[endOrig.x], let cy2 = yMap[endOrig.y] else {
//            fatalError("Coordinate mapping failed")
//        }
//        if cx1 == cx2 { // Vertical
//            let cx = cx1; let startY = min(cy1, cy2); let endY = max(cy1, cy2)
//            if startY < endY { vRunsByCol[cx, default: []].append(Run(start: startY, end: endY)) }
//        } else { // Horizontal
//            let cy = cy1; let startX = min(cx1, cx2); let endX = max(cx1, cx2)
//            if startX < endX { hRunsByRow[cy, default: []].append(Run(start: startX, end: endX)) }
//        }
//    }
//
//    // --- Step 4: Sort and Merge Runs ---
//    let mergedHRuns = hRunsByRow.mapValues { mergeSortedRuns($0.sorted()) }
//    let mergedVRuns = vRunsByCol.mapValues { mergeSortedRuns($0.sorted()) }
//
//    // --- Step 5: Generate Potential Center Sets based on 4-arm potential ---
//    // generateHCenters checks if H runs cover cx-1, cx, cx+1
//    // generateVCenters checks if V runs cover cy-1, cy, cy+1
//    let hCenters = generateHCenters(mergedHRuns: mergedHRuns, compNX: compNX, compNY: compNY)
//    let vCenters = generateVCenters(mergedVRuns: mergedVRuns, compNX: compNX, compNY: compNY)
//
//    // --- Step 6: Calculate Intersection Size ---
//    // A point is a plus center iff it has both H-arms potential AND V-arms potential
//    let intersection = hCenters.intersection(vCenters)
//    return intersection.count
//}
////
////// --- Sample Tests (Using Set Intersection approach) ---
////print("--- Running Sample Test Cases (Set Intersection O(N log N + Area)) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N5 = 8; let L5 = [4, 4, 4, 4, 2, 4, 4, 4]; let D5 = "RULDRULD"; let result5 = getPlusSignCount(N5, L5, D5); print("Sample 5 Result: \(result5) (\(result5 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////print("\n--- Testing Complete ---")
