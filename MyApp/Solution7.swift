//
//  Solution7.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

import Foundation

// Use Int64 for costs to prevent potential overflow
typealias Cost = Int64
// A large enough value representing infinity, careful not to overflow when adding
let infinity: Cost = Cost.max / 3

// Helper function to calculate cost of changing radius
// Takes Int arguments as per problem statement but returns Cost (Int64)
func calculate_cost(_ initial_r: Int, _ final_r: Int, _ A: Int, _ B: Int) -> Cost {
    // Constraint: Final radius must be positive
    if final_r < 1 {
        return infinity
    }

    // Convert to Cost (Int64) for calculations
    let costA = Cost(A)
    let costB = Cost(B)
    let initialR64 = Cost(initial_r)
    let finalR64 = Cost(final_r)

    if finalR64 == initialR64 {
        return 0
    } else if finalR64 > initialR64 {
        // Inflation cost
        return (finalR64 - initialR64) * costA
    } else { // finalR64 < initialR64
        // Constraint: Cannot deflate if initial radius is 1
        if initial_r == 1 {
            // This change is impossible
            return infinity
        }
        // Deflation cost (possible since initial_r >= 2 implied by initial_r != 1)
        return (initialR64 - finalR64) * costB
    }
}

/**
 * Calculates the minimum time required to stabilize the stack of discs.
 *
 * - Parameters:
 *   - N: The number of discs.
 *   - R: An array of initial radii, from top (index 0) to bottom (index N-1).
 *   - A: The cost to inflate a disc's radius by 1.
 *   - B: The cost to deflate a disc's radius by 1 (requires radius >= 2).
 * - Returns: The minimum time (cost) required, or -1 if impossible (though problem constraints likely ensure possibility).
 */
