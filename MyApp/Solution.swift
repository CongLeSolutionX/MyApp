////
////  Solution.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import Foundation
//
//struct Belt {
//    var A: Int
//    var B: Int
//    var H: Int
//}
//
//func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int],
//                                            _ A: [Int], _ B: [Int]) -> Float {
//
//    // First, define conveyor belts & sort by height in descending order.
//    var belts = [Belt]()
//    for i in 0..<N {
//        belts.append(Belt(A: min(A[i], B[i]), B: max(A[i], B[i]), H: H[i]))
//    }
//    belts.sort { $0.H > $1.H }
//
//    // Expected distances after landing on this belt from above
//    var dp = Array(repeating: 0.0, count: N)
//
//    // Base case: bottom-most belt always has 0 expectation (no belts below)
//    for i in (0..<N).reversed() {
//        dp[i] = Double(belts[i].B - belts[i].A) // Initial expectation, whole belt length
//        for end in ["left", "right"] {
//            let xPos = (end == "left") ? belts[i].A : belts[i].B
//            // package falls down next, check belts below
//            var nextExpectation = 0.0
//            for j in (i+1)..<N {
//                if belts[j].A < xPos && xPos < belts[j].B {
//                    // belt j will be encountered
//                    nextExpectation = dp[j] / 2  // 50% probability each direction
//                    break
//                }
//            }
//            dp[i] += nextExpectation
//        }
//        dp[i] /= 2.0 // Average over both ends
//    }
//
//    // Check each belt as fixed (direction known) for optimal result
//    var optimalExpectedDistance = Double.infinity
//    
//    for i in 0..<N {
//        for dir in ["left", "right"] {
//            var expectedDist = 0.0
//            
//            // separate probability intervals for x position [0..1_000_000]:
//            let fixedLeftEnd = (dir == "left")
//            let fixedRightEnd = !fixedLeftEnd
//
//            // position intervals
//            let leftInterval = belts[i].A
//            let rightInterval = 1000000 - belts[i].B
//            let midInterval = belts[i].B - belts[i].A
//            
//            // left side [0, A[i]] package falls directly to ground (0 distance)
//            // middle side [A[i], B[i]] package moves on this fixed belt
//            expectedDist += Double(midInterval) / 2.0
//
//            // reaching left or right end after midInterval/2 expected distance travesed
//            for endpoint in ["A", "B"] {
//                let endpointPos = (endpoint == "A") ? belts[i].A : belts[i].B
//                let fallNext = endpointPos
//                
//                var nextExpectation = 0.0
//                for j in (i+1)..<N {
//                    if belts[j].A < fallNext && fallNext < belts[j].B {
//                        nextExpectation = dp[j] / 2.0
//                        break
//                    }
//                }
//                expectedDist += (Double(midInterval) / 2.0) * (nextExpectation / Double(midInterval))
//            }
//            
//            // right side [B[i], 1,000,000] directly to ground
//            // Average across entire range
//            let totalInterval = 1000000.0
//            optimalExpectedDistance = min(optimalExpectedDistance, expectedDist)
//        }
//    }
//    
//    return Float(optimalExpectedDistance)
//}
////
////// Validate initial with provided example case to ensure everything works initially:
////let N1 = 2
////let H1 = [10, 20]
////let A1 = [100000, 400000]
////let B1 = [600000, 800000]
////
////// test it:
////let result1 = getMinExpectedHorizontalTravelDistance(N1, H1, A1, B1)
////print(result1)    // should be close to 155000.0
////
////let N2 = 5
////let H2 = [2, 8, 5, 9, 4]
////let A2 = [5000, 2000, 7000, 9000, 0]
////let B2 = [7000, 8000, 11000, 11000, 4000]
////
////let result2 = getMinExpectedHorizontalTravelDistance(N2, H2, A2, B2)
////print(result2)    // should be close to 36.5
