////
////  Solution9.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// No Pair struct needed if we check directly
//
//// Using Sets for sparse grid storage
//// hGrid: [cy: Set<cx>] stores starting cx of horizontal segments [cx, cx+1] at row cy
//// vGrid: [cx: Set<cy>] stores starting cy of vertical segments [cy, cy+1] at column cx
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 1, L.count == N, D.count == N else {
//        // Handle invalid input if necessary, though problem constraints might guarantee validity
//        return 0
//    }
//    let directions = Array(D)
//
//    // --- Base Cases ---
//    // If N is too small to form a plus sign (need at least 4 segments potentially)
//    // This check is implicitly handled by coordinate compression grid size later
//
//    // --- Step 1: Simulate Path, Collect Coordinates & Raw Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    // Use Sets for efficient unique coordinate collection
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//
//    // Store events as (coordinate1, coordinate2, constant_coord, type: +1 start, -1 end)
//    // For horizontal: (x1, x2, y, type) where x1 is start x if type=1, or end x if type=-1? No, simpler.
//    // Use event point sweep line standard: (coord_of_event, other_coord, type)
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Event at x, on row y
//    var rawVEvents: [(x: Int, y: Int, type: Int)] = [] // Event at y, on column x
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue } // Skip zero-length segments
//        let direction = directions[i]
//
//        let startX = currentX
//        let startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            let y1 = startY // Lower y
//            let y2 = endY   // Higher y
//            // Vertical segment goes from (startX, y1) to (startX, y2)
//            // Event at y1 (start), Event at y2 (end) for column startX
//            rawVEvents.append((x: startX, y: y1, type: 1)) // Start at y1
//            rawVEvents.append((x: startX, y: y2, type: -1)) // End at y2
//            allY.insert(y2)
//        case "D":
//            endY -= length
//            let y1 = endY   // Lower y
//            let y2 = startY // Higher y
//             // Vertical segment goes from (startX, y2) down to (startX, y1)
//            rawVEvents.append((x: startX, y: y1, type: 1)) // Start at y1
//            rawVEvents.append((x: startX, y: y2, type: -1)) // End at y2
//            allY.insert(y1)
//        case "L":
//            endX -= length
//            let x1 = endX   // Left x
//            let x2 = startX // Right x
//            // Horizontal segment goes from (x2, startY) left to (x1, startY)
//            rawHEvents.append((x: x1, y: startY, type: 1)) // Start at x1
//            rawHEvents.append((x: x2, y: startY, type: -1)) // End at x2
//            allX.insert(x1)
//        case "R":
//            endX += length
//            let x1 = startX // Left x
//            let x2 = endX   // Right x
//            // Horizontal segment goes from (x1, startY) right to (x2, startY)
//            rawHEvents.append((x: x1, y: startY, type: 1)) // Start at x1
//            rawHEvents.append((x: x2, y: startY, type: -1)) // End at x2
//            allX.insert(x2)
//        default:
//             fatalError("Invalid direction encountered: \(direction)") // Or handle error
//        }
//        // Update coordinates and ensure they are in the sets
//        allX.insert(endX)
//        allY.insert(endY)
//        currentX = endX
//        currentY = endY
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    // Map real coordinates to compressed indices
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    // Need at least 3 distinct x and 3 distinct y coordinates to form a plus sign center
//    if compNX < 3 || compNY < 3 {
//        return 0
//    }
//
//    // --- Step 3: Create Compressed & Grouped Sweep Events (Preprocessing for Grid Building) ---
//    // Group horizontal events by row (cy)
//    var hSweepEvents = [Int: [(cx: Int, type: Int)]]() // Key: cy
//    for event in rawHEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEvents[cy, default: []].append((cx: cx, type: event.type))
//    }
//
//    // Group vertical events by column (cx)
//    var vSweepEvents = [Int: [(cy: Int, type: Int)]]() // Key: cx
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEvents[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 4 & 5: Build hGrid and vGrid using Optimized Sweep-Line ---
//
//    // Build hGrid: Horizontal segments present between compressed coordinates
//    // Key: cy (compressed row index)
//    // Value: Set<Int> containing starting cx of each segment [cx, cx+1] existing in that row
//    var hGrid = [Int: Set<Int>]()
//    for cy in hSweepEvents.keys { // Iterate only over rows with events
//        guard let events = hSweepEvents[cy], !events.isEmpty else { continue }
//        let sortedEvents = events.sorted { $0.cx < $1.cx } // Sort events for this row
//
//        var currentCoverage = 0
//        var lastCX = sortedEvents.first!.cx // Assumes !events.isEmpty
//
//        for event in sortedEvents {
//            let cx = event.cx
//            let type = event.type
//
//            // If coverage was positive *before* this event point,
//            // fill in the segments between the last event point and this one.
//            if currentCoverage > 0 && cx > lastCX {
//                for segmentStartIndex in lastCX..<cx {
//                    hGrid[cy, default: Set<Int>()].insert(segmentStartIndex)
//                }
//            }
//            currentCoverage += type // Update coverage level at this event point
//            lastCX = cx // Update the position of the last processed event
//        }
//        // After the loop, coverage should be 0 if events are balanced.
//    }
//
//    // Build vGrid: Vertical segments present between compressed coordinates
//    // Key: cx (compressed column index)
//    // Value: Set<Int> containing starting cy of each segment [cy, cy+1] existing in that column
//    var vGrid = [Int: Set<Int>]()
//    for cx in vSweepEvents.keys { // Iterate only over columns with events
//         guard let events = vSweepEvents[cx], !events.isEmpty else { continue }
//         let sortedEvents = events.sorted { $0.cy < $1.cy } // Sort events for this column
//
//         var currentCoverage = 0
//         var lastCY = sortedEvents.first!.cy
//
//         for event in sortedEvents {
//             let cy = event.cy
//             let type = event.type
//
//             if currentCoverage > 0 && cy > lastCY {
//                for segmentStartIndex in lastCY..<cy {
//                    vGrid[cx, default: Set<Int>()].insert(segmentStartIndex)
//                 }
//             }
//             currentCoverage += type
//             lastCY = cy
//         }
//    }
//
//    // --- Step 6: Optimized Check using Grid Iteration ---
//    var plusCount = 0
//
//    // Iterate through the horizontal grid to find potential horizontal bars ([cx-1, cx+1] at cy)
//    // The potential center cx is scx + 1
//    for cy in 0..<compNY { // Check all possible compressed rows
//        // Need space below (cy-1) and above (cy+1 for vertical check) -> center must be 1 <= cy <= compNY-2
//        guard cy > 0 && cy < compNY - 1 else { continue }
//        guard let hSegments = hGrid[cy], !hSegments.isEmpty else { continue } // Row must have segments
//
//        // Iterate through the STARTING points `scx` of horizontal segments [scx, scx+1] on this row
//        for scx in hSegments {
//             // Center x-coordinate needs space to its left (scx) and right (scx+1)
//             // -> center cx must be 1 <= cx <= compNX-2
//             // -> scx must be 0 <= scx <= compNX - 3
//             // -> scx+1 must be 1 <= scx+1 <= compNX - 2
//             let potentialCenterX = scx + 1
//             guard potentialCenterX > 0 && potentialCenterX < compNX - 1 else { continue }
//
//            // Check if the segment immediately to the right ALSO exists in this row
//            if hSegments.contains(potentialCenterX) { // Check for segment starting at cx=scx+1
//                // Found horizontal bar centered at (potentialCenterX, cy)
//
//                // Now check the vertical grid for the required crossing segments
//                // Does column potentialCenterX exist in vGrid?
//                // Does it contain segment below: starting at cy-1?
//                // Does it contain segment above: starting at cy?
//                if let vSegmentsInCol = vGrid[potentialCenterX],
//                   vSegmentsInCol.contains(cy - 1), // Segment [cy-1, cy] exists
//                   vSegmentsInCol.contains(cy) {    // Segment [cy, cy+1] exists
//                    plusCount += 1
//                }
//            }
//        }
//    }
//
//    return plusCount
//}
////
////// --- Testing with provided examples ---
////let N1 = 9
////let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
////let D1 = "ULDRULURD"
////let result1 = getPlusSignCount(N1, L1, D1)
////print("Sample 1 Result: \(result1) (Expected: 4)")
////
////let N2 = 8
////let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
////let D2 = "RDLUULDR"
////let result2 = getPlusSignCount(N2, L2, D2)
////print("Sample 2 Result: \(result2) (Expected: 1)")
////
////let N3 = 8
////let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
////let D3 = "UDUDLRLR"
////let result3 = getPlusSignCount(N3, L3, D3)
////print("Sample 3 Result: \(result3) (Expected: 1)")
////
////// Test case: Simple rectangle causing intersection, should yield 1 plus
////let N4 = 4
////let L4 = [5, 2, 5, 2] // R_5, D_2, L_5, U_2
////let D4 = "RDLU"
////let result4 = getPlusSignCount(N4, L4, D4)
////print("Sample 4 (Rectangle) Result: \(result4) (Expected: 1)") // Path (0,0)->(5,0)->(5,-2)->(0,-2)->(0,0). Plus at ? Needs offset.
////
////let N5 = 4
////let L5 = [3, 3, 3, 3] // R_3, U_3, L_3, D_3 -> Square
////let D5 = "RULD"
////let result5 = getPlusSignCount(N5, L5, D5)
////print("Sample 5 (Square) Result: \(result5) (Expected: 1)") // Plus at (1.5, 1.5) -> Compressed center
////
////let N6 = 4
////let L6 = [5, 2, 3, 4] // From prev test, R 5, D 2, L 3, U 4
////let D6 = "RDLU"
////let result6 = getPlusSignCount(N6, L6, D6)
////print("Sample 6 (Intersection) Result: \(result6) (Expected: 1)") // Path (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2). Plus at (2,0)
////
////// Test Case: No plus sign
////let N7 = 2
////let L7 = [5, 5]
////let D7 = "RU"
////let result7 = getPlusSignCount(N7, L7, D7)
////print("Sample 7 (No Plus) Result: \(result7) (Expected: 0)")
