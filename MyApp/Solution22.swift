////
////  Solution22.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Helper to check coverage using binary search on sorted, disjoint ranges
//// Note: Requires ranges to be sorted by lower bound. The construction ensures this.
//func isCovered(point: Int, ranges: [Range<Int>]?) -> Bool {
//    guard let ranges = ranges, !ranges.isEmpty else { return false }
//
//    // Binary search to find a range potentially containing the point
//    var low = 0
//    var high = ranges.count - 1
//    var potentialRangeIndex: Int? = nil
//
//    while low <= high {
//        let mid = low + (high - low) / 2
//        let range = ranges[mid]
//
//        if range.contains(point) {
//            return true // Exact point found within this range
//        } else if range.lowerBound > point {
//            // Point is before this range, search left half
//            high = mid - 1
//        } else { // range.upperBound <= point (since it doesn't contain)
//            // Point is after or at the end of this range, search right half
//            // Store this range as a potential candidate if needed for edge cases, though contains() should suffice.
//            low = mid + 1
//        }
//    }
//
//    // If the loop finishes, the point was not found within any range.
//    return false
//}
//
///// Solves the Mathematical Art problem using coordinate compression and range-based sweep-line.
///// Counts plus signs by checking coverage around internal grid vertices iterated via vertical ranges.
//func getPlusSignCountOptimized(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path, Collect Unique Coordinates & Raw Sweep Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = [] // Horizontal sweep: event at x, on line y
//    var rawVEvents: [(y: Int, x: Int, type: Int)] = [] // Vertical sweep: event at y, on line x
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue } // Skip zero-length segments
//        let direction = directions[i]
//        let startX = currentX
//        let startY = currentY
//        var endX = startX
//        var endY = startY
//
//        switch direction {
//        case "U":
//            endY += length
//            rawVEvents.append((y: startY, x: startX, type: 1))
//            rawVEvents.append((y: endY,   x: startX, type: -1))
//        case "D":
//            endY -= length
//            rawVEvents.append((y: endY,   x: startX, type: 1))
//            rawVEvents.append((y: startY, x: startX, type: -1))
//        case "L":
//            endX -= length
//            rawHEvents.append((x: endX,   y: startY, type: 1))
//            rawHEvents.append((x: startX, y: startY, type: -1))
//        case "R":
//            endX += length
//            rawHEvents.append((x: startX, y: startY, type: 1))
//            rawHEvents.append((x: endX,   y: startY, type: -1))
//        default: continue
//        }
//        currentX = endX
//        currentY = endY
//        allX.insert(startX); allX.insert(endX)
//        allY.insert(startY); allY.insert(endY)
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    if compNX < 3 || compNY < 3 { return 0 } // Need internal points
//
//    // --- Step 3: Create Compressed & Grouped Sweep Events ---
//    var hSweepEventsByRow = [Int: [(cx: Int, type: Int)]]()
//    for event in rawHEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEventsByRow[cy, default: []].append((cx: cx, type: event.type))
//    }
//    var vSweepEventsByCol = [Int: [(cy: Int, type: Int)]]()
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEventsByCol[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 4: Build Range Grids using Optimized Sweep-Line ---
//    // hGridRanges[cy] = [Range<Int>] storing covered horizontal intervals [startCX..<endCX)
//    var hGridRanges = [Int: [Range<Int>]]()
//    for (cy, events) in hSweepEventsByRow {
//        guard !events.isEmpty else { continue }
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//        var currentCoverage = 0
//        var rangeStartCX: Int? = nil
//
//        for event in sortedEvents {
//            let cx = event.cx
//            let type = event.type
//            let previousCoverage = currentCoverage
//            currentCoverage += type
//
//            // Start of a covered range
//            if previousCoverage == 0 && currentCoverage > 0 {
//                rangeStartCX = cx
//            }
//            // End of a covered range
//            if previousCoverage > 0 && currentCoverage == 0 {
//                if let start = rangeStartCX {
//                     // Only add if range is valid (cx > start)
//                     if cx > start {
//                         hGridRanges[cy, default: []].append(start..<cx)
//                         rangeStartCX = nil // Reset for next potential range
//                     } else {
//                         // Handle potential point event overlap if necessary, though types should balance
//                         rangeStartCX = nil
//                     }
//                }
//            }
//             // Update lastCX implicitly via loop iteration
//        }
//         // Note: Assumes events properly balance coverage back to 0.
//         // Need to handle edge case if last event doesn't bring coverage to 0?
//         // The problem implies segments end, so it should balance.
//    }
//
//    // vGridRanges[cx] = [Range<Int>] storing covered vertical intervals [startCY..<endCY)
//    var vGridRanges = [Int: [Range<Int>]]()
//     for (cx, events) in vSweepEventsByCol {
//         guard !events.isEmpty else { continue }
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//         var currentCoverage = 0
//         var rangeStartCY: Int? = nil
//
//         for event in sortedEvents {
//             let cy = event.cy
//             let type = event.type
//             let previousCoverage = currentCoverage
//             currentCoverage += type
//
//             if previousCoverage == 0 && currentCoverage > 0 {
//                 rangeStartCY = cy
//             }
//             if previousCoverage > 0 && currentCoverage == 0 {
//                 if let start = rangeStartCY {
//                    if cy > start {
//                        vGridRanges[cx, default: []].append(start..<cy)
//                        rangeStartCY = nil
//                    } else {
//                         rangeStartCY = nil
//                    }
//                 }
//             }
//         }
//     }
//
//    // --- Step 5: Optimized Check for Plus Signs (Iterate via Vertical Ranges) ---
//    var plusCount = 0
//
//    // Iterate through columns 'cx' that are internal and have vertical segments
//    for cx in vGridRanges.keys where cx >= 1 && cx < compNX - 1 {
//        guard let vRanges = vGridRanges[cx] else { continue } // Should exist
//
//        // Iterate through the vertical ranges in this column
//        for vRange in vRanges { // vRange = startCY..<endCY
//            let startCY = vRange.lowerBound
//            let endCY = vRange.upperBound
//
//            // Potential center points 'cy' must be internal to the vertical range
//            // and also internal to the overall grid height.
//            // Loop from max(1, startCY + 1) up to min(compNY - 1, endCY)
//            let potentialCYStart = max(1, startCY + 1)
//            let potentialCYEnd = min(compNY - 1, endCY) // Use ..< for exclusive upper bound
//
//            if potentialCYStart >= potentialCYEnd { continue } // No internal points in this range segment
//
//            for cy in potentialCYStart..<potentialCYEnd {
//                // Center candidate is (cx, cy)
//                // Vertical Down ([cy-1, cy)) and Up ([cy, cy+1)) segments are guaranteed
//                // because 'cy' is strictly between startCY and endCY.
//
//                // Check Horizontal segments using binary search on hGridRanges[cy]
//                guard let hRanges = hGridRanges[cy] else { continue } // Row 'cy' must have horizontal segments
//
//                // Check Left: segment [(cx-1, cy), (cx, cy)] must exist -> point cx-1 covered
//                // (Check cx >= 1 is implicit from outer loop bounds)
//                guard isCovered(point: cx - 1, ranges: hRanges) else { continue }
//
//                // Check Right: segment [(cx, cy), (cx+1, cy)] must exist -> point cx covered
//                 // (Check cx < compNX - 1 is implicit from outer loop bounds)
//                 guard isCovered(point: cx, ranges: hRanges) else { continue }
//
//                // All 4 conditions met (2 vertical implicit, 2 horizontal checked)
//                plusCount += 1
//            }
//        }
//    }
//
//    return plusCount
//}
////
////// --- Testing with Examples ---
////print("--- Running Sample Test Cases (Optimized) ---")
////let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
////print("Sample 1 Result: \(getPlusSignCountOptimized(N1, L1, D1))")
////let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
////print("Sample 2 Result: \(getPlusSignCountOptimized(N2, L2, D2))")
////let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
////print("Sample 3 Result: \(getPlusSignCountOptimized(N3, L3, D3))")
////
////print("\n--- Running Boundary/Edge Test Cases (Optimized) ---")
////let N4 = 4, L4 = [5, 2, 5, 2], D4 = "RDLU" // Rectangle, Expected: 0
////print("Sample 4 (Rectangle) Result: \(getPlusSignCountOptimized(N4, L4, D4))")
////let N5 = 4, L5 = [3, 3, 3, 3], D5 = "RULD" // Square, Expected: 0
////print("Sample 5 (Square) Result: \(getPlusSignCountOptimized(N5, L5, D5))")
////
////print("\n--- Running Intersection Test Cases (Optimized) ---")
////let N6 = 4, L6 = [5, 2, 3, 4], D6 = "RDLU" // Intersection, Expected: 1
////print("Sample 6 (Intersection) Result: \(getPlusSignCountOptimized(N6, L6, D6))")
////let N7 = 2, L7 = [5, 5], D7 = "RU" // No plus possible, Expected: 0
////print("Sample 7 (No Plus) Result: \(getPlusSignCountOptimized(N7, L7, D7))")
////
////// Added Test Case: Large coordinates and lengths, multiple pluses
////let N8 = 13
////let L8 = [10, 100_000_000, 10, 1, 1, 1, 1, 1, 1, 10, 100_000_000, 10, 5]
////let D8 = "RDLULDRURDLUL" // Creates two plus signs separated vertically
////// Expected: 2 (at (1,0) and (1,-10)) -> In compressed grid, check relative positions
////print("\nSample 8 (Large Coords) Result: \(getPlusSignCountOptimized(N8, L8, D8))")
////
////print("\n--- Testing Complete ---")
