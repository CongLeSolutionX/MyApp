////
////  Solution27.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// --- Fenwick Tree (BIT) Implementation ---
//fileprivate struct FenwickTree {
//    private var tree: [Int]
//    private let size: Int
//
//    init(size: Int) {
//        // size should be compNX (number of columns)
//        // BIT uses 1-based indexing conceptually, but we adapt to 0-based array
//        self.size = size
//        self.tree = [Int](repeating: 0, count: size + 1) // O(N) space
//    }
//
//    // Add value to index (0-based)
//    // O(log N)
//    mutating func add(_ index: Int, _ value: Int) {
//        guard value != 0 else { return } // Optimization
//        var i = index + 1 // Convert to 1-based
//        while i <= size {
//            tree[i] += value
//            i += i & (-i) // Move to next relevant index
//        }
//    }
//
//    // Set index (0-based) to a specific value (by calculating delta)
//    // O(log N)
//    mutating func update(_ index: Int, _ newValue: Int) {
//        let currentValue = query(index) - query(index - 1) // Get current value at index
//        let delta = newValue - currentValue
//        if delta != 0 {
//            add(index, delta)
//        }
//    }
//
//    // Query prefix sum up to index (inclusive, 0-based)
//    // O(log N)
//    func query(_ index: Int) -> Int {
//        var sum = 0
//        var i = index + 1 // Convert to 1-based
//        while i > 0 {
//            sum += tree[i]
//            i -= i & (-i) // Move to previous relevant index
//        }
//        return sum
//    }
//
//    // Query sum for range [start, end) (0-based)
//    // O(log N)
//    func queryRange(_ start: Int, _ end: Int) -> Int {
//        guard start < end else { return 0 }
//        // Sum to end-1 (inclusive) - Sum to start-1 (inclusive)
//        let sumEnd = query(end - 1)
//        let sumStart = (start == 0) ? 0 : query(start - 1)
//        return sumEnd - sumStart
//    }
//}
//
//// --- Run Struct ---
//fileprivate struct Run: Comparable {
//    let start: Int
//    let end: Int // Exclusive
//
//    static func < (lhs: Run, rhs: Run) -> Bool {
//        if lhs.start != rhs.start {
//            return lhs.start < rhs.start
//        }
//        return lhs.end < rhs.end // Shorter runs first if starts are equal
//    }
//}
//
//// --- Merge Runs Function ---
//fileprivate func mergeRuns(_ runs: [Run]) -> [Run] {
//     guard !runs.isEmpty else { return [] }
//    // Ensure sorting before merging logic
//    let sortedRuns = runs.sorted()
//    var merged: [Run] = []
//    var currentRun = sortedRuns[0]
//
//    for i in 1..<sortedRuns.count {
//        let nextRun = sortedRuns[i]
//        // Merge if they overlap or touch [start1, end1) [start2, end2) -> end1 >= start2
//        if currentRun.end >= nextRun.start {
//            currentRun = Run(start: currentRun.start, end: max(currentRun.end, nextRun.end))
//        } else {
//            merged.append(currentRun)
//            currentRun = nextRun
//        }
//    }
//    merged.append(currentRun)
//    return merged
//}
//
//// --- Event Struct ---
//fileprivate enum EventType: Int {
//    case enableV = 0 // Process first
//    case queryH = 1  // Process second
//    case disableV = 2 // Process last
//}
//
//fileprivate struct Event: Comparable {
//    let y: Int
//    let type: EventType
//    let x: Int      // For V events (cx)
//    let xEnd: Int?  // For H events (end cx)
//
//    init(y: Int, type: EventType, x: Int, xEnd: Int? = nil) {
//        self.y = y
//        self.type = type
//        self.x = x
//        self.xEnd = xEnd
//    }
//
//    static func < (lhs: Event, rhs: Event) -> Bool {
//        if lhs.y != rhs.y {
//            return lhs.y < rhs.y
//        }
//        // If y is same, process by type order
//        return lhs.type.rawValue < rhs.type.rawValue
//    }
//}
//
//// --- Main Function ---
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path & Collect Coordinates ---
//    var currentX: Int64 = 0
//    var currentY: Int64 = 0
//    var allX = Set<Int64>([0])
//    var allY = Set<Int64>([0])
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i])
//        guard length > 0 else { continue } // Ignore zero-length strokes
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: return 0 // Invalid direction
//        }
//
//        // Insert both start and end coordinates of the stroke segment
//        allX.insert(currentX)
//        allY.insert(currentY)
//        allX.insert(nextX)
//        allY.insert(nextY)
//
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allX.sorted()
//    let sortedY = allY.sorted()
//    guard sortedX.count <= N + 1, sortedY.count <= N + 1 else {
//         // This shouldn't happen if input N is correct
//         print("Warning: More unique coordinates than expected.")
//         return 0
//    }
//    // Ensure map values fit in Int
//    guard sortedX.count <= Int.max, sortedY.count <= Int.max else { return 0 }
//
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count // Number of discrete x-coordinates
//    let compNY = sortedY.count // Number of discrete y-coordinates
//
//    // Need at least 3x3 grid lines (compNX>=3, compNY>=3) to form internal centers
//    guard compNX >= 3 && compNY >= 3 else { return 0 }
//
//    // --- Step 3: Create and Merge Runs ---
//    var hRunsByRow = [Int: [Run]]()
//    var vRunsByCol = [Int: [Run]]()
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//        // Force unwrap should be safe due to Set population logic
//        let cx1 = xMap[startOrig.x]!
//        let cy1 = yMap[startOrig.y]!
//        let cx2 = xMap[endOrig.x]!
//        let cy2 = yMap[endOrig.y]!
//
//        if cx1 == cx2 { // Vertical stroke
//            let x = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            if startY < endY {
//                 vRunsByCol[x, default: []].append(Run(start: startY, end: endY))
//            }
//        } else { // Horizontal stroke
//            let y = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//             if startX < endX {
//                 hRunsByRow[y, default: []].append(Run(start: startX, end: endX))
//            }
//        }
//    }
//
//    let mergedHRuns = hRunsByRow.mapValues { mergeRuns($0) }
//    let mergedVRuns = vRunsByCol.mapValues { mergeRuns($0) }
//
//    // --- Step 4: Create Events ---
//    var events = [Event]()
//
//    // V-Run Events: Enable/Disable Vertical Condition
//    for (cx, runs) in mergedVRuns {
//        for run in runs {
//            // Enables V-condition for cy in [run.start + 1, run.end)
//            let enableY = run.start + 1
//            let disableY = run.end
//            if enableY < disableY { // Only add if range is valid
//                 events.append(Event(y: enableY, type: .enableV, x: cx))
//                 events.append(Event(y: disableY, type: .disableV, x: cx))
//            }
//        }
//    }
//
//    // H-Run Events: Query for centers
//    for (cy, runs) in mergedHRuns {
//         guard cy > 0 && cy < compNY - 1 else { continue } // Center cy must be internal
//         for run in runs {
//            // Enables H-condition for cx if run covers [cx-1, cx+1)
//            //
//            // Valid cx range for centers: [startX + 1, endX)
//            // Clip to internal grid range: [1, compNX - 1)
//            let queryStartX = max(1, run.start + 1)
//            let queryEndX = min(compNX - 1, run.end) // query range is [queryStartX, queryEndX)
//
//            if queryStartX < queryEndX {
//                events.append(Event(y: cy, type: .queryH, x: queryStartX, xEnd: queryEndX))
//            }
//        }
//    }
//
//    // --- Step 5: Sort Events ---
//    events.sort()
//
//    // --- Step 6: Sweep Line ---
//    var plusCount = 0
//    var tree = FenwickTree(size: compNX) // Size based on number of columns
//
//    for event in events {
//        switch event.type {
//        case .enableV:
//            // Increment indicates this column `event.x` now potentially supports V-Condition
//            // We use update to set it to 1, assuming runs don't overlap in a way
//            // that requires counts > 1 for this logic.
//             tree.update(event.x, 1) // Set leaf cx to 1
//        case .disableV:
//             tree.update(event.x, 0) // Set leaf cx to 0
//        case .queryH:
//            // Query the sum of columns `cx` that have V-condition enabled
//            // within the range required by the H-condition.
//            let queryStart = event.x
//            let queryEnd = event.xEnd! // Must exist for queryH
//            if queryStart < queryEnd {
//                 let count = tree.queryRange(queryStart, queryEnd)
//                 plusCount += count
//            }
//        }
//    }
//
//    return plusCount
//}
//
////// --- Sample Tests (Sweep Line) ---
////print("--- Running Sample Test Cases (Sweep Line) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////print("\n--- Running Boundary/Edge Test Cases (Sweep Line) ---")
////let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////// Test Case 5: Single Plus
////let N5 = 4; let L5 = [1, 1, 1, 1]; let D5 = "RULD"; let result5 = getPlusSignCount(N5, L5, D5); print("Sample 5 (Single Plus) Result: \(result5) (\(result5 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////// Test Case 6: Intersection but no plus because arms don't fully cross
////let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct": "Incorrect"), Expected: 1)")
////// Test Case 7: No plus sign possible
////let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////// Test Case 8: Large coordinates
////let N8 = 4; let L8 = [1000000000, 1, 1000000000, 1]; let D8 = "RULD"; let result8 = getPlusSignCount(N8, L8, D8); print("Sample 8 (Large Coords) Result: \(result8) (\(result8 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////// Test Case 9: Overlapping path creates plus
////let N9 = 8; let L9 = [2, 2, 2, 2, 2, 2, 2, 2]; let D9 = "RURULDLDR"; let result9 = getPlusSignCount(N9, L9, D9); print("Sample 9 (Overlap Plus) Result: \(result9) (\(result9 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////// Test Case 10 : Complex Path
////let N10 = 12; let L10 = [2,2,1,1,2,2,1,1,2,2,1,1]; let D10 = "RULD RULD LDRU"; let result10 = getPlusSignCount(N10, L10, D10); print("Sample 10 (Complex) Result: \(result10) (\(result10 == 2 ? "Correct" : "Incorrect"), Expected: 2)")
////// Test Case 11: Explicit Cross (Should be 0 pluses)
////let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
////
////print("\n--- Testing Complete ---")
