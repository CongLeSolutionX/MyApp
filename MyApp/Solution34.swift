//
//  Solution34.swift
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
/// Iterates through horizontal segments to find potential centers.
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation ---
    guard N >= 2, L.count == N, D.count == N else { return 0 }
    let directions = Array(D)

    // --- Step 1: Simulate Path and Collect Coordinates ---
    var currentX: Int64 = 0 // Use Int64 for coordinates to avoid overflow
    var currentY: Int64 = 0
    var uniqueX = Set<Int64>([0])
    var uniqueY = Set<Int64>([0])
    var pathVertices = [(x: Int64, y: Int64)]()
    pathVertices.reserveCapacity(N + 1)
    pathVertices.append((x: 0, y: 0))

    for i in 0..<N {
        let length = Int64(L[i])
        guard length >= 1 else { return 0 } // Length must be positive
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

    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })

    let compNX = sortedX.count
    let compNY = sortedY.count

    // Need at least 3x3 compressed grid for an internal center point
    guard compNX >= 3 && compNY >= 3 else { return 0 }

    // --- Step 3: Identify All Painted Unit Segments ---
    // Store the *start* points of unit segments in sets for O(1) average lookup.
    var hSegments = Set<Point>() // Point(cx, cy) means horizontal segment [cx, cx+1) exists at row cy
    var vSegments = Set<Point>() // Point(cx, cy) means vertical segment [cy, cy+1) exists at column cx

    // Estimate capacity (can be tuned, but helps avoid rehashes)
    hSegments.reserveCapacity(compNX * compNY / 2)
    vSegments.reserveCapacity(compNX * compNY / 2)

    for i in 0..<(pathVertices.count - 1) {
        let startOrig = pathVertices[i]
        let endOrig = pathVertices[i+1]

        // Map original path vertices to compressed coordinates (safe to unwrap)
        let cx1 = xMap[startOrig.x]!
        let cy1 = yMap[startOrig.y]!
        let cx2 = xMap[endOrig.x]!
        let cy2 = yMap[endOrig.y]!

        if cx1 == cx2 { // Vertical stroke
            let cx = cx1
            let startY = min(cy1, cy2)
            let endY = max(cy1, cy2)
            for cy in startY..<endY {
                vSegments.insert(Point(x: cx, y: cy))
            }
        } else { // Horizontal stroke (cy1 == cy2)
            let cy = cy1
            let startX = min(cx1, cx2)
            let endX = max(cx1, cx2)
            for cx in startX..<endX {
                 hSegments.insert(Point(x: cx, y: cy))
            }
        }
    }

    // --- Step 4: Check for Plus Signs (Iterate through horizontal segments) ---
    var plusCount = 0

    // Iterate through all recorded horizontal unit segments.
    // Each 'center' point here represents the segment (cx, cy) -> (cx+1, cy).
    // This point itself IS the potential center of a plus sign.
    for center in hSegments {
        let cx = center.x
        let cy = center.y

        // A plus sign center must be strictly internal in the compressed grid.
        // Check if there's space for left, down, and up arms.
        guard cx > 0 && cx < compNX - 1 && cy > 0 && cy < compNY - 1 else {
            continue
        }

        // Condition 1: Right Arm - Exists because 'center' is from hSegments.
        // Check the other three required arms:

        // Condition 2: Left Arm - Requires horizontal segment ending *at* (cx, cy),
        // which means a segment starting at (cx - 1, cy).
        guard hSegments.contains(Point(x: cx - 1, y: cy)) else { continue }

        // Condition 3: Up Arm - Requires vertical segment starting *at* (cx, cy),
        // going from (cx, cy) to (cx, cy + 1).
        guard vSegments.contains(Point(x: cx, y: cy)) else { continue }

        // Condition 4: Down Arm - Requires vertical segment ending *at* (cx, cy),
        // which means a segment starting at (cx, cy - 1).
        guard vSegments.contains(Point(x: cx, y: cy - 1)) else { continue }

        // If all four conditions pass, we found a plus sign centered at this compressed point.
        plusCount += 1
    }

    return plusCount
}
//
//// --- Sample Tests (Using Corrected Set-Based Check) ---
//print("--- Running Sample Test Cases (Corrected Set Check) ---")
//let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
//let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//
//print("\n--- Running Boundary/Edge Test Cases (Corrected Set Check) ---")
//let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N5 = 5; let L5 = [2, 2, 2, 2, 4]; let D5 = "RDULR"; // Using corrected D5 based on assumption
//let result5 = getPlusSignCount(N5, L5, D5); print("Sample 5 (Overlap) Result: \(result5) (\(result5 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Expected 1 at origin
//let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center (2,0) original -> (1,1) compressed
//let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N8 = 4; let L8 = [1,1,1,1]; let D8 = "RDLU"; let result8 = getPlusSignCount(N8, L8, D8); print("Sample 8 (Small Square) Result: \(result8) (\(result8 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center at (0,0) original -> (1,1) compressed
//let N9 = 7; let L9 = [1,1,1,1,1,1,1]; let D9 = "RDRDRDR"; let result9 = getPlusSignCount(N9, L9, D9); print("Sample 9 (Staircase) Result: \(result9) (\(result9 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N10 = 8; let L10 = [1,1,1,1,1,1,1,1]; let D10 = "RURURURU"; let result10 = getPlusSignCount(N10, L10, D10); print("Sample 10 (Diagonal) Result: \(result10) (\(result10 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center (-1,0) original -> (1,1) compressed after path:(0,0)->(1,0)->(-1,0)->(-1,1)->(-1,-1)
//
//// // Re-enable large test case if needed
//// let largeN = 2_000_000
//// var largeL = [Int](repeating: 1, count: largeN)
//// var largeD = ""
//// for i in 0..<largeN { largeD += ["R", "U", "L", "D"][i % 4] } // Creates a large spiral outward
//// print("\n--- Running Large Test Case (Corrected Set Check) ---")
//// let start = CFAbsoluteTimeGetCurrent()
//// let resultLarge = getPlusSignCount(largeN, largeL, largeD)
//// let time = CFAbsoluteTimeGetCurrent() - start
//// print("Large N Result: \(resultLarge) (\(resultLarge == 1 ? "Correct" : "Incorrect"), Expected: 1) (Time: \(String(format: "%.3f", time))s)")
//
//print("\n--- Testing Complete ---")
