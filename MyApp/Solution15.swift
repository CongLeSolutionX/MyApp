////
////  Solution15.swift
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
//struct Edge: Hashable {
//    // Always store (a < b) for undirected segment
//    let a: Point
//    let b: Point
//
//    init(_ a: Point, _ b: Point) {
//        // For painting, direction matters
//        self.a = a
//        self.b = b
//    }
//}
//
//func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
//    let dirs = Array(D)
//    var x = 0, y = 0
//    var allX = Set<Int>([0])
//    var allY = Set<Int>([0])
//    // For compression
//    var moves = [Point(x: 0, y: 0)]
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
//        x = nx
//        y = ny
//        moves.append(Point(x: x, y: y))
//    }
//    
//    // 2. Coordinate compression
//    let xs = allX.sorted(), ys = allY.sorted()
//    let xMap = Dictionary(uniqueKeysWithValues: xs.enumerated().map { ($1, $0) })
//    let yMap = Dictionary(uniqueKeysWithValues: ys.enumerated().map { ($1, $0) })
//    let nx = xs.count, ny = ys.count
//    if nx < 3 || ny < 3 { return 0 }
//    
//    // 3. Paint each segment edge (record all painted horizontal and vertical edges)
//    var hEdges = Set<Edge>() // horizontal edges
//    var vEdges = Set<Edge>() // vertical edges
//    for i in 0..<(moves.count-1) {
//        let start = moves[i]
//        let end = moves[i+1]
//        let cx1 = xMap[start.x]!, cy1 = yMap[start.y]!
//        let cx2 = xMap[end.x]!, cy2 = yMap[end.y]!
//        if cx1 == cx2 {
//            // Vertical movement: paint edges between (cx, cy1)--(cx, cy2), for all min..max-1
//            let range = cy1 < cy2 ? cy1..<cy2 : cy2..<cy1
//            for cy in range {
//                let from = Point(x: cx1, y: cy)
//                let to = Point(x: cx1, y: cy+1)
//                vEdges.insert(Edge(from, to))
//            }
//        } else {
//            // Horizontal movement
//            let range = cx1 < cx2 ? cx1..<cx2 : cx2..<cx1
//            for cx in range {
//                let from = Point(x: cx, y: cy1)
//                let to = Point(x: cx+1, y: cy1)
//                hEdges.insert(Edge(from, to))
//            }
//        }
//    }
//    
//    var plusCount = 0
//    // For every interior compressed point (not on outermost grid!)
//    for cy in 1..<(ny-1) {
//        for cx in 1..<(nx-1) {
//            let center = Point(x: cx, y: cy)
//            // Four arms: left, right, up, down
//            let leftEdge  = Edge(Point(x: cx-1, y: cy), center)
//            let rightEdge = Edge(center, Point(x: cx+1, y: cy))
//            let upEdge    = Edge(center, Point(x: cx, y: cy+1))
//            let downEdge  = Edge(Point(x: cx, y: cy-1), center)
//            if hEdges.contains(leftEdge) &&
//               hEdges.contains(rightEdge) &&
//               vEdges.contains(upEdge) &&
//               vEdges.contains(downEdge) {
//                plusCount += 1
//            }
//        }
//    }
//    return plusCount
//}
////
////// --------- Test Cases ---------
////print(getPlusSignCount(9, [6,3,4,5,1,6,3,3,4], "ULDRULURD")) // 4
////print(getPlusSignCount(8, [1,1,1,1,1,1,1,1], "RDLUULDR")) // 1
////print(getPlusSignCount(8, [1,2,2,1,1,2,2,1], "UDUDLRLR")) // 1
