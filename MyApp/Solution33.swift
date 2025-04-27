//
//  Solution33.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

import Foundation

// Represents a point in the compressed 2D grid.
// Hashable for use in Sets.
fileprivate struct Point: Hashable {
    let x: Int // Compressed x-coordinate
    let y: Int // Compressed y-coordinate
}

/// Solves the Mathematical Art problem using coordinate compression
/// and checking for plus signs based on sets of unit horizontal and vertical segments.
/// Optimized to check only potential centers derived from segment endpoints.
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation ---
    guard N >= 2, L.count == N, D.count == N else { return 0 }
    let directions = Array(D)

    // --- Step 1: Simulate Path and Collect Coordinates ---
    var currentX: Int64 = 0 // Use Int64 for coordinates to avoid overflow
    var currentY: Int64 = 0
    var uniqueX = Set<Int64>([0])
    var uniqueY = Set<Int64>([0])
    // Store vertices to reconstruct segments later efficiently
    var pathVertices = [(x: Int64, y: Int64)]()
    pathVertices.reserveCapacity(N + 1) // Reserve memory
    pathVertices.append((x: 0, y: 0))

    for i in 0..<N {
        let length = Int64(L[i])
        let direction = directions[i]
        var nextX = currentX
        var nextY = currentY

        switch direction {
        case "U": nextY += length
        case "D": nextY -= length
        case "L": nextX -= length
        case "R": nextX += length
        default: return 0 // Invalid direction
        }

        uniqueX.insert(nextX)
        uniqueY.insert(nextY)
        currentX = nextX
        currentY = nextY
        pathVertices.append((x: currentX, y: currentY))
    }

    // --- Step 2: Coordinate Compression ---
    let sortedX = uniqueX.sorted()
    let sortedY = uniqueY.sorted()

    // Map original coordinates to compressed integer indices
    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })

    let compNX = sortedX.count // Number of unique x-coordinates
    let compNY = sortedY.count // Number of unique y-coordinates

    // Need at least 3x3 compressed grid for an internal center point
    guard compNX >= 3 && compNY >= 3 else { return 0 }

    // --- Step 3: Identify All Painted Unit Segments ---
    // Store the *start* points of unit segments in sets for O(1) average lookup.
    // Point(cx, cy) in hSegments means horizontal segment [cx, cx+1) exists at row cy
    var hSegments = Set<Point>()
    // Point(cx, cy) in vSegments means vertical segment [cy, cy+1) exists at column cx
    var vSegments = Set<Point>()
    // Keep track of all unique points that are part of any segment endpoint.
    // These are the only candidates for plus-sign centers.
    var potentialCenters = Set<Point>()

    hSegments.reserveCapacity(compNX * compNY / 2) // Rough initial guess
    vSegments.reserveCapacity(compNX * compNY / 2) // Rough initial guess
    potentialCenters.reserveCapacity(compNX + compNY) // Rough initial guess

    for i in 0..<(pathVertices.count - 1) {
        let startOrig = pathVertices[i]
        let endOrig = pathVertices[i+1]

        // Map original path vertices to compressed coordinates. Force unwrap is safe
        // as all path vertices were used to build the uniqueX/Y sets and maps.
        let cx1 = xMap[startOrig.x]!
        let cy1 = yMap[startOrig.y]!
        let cx2 = xMap[endOrig.x]!
        let cy2 = yMap[endOrig.y]!

        let startPoint = Point(x: cx1, y: cy1)
        let endPoint = Point(x: cx2, y: cy2)

        // Add endpoints of the *original* compressed segment to potential centers
        potentialCenters.insert(startPoint)
        potentialCenters.insert(endPoint)

        if cx1 == cx2 { // Vertical stroke
            let cx = cx1
            let startY = min(cy1, cy2)
            let endY = max(cy1, cy2)
            // Iterate through unit segments contained within the stroke
            for cy in startY..<endY {
                let segmentStart = Point(x: cx, y: cy)
                vSegments.insert(segmentStart)
                // Also add the endpoints of this *unit* segment if needed, though
                // adding the original segment endpoints should cover all vertices.
                // potentialCenters.insert(segmentStart)
                // potentialCenters.insert(Point(x: cx, y: cy + 1))
            }
        } else { // Horizontal stroke (cy1 == cy2)
            let cy = cy1
            let startX = min(cx1, cx2)
            let endX = max(cx1, cx2)
            // Iterate through unit segments contained within the stroke
            for cx in startX..<endX {
                 let segmentStart = Point(x: cx, y: cy)
                 hSegments.insert(segmentStart)
                // Also add the endpoints of this *unit* segment if needed
                // potentialCenters.insert(segmentStart)
                // potentialCenters.insert(Point(x: cx + 1, y: cy))
            }
        }
    }

    // --- Step 4: Check for Plus Signs (Iterate only over potential centers) ---
    var plusCount = 0

    // Iterate through the points that actually lie on the path in the compressed grid
    for center in potentialCenters {
        let cx = center.x
        let cy = center.y

        // A plus sign center must be strictly internal in the compressed grid
        // Boundary points cannot be centers.
        guard cx > 0 && cx < compNX - 1 && cy > 0 && cy < compNY - 1 else {
            continue
        }

        // Check if the four required unit segments incident to this center exist using the sets.
        // Condition 1: Right Arm - Requires horizontal segment starting AT (cx, cy)
        guard hSegments.contains(Point(x: cx, y: cy)) else { continue }

        // Condition 2: Left Arm - Requires horizontal segment starting AT (cx - 1, cy)
        guard hSegments.contains(Point(x: cx - 1, y: cy)) else { continue }

        // Condition 3: Up Arm - Requires vertical segment starting AT (cx, cy)
        guard vSegments.contains(Point(x: cx, y: cy)) else { continue }

        // Condition 4: Down Arm - Requires vertical segment starting AT (cx, cy - 1)
        guard vSegments.contains(Point(x: cx, y: cy - 1)) else { continue }

        // If all four conditions pass, we found a plus sign centered at this compressed point.
        plusCount += 1
    }

    return plusCount
}
//
//// --- Sample Tests (Using Optimized Approach) ---
//print("--- Running Sample Test Cases (Optimized Endpoint Check) ---")
//let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
//let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//
//print("\n--- Running Boundary/Edge Test Cases (Optimized Endpoint Check) ---")
//let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N5 = 5; let L5 = [2, 2, 2, 2, 4]; let D5 = "RULD R"; let result5 = getPlusSignCount(N5, L5, D5); // Note: Typo in D5 assumed RDULR
//print("Sample 5 (Overlap) Result: Skipped due to unclear D5") // Original problem likely used 'RDULR' -> gives 1 plus at (0,0). Path: (0,0)->(2,0)->(2,-2)->(0,-2)->(0,0)->(4,0)
//let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center (2,0). Path: (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
//let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N8 = 4; let L8 = [1,1,1,1]; let D8 = "RDLU"; let result8 = getPlusSignCount(N8, L8, D8); print("Sample 8 (Small Square) Result: \(result8) (\(result8 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center at (0,0) original (1,1) compressed
//let N9 = 7; let L9 = [1,1,1,1,1,1,1]; let D9 = "RDRDRDR"; let result9 = getPlusSignCount(N9, L9, D9); print("Sample 9 (Staircase) Result: \(result9) (\(result9 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N10 = 8; let L10 = [1,1,1,1,1,1,1,1]; let D10 = "RURURURU"; let result10 = getPlusSignCount(N10, L10, D10); print("Sample 10 (Diagonal) Result: \(result10) (\(result10 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct" : "Incorrect"), Expected: 0)") // Center (-1,0) original is not internal after compression. Path vertices:(0,0),(1,0),(-1,0),(-1,1),(-1,-1)
//
//// Test case likely causing TLE before optimization (Large N, possibly large compressed grid)
//// let largeN = 2_000_000
//// var largeL = [Int](repeating: 1, count: largeN)
//// var largeD = ""
//// for i in 0..<largeN { largeD += ["R", "U", "L", "D"][i % 4] } // Creates a large spiral outward
//// print("\n--- Running Large Test Case (Optimized Endpoint Check) ---")
//// let start = CFAbsoluteTimeGetCurrent()
//// let resultLarge = getPlusSignCount(largeN, largeL, largeD)
//// let time = CFAbsoluteTimeGetCurrent() - start
//// print("Large N Result: \(resultLarge) (Time: \(String(format: "%.3f", time))s)") // Expect 1 plus at origin.
//
//print("\n--- Testing Complete ---")
