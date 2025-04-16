//
//  Solution4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import Foundation

struct Belt {
    var l : Int
    var r : Int
    var h : Int
}

func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int], _ A: [Int], _ B: [Int]) -> Float {

    let belts = zip(zip(A,B),H).map { Belt(l:min($0.0,$0.1), r:max($0.0,$0.1), h:$1) }.sorted(by: { $0.h > $1.h })

    var dpLeft = Array(repeating:0.0, count:N)
    var dpRight = Array(repeating:0.0, count:N)

    func findBelow(_ x:Int, _ idx: Int) -> Int? {
        for j in (idx+1)..<N {
            if belts[j].l < x && x < belts[j].r { return j }
        }
        return nil
    }

    for i in stride(from:N-1, through:0, by:-1) {
        let len = Double(belts[i].r - belts[i].l)

        dpLeft[i] = len
        dpRight[i] = len
        
        if let below = findBelow(belts[i].l, i) {
            dpLeft[i] += (dpLeft[below] + dpRight[below])/2
        }
        if let below = findBelow(belts[i].r, i) {
            dpRight[i] += (dpLeft[below] + dpRight[below])/2
        }
    }

    var bestExpectation = Double.infinity

    // Test choosing each belt & each direction explicitly
    for (idx,belt) in belts.enumerated(){
        for fixedDir in [0,1]{
            let l = Double(belt.l), r = Double(belt.r)

            // intervals and their proportion over [0,1,000,000]
            let leftP = l/1e6
            let rightP = (1e6 - r)/1e6
            let midP = (r - l)/1e6

            var expectation = 0.0

            // mid part: belt fixed direction avg travel = half belt len
            expectation += midP * (r-l)/2.0

            // From fixed belt, at endpoints
            if let leftbelow = findBelow(belt.l, idx){ expectation += midP/2*(dpLeft[leftbelow]+dpRight[leftbelow])/2}
            if let rightbelow = findBelow(belt.r, idx){ expectation += midP/2*(dpLeft[rightbelow]+dpRight[rightbelow])/2}

            bestExpectation = min(bestExpectation, expectation)
        }
    }

    return Float(bestExpectation)
}
//
//// Test cases provided explicitly by Problem statement
//print(getMinExpectedHorizontalTravelDistance(2,[10,20],[100000,400000],[600000,800000])) //Expected:155000.0
//print(getMinExpectedHorizontalTravelDistance(5,[2,8,5,9,4],[5000,2000,7000,9000,0],[7000,8000,11000,11000,4000])) //Expected:36.5
