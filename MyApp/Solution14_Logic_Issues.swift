////
////  Solution14.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//struct Point: Hashable {
//    let x: Int
//    let y: Int
//}
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    let dirs = Array(D)
//    var x = 0, y = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    var hSegs = [(y: Int, x1: Int, x2: Int)]()
//    var vSegs = [(x: Int, y1: Int, y2: Int)]()
//    
//    // 1. Simulate brush movement and gather all unique coordinates
//    for i in 0..<N {
//        let d = dirs[i], len = L[i]
//        var nx = x, ny = y
//        switch d {
//        case "U": ny = y + len
//        case "D": ny = y - len
//        case "L": nx = x - len
//        case "R": nx = x + len
//        default: continue
//        }
//        allX.insert(x); allX.insert(nx)
//        allY.insert(y); allY.insert(ny)
//        if d == "L" || d == "R" {
//            let left = min(x, nx)
//            let right = max(x, nx)
//            hSegs.append((y: y, x1: left, x2: right))
//        } else {
//            let down = min(y, ny)
//            let up = max(y, ny)
//            vSegs.append((x: x, y1: down, y2: up))
//        }
//        x = nx
//        y = ny
//    }
//    
//    // 2. Coordinate compression
//    let xs = allX.sorted(), ys = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: xs.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: ys.enumerated().map { ($1, $0) })
//    let nx = xs.count, ny = ys.count
//    if nx < 3 || ny < 3 { return 0 }
//    
//    // 3. Construct painted (horizontal, vertical) segment sets (`hArms`, `vArms`)
//    var hArms = Set<Point>()
//    var vArms = Set<Point>()
//    for s in hSegs {
//        let cy = yMap[s.y]!
//        let lx = xMap[s.x1]!, rx = xMap[s.x2]!
//        for cx in lx..<rx {
//            hArms.insert(Point(x: cx, y: cy))
//        }
//    }
//    for s in vSegs {
//        let cx = xMap[s.x]!
//        let ly = yMap[s.y1]!, ry = yMap[s.y2]!
//        for cy in ly..<ry {
//            vArms.insert(Point(x: cx, y: cy))
//        }
//    }
//    
//    // 4. Find plus signs at intersection points
//    var plusCount = 0
//    let candidates = hArms.intersection(vArms)
//    for point in candidates {
//        let (cx, cy) = (point.x, point.y)
//        // Need "arms" in all 4 directions (immediately adjacent):
//        let left  = Point(x: cx-1, y: cy)
//        let right = Point(x: cx+1, y: cy)
//        let up    = Point(x: cx, y: cy+1)
//        let down  = Point(x: cx, y: cy-1)
//        // For a plus, must have horizontal arms at (left, center, right)
//        // and vertical arms at (up, center, down)
//        if hArms.contains(left) && hArms.contains(point) &&
//           hArms.contains(right) &&
//           vArms.contains(up) && vArms.contains(point) &&
//           vArms.contains(down) {
//            plusCount += 1
//        }
//    }
//    return plusCount
//}
//
////// --------- Test Cases ---------
////print(getPlusSignCount(9, [6,3,4,5,1,6,3,3,4], "ULDRULURD")) // 4
////print(getPlusSignCount(8, [1,1,1,1,1,1,1,1], "RDLUULDR")) // 1
////print(getPlusSignCount(8, [1,2,2,1,1,2,2,1], "UDUDLRLR")) // 1
