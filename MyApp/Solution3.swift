////
////  Solution3.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import Foundation
//
//struct Belt {
//    var l: Int
//    var r: Int
//    var h: Int
//}
//
//func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int],
//                                            _ A: [Int], _ B: [Int]) -> Float {
//
//    let INF = Double.infinity
//    var belts = [Belt]()
//    for i in 0..<N {
//        belts.append(Belt(l: min(A[i], B[i]), r: max(A[i], B[i]), h: H[i]))
//    }
//    belts.sort { $0.h > $1.h }
//
//    // For efficient search:
//    var xSegments = belts.map { ($0.l, $0.r, 0.0, 0.0) } //(left, right, dpLeft, dpRight)
//
//    func nextBelow(_ x: Int, _ sortedBelts: [(Int,Int,Double,Double)], _ currentY: Int) -> Int? {
//        var lo = 0, hi = N - 1, res: Int? = nil
//        while lo <= hi {
//            let mid = (lo + hi) / 2
//            if belts[mid].h >= currentY {
//                lo = mid + 1
//                continue
//            }
//            if belts[mid].l < x && x < belts[mid].r {
//                res = mid
//                hi = mid - 1
//            } else {
//                lo = mid + 1
//            }
//        }
//        return res
//    }
//
//    for i in (0..<N).reversed() {
//        // expectation from left-endpoint downward:
//        if let belowLeft = nextBelow(belts[i].l, xSegments, belts[i].h) {
//            xSegments[i].2 = Double(belts[i].r-belts[i].l) + 0.5*(xSegments[belowLeft].2+xSegments[belowLeft].3)
//        } else {
//            xSegments[i].2 = Double(belts[i].r-belts[i].l)
//        }
//
//        // expectation from right-endpoint downward:
//        if let belowRight = nextBelow(belts[i].r, xSegments, belts[i].h) {
//            xSegments[i].3 = Double(belts[i].r-belts[i].l) + 0.5*(xSegments[belowRight].2+xSegments[belowRight].3)
//        } else {
//            xSegments[i].3 = Double(belts[i].r-belts[i].l)
//        }
//    }
//
//    var bestExp = INF
//    // Try each belt as fixed direction belt explicitly:
//    for i in 0..<N {
//        for fixedDir in 0...1 { //0:left, 1:right
//            var exp = 0.0
//            // Integrate expectation over interval [0,10^6]:
//            // Three intervals: [0,l], [l,r], [r,10^6]:
//            let L = Double(belts[i].l), R = Double(belts[i].r)
//            exp += 0.0 * (L/1000000.0) // direct ground hit left
//            exp += (R-L + (fixedDir==0 ? xSegments[i].2 : xSegments[i].3))*( (R-L)/1000000.0 )/2.0
//            exp += 0.0 * ((1000000.0-R)/1000000.0) // direct ground hit right
//            //endpoint left
//            if let below = nextBelow(belts[i].l, xSegments, belts[i].h) {
//                exp += ( (R-L)/1000000.0/2.0 ) * ( (xSegments[below].2+xSegments[below].3)/2.0 )
//            }
//            //endpoint right
//            if let below = nextBelow(belts[i].r, xSegments, belts[i].h) {
//                exp += ( (R-L)/1000000.0/2.0 ) * ( (xSegments[below].2+xSegments[below].3)/2.0 )
//            }
//            bestExp = min(bestExp, exp)
//        }
//    }
//    return Float(bestExp)
//}
////
////// Sample tests from image (must pass exactly!)
////print(getMinExpectedHorizontalTravelDistance(2,[10,20],[100000,400000],[600000,800000])) // ~155000.0
////print(getMinExpectedHorizontalTravelDistance(5,[2,8,5,9,4],[5000,2000,7000,9000,0],[7000,8000,11000,11000,4000])) // ~36.5
