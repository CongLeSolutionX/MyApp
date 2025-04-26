//
//  Solution10.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//

import Foundation

// No specific data structures needed beyond standard Dict/Set

// Using Sets for sparse grid storage
// hGrid: [cy: Set<Int>] stores starting cx of horizontal compressed segments [cx, cx+1] at compressed row cy
// vGrid: [cx: Set<Int>] stores starting cy of vertical compressed segments [cy, cy+1] at compressed column cx
func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // --- Input Validation ---
    // Assuming valid inputs based on constraints for simplicity, but good practice to add guards
    guard N >= 2, L.count == N, D.count == N else {
        return 0 // Cannot form a plus sign with fewer than ~4 segments relevantly placed.
    }
    let directions = Array(D)

    // --- Step 1: Simulate Path, Collect Coordinates & Raw Events ---
    var currentX: Int = 0
    var currentY: Int = 0
    var allX = Set<Int>([0]) // Use Sets for efficient unique coordinate collection
    var allY = Set<Int>([0])

    // Store raw sweep-line events: (coordinate_of_event, constant_coordinate, type: +1 start, -1 end)
    // Note: We use the coordinate *where the event happens* as the first element for sorting.
    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Event at x, on row y
    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Event at y, on column x

    for i in 0..<N {
        let length = L[i]
        guard length > 0 else { continue } // Skip zero-length segments
        let direction = directions[i]

        let startX = currentX
        let startY = currentY
        var endX = startX
        var endY = startY

        switch direction {
        case "U":
            endY += length
            let y1 = startY // Lower y
            let y2 = endY   // Higher y
            // Vertical segment from (startX, y1) to (startX, y2)
            rawVEvents.append((y: y1, x: startX, type: 1)) // Start event at y1
            rawVEvents.append((y: y2, x: startX, type: -1)) // End event at y2
            allY.insert(y2)
        case "D":
            endY -= length
            let y1 = endY   // Lower y
            let y2 = startY // Higher y
             // Vertical segment from (startX, y2) down to (startX, y1)
            rawVEvents.append((y: y1, x: startX, type: 1)) // Start event at y1
            rawVEvents.append((y: y2, x: startX, type: -1)) // End event at y2
            allY.insert(y1)
        case "L":
            endX -= length
            let x1 = endX   // Left x
            let x2 = startX // Right x
            // Horizontal segment from (x2, startY) left to (x1, startY)
            rawHEvents.append((x: x1, y: startY, type: 1)) // Start event at x1
            rawHEvents.append((x: x2, y: startY, type: -1)) // End event at x2
            allX.insert(x1)
        case "R":
            endX += length
            let x1 = startX // Left x
            let x2 = endX   // Right x
            // Horizontal segment from (x1, startY) right to (x2, startY)
            rawHEvents.append((x: x1, y: startY, type: 1)) // Start event at x1
            rawHEvents.append((x: x2, y: startY, type: -1)) // End event at x2
            allX.insert(x2)
        default:
             // Or handle error gracefully based on problem constraints/guarantees
             fatalError("Invalid direction encountered: \(direction)")
        }
        // Update coordinates AFTER processing the segment from start to end
        allX.insert(endX)
        allY.insert(endY)
        currentX = endX
        currentY = endY
    }

    // --- Step 2: Coordinate Compression ---
    let sortedX = allX.sorted()
    let sortedY = allY.sorted()

    // Efficiently create mapping dictionaries
    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))

    let compNX = sortedX.count
    let compNY = sortedY.count

    // Check if grid is large enough to even contain an internal vertex
    // A plus sign requires segments [cx-1,cx], [cx,cx+1], [cy-1,cy], [cy,cy+1]
    // This implies cx >= 1, cx <= compNX-2, cy >= 1, cy <= compNY-2.
    // Thus, we need compNX >= 3 and compNY >= 3.
    if compNX < 3 || compNY < 3 {
        return 0
    }

    // --- Step 3: Create Compressed & Grouped Sweep Events ---
    // Group horizontal events by COMPRESSED row (cy)
    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]() // Key: cy
    for event in rawHEvents {
        // Use guard let for safer dictionary lookups
        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
    }

    // Group vertical events by COMPRESSED column (cx)
    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]() // Key: cx
    for event in rawVEvents {
        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
    }

    // --- Step 4: Build hGrid and vGrid using Optimized Sweep-Line ---

    // Build hGrid: Horizontal segments present between compressed coordinates
    // Key: cy (compressed row index)
    // Value: Set<Int> containing starting cx of each segment [cx, cx+1] existing in that row
    var hGrid = [Int: Set<Int>]()
    for (cy, events) in hSweepEventsByRow { // Iterate only over rows with events
        guard !events.isEmpty else { continue }
        // Sort events by compressed x-coordinate for the sweep
        let sortedEvents = events.sorted { $0.cx < $1.cx }

        var currentCoverage = 0
        // Use first event's cx to initialize lastCX safely
        var lastCX = sortedEvents.first!.cx

        for event in sortedEvents {
            let cx = event.cx
            let type = event.type

            // Fill segments if coverage was positive between lastCX and cx
            if currentCoverage > 0 && cx > lastCX {
                // Insert starting index of all unit segments spanned
                for segmentStartIndex in lastCX..<cx {
                    hGrid[cy, default: Set<Int>()].insert(segmentStartIndex)
                }
            }
            currentCoverage += type // Update coverage level AT this event point
            lastCX = cx // Update the position of the last processed event point
        }
        // Sanity check: final coverage should be 0 if starts/ends match
        // assert(currentCoverage == 0, "Coverage unbalanced for cy=\(cy)")
    }

    // Build vGrid: Vertical segments present between compressed coordinates
    // Key: cx (compressed column index)
    // Value: Set<Int> containing starting cy of each segment [cy, cy+1] existing in that column
    var vGrid = [Int: Set<Int>]()
    for (cx, events) in vSweepEventsByCol { // Iterate only over columns with events
         guard !events.isEmpty else { continue }
         // Sort events by compressed y-coordinate for the sweep
         let sortedEvents = events.sorted { $0.cy < $1.cy }

         var currentCoverage = 0
         var lastCY = sortedEvents.first!.cy

         for event in sortedEvents {
             let cy = event.cy
             let type = event.type

             if currentCoverage > 0 && cy > lastCY {
                // Insert starting index of all unit segments spanned
                for segmentStartIndex in lastCY..<cy {
                    vGrid[cx, default: Set<Int>()].insert(segmentStartIndex)
                 }
             }
             currentCoverage += type
             lastCY = cy
         }
         // assert(currentCoverage == 0, "Coverage unbalanced for cx=\(cx)")
    }

    // --- Step 5: Optimized Check using Grid Iteration ---
    var plusCount = 0

    // Iterate through potential center coordinates (cx, cy)
    // These correspond to the internal vertices of the compressed grid
    for cx in 1..<(compNX - 1) { // cx ranges from 1 to compNX - 2
        // Check if vertical segments exist in this column first (minor optimization)
        guard let vSegments = vGrid[cx] else { continue }

        for cy in 1..<(compNY - 1) { // cy ranges from 1 to compNY - 2
            // Check Horizontal segments existence using hGrid
            guard let hSegments = hGrid[cy] else { continue }

            // Check the four required segments around the compressed center (cx, cy)
            let hasLeft = hSegments.contains(cx - 1)    // Segment [cx-1, cx] at cy
            let hasRight = hSegments.contains(cx)       // Segment [cx, cx+1] at cy
            let hasDown = vSegments.contains(cy - 1)    // Segment [cy-1, cy] at cx
            let hasUp = vSegments.contains(cy)          // Segment [cy, cy+1] at cx

            if hasLeft && hasRight && hasDown && hasUp {
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
//print("Sample 1 Result: \(result1) (Expected: 4)") // Should be 4
//
//let N2 = 8
//let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
//let D2 = "RDLUULDR"
//let result2 = getPlusSignCount(N2, L2, D2)
//print("Sample 2 Result: \(result2) (Expected: 1)") // Should be 1
//
//let N3 = 8
//let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
//let D3 = "UDUDLRLR"
//let result3 = getPlusSignCount(N3, L3, D3)
//print("Sample 3 Result: \(result3) (Expected: 1)") // Should be 1
//
//// --- Testing with custom potentially problematic cases ---
//let N4 = 4
//let L4 = [5, 2, 5, 2] // Rectangle R_5, D_2, L_5, U_2
//let D4 = "RDLU"
//// Expect 0 based on the logic that no internal vertices are formed
//let result4 = getPlusSignCount(N4, L4, D4)
//print("Sample 4 (Rectangle) Result: \(result4) (Expected based on logic: 0)")
//
//let N5 = 4
//let L5 = [3, 3, 3, 3] // Square R_3, U_3, L_3, D_3
//let D5 = "RULD"
//// Expect 0 based on the logic
//let result5 = getPlusSignCount(N5, L5, D5)
//print("Sample 5 (Square) Result: \(result5) (Expected based on logic: 0)")
//
//// Test Case: Intersection creating an internal vertex
//let N6 = 4
//let L6 = [5, 2, 3, 4] // From prev test, R 5, D 2, L 3, U 4 -> Path (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
//let D6 = "RDLU"
//// Expect 1, center at real (2,0) -> compressed (1,1)
//let result6 = getPlusSignCount(N6, L6, D6)
//print("Sample 6 (Intersection) Result: \(result6) (Expected: 1)") // Should be 1
//
//// Test Case: No plus sign
//let N7 = 2
//let L7 = [5, 5]
//let D7 = "RU"
//let result7 = getPlusSignCount(N7, L7, D7)
//print("Sample 7 (No Plus) Result: \(result7) (Expected: 0)") // Should be 0
