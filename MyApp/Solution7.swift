//
//  Solution7.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//

import Foundation

// Using Sets for sparse grid storage is generally efficient for large, sparse grids.
// Dictionaries of Sets: [row/col_index: Set<col/row_segment_index>]

func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation and Base Cases ---
    guard N >= 1 else { return 0 } // No strokes, no plus signs

    // --- Step 1 & 2: Simulate Path, Collect Coordinates & Difference Maps ---
    var currentX: Int = 0
    var currentY: Int = 0
    var allX = Set<Int>([0]) // Use Sets for automatic uniqueness
    var allY = Set<Int>([0])

    // Difference maps using ORIGINAL coordinates
    // hDiffMap[y][x] = change (+1 start / -1 end) horizontal segment at (x,y)
    var hDiffMap: [Int: [Int: Int]] = [:]
    // vDiffMap[x][y] = change (+1 start / -1 end) vertical segment at (x,y)
    var vDiffMap: [Int: [Int: Int]] = [:]

    let directions = Array(D)

    for i in 0..<N {
        let length = L[i]
        guard length > 0 else { continue } // Ignore zero-length strokes
        let direction = directions[i]

        let startX = currentX
        let startY = currentY
        var endX = currentX
        var endY = currentY

        // Update end coordinates and populate difference maps
        switch direction {
        case "U":
            endY += length
            // Vertical segment from (startX, startY) to (startX, endY)
            let y1 = startY; let y2 = endY // y1 is below y2
            vDiffMap[startX, default: [:]][y1, default: 0] += 1
            vDiffMap[startX, default: [:]][y2, default: 0] -= 1
        case "D":
            endY -= length
            // Vertical segment from (startX, endY) to (startX, startY)
            let y1 = endY; let y2 = startY // y1 is below y2
            vDiffMap[startX, default: [:]][y1, default: 0] += 1
            vDiffMap[startX, default: [:]][y2, default: 0] -= 1
        case "L":
            endX -= length
            // Horizontal segment from (endX, startY) to (startX, startY)
            let x1 = endX; let x2 = startX // x1 is left of x2
            hDiffMap[startY, default: [:]][x1, default: 0] += 1
            hDiffMap[startY, default: [:]][x2, default: 0] -= 1
        case "R":
            endX += length
            // Horizontal segment from (startX, startY) to (endX, startY)
            let x1 = startX; let x2 = endX // x1 is left of x2
            hDiffMap[startY, default: [:]][x1, default: 0] += 1
            hDiffMap[startY, default: [:]][x2, default: 0] -= 1
        default:
            fatalError("Invalid direction encountered: \(direction)")
        }

        // Collect coordinates from both start and end points
        allX.insert(startX); allX.insert(endX)
        allY.insert(startY); allY.insert(endY)

        // Update current position for the next stroke
        currentX = endX
        currentY = endY
    }

    // --- Step 3: Coordinate Compression ---
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()

    // Create mappings from original coordinate to compressed index
    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))

    let compNX = sortedX.count // Number of unique X grid lines
    let compNY = sortedY.count // Number of unique Y grid lines

    // Early exit if grid is too small to contain a plus sign
    if compNX < 3 || compNY < 3 {
        return 0 // Cannot form a plus sign without at least 3x3 grid lines
    }

    // --- Step 4: Build Coverage Grids using Sweep-Line ---

    // hGrid[cy] stores Set of cx where segment from cx to cx+1 is painted
    var hGrid: [Int: Set<Int>] = [:]
    for (origY, xCoordinateChanges) in hDiffMap {
        // Map the original Y to its compressed row index (cy)
        guard let cy = yMap[origY], !xCoordinateChanges.isEmpty else { continue }

        // Get original X coordinates where changes happen in this row, and sort them
        let sortedOriginalXCoords = xCoordinateChanges.keys.sorted()

        var currentCoverage = 0
        // Start sweep from the first point's compressed index
        guard let firstOrigX = sortedOriginalXCoords.first,
              let firstCX = xMap[firstOrigX] else { continue } // Should always succeed
        var lastCX = firstCX

        for origX in sortedOriginalXCoords {
            guard let cx = xMap[origX] else { continue } // Current point's compressed index

            // If coverage was active *before* this point, fill the segments
            if currentCoverage > 0 && cx > lastCX {
                // Mark horizontal segments between lastCX and cx as painted
                for segmentIndex in lastCX..<cx {
                    hGrid[cy, default: Set<Int>()].insert(segmentIndex)
                }
            }

            // Apply the change in coverage at the current point
            currentCoverage += xCoordinateChanges[origX, default: 0]
            // Update the last processed compressed X index
            lastCX = cx
        }
         // Final segment check is implicitly handled as coverage should return to 0
    }

    // vGrid[cx] stores Set of cy where segment from cy to cy+1 is painted
    var vGrid: [Int: Set<Int>] = [:]
    for (origX, yCoordinateChanges) in vDiffMap {
         // Map the original X to its compressed column index (cx)
        guard let cx = xMap[origX], !yCoordinateChanges.isEmpty else { continue }

        // Get original Y coordinates where changes happen in this column, and sort them
        let sortedOriginalYCoords = yCoordinateChanges.keys.sorted()

        var currentCoverage = 0
         // Start sweep from the first point's compressed index
        guard let firstOrigY = sortedOriginalYCoords.first,
              let firstCY = yMap[firstOrigY] else { continue } // Should always succeed
        var lastCY = firstCY

        for origY in sortedOriginalYCoords {
             guard let cy = yMap[origY] else { continue } // Current point's compressed index

            // If coverage was active *before* this point, fill the segments
             if currentCoverage > 0 && cy > lastCY {
                // Mark vertical segments between lastCY and cy as painted
                 for segmentIndex in lastCY..<cy {
                    vGrid[cx, default: Set<Int>()].insert(segmentIndex)
                 }
             }
             
             // Apply the change in coverage at the current point
             currentCoverage += yCoordinateChanges[origY, default: 0]
             // Update the last processed compressed Y index
             lastCY = cy
        }
    }

    // --- Step 5: Check All Internal Grid Points for Plus Signs ---
    var plusCount = 0
    // Iterate through all potential center points (cx, cy)
    // These points must be internal, not on the boundary grid lines
    for cx in 1..<(compNX - 1) {         // from cx=1 up to compNX-2
        for cy in 1..<(compNY - 1) {     // from cy=1 up to compNY-2

            // Check for painted segments in all 4 directions FROM this point (cx, cy)
            // A segment's index corresponds to the coordinate of its starting point in that direction.
            // Left segment starts at cx-1, Right segment starts at cx
            // Down segment starts at cy-1, Up segment starts at cy

            // Check LEFT : segment between cx-1 and cx exists at row cy?
            let hasLeftSegment = hGrid[cy]?.contains(cx - 1) ?? false
            // Check RIGHT: segment between cx and cx+1 exists at row cy?
            let hasRightSegment = hGrid[cy]?.contains(cx) ?? false
            // Check DOWN : segment between cy-1 and cy exists at col cx?
            let hasDownSegment = vGrid[cx]?.contains(cy - 1) ?? false
            // Check UP   : segment between cy and cy+1 exists at col cx?
            let hasUpSegment = vGrid[cx]?.contains(cy) ?? false

            // If all four segments touching the point (cx, cy) are painted
            if hasLeftSegment && hasRightSegment && hasDownSegment && hasUpSegment {
                plusCount += 1
            }
        }
    }

    return plusCount
}

