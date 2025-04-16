////
////  Solution.swift
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
//        // Check if the current disc is smaller than or equal to the previous disc
//        if discs[i - 1] >= discs[i] {
//            // calculate both inflate and deflate costs
//            let inflateCost = (discs[i - 1] - discs[i] + 1) * A
//            let deflateCost = (discs[i - 1] - discs[i] + 1) * B
//
//            // always choose the cheaper operation.
//            if inflateCost < deflateCost {
//                // inflate upper disc
//                discs[i - 1] += (discs[i - 1] - discs[i] + 1)
//                totalSeconds += inflateCost
//            } else {
//                // deflate lower disc
//                discs[i] -= (discs[i - 1] - discs[i] + 1)
//                totalSeconds += deflateCost
//            }
//        }
//    }
//    return totalSeconds
//}

//
//// Check provided sample cases to verify correctness before general optimization
//print(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1)) // expect 5
//print(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3)) // expect 5
//print(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3)) // expect 9
//print(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))   // expect 19
//print(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))// expect 207
//print(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1)) // expect 10
