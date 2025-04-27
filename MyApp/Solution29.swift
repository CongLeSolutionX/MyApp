////
////  Solution29.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// ----- Fenwick Tree (BIT) Implementation -----
//// Supports point updates and range queries (inclusive).
//// 0-indexed externally, but internally uses 1-based logic.
//struct FenwickTree {
//    private var tree: [Int]
//    let size: Int // Max index is size-1
//
//    init(size: Int) {
//        // Size needs to be at least 1 for tree array allocation
//        // Needs size+1 elements for 1-based internal logic
//        guard size > 0 else {
//             self.size = 0
//             self.tree = []
//             return
//         }
//        self.size = size
//        self.tree = Array(repeating: 0, count: size + 1)
//    }
//
//    // Adds delta to the element at index `idx`.
//    // idx is 0-based from the user perspective.
//    mutating func add(_ idx: Int, _ delta: Int) {
//        guard idx >= 0 && idx < size else {
//            // Consider logging or handling error if bounds are critical
//            // print("Warning: BIT add index out of bounds: \(idx)")
//            return
//        }
//        var i = idx + 1 // Convert to 1-based index for BIT logic
//        while i <= size {
//            tree[i] += delta
//            i += i & (-i) // Move to the next index responsible for this range
//        }
//    }
//
//    // Queries the prefix sum up to index `idx` (inclusive).
//    // idx is 0-based from the user perspective. Returns 0 if idx < 0.
//    private func queryPrefix(_ idx: Int) -> Int {
//        guard idx >= 0 else { return 0 }
//        let effectiveIdx = min(idx, size - 1) // Clamp idx if it goes beyond size
//        guard effectiveIdx >= 0 else { return 0 } // If size is 0 or idx clamped below 0
//
//        var sum = 0
//        var i = effectiveIdx + 1 // Convert to 1-based index for BIT logic
//        while i > 0 {
//            sum += tree[i]
//            i -= i & (-i) // Move to the parent index in the implicit tree
//        }
//        return sum
//    }
//
//    // Queries the sum of elements in the range [startIndex, endIndex] (inclusive).
//    // Indices are 0-based. Returns 0 for invalid or empty ranges.
//    func queryRange(startIndex: Int, endIndex: Int) -> Int {
//        // Basic validity checks
//        guard size > 0, startIndex <= endIndex else { return 0 }
//        // Check if range is entirely outside [0, size-1]
//        guard endIndex >= 0, startIndex < size else { return 0}
//
//        // Clamp range to be within valid BIT indices [0, size-1]
//        let clampStart = max(0, startIndex)
//        let clampEnd = min(size - 1, endIndex)
//
//        // If clamped range is invalid (e.g., startIndex > size-1)
//        guard clampStart <= clampEnd else { return 0 }
//
//        // Standard range query P(end) - P(start-1) using prefix sums
//        let sumEnd = queryPrefix(clampEnd)
//        let sumStartMinus1 = queryPrefix(clampStart - 1)
//        return sumEnd - sumStartMinus1
//    }
//}
//
//// ----- Event Structure -----
//// Defines the type of event happening at a specific x-coordinate (cx)
//enum EventType: Int, Comparable {
//    case hcEnd = 0    // End of Horizontal Center coverage (process first to remove contribution)
//    case vcQuery = 1  // Vertical Center query (process after ends, before starts)
//    case hcStart = 2  // Start of Horizontal Center coverage (process last to add contribution)
//
//    // Enables sorting events by type for correct processing order at the same cx
//    static func < (lhs: EventType, rhs: EventType) -> Bool {
//        return lhs.rawValue < rhs.rawValue
//    }
//}
//
//// Represents a sweep-line event
//struct Event: Comparable {
//    static func == (lhs: Event, rhs: Event) -> Bool {
//        return true
//    }
//    
//    let cx: Int             // X-coordinate (compressed) where the event occurs
//    let type: EventType
//    // Data payload depends on the event type
//    let cyData: Int?        // For HC_START, HC_END: the y-coordinate (compressed)
//    let rangeData: (Int, Int)? // For VC_QUERY: the inclusive y-range [cy1, cy2] (compressed)
//
//    // Initializer for Horizontal Centerline events
//    init(cx: Int, type: EventType, cy: Int) {
//        guard type == .hcStart || type == .hcEnd else {
//            fatalError("Invalid type for cyData initializer")
//        }
//        self.cx = cx
//        self.type = type
//        self.cyData = cy
//        self.rangeData = nil
//    }
//
//    // Initializer for Vertical Centerline query events
//    init(cx: Int, type: EventType, range: (Int, Int)) {
//         guard type == .vcQuery else {
//            fatalError("Invalid type for rangeData initializer")
//        }
//        self.cx = cx
//        self.type = type
//        self.cyData = nil
//        self.rangeData = range
//    }
//
//    // Comparison for sorting events: primarily by cx, secondarily by type
//    static func < (lhs: Event, rhs: Event) -> Bool {
//        if lhs.cx != rhs.cx {
//            return lhs.cx < rhs.cx
//        }
//        // If cx is the same, use enum's Comparable conformance for order
//        return lhs.type < rhs.type
//    }
//}
//
///// Solves the Mathematical Art problem using a vertical sweep-line algorithm
///// based on center lines intersections and a Fenwick Tree. O(N log N) complexity.
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    // --- Input Validation ---
//    guard N >= 2, L.count == N, D.count == N else { return 0 }
//    let directions = Array(D)
//
//    // --- Step 1: Simulate Path and Collect Unique Coordinates ---
//    var currentX: Int64 = 0
//    var currentY: Int64 = 0
//    // Use Sets for efficient uniqueness check during collection
//    var allXSet = Set<Int64>([0])
//    var allYSet = Set<Int64>([0])
//    // Store vertices to reconstruct segments later
//    var pathVertices = [(x: Int64, y: Int64)]()
//    pathVertices.append((x: 0, y: 0))
//
//    for i in 0..<N {
//        let length = Int64(L[i])
//        guard length > 0 else { continue } // Ignore zero-length segments
//        let direction = directions[i]
//        var nextX = currentX
//        var nextY = currentY
//
//        switch direction {
//        case "U": nextY += length
//        case "D": nextY -= length
//        case "L": nextX -= length
//        case "R": nextX += length
//        default: print("Error: Invalid direction \(direction)"); return 0 // Invalid input
//        }
//        // Add the end coordinate to the sets
//        allXSet.insert(nextX)
//        allYSet.insert(nextY)
//        currentX = nextX
//        currentY = nextY
//        pathVertices.append((x: currentX, y: currentY))
//    }
//
//    // --- Step 2: Coordinate Compression ---
//    let sortedX = allXSet.sorted() // O(X log X), X <= N+1
//    let sortedY = allYSet.sorted() // O(Y log Y), Y <= N+1
//    // Create dictionaries mapping original coordinate to compressed index
//    let xMap = Dictionary(uniqueKeysWithValues: sortedX.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: sortedY.enumerated().map { ($1, $0) })
//    let compNX = sortedX.count // Number of distinct vertical grid lines
//    let compNY = sortedY.count // Number of distinct horizontal grid lines
//
//     // A plus sign requires at least 3 distinct x and 3 distinct y coordinates
//    guard compNX >= 3 && compNY >= 3 else { return 0 }
//
//    // --- Step 3: Generate Sweep Line Events ---
//    var events: [Event] = []
//    // Reserve capacity proportional to N for potential minor performance gain
//    events.reserveCapacity(N * 2)
//
//    for i in 0..<(pathVertices.count - 1) {
//        let startOrig = pathVertices[i]
//        let endOrig = pathVertices[i+1]
//        // Map original coordinates to compressed indices. Should always succeed.
//        guard let cx1 = xMap[startOrig.x], let cy1 = yMap[startOrig.y],
//              let cx2 = xMap[endOrig.x], let cy2 = yMap[endOrig.y] else {
//            fatalError("Coordinate mapping failed - internal error")
//        }
//
//        if cx1 == cx2 { // Vertical stroke segment (cx, startY, endY)
//            let cx = cx1
//            let startY = min(cy1, cy2)
//            let endY = max(cy1, cy2)
//            let length = endY - startY
//            if length >= 2 { // Can form a vertical center line segment
//                // Vertical center line exists for y in [startY + 1, endY - 1]
//                let vc_start_y = startY + 1
//                let vc_end_y = endY - 1
//                // Ensure the range is valid before adding the query event
//                if vc_start_y <= vc_end_y {
//                    events.append(Event(cx: cx, type: .vcQuery, range: (vc_start_y, vc_end_y)))
//                 }
//            }
//        } else { // Horizontal stroke segment (cy, startX, endX)
//            let cy = cy1
//            let startX = min(cx1, cx2)
//            let endX = max(cx1, cx2)
//            let length = endX - startX
//            if length >= 2 { // Can form a horizontal center line segment
//                // Horizontal center line exists for x in [startX + 1, endX - 1]
//                let hc_start_cx = startX + 1
//                // End event occurs when the sweep line *passes* the last x it covers (endX - 1).
//                // The event coordinate is thus endX.
//                let hc_end_cx_exclusive = endX
//
//                // Ensure the range is valid before adding start/end events
//                if hc_start_cx < hc_end_cx_exclusive {
//                    events.append(Event(cx: hc_start_cx, type: .hcStart, cy: cy))
//                    events.append(Event(cx: hc_end_cx_exclusive, type: .hcEnd, cy: cy))
//                }
//            }
//        }
//    }
//
//    // --- Step 4: Sort Events ---
//    events.sort() // O(N log N)
//
//    // --- Step 5: Sweep Line Process ---
//    // Initialize Fenwick Tree for y-coordinates (size compNY)
//    var bit = FenwickTree(size: compNY)
//    var plusCount = 0
//
//    // Process events in sorted order
//    for event in events {
//        switch event.type {
//        case .hcStart:
//            // A horizontal center line becomes active at this cy
//            if let cy = event.cyData {
//                bit.add(cy, +1) // Increment count for this y-coordinate
//            }
//        case .hcEnd:
//            // A horizontal center line becomes inactive at this cy
//            if let cy = event.cyData {
//                 bit.add(cy, -1) // Decrement count for this y-coordinate
//            }
//        case .vcQuery:
//             // A vertical segment provides center lines in a y-range at this cx.
//             // Query how many of these y's also have an active horizontal center line.
//            if let (query_cy1, query_cy2) = event.rangeData {
//                // Query the BIT for the sum of active H-centers in the inclusive range
//                let count = bit.queryRange(startIndex: query_cy1, endIndex: query_cy2)
//                plusCount += count // Each active H-center in range forms a plus with this V-center
//            }
//        }
//    }
//
//    // --- Step 6: Return Final Count ---
//    return plusCount
//}
////
////// --- Sample Tests (Using the final Sweep Line function) ---
////print("--- Running Sample Test Cases (Sweep Line O(N log N)) ---")
////let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
////let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////let N5 = 8; let L5 = [4, 4, 4, 4, 2, 4, 4, 4]; let D5 = "RULDRULD"; let result5 = getPlusSignCount(N5, L5, D5); print("Sample 5 Result: \(result5) (\(result5 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
////print("\n--- Testing Complete ---")
