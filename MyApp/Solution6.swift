////
////  Solution6.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//import Foundation
//
//// Use Int64 for costs to prevent potential overflow
//typealias Cost = Int64
//let infinity: Cost = Cost.max / 2 // A large enough value representing infinity
//
//// Helper function to calculate cost of changing radius
//func calculate_cost(_ initial_r: Int, _ final_r: Int, _ A: Int, _ B: Int) -> Cost {
//    // Constraint: Final radius must be positive
//    if final_r < 1 {
//        return infinity
//    }
//
//    let costA = Cost(A)
//    let costB = Cost(B)
//    let initialR64 = Cost(initial_r)
//    let finalR64 = Cost(final_r)
//
//    if finalR64 == initialR64 {
//        return 0
//    } else if finalR64 > initialR64 {
//        return (finalR64 - initialR64) * costA
//    } else { // finalR64 < initialR64
//        // Constraint: Cannot deflate if initial radius is 1
//        if initial_r == 1 {
//            return infinity
//        }
//        // Deflation cost (possible since initial_r >= 2)
//        return (initialR64 - finalR64) * costB
//    }
//}
//
//// --- Main Function ---
//func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {
//
//    // Handle N=1 case
//    if N <= 1 {
//        return 0
//    }
//
//    // 1. Calculate target S values and candidate list V
//    var targetS: [Int] = []
//    for i in 0..<N {
//        targetS.append(R[i] - i)
//    }
//
//    // Create sorted unique candidate list V
//    let V = Array(Set(targetS)).sorted()
//    let M = V.count
//
//    // 2. Initialize DP table
//    // dp[i][k] = min cost for prefix 0..i where S[i] = V[k]
//    var dp = Array(repeating: Array(repeating: infinity, count: M), count: N)
//
//    // 3. Base Case (i = 0)
//    for k in 0..<M {
//        let s_val = V[k]
//        // Check constraint S[i] >= 1 - i (i.e., S[0] >= 1)
//        if s_val >= 1 - 0 {
//            let final_radius = s_val + 0
//            dp[0][k] = calculate_cost(R[0], final_radius, A, B)
//        }
//         // Optional: Print for debugging base cases
//        // print("Base i=0, k=\(k), V[k]=\(V[k]), cost=\(dp[0][k])")
//    }
//
//    // 4. Iteration (i from 1 to N-1)
//    var min_prev_cost = Array(repeating: infinity, count: M) // To store running minimums
//
//    for i in 1..<N {
//        // Compute min_prev_cost array from dp[i-1] efficiently
//        var min_val = infinity
//        for j in 0..<M {
//            min_val = min(min_val, dp[i-1][j])
//            min_prev_cost[j] = min_val
//        }
//         // Optional: Print min_prev_cost for debugging
//         // print("i=\(i), min_prev_cost = \(min_prev_cost)")
//
//        // Calculate dp[i][k] using the optimized transition
//        for k in 0..<M {
//            let s_val = V[k]
//            // Check constraint S[i] >= 1 - i
//            if s_val >= 1 - i {
//                 let final_radius = s_val + i
//                let current_cost = calculate_cost(R[i], final_radius, A, B)
//                let prev_min = min_prev_cost[k] // Min cost ending with S[i-1] <= S[i] = V[k]
//
//                if current_cost != infinity && prev_min != infinity {
//                    dp[i][k] = current_cost + prev_min
//                }
//            }
//            // Optional: Print DP state calculation
//            // print("  -> i=\(i), k=\(k), V[k]=\(V[k]), R[\(i)]=\(R[i]), R'[\(i)]=\(s_val + i), cost=\(dp[i][k])")
//        }
//    }
//
//    // 5. Final Answer: Minimum value in the last row
//    var final_min_cost = infinity
//    for k in 0..<M {
//        final_min_cost = min(final_min_cost, dp[N-1][k])
//    }
//
//    // The problem asks for Int return, assume final cost fits Int if not infinity
//    return final_min_cost == infinity ? -1 : Int(final_min_cost) // Or handle error appropriately
//}
////
////// --- Testing with Sample Cases ---
////print("Sample 1: Expected 5, Got: \(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1))")
////print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))") // Corrected R' is [98, 99, 100] -> Cost (100-98)*3 + (100-99)*3 + 0 = 6+3=9. Hmm, example says 5? Let's re-read. Example 2 explanation: Deflate [100] to 99 (cost 3), Inflate [100] to 101 (cost 2). R'=[?,99,101]. Maybe R'=[98,99,101]? Cost (100-98)*3 + (100-99)*3 + (101-100)*2 = 6+3+2 = 11. Example 2 explanation says: *deflating disc 1 from 100" to 99" (taking 3 seconds) and inflating disc 3 from 100" to 101" (taking 2 seconds)*. This means R'=[100, 99, 101]. This IS NOT STABLE! 100 is not < 99. There might be an error in the example explanation or my understanding for Case 2. Let's trust the DP logic. DP gives 9 for R'=[98,99,100]. Let's check R'=[99,100,101]. Cost (100-99)*3 + 0 + (101-100)*2 = 3+2=5. OK, R'=[99,100,101] is stable and costs 5. The DP should find this. Let's trace DP for case 2. V=[98,99,100].
////// Trace Case 2: N=3, R=[100,100,100], A=2, B=3. V=[98,99,100] (M=3)
////// i=0: R[0]=100. S[0]>=1.
//////   k=0, V=98: R'=98. Cost=(100-98)*3=6. dp[0][0]=6
//////   k=1, V=99: R'=99. Cost=(100-99)*3=3. dp[0][1]=3
//////   k=2, V=100: R'=100. Cost=0. dp[0][2]=0
////// i=1: R[1]=100. S[1]>=0. V=[98,99,100] all >=0.
//////   min_prev = [6, 3, 0]
//////   k=0, V=98: R'=98+1=99. Cost=(100-99)*3=3. prev_min=min_prev[0]=6. dp[1][0]=3+6=9
//////   k=1, V=99: R'=99+1=100. Cost=0. prev_min=min_prev[1]=3. dp[1][1]=0+3=3
//////   k=2, V=100: R'=100+1=101. Cost=(101-100)*2=2. prev_min=min_prev[2]=0. dp[1][2]=2+0=2
////// i=2: R[2]=100. S[2]>=-1. V=[98,99,100] all >=-1.
//////   min_prev = [9, 3, 2]
//////   k=0, V=98: R'=98+2=100. Cost=0. prev_min=min_prev[0]=9. dp[2][0]=0+9=9
//////   k=1, V=99: R'=99+2=101. Cost=(101-100)*2=2. prev_min=min_prev[1]=3. dp[2][1]=2+3=5
//////   k=2, V=100: R'=100+2=102. Cost=(102-100)*2=4. prev_min=min_prev[2]=2. dp[2][2]=4+2=6
////// Final min(dp[2]) = min(9, 5, 6) = 5. OK, the DP logic works and matches Sample 2's expected value.
////
////print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))")
////print("Sample 3: Expected 9, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))")
////print("Sample 4: Expected 19, Got: \(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))")
////print("Sample 5: Expected 207, Got: \(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))")
////print("Sample 6: Expected 10, Got: \(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1))")
//
