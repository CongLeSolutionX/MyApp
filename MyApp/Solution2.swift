////
////  Solution2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {
//    var totalSeconds = 0
//    var discs = R
//
//    for i in 1..<N {
//        if discs[i - 1] >= discs[i] {
//            let requiredAdjustment = discs[i - 1] - discs[i] + 1
//            
//            // Calculate inflate & deflate cost separately
//            let inflateCost = requiredAdjustment * A
//            let deflateCost = requiredAdjustment * B
//            
//            // execute cheaper operation
//            if inflateCost <= deflateCost {
//                discs[i - 1] += requiredAdjustment
//                totalSeconds += inflateCost
//            } else {
//                discs[i] -= requiredAdjustment
//                totalSeconds += deflateCost
//            }
//        }
//    }
//    return totalSeconds
//}
//
////// Verification against provided test cases:
////print(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1)) // output: 5
////print(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))//output: 5
////print(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))//output: 9
////print(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))  //output: 19
////print(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))//output: 207
////print(getMinimumSecondsRequired(6, [6,5,2,4,4,7],1,1))    //output: 10
