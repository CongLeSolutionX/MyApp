//
//  Solution4.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//

import Foundation

// Using a Tuple for Set storage requires making it Hashable
// Alternatively, define a simple struct
struct Point: Hashable {
    let x: Int
    let y: Int
}

func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    var cx: Int = 0
    var cy: Int = 0
    var allX = Set<Int>([0])
    var allY = Set<Int>([0])

    // Store differences using original coordinates
    // hDiffMap[y][x] = change (+1 start / -1 end)
    var hDiffMap: [Int: [Int: Int]] = [:]
    // vDiffMap[x][y] = change (+1 start / -1 end)
    var vDiffMap: [Int: [Int: Int]] = [:]

    // Store all unique vertices (original coords) visited
    var vertices = Set<Point>([Point(x: 0, y: 0)])

    let directions = Array(D)

    // === Step 1: Simulate Path, Collect Coords, Diffs, Vertices ===
    for i in 0..<N {
        let len = L[i]
        let dir = directions[i]
        var nx = cx
        var ny = cy
        let startVertex = Point(x: cx, y: cy) // Store start point

        switch dir {
        case "U":
            ny += len
            let y1 = cy // Lower y
            let y2 = ny // Upper y
            vDiffMap[cx, default: [:]][y1, default: 0] += 1
            vDiffMap[cx, default: [:]][y2, default: 0] -= 1
        case "D":
            ny -= len
            let y1 = ny // Lower y
            let y2 = cy // Upper y
            vDiffMap[cx, default: [:]][y1, default: 0] += 1
            vDiffMap[cx, default: [:]][y2, default: 0] -= 1
        case "L":
            nx -= len
            let x1 = nx // Left x
            let x2 = cx // Right x
            hDiffMap[cy, default: [:]][x1, default: 0] += 1
            hDiffMap[cy, default: [:]][x2, default: 0] -= 1
        case "R":
            nx += len
            let x1 = cx // Left x
            let x2 = nx // Right x
            hDiffMap[cy, default: [:]][x1, default: 0] += 1
            hDiffMap[cy, default: [:]][x2, default: 0] -= 1
        default:
            break // Should not happen
        }

        allX.insert(nx)
        allY.insert(ny)
        
        let endVertex = Point(x: nx, y: ny) // Store end point
        vertices.insert(startVertex)
        vertices.insert(endVertex)

        cx = nx
        cy = ny
    }

    // === Step 2: Coordinate Compression ===
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()

    // Map: original coordinate -> compressed index
    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))

    let compNX = sortedX.count
    let compNY = sortedY.count

    // === Step 3: Build Sparse Coverage Grids ===
    // hGrid[cy][cx] = true if horizontal segment cx -> cx+1 exists at row cy
    var hGrid: [Int: [Int: Bool]] = [:]
    for (origY, xDiffs) in hDiffMap {
        guard let cy = yMap[origY] else { continue } // Get compressed y-index

        let sortedOrigX = xDiffs.keys.sorted()
        var currentCoverage = 0
        var lastOrigX = -1 // Keep track to determine segment ranges

        if sortedOrigX.isEmpty { continue }
        
        lastOrigX = sortedOrigX[0] // Start with the first x coordinate

        for origX in sortedOrigX {
            guard let cx = xMap[origX] else { continue } // Get compressed x-index

            // Fill the gap between lastOrigX's compressed index and current cx
            if currentCoverage > 0 {
                let lastCX = xMap[lastOrigX]!
                // Mark segments from lastCX up to (but not including) cx as covered
                for k in lastCX..<cx {
                    hGrid[cy, default: [:]][k] = true
                }
            }

            // Apply the change at the current point
            currentCoverage += xDiffs[origX, default: 0]
            lastOrigX = origX // Update the last coordinate visited
        }
         // Important: No need for a final fill, as the loop covers intervals *before* the change point
         // and the difference map ensures net coverage eventually returns to 0.
    }

    // vGrid[cx][cy] = true if vertical segment cy -> cy+1 exists at column cx
    var vGrid: [Int: [Int: Bool]] = [:]
    for (origX, yDiffs) in vDiffMap {
        guard let cx = xMap[origX] else { continue } // Get compressed x-index

        let sortedOrigY = yDiffs.keys.sorted()
        var currentCoverage = 0
        var lastOrigY = -1

        if sortedOrigY.isEmpty { continue }
        
        lastOrigY = sortedOrigY[0]

        for origY in sortedOrigY {
            guard let cy = yMap[origY] else { continue } // Get compressed y-index

            // Fill the gap
            if currentCoverage > 0 {
                 let lastCY = yMap[lastOrigY]!
                 for k in lastCY..<cy {
                     vGrid[cx, default: [:]][k] = true
                 }
            }

            // Apply the change
            currentCoverage += yDiffs[origY, default: 0]
            lastOrigY = origY
        }
    }

    // === Step 4 & 5: Check Internal Vertices for Plus Signs ===
    var plusCount = 0
    var checkedCenters = Set<Point>() // Use compressed coordinates for checking

    for vertex in vertices {
        // Map original vertex coordinate to compressed indices
        guard let cx = xMap[vertex.x], let cy = yMap[vertex.y] else { continue }

        // Only consider internal points of the compressed grid as potential centers
        if cx > 0 && cx < compNX - 1 && cy > 0 && cy < compNY - 1 {
            let centerPoint = Point(x: cx, y: cy) // Center candidate in compressed coords
            
            // Avoid re-checking the same center if it was an endpoint multiple times
            if checkedCenters.contains(centerPoint) {
                continue
            }
            checkedCenters.insert(centerPoint)

            // Check the four surrounding segments using the sparse coverage grids
            // Check segment to the left: hGrid[cy][cx - 1]
            let hasLeft = hGrid[cy]?[cx - 1] ?? false
            // Check segment to the right: hGrid[cy][cx]
            let hasRight = hGrid[cy]?[cx] ?? false
            // Check segment below: vGrid[cx][cy - 1]
            let hasDown = vGrid[cx]?[cy - 1] ?? false
            // Check segment above: vGrid[cx][cy]
            let hasUp = vGrid[cx]?[cy] ?? false

            if hasLeft && hasRight && hasDown && hasUp {
                plusCount += 1
            }
        }
    }

    return plusCount
}