func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {

    // Edge case: If N is 0 or 1, the stack is trivially stable with 0 cost.
    if N <= 1 {
        return 0
    }

    // 1. Transform radii R[i] to target S[i] = R[i] - i.
    // Create the sorted, unique list V of candidate values for S[i].
    var targetS: [Int] = []
    for i in 0..<N {
        targetS.append(R[i] - i)
    }
    let V = Array(Set(targetS)).sorted()
    let M = V.count // Number of unique candidate values

    // 2. Initialize DP table: dp[i][k] = min cost for prefix 0..i where S[i] = V[k]
    // Use two rows to optimize space from O(N*M) to O(M).
    // dp_curr represents dp[i], dp_prev represents dp[i-1]
    var dp_prev = Array(repeating: infinity, count: M)
    var dp_curr = Array(repeating: infinity, count: M)

    // 3. Base Case (i = 0)
    for k in 0..<M {
        let s_val = V[k]
        // Check constraint: S[0] = V[k] >= 1 - 0  (i.e., final radius R'[0] >= 1)
        if s_val >= 1 {
            let final_radius = s_val + 0
            dp_prev[k] = calculate_cost(R[0], final_radius, A, B) // Initialize dp_prev for i=0
        }
    }

    // 4. Iteration (i from 1 to N-1)
    for i in 1..<N {
        // Compute running minimum from previous row (dp_prev) efficiently
        var min_val = infinity
        var min_prev_cost_for_k = infinity // Stores min(dp_prev[j] for j <= k)

        // Reset dp_curr for the current iteration i
        // dp_curr = Array(repeating: infinity, count: M) // Already done implicitly by overwriting

        for k in 0..<M {
            // Update the running minimum up to index k from the previous step (i-1)
            min_val = min(min_val, dp_prev[k])
            min_prev_cost_for_k = min_val // This is min(dp[i-1][j] for j <= k)

            let s_val = V[k]

            // Check constraint: S[i] = V[k] >= 1 - i (i.e., final radius R'[i] >= 1)
            if s_val >= 1 - i {
                let final_radius = s_val + i
                let current_cost = calculate_cost(R[i], final_radius, A, B)
                let prev_min = min_prev_cost_for_k

                // If the current step is possible and a valid path from previous step exists
                if current_cost != infinity && prev_min != infinity {
                    // Use addition that checks for overflow, though large value should prevent it
                     dp_curr[k] = current_cost + prev_min
                } else {
                     dp_curr[k] = infinity // Ensure impossible states remain infinity
                }
            } else {
                 dp_curr[k] = infinity // State violates S[i] >= 1-i constraint
            }
        }
        // Update dp_prev for the next iteration (i+1)
        dp_prev = dp_curr
         // Reset dp_curr *if needed* or just let it be overwritten in next loop pass
         // If strictly required, uncomment: dp_curr = Array(repeating: infinity, count: M)
    }

    // 5. Final Answer: Minimum value in the last computed row (dp_prev now holds results for i=N-1)
    let final_min_cost = dp_prev.min() ?? infinity // Find the minimum cost in the last row

    // Return the result as Int, handling the infinity case if necessary
    return final_min_cost >= infinity ? -1 : Int(final_min_cost)
}
//
//// --- Testing with Sample Cases ---
//print("Sample 1: Expected 5, Got: \(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1))")
//print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))") // Corrected R' is [98, 99, 100] -> Cost (100-98)*3 + (100-99)*3 + 0 = 6+3=9. Hmm, example says 5? Let's re-read. Example 2 explanation: Deflate [100] to 99 (cost 3), Inflate [100] to 101 (cost 2). R'=[?,99,101]. Maybe R'=[98,99,101]? Cost (100-98)*3 + (100-99)*3 + (101-100)*2 = 6+3+2 = 11. Example 2 explanation says: *deflating disc 1 from 100" to 99" (taking 3 seconds) and inflating disc 3 from 100" to 101" (taking 2 seconds)*. This means R'=[100, 99, 101]. This IS NOT STABLE! 100 is not < 99. There might be an error in the example explanation or my understanding for Case 2. Let's trust the DP logic. DP gives 9 for R'=[98,99,100]. Let's check R'=[99,100,101]. Cost (100-99)*3 + 0 + (101-100)*2 = 3+2=5. OK, R'=[99,100,101] is stable and costs 5. The DP should find this. Let's trace DP for case 2. V=[98,99,100].
//// Trace Case 2: N=3, R=[100,100,100], A=2, B=3. V=[98,99,100] (M=3)
//// i=0: R[0]=100. S[0]>=1.
////   k=0, V=98: R'=98. Cost=(100-98)*3=6. dp[0][0]=6
////   k=1, V=99: R'=99. Cost=(100-99)*3=3. dp[0][1]=3
////   k=2, V=100: R'=100. Cost=0. dp[0][2]=0
//// i=1: R[1]=100. S[1]>=0. V=[98,99,100] all >=0.
////   min_prev = [6, 3, 0]
////   k=0, V=98: R'=98+1=99. Cost=(100-99)*3=3. prev_min=min_prev[0]=6. dp[1][0]=3+6=9
////   k=1, V=99: R'=99+1=100. Cost=0. prev_min=min_prev[1]=3. dp[1][1]=0+3=3
////   k=2, V=100: R'=100+1=101. Cost=(101-100)*2=2. prev_min=min_prev[2]=0. dp[1][2]=2+0=2
//// i=2: R[2]=100. S[2]>=-1. V=[98,99,100] all >=-1.
////   min_prev = [9, 3, 2]
////   k=0, V=98: R'=98+2=100. Cost=0. prev_min=min_prev[0]=9. dp[2][0]=0+9=9
////   k=1, V=99: R'=99+2=101. Cost=(101-100)*2=2. prev_min=min_prev[1]=3. dp[2][1]=2+3=5
////   k=2, V=100: R'=100+2=102. Cost=(102-100)*2=4. prev_min=min_prev[2]=2. dp[2][2]=4+2=6
//// Final min(dp[2]) = min(9, 5, 6) = 5. OK, the DP logic works and matches Sample 2's expected value.
//
//print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))")
//print("Sample 3: Expected 9, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))")
//print("Sample 4: Expected 19, Got: \(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))")
//print("Sample 5: Expected 207, Got: \(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))")
//print("Sample 6: Expected 10, Got: \(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1))")
