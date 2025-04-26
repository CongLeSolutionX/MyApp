////
////  Solution8.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Using Sets for sparse grid storage is generally efficient for large, sparse grids.
//// Dictionaries of Sets: [row/col_index: Set<col/row_segment_index>]
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation and Base Cases ---
//    guard N >= 1 else { return 0 }
//
//    // --- Step 1: Simulate Path, Collect Coordinates & Raw Events ---
//    var currentX: Int = 0
//    var currentY: Int = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//
//    var rawHEvents: [(x: Int, y: Int, type: Int)] = []
//    var rawVEvents: [(x: Int, y: Int, type: Int)] = []
//
//    let directions = Array(D)
//
//    for i in 0..<N {
//        let length = L[i]
//        guard length > 0 else { continue }
//        let direction = directions[i]
//
//        let startX = currentX
//        let startY = currentY
//        var endX = currentX
//        var endY = currentY
//
//        switch direction {
//        case "U":
//            endY += length
//            let y1 = startY; let y2 = endY // y1 is below y2
//            rawVEvents.append((x: startX, y: y1, type: 1))
//            rawVEvents.append((x: startX, y: y2, type: -1))
//            allY.insert(y2)
//        case "D":
//            endY -= length
//            let y1 = endY; let y2 = startY // y1 is below y2
//            rawVEvents.append((x: startX, y: y1, type: 1))
//            rawVEvents.append((x: startX, y: y2, type: -1))
//            allY.insert(y1)
//        case "L":
//            endX -= length
//            let x1 = endX; let x2 = startX // x1 is left of x2
//            rawHEvents.append((x: x1, y: startY, type: 1))
//            rawHEvents.append((x: x2, y: startY, type: -1))
//            allX.insert(x1)
//        case "R":
//            endX += length
//            let x1 = startX; let x2 = endX // x1 is left of x2
//            rawHEvents.append((x: x1, y: startY, type: 1))
//            rawHEvents.append((x: x2, y: startY, type: -1))
//            allX.insert(x2)
//        default:
//             fatalError("Invalid direction encountered: \(direction)")
//        }
//        // Keep allX/allY updated (already includes start point from previous round)
//        allX.insert(endX)
//        allY.insert(endY)
//
//        currentX = endX
//        currentY = endY
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//
//    let xMap = Dictionary(uniqueKeysWithValues: zip(sortedX, 0..<sortedX.count))
//    let yMap = Dictionary(uniqueKeysWithValues: zip(sortedY, 0..<sortedY.count))
//
//    let compNX = sortedX.count
//    let compNY = sortedY.count
//
//    if compNX < 3 || compNY < 3 {
//        return 0
//    }
//
//    // --- Step 3: Create Compressed & Grouped Sweep Events ---
//    var hSweepEvents = [Int: [(cx: Int, type: Int)]]() // Key: cy
//    for event in rawHEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        hSweepEvents[cy, default: []].append((cx: cx, type: event.type))
//    }
//
//    var vSweepEvents = [Int: [(cy: Int, type: Int)]]() // Key: cx
//    for event in rawVEvents {
//        guard let cx = xMap[event.x], let cy = yMap[event.y] else { continue }
//        vSweepEvents[cx, default: []].append((cy: cy, type: event.type))
//    }
//
//    // --- Step 4: Build hGrid (Horizontal Coverage) ---
//    var hGrid = [Int: Set<Int>]() // Key: cy, Value: Set of cx segment starts
//    for cy in hSweepEvents.keys { // Iterate only over rows with events
//        guard let events = hSweepEvents[cy], !events.isEmpty else { continue }
//
//        // Sort events for this row by cx
//        let sortedEvents = events.sorted { $0.cx < $1.cx }
//
//        var currentCoverage = 0
//        // Use first event's cx if available, otherwise handle empty list case (already done by !events.isEmpty)
//        var lastCX = sortedEvents.first!.cx
//
//        for event in sortedEvents {
//            let cx = event.cx
//            let type = event.type
//
//            // Fill segments if coverage was active *before* this event's cx
//            if currentCoverage > 0 && cx > lastCX {
//                for segmentIndex in lastCX..<cx {
//                    hGrid[cy, default: Set<Int>()].insert(segmentIndex)
//                }
//            }
//
//            currentCoverage += type
//            lastCX = cx
//        }
//        // No need to check final segment - coverage should return to 0
//    }
//
//    // --- Step 5: Build vGrid (Vertical Coverage) ---
//    var vGrid = [Int: Set<Int>]() // Key: cx, Value: Set of cy segment starts
//    for cx in vSweepEvents.keys { // Iterate only over columns with events
//         guard let events = vSweepEvents[cx], !events.isEmpty else { continue }
//
//         // Sort events for this column by cy
//         let sortedEvents = events.sorted { $0.cy < $1.cy }
//
//         var currentCoverage = 0
//         var lastCY = sortedEvents.first!.cy
//
//         for event in sortedEvents {
//             let cy = event.cy
//             let type = event.type
//
//             // Fill segments if coverage was active *before* this event's cy
//             if currentCoverage > 0 && cy > lastCY {
//                 for segmentIndex in lastCY..<cy {
//                     vGrid[cx, default: Set<Int>()].insert(segmentIndex)
//                 }
//             }
//
//             currentCoverage += type
//             lastCY = cy
//         }
//    }
//
//    // --- Step 6: Check All Internal Grid Points for Plus Signs ---
//    var plusCount = 0
//    for cx in 1..<(compNX - 1) {
//        for cy in 1..<(compNY - 1) {
//            // Check LEFT : segment between cx-1 and cx exists at row cy?
//            let hasLeftSegment = hGrid[cy]?.contains(cx - 1) ?? false
//            // Check RIGHT: segment between cx and cx+1 exists at row cy?
//            let hasRightSegment = hGrid[cy]?.contains(cx) ?? false
//            // Check DOWN : segment between cy-1 and cy exists at col cx?
//            let hasDownSegment = vGrid[cx]?.contains(cy - 1) ?? false
//            // Check UP   : segment between cy and cy+1 exists at col cx?
//            let hasUpSegment = vGrid[cx]?.contains(cy) ?? false
//
//            if hasLeftSegment && hasRightSegment && hasDownSegment && hasUpSegment {
//                plusCount += 1
//            }
//        }
//    }
//
//    return plusCount
//}
//
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
////let N4_path = 4
////let L4_path = [5, 2, 3, 4] // R 5, D 2, L 3, U 4
////let D4_path = "RDLU"
////let result4 = getPlusSignCount(N4_path, L4_path, D4_path)
////print("Sample 4 (Intersection) Result: \(result4) (Expected: 1)")
