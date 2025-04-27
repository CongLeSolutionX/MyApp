////
////  Solution35.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//import Foundation
//
//fileprivate struct Point: Hashable, CustomStringConvertible {
//    let x: Int // Compressed x-coordinate
//    let y: Int // Compressed y-coordinate
//
//    var description: String {
//        return "(\(x),\(y))"
//    }
//}
//
///// Solves the Mathematical Art problem using coordinate compression
///// and checking for plus signs based on sets of unit horizontal and vertical segments.
///// Iterates through potential center points derived from segment endpoints.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Coordinates (Endpoints Only) ---
//    var currentX: Int64 = 0
//    var currentY: Int64 = 0
//    var uniqueX = Set<Int64>([0])
//    var uniqueY = Set<Int64>([0])
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.reserveCapacity(N + 1)
//    pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i])
//        guard length >= 1 else {
//            // Handle invalid input length if necessary, problem implies L_i >= 1
//            // For safety, maybe return 0 or throw an error
//             return 0 // Or handle as appropriate
//        }
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
//
//    // Check if coordinates collapsed (e.g., only one unique X or Y)
//    guard sortedX.count > 1 || sortedY.count > 1 else { return 0 } // Need variance
//
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // --- Step 3: Identify All Painted Unit Segments (Compressed) ---
//    var hSegments = Set<Point>() // Point(cx, cy) means horizontal segment [cx, cx+1) exists at row cy
//    var vSegments = Set<Point>() // Point(cx, cy) means vertical segment [cy, cy+1) exists at column cx
//    var potentialCenters = Set<Point>() // Grid points that are ends of unit segments
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//
//        guard let cx1 = xMap[startOrig.x],
//              let cy1 = yMap[startOrig.y],
//              let cx2 = xMap[endOrig.x],
//              let cy2 = yMap[endOrig.y] else {
//            // This should not happen if uniqueX/Y contain all vertices
//            fatalError("Coordinate mapping failed")
//        }
//
//        if cx1 == cx2 { // Vertical stroke
//            let cx = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            for cy in startY..<endY {
//                let segStart = Point(x: cx, y: cy)
//                vSegments.insert(segStart)
//                potentialCenters.insert(segStart) // Add start point
//                potentialCenters.insert(Point(x: cx, y: cy + 1)) // Add end point
//            }
//        } else { // Horizontal stroke (cy1 == cy2)
//            let cy = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//            for cx in startX..<endX {
//                 let segStart = Point(x: cx, y: cy)
//                 hSegments.insert(segStart)
//                 potentialCenters.insert(segStart) // Add start point
//                 potentialCenters.insert(Point(x: cx + 1, y: cy)) // Add end point
//            }
//        }
//    }
//
//    // --- Step 4: Check Potential Centers for Plus Signs ---
//    var plusCount = 0
//
//    for center in potentialCenters {
//        let cx = center.x
//        let cy = center.y
//
//        // Check boundary conditions for neighbors needed in the checks
//        // Need cx-1 >= 0 => cx > 0
//        // Need cy-1 >= 0 => cy > 0
//        // Need segment starting at cx => cx < compNX - 1 (implicit in h/v set checks)
//        // Need segment starting at cy => cy < compNY - 1 (implicit in h/v set checks)
//        guard cx > 0, cy > 0 else {
//            continue // Cannot have left or down arm if cx=0 or cy=0
//        }
//         // We also need cx < compNX (to potentially query cx) and cy < compNY
//         // These are inherent if center came from segments within the bounds.
//         // The critical check is for cx-1 and cy-1 used explicitly below.
//
//        // Condition 1: Right Arm: segment (cx, cy) -> (cx+1, cy) must exist
//        guard hSegments.contains(Point(x: cx, y: cy)) else { continue }
//
//        // Condition 2: Left Arm: segment (cx-1, cy) -> (cx, cy) must exist
//        guard hSegments.contains(Point(x: cx - 1, y: cy)) else { continue }
//
//        // Condition 3: Up Arm: segment (cx, cy) -> (cx, cy+1) must exist
//        guard vSegments.contains(Point(x: cx, y: cy)) else { continue }
//
//        // Condition 4: Down Arm: segment (cx, cy-1) -> (cx, cy) must exist
//        guard vSegments.contains(Point(x: cx, y: cy - 1)) else { continue }
//
//        // If all four conditions pass, we found a plus sign centered at the original
//        // position corresponding to the compressed point (cx, cy).
//        plusCount += 1
//    }
//
//    return plusCount
//}
////
////// --- Sample Tests (Using Potential Centers Set) ---
////print("--- Running Sample Test Cases (Potential Centers Set Logic) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////print("\n--- Running Boundary/Edge Test Cases (Potential Centers Set Logic) ---")
////let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N5 = 5; let L5 = [2, 2, 2, 2, 4]; let D5 = "RDULR"; let result5 = getPlusSignCount(N5, L5, D5); print("Sample 5 (Overlap) Result: \(result5) (\(result5 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N8 = 4; let L8 = [1,1,1,1]; let D8 = "RDLU"; let result8 = getPlusSignCount(N8, L8, D8); print("Sample 8 (Small Square) Result: \(result8) (\(result8 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N9 = 7; let L9 = [1,1,1,1,1,1,1]; let D9 = "RDRDRDR"; let result9 = getPlusSignCount(N9, L9, D9); print("Sample 9 (Staircase) Result: \(result9) (\(result9 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N10 = 8; let L10 = [1,1,1,1,1,1,1,1]; let D10 = "RURURURU"; let result10 = getPlusSignCount(N10, L10, D10); print("Sample 10 (Diagonal) Result: \(result10) (\(result10 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////
////print("\n--- Testing Complete ---")
