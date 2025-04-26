////
////  Solution13.swift
////  MyApp
////
////  Created by Cong Le on 4/25/25.
////
//
//import Foundation
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    let dirs = Array(D)
//    var x = 0, y = 0
//    var allX = Set<Int>([0]), allY = Set<Int>([0])
//    var hSegs = [(y: Int, x1: Int, x2: Int)]()
//    var vSegs = [(x: Int, y1: Int, y2: Int)]()
//    
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
//            let (l, r) = (min(x, nx), max(x, nx))
//            hSegs.append((y: y, x1: l, x2: r))
//        } else {
//            let (l, r) = (min(y, ny), max(y, ny))
//            vSegs.append((x: x, y1: l, y2: r))
//        }
//        x = nx
//        y = ny
//    }
//    let xs = allX.sorted(), ys = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: xs.enumerated().map{ ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: ys.enumerated().map{ ($1, $0) })
//    let nx = xs.count, ny = ys.count
//    if nx < 3 || ny < 3 { return 0 }
//    
//    var hArms = Set<(Int, Int)>()
//    var vArms = Set<(Int, Int)>()
//    // Horizontal arms: for all (cx, cy), mark (cx, cy) for segments to the right, and (cx-1, cy) for segments to the left
//    for s in hSegs {
//        let cy = yMap[s.y]!
//        let lx = xMap[s.x1]!, rx = xMap[s.x2]!
//        for cx in (lx)..<(rx) {
//            hArms.insert((cx, cy))
//        }
//    }
//    // Vertical arms
//    for s in vSegs {
//        let cx = xMap[s.x]!
//        let ly = yMap[s.y1]!, ry = yMap[s.y2]!
//        for cy in (ly)..<(ry) {
//            vArms.insert((cx, cy))
//        }
//    }
//    var plus = 0
//    // Check all intersections (i.e., where both hArms and vArms exist)
//    let candidates = hArms.intersection(vArms)
//    for (cx, cy) in candidates {
//        // left/right in hArms, up/down in vArms
//        if hArms.contains((cx-1, cy)) && hArms.contains((cx, cy)) &&
//           vArms.contains((cx, cy-1)) && vArms.contains((cx, cy)) {
//            plus += 1
//        }
//    }
//    return plus
//}
//
////// Sample tests again
////print(getPlusSignCount(9, [6,3,4,5,1,6,3,3,4], "ULDRULURD")) // 4
////print(getPlusSignCount(8, [1,1,1,1,1,1,1,1], "RDLUULDR")) // 1
////print(getPlusSignCount(8, [1,2,2,1,1,2,2,1], "UDUDLRLR")) // 1
