////
////  Solution12.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//// Represents a semi-open segment interval [start, end)
//fileprivate struct Interval {
//    var start: Int
//    var end: Int
//}
//
//// Efficient binary search to check if an interval list covers point x
//fileprivate func covers(_ intervals: [Interval], _ x: Int) -> Bool {
//    var l = 0, r = intervals.count - 1
//    while l <= r {
//        let m = (l + r) / 2
//        if intervals[m].start <= x && x + 1 <= intervals[m].end {
//            return true
//        } else if x + 1 <= intervals[m].start {
//            r = m - 1
//        } else {
//            l = m + 1
//        }
//    }
//    return false
//}
//
//// Merge overlapping/adjacent intervals into one
//fileprivate func mergeIntervals(_ arr: [Interval]) -> [Interval] {
//    guard !arr.isEmpty else { return [] }
//    let sortedArr = arr.sorted { $0.start < $1.start }
//    var result = [sortedArr[0]]
//    for i in 1..<sortedArr.count {
//        var last = result.removeLast()
//        let next = sortedArr[i]
//        if next.start <= last.end {
//            last.end = max(last.end, next.end)
//            result.append(last)
//        } else {
//            result.append(last)
//            result.append(next)
//        }
//    }
//    return result
//}
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    let dirs = Array(D)
//    var x = 0, y = 0
//    var allX = Set<Int>([0]), allY = Set<Int>([0])
//    var segmentsH = [(y: Int, x1: Int, x2: Int)]()
//    var segmentsV = [(x: Int, y1: Int, y2: Int)]()
//    
//    // 1. Simulate all moves, collect all unique coordinates and segment intervals
//    for i in 0..<N {
//        let d = dirs[i], len = L[i]
//        let (nx, ny): (Int, Int)
//        switch d {
//        case "U": nx = x; ny = y + len
//        case "D": nx = x; ny = y - len
//        case "L": nx = x - len; ny = y
//        case "R": nx = x + len; ny = y
//        default: fatalError("Invalid dir")
//        }
//        allX.insert(x); allX.insert(nx); allY.insert(y); allY.insert(ny)
//        if d == "L" || d == "R" {
//            let l = min(x, nx), r = max(x, nx)
//            segmentsH.append((y: y, x1: l, x2: r))
//        } else {
//            let l = min(y, ny), r = max(y, ny)
//            segmentsV.append((x: x, y1: l, y2: r))
//        }
//        x = nx
//        y = ny
//    }
//    
//    // 2. Coordinate compression
//    let xs = allX.sorted(), ys = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: xs.enumerated().map{ ($1,$0) } )
//    let yMap = Dictionary(uniqueKeysWithValues: ys.enumerated().map{ ($1,$0) } )
//    let nx = xs.count, ny = ys.count
//    if nx < 3 || ny < 3 { return 0 }
//    
//    // 3. Store intervals per row/column (compressed coords)
//    var hSeg = Array(repeating: [Interval](), count: ny)
//    for s in segmentsH {
//        let cy = yMap[s.y]!
//        let lx = xMap[s.x1]!, rx = xMap[s.x2]!
//        hSeg[cy].append(Interval(start: lx, end: rx))
//    }
//    var vSeg = Array(repeating: [Interval](), count: nx)
//    for s in segmentsV {
//        let cx = xMap[s.x]!
//        let ly = yMap[s.y1]!, ry = yMap[s.y2]!
//        vSeg[cx].append(Interval(start: ly, end: ry))
//    }
//    for i in 0..<ny { hSeg[i] = mergeIntervals(hSeg[i]) }
//    for i in 0..<nx { vSeg[i] = mergeIntervals(vSeg[i]) }
//    
//    // 4. For every *internal* compressed grid vertex, check for plus sign
//    var result = 0
//    for cy in 1..<(ny-1) {
//        for cx in 1..<(nx-1) {
//            // Need hSeg[cy] covers [cx-1,cx] and [cx,cx+1]
//            if covers(hSeg[cy], cx-1) && covers(hSeg[cy], cx) &&
//               covers(vSeg[cx], cy-1) && covers(vSeg[cx], cy) {
//                result += 1
//            }
//        }
//    }
//    return result
//}
//
////// ------------------ Test samples ---------------------- //
////print("Sample 1:", getPlusSignCount(9, [6,3,4,5,1,6,3,3,4], "ULDRULURD")) // → 4 (expected)
////print("Sample 2:", getPlusSignCount(8, [1,1,1,1,1,1,1,1], "RDLUULDR")) // → 1 (expected)
////print("Sample 3:", getPlusSignCount(8, [1,2,2,1,1,2,2,1], "UDUDLRLR")) // → 1 (expected)
