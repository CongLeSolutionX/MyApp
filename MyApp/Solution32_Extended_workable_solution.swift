////
////  Solution32.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Represents a point in the compressed 2D grid.
//// Hashable for use in Sets.
//fileprivate struct Point: Hashable {
//    let x: Int // Compressed x-coordinate
//    let y: Int // Compressed y-coordinate
//}
//
///// Solves the Mathematical Art problem using coordinate compression
///// and checking for plus signs based on sets of unit horizontal and vertical segments.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    // Constraints: 2 <= N <= 2,000,000; 1 <= Li <= 1,000,000,000
//    // N * max(L) can exceed Int64.max, but individual coordinates should fit
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Coordinates ---
//    var currentX: Int64 = 0 // Use Int64 for coordinates
//    var currentY: Int64 = 0
//    // Using Arrays and sorting later might be more memory efficient for large N
//    // than inserting directly into Sets if coordinates are very spread out.
//    // However, Sets handle duplicates naturally. Let's stick with sets for simplicity
//    // unless memory becomes an issue.
//    var uniqueX = Set<Int64>([0])
//    var uniqueY = Set<Int64>([0])
//    // Store vertices to reconstruct segments later
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i]) // Use Int64
//        // Constraint: L_i >= 1, so no need to check for zero-length strokes
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: return 0 // Invalid direction (though constraints say only U,D,L,R)
//        }
//        // Check for potential overflow (extremely unlikely given constraints on N and L,
//        // but good practice if limits were different)
//        // if nextX < Int64.min || nextX > Int64.max || nextY < Int64.min || nextY > Int64.max {
//        //     // Handle potential overflow if necessary
//        //     return -1 // Or some error indicator
//        // }
//
//        uniqueX.insert(nextX)
//        uniqueY.insert(nextY)
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = uniqueX.sorted()
//    let sortedY = uniqueY.sorted()
//    // Check if mapping fits in Int (N <= 2M, so N+1 coordinates max, fits Int)
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // Need at least 3x3 compressed grid for an internal center point
//    guard compNX >= 3 && compNY >= 3 else { return 0 }
//
//    // --- Step 3: Identify All Painted Unit Segments ---
//    // Point(cx, cy) in hSegments means horizontal segment [cx, cx+1) exists at row cy
//    var hSegments = Set<Point>()
//    // Point(cx, cy) in vSegments means vertical segment [cy, cy+1) exists at column cx
//    var vSegments = Set<Point>()
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//        // Force unwrap safe: all path vertices originated from coordinates added to unique sets
//        let cx1 = xMap[startOrig.x]!
//        let cy1 = yMap[startOrig.y]!
//        let cx2 = xMap[endOrig.x]!
//        let cy2 = yMap[endOrig.y]!
//
//        if cx1 == cx2 { // Vertical stroke
//            let cx = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            for cy in startY..<endY { // Iterate through unit segments contained within the stroke
//                vSegments.insert(Point(x: cx, y: cy))
//            }
//        } else { // Horizontal stroke (cy1 == cy2)
//            let cy = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//            for cx in startX..<endX { // Iterate through unit segments contained within the stroke
//                hSegments.insert(Point(x: cx, y: cy))
//            }
//        }
//    }
//
//    // --- Step 4: Check for Plus Signs (Iterate over potential internal centers) ---
//    var plusCount = 0
//
//    // A plus sign center must be strictly internal in the compressed grid
//    // Range: cx from 1 to compNX-2, cy from 1 to compNY-2
//    for cx in 1..<(compNX - 1) {
//        for cy in 1..<(compNY - 1) {
//            // Check if the four required unit segments incident to this center exist
//            // 1. Right Arm: Horizontal segment starting at (cx, cy)
//            let rightArmExists = hSegments.contains(Point(x: cx, y: cy))
//            guard rightArmExists else { continue } // Optimization: if right arm is missing, can't be a center
//
//            // 2. Left Arm: Horizontal segment starting at (cx - 1, cy)
//            let leftArmExists = hSegments.contains(Point(x: cx - 1, y: cy))
//            guard leftArmExists else { continue }
//
//            // 3. Up Arm: Vertical segment starting at (cx, cy)
//            let upArmExists = vSegments.contains(Point(x: cx, y: cy))
//            guard upArmExists else { continue }
//
//            // 4. Down Arm: Vertical segment starting at (cx, cy - 1)
//            let downArmExists = vSegments.contains(Point(x: cx, y: cy - 1))
//            // Don't need guard here, if it exists, increment count
//
//            if downArmExists {
//                plusCount += 1
//            }
//        }
//    }
//
//    return plusCount
//}
////
////// --- Sample Tests ---
////print("--- Running Sample Test Cases (Unit Segment Set - Internal Center Check) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////print("\n--- Running Boundary/Edge Test Cases (Unit Segment Set - Internal Center Check) ---")
////let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Path: (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2) - Center is (2,0) Compresses to internal point
////let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct based on rules" : "Incorrect"), Expected: 0 based on rules)") // Center (-1,0) is not internal, no connection Left.
////print("\n--- Testing Complete ---")
