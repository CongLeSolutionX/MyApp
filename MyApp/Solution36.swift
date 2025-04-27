////
////  Solution36.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Represents a point in the compressed 2D grid.
//// Hashable for use in Sets. Stored value is the *start* of a unit segment.
//fileprivate struct Point: Hashable, CustomStringConvertible {
//    let x: Int // Compressed x-coordinate
//    let y: Int // Compressed y-coordinate
//
//    // Optional: For debugging clarity
//    var description: String {
//        return "(\(x),\(y))"
//    }
//}
//
///// Solves the Mathematical Art problem by finding plus signs in a painted path.
///// Uses coordinate compression and checks for the presence of four adjacent
///// unit segments around potential center points.
/////
///// - Parameters:
/////   - N: The number of strokes. (2 <= N <= 2,000,000)
/////   - L: An array of stroke lengths. (1 <= L_i <= 1,000,000,000)
/////   - D: A string representing stroke directions (U, D, L, R).
///// - Returns: The number of positions where a plus sign is present.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Coordinates (Endpoints Only) ---
//    // Use Int64 for original coordinates to prevent overflow.
//    var currentX: Int64 = 0
//    var currentY: Int64 = 0
//    // Sets to store unique x and y coordinates encountered. Include origin.
//    var uniqueX = Set<Int64>([0])
//    var uniqueY = Set<Int64>([0])
//    // Store vertices of the path for segment generation later.
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.reserveCapacity(N + 1)
//    pathVertices.append((x: 0, y: 0)) // Start at origin
//
//    for i in 0..<N {
//        let length = Int64(L[i])
//        // Basic validation for stroke length, problem statement implies >= 1.
//        guard length >= 1 else { return 0 }
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        // Calculate the next vertex based on direction and length.
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: return 0 // Invalid direction character
//        }
//
//        // Store unique coordinates for compression.
//        uniqueX.insert(nextX)
//        uniqueY.insert(nextY)
//        // Update current position and add vertex to path.
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    // Sort the unique coordinates to establish mapping.
//    let sortedX = uniqueX.sorted()
//    let sortedY = uniqueY.sorted()
//
//    // Create dictionaries to map original coordinates to compressed indices (0-based).
//    // If only one unique coordinate exists, compression isn't meaningful for plus signs.
//    guard sortedX.count > 1 || sortedY.count > 1 else { return 0 }
//
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//
//    // Dimensions of the compressed grid.
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // --- Step 3: Identify All Painted Unit Segments (Compressed Grid) ---
//    // hSegments stores Point(cx, cy) if horizontal unit segment [cx, cx+1) exists at row cy.
//    var hSegments = Set<Point>()
//    // vSegments stores Point(cx, cy) if vertical unit segment [cy, cy+1) exists at column cx.
//    var vSegments = Set<Point>()
//    // potentialCenters stores all grid points (cx, cy) that are endpoints of any unit segment.
//    var potentialCenters = Set<Point>()
//
//    // Reserve capacity for performance, estimates can be tuned.
//    hSegments.reserveCapacity(N * 2)
//    vSegments.reserveCapacity(N * 2)
//    potentialCenters.reserveCapacity(N * 4)
//
//    // Iterate through the path segments defined by consecutive vertices.
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//
//        // Map original vertices to compressed coordinates. Force unwrap is safe here
//        // as all vertices were added to uniqueX/Y.
//        let cx1 = xMap[startOrig.x]!
//        let cy1 = yMap[startOrig.y]!
//        let cx2 = xMap[endOrig.x]!
//        let cy2 = yMap[endOrig.y]!
//
//        // Generate the unit segments covered by this original stroke.
//        if cx1 == cx2 { // Vertical stroke
//            let cx = cx1
//            let startY = min(cy1, cy2) // Start index for loop
//            let endY = max(cy1, cy2)   // End index (exclusive) for loop
//            // Add all unit vertical segments along the stroke.
//            for cy in startY..<endY {
//                let segStartPoint = Point(x: cx, y: cy)
//                vSegments.insert(segStartPoint)
//                // Add both endpoints of the unit segment to potential centers.
//                potentialCenters.insert(segStartPoint)
//                potentialCenters.insert(Point(x: cx, y: cy + 1))
//            }
//        } else { // Horizontal stroke (cy1 == cy2)
//            let cy = cy1
//            let startX = min(cx1, cx2) // Start index for loop
//            let endX = max(cx1, cx2)   // End index (exclusive) for loop
//            // Add all unit horizontal segments along the stroke.
//            for cx in startX..<endX {
//                 let segStartPoint = Point(x: cx, y: cy)
//                 hSegments.insert(segStartPoint)
//                 // Add both endpoints of the unit segment to potential centers.
//                 potentialCenters.insert(segStartPoint)
//                 potentialCenters.insert(Point(x: cx + 1, y: cy))
//            }
//        }
//    }
//
//    // --- Step 4: Check Potential Centers for Plus Signs ---
//    var plusCount = 0
//
//    // Iterate through every point that could potentially be a center.
//    // A point (cx, cy) represents original (sortedX[cx], sortedY[cy]).
//    for center in potentialCenters {
//        let cx = center.x
//        let cy = center.y
//
//        // Boundary checks: For a point (cx, cy) to be a center, we need to check
//        // segments starting at (cx-1, cy) and (cx, cy-1).
//        // This requires cx > 0 and cy > 0.
//        guard cx > 0, cy > 0 else {
//            continue // Skip points on the boundary where left/down checks are invalid.
//        }
//        // We also implicitly need cx < compNX and cy < compNY for the cx, cy checks.
//        // And need cx < compNX - 1 for h(cx,_) checks, cy < compNY - 1 for v(_,cy) checks.
//        // These are usually handled if the center point came from segment generation,
//        // but the explicit check for cx>0, cy>0 is safest.
//
//        // Check for the presence of the four required unit segments around the center (cx, cy).
//
//        // 1. Right Arm: Segment (cx, cy) -> (cx+1, cy) painted? Check h(cx, cy)
//        guard hSegments.contains(center) else { continue } // Use 'center' directly
//
//        // 2. Left Arm: Segment (cx-1, cy) -> (cx, cy) painted? Check h(cx-1, cy)
//        guard hSegments.contains(Point(x: cx - 1, y: cy)) else { continue }
//
//        // 3. Up Arm: Segment (cx, cy) -> (cx, cy+1) painted? Check v(cx, cy)
//        guard vSegments.contains(center) else { continue } // Use 'center' directly
//
//        // 4. Down Arm: Segment (cx, cy-1) -> (cx, cy) painted? Check v(cx, cy-1)
//        guard vSegments.contains(Point(x: cx, y: cy - 1)) else { continue }
//
//        // If all four segment checks pass, increment the count.
//        plusCount += 1
//    }
//
//    return plusCount
//}
