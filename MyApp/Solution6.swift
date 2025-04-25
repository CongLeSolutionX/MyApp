////
////  Solution6.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Simple Point struct for coordinates, Hashable for Set storage
//struct Point: Hashable {
//    let x: Int
//    let y: Int
//}
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    guard N >= 1 else { return 0 } // Handle edge case
//
//    var cx: Int = 0
//    var cy: Int = 0
//    // Use Sets to automatically handle uniqueness
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//
//    // Difference maps using original coordinates
//    // hDiffMap[y_coord][x_coord] = change (+1 start / -1 end)
//    var hDiffMap: [Int: [Int: Int]] = [:]
//    // vDiffMap[x_coord][y_coord] = change (+1 start / -1 end)
//    var vDiffMap: [Int: [Int: Int]] = [:]
//
//    // Store all unique vertices (original coords) visited during the path
//    var originalVertices = Set<Point>([Point(x: 0, y: 0)])
//
//    let directions = Array(D)
//
//    // === Step 1: Simulate Path, Collect Coords, Diffs, Vertices ===
//    for i in 0..<N {
//        let len = L[i]
//        guard len > 0 else { continue } // Ignore zero-length strokes
//        let dir = directions[i]
//        
//        let startVertex = Point(x: cx, y: cy)
//        var nx = cx
//        var ny = cy
//
//        switch dir {
//        case "U":
//            ny += len
//            let y1 = cy; let y2 = ny // y1 < y2
//            vDiffMap[cx, default: [:]][y1, default: 0] += 1
//            vDiffMap[cx, default: [:]][y2, default: 0] -= 1
//        case "D":
//            ny -= len
//            let y1 = ny; let y2 = cy // y1 < y2
//            vDiffMap[cx, default: [:]][y1, default: 0] += 1
//            vDiffMap[cx, default: [:]][y2, default: 0] -= 1
//        case "L":
//            nx -= len
//            let x1 = nx; let x2 = cx // x1 < x2
//            hDiffMap[cy, default: [:]][x1, default: 0] += 1
//            hDiffMap[cy, default: [:]][x2, default: 0] -= 1
//        case "R":
//            nx += len
//            let x1 = cx; let x2 = nx // x1 < x2
//            hDiffMap[cy, default: [:]][x1, default: 0] += 1
//            hDiffMap[cy, default: [:]][x2, default: 0] -= 1
//        default:
//             fatalError("Invalid direction") // Should not happen based on constraints
//        }
//
//        // Add coordinates from both start and end points of the segment
//        allX.insert(cx); allX.insert(nx)
//        allY.insert(cy); allY.insert(ny)
//
//        let endVertex = Point(x: nx, y: ny)
//        originalVertices.insert(startVertex)
//        originalVertices.insert(endVertex)
//
//        // Update current position
//        cx = nx
//        cy = ny
//    }
//
//    // === Step 2: Coordinate Compression ===
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Map: original coordinate -> compressed index
//    // Use compactMapValues if you anticipate potential mapping issues, though unlikely here
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // If the compressed grid is too small, no plus sign can form
//    if compNX <= 2 || compNY <= 2 {
//        return 0
//    }
//
//    // === Step 3: Build Sparse Coverage Grids using Sweep-Line ===
//    // hGrid[cy][cx] = true if horizontal segment cx -> cx+1 exists at row cy
//    var hGrid: [Int: [Int: Bool]] = [:]
//    for (origY, xDiffs) in hDiffMap {
//        // Map original Y to compressed Y Index (cy)
//        guard let cy = yMap[origY], !xDiffs.isEmpty else { continue }
//
//        // Sort original X coordinates where changes occur for this Y
//        let sortedOrigX = xDiffs.keys.sorted()
//        var currentCoverage = 0
//        
//        // Map the first X coordinate to initialize the sweep
//        guard let firstOrigX = sortedOrigX.first, let firstCX = xMap[firstOrigX] else { continue }
//        var lastCX = firstCX // Store the *compressed* index of the previous point
//
//        // Sweep across the X coordinates for the current row cy
//        for origX in sortedOrigX {
//            guard let cx = xMap[origX] else { continue } // Current compressed X index
//
//            // If coverage was positive before this point, fill segments in hGrid
//            // Check cx > lastCX ensures we don't try to fill zero-width segments
//            if currentCoverage > 0 && cx > lastCX {
//                // Mark all compressed segments between lastCX and cx as covered
//                for k in lastCX..<cx {
//                    hGrid[cy, default: [:]][k] = true
//                }
//            }
//
//            // Apply the coverage change at the current point
//            currentCoverage += xDiffs[origX, default: 0]
//            // Update the last processed compressed X index
//            lastCX = cx
//        }
//         // No final fill needed; diffs sum to 0, coverage ends naturally.
//    }
//
//    // vGrid[cx][cy] = true if vertical segment cy -> cy+1 exists at column cx
//    var vGrid: [Int: [Int: Bool]] = [:]
//    for (origX, yDiffs) in vDiffMap {
//        // Map original X to compressed X Index (cx)
//        guard let cx = xMap[origX], !yDiffs.isEmpty else { continue }
//
//        let sortedOrigY = yDiffs.keys.sorted()
//        var currentCoverage = 0
//
//        guard let firstOrigY = sortedOrigY.first, let firstCY = yMap[firstOrigY] else { continue }
//        var lastCY = firstCY // Compressed index
//
//        // Sweep across the Y coordinates for the current column cx
//        for origY in sortedOrigY {
//            guard let cy = yMap[origY] else { continue } // Current compressed Y index
//
//            if currentCoverage > 0 && cy > lastCY {
//                 // Mark segments between lastCY and cy as covered
//                 for k in lastCY..<cy {
//                     vGrid[cx, default: [:]][k] = true
//                 }
//            }
//            // Apply coverage change and update last point
//            currentCoverage += yDiffs[origY, default: 0]
//            lastCY = cy
//        }
//    }
//
//    // === Step 4: Identify Potential Centers (Map original vertices to compressed) ===
//    var potentialCenters = Set<Point>() // Stores Points with *compressed* coordinates
//    for vertex in originalVertices {
//        // Safely unwrap mapped coordinates
//        if let cx = xMap[vertex.x], let cy = yMap[vertex.y] {
//            potentialCenters.insert(Point(x: cx, y: cy))
//        }
//    }
//
//    // === Step 5: Count Plus Signs by Checking Potential Centers ===
//    var plusCount = 0
//    for center in potentialCenters {
//        let cx = center.x
//        let cy = center.y
//
//        // A plus sign center must be an *internal* point in the compressed grid
//        // It cannot be on the boundary (index 0 or N-1)
//        if cx > 0 && cx < compNX - 1 && cy > 0 && cy < compNY - 1 {
//
//            // Check the four adjacent segments using the computed coverage grids
//            // Check segment to the LEFT : hGrid[cy][cx - 1]
//            let hasLeft = hGrid[cy]?[cx - 1] ?? false
//            // Check segment to the RIGHT: hGrid[cy][cx]
//            let hasRight = hGrid[cy]?[cx] ?? false
//            // Check segment BELOW    : vGrid[cx][cy - 1]
//            let hasDown = vGrid[cx]?[cy - 1] ?? false
//            // Check segment ABOVE    : vGrid[cx][cy]
//            let hasUp = vGrid[cx]?[cy] ?? false
//
//            // If segments exist in all four directions relative to the point
//            if hasLeft && hasRight && hasDown && hasUp {
//                plusCount += 1
//            }
//        }
//    }
//
//    return plusCount
//}
////
////// === Test with Provided Examples ===
////let N1 = 9
////let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
////let D1 = "ULDRULURD"
////let result1 = getPlusSignCount(N1, L1, D1)
////print("Sample 1 Result: \(result1) (Expected: 4)") // Expected: 4
////
////let N2 = 8
////let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
////let D2 = "RDLUULDR"
////let result2 = getPlusSignCount(N2, L2, D2)
////print("Sample 2 Result: \(result2) (Expected: 1)") // Expected: 1
////
////let N3 = 8
////let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
////let D3 = "UDUDLRLR"
////let result3 = getPlusSignCount(N3, L3, D3)
////print("Sample 3 Result: \(result3) (Expected: 1)") // Expected: 1