//// --- Testing with provided examples ---
//let N1 = 9
//let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
//let D1 = "ULDRULURD"
//let result1 = getPlusSignCount(N1, L1, D1)
//print("Sample 1 Result: \(result1) (Expected: 4)") // Confirmed correct logic gives 4
//
//let N2 = 8
//let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
//let D2 = "RDLUULDR"
//let result2 = getPlusSignCount(N2, L2, D2)
//print("Sample 2 Result: \(result2) (Expected: 1)") // Confirmed correct logic gives 1 (at 0,0)
//
//let N3 = 8
//let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
//let D3 = "UDUDLRLR"
//let result3 = getPlusSignCount(N3, L3, D3)
//print("Sample 3 Result: \(result3) (Expected: 1)") // Confirmed correct logic gives 1 (at 0,0)
//
//// Additional test case: Path: (0,0) -> (5,0) -> (5,-2) -> (2,-2) -> (2,2)
//// Intersection and plus sign expected at (2,0), which is not an original vertex.
//let N4_path = 4
//let L4_path = [5, 2, 3, 4] // R 5, D 2, L 3, U 4
//let D4_path = "RDLU"
//let result4 = getPlusSignCount(N4_path, L4_path, D4_path)
//print("Sample 4 (Intersection) Result: \(result4) (Expected: 1 at (2,0))") // Correct logic gives 1
