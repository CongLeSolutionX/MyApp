//
//  Solution31.swift
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
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation ---
    guard N >= 2, L.count == N, D.count == N else { return 0 }
    let directions = Array(D)

    // --- Step 1: Simulate Path and Collect Coordinates ---
    var currentX: Int64 = 0 // Use Int64 for coordinates
    var currentY: Int64 = 0
    var allX = Set<Int64>([0])
    var allY = Set<Int64>([0])
    var pathVertices = [(x: Int64, y: Int64)]() // Store original coordinates
    pathVertices.append((x: 0, y: 0))

    for i in 0..<N {
        let length = Int64(L[i]) // Use Int64
        guard length > 0 else { continue } // Skip zero-length strokes
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
        allX.insert(nextX)
        allY.insert(nextY)
        currentX = nextX
        currentY = nextY
        pathVertices.append((x: currentX, y: currentY))
    }

    // --- Step 2: Coordinate Compression ---
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()
    // Check if mapping fits in Int (highly likely unless N > Int.max)
    guard sortedX.count <= Int.max, sortedY.count <= Int.max else { return 0 }
    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
    let compNX = sortedX.count
    let compNY = sortedY.count

    // Need at least 3x3 compressed grid for a plus sign ('internal' point)
    guard compNX >= 3 && compNY >= 3 else { return 0 }

    // --- Step 3: Identify All Painted Unit Segments ---
    var hSegments = Set<Point>() // Point(cx, cy) means segment [cx, cx+1) at row cy exists
    var vSegments = Set<Point>() // Point(cx, cy) means segment [cy, cy+1) at col cx exists

    for i in 0..<(pathVertices.count - 1) {
        let startOrig = pathVertices[i]
        let endOrig = pathVertices[i+1]
        // Force unwrap safe: all path vertices are in the sets used for mapping
        let cx1 = xMap[startOrig.x]!
        let cy1 = yMap[startOrig.y]!
        let cx2 = xMap[endOrig.x]!
        let cy2 = yMap[endOrig.y]!

        if cx1 == cx2 { // Vertical stroke
            let cx = cx1
            let startY = min(cy1, cy2)
            let endY = max(cy1, cy2)
            for cy in startY..<endY { // Iterate through unit segments
                vSegments.insert(Point(x: cx, y: cy))
            }
        } else { // Horizontal stroke (cy1 == cy2)
            let cy = cy1
            let startX = min(cx1, cx2)
            let endX = max(cx1, cx2)
            for cx in startX..<endX { // Iterate through unit segments
                hSegments.insert(Point(x: cx, y: cy))
            }
        }
    }

    // --- Step 4: Check for Plus Signs ---
    var plusCount = 0

    // Iterate through potential right-arm starting points
    for point in hSegments {
        let cx = point.x
        let cy = point.y

        // Check if this point (cx, cy) could be a valid center.
        // Requires neighbors cx-1, cy-1, cy+1 to be potentially valid indices.
        guard cx > 0, cy > 0, cy < compNY - 1 else { continue }
        // Note cx+1 is implicitly < compNX because point(cx,cy) is in hSegments

        // Check for the other 3 required arms using the sets:
        // 1. Left Arm: Segment [cx-1, cx) at row cy must exist
        let leftArmExists = hSegments.contains(Point(x: cx - 1, y: cy))
        guard leftArmExists else { continue }

        // 2. Down Arm: Segment [cy-1, cy) at column cx must exist
        let downArmExists = vSegments.contains(Point(x: cx, y: cy - 1))
        guard downArmExists else { continue }

        // 3. Up Arm: Segment [cy, cy+1) at column cx must exist
        let upArmExists = vSegments.contains(Point(x: cx, y: cy))
        guard upArmExists else { continue }

        // If all checks passed (Right arm exists by definition, Left, Down, Up checked):
        plusCount += 1
    }

    return plusCount
}

//// --- Sample Tests ---
//print("--- Running Sample Test Cases (Unit Segment Set) ---")
//let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
//let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
//print("\n--- Running Boundary/Edge Test Cases (Unit Segment Set) ---")
//let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Path: (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2) - Center is (2,0)
//let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
//let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Path: (0,0)->(1,0)->(1,-2)->(0,-2)->(0,0) - Center is (0,?) correction -> path (0,0)->(1,0)->(1,-2)->(0,-2)->(0,0) -> No internal points. Let's trace D11="RLUD": (0,0)->(1,0), (1,0)->(-1,0), (-1,0)->(-1,1), (-1,1)->(-1,-1). Center should be (-1, 0). Correct expected=1.
//print("\n--- Testing Complete ---")
