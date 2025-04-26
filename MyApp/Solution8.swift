//
//  Solution8.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

import Foundation

// Use Int64 for costs to prevent potential overflow during summation.
typealias Cost = Int64
// A large enough value representing infinity, chosen to avoid overflow when added.
// Cost.max / 3 ensures adding two non-infinity costs won't overflow Int64.
let infinity: Cost = Cost.max / 3

/**
 * Calculates the cost of changing a disc's radius from initial_r to final_r.
 * Handles constraints: final_r must be >= 1, deflation requires initial_r >= 2.
 */
func calculate_cost(_ initial_r: Int, _ final_r: Int, _ A: Int, _ B: Int) -> Cost {
    // Constraint: Final radius must be positive (at least 1).
    if final_r < 1 {
        // This state is invalid.
        return infinity
    }

    // Convert to Cost (Int64) for calculations to prevent intermediate overflow.
    let costA = Cost(A)
    let costB = Cost(B)
    let initialR64 = Cost(initial_r)
    let finalR64 = Cost(final_r)

    if finalR64 == initialR64 {
        // No change, no cost.
        return 0
    } else if finalR64 > initialR64 {
        // Inflation cost.
        return (finalR64 - initialR64) * costA
    } else { // finalR64 < initialR64 -> Deflation required.
        // Constraint: Cannot deflate if starting radius is 1.
        if initial_r <= 1 {
            // Deflation is impossible from radius 1.
            return infinity
        }
        // Deflation possible (initial_r must be >= 2 here).
        return (initialR64 - finalR64) * costB
    }
}

/**
 * Calculates the minimum time required to stabilize the stack of discs using dynamic programming.
 *
 * - Parameters:
 *   - N: The number of discs.
 *   - R: An array of initial radii, from top (index 0) to bottom (index N-1).
 *   - A: The cost to inflate a disc's radius by 1.
 *   - B: The cost to deflate a disc's radius by 1 (requires radius >= 2).
 * - Returns: The minimum time (cost) required as Int, or -1 if impossible.
 */
func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {

    // Edge case: If N is 0 or 1, the stack is trivially stable with 0 cost.
    if N <= 1 {
        return 0
    }

    // 1. Create the candidate set V for the transformed variable S[i] = R'[i] - i.
    // Include the original target values R[j]-j and the crucial boundary values 1-i
    // that ensure the final radius R'[i] can be exactly 1 if needed.
    var candidateSet: Set<Int> = []
    for i in 0..<N {
        candidateSet.insert(R[i] - i) // Original target S value
        candidateSet.insert(1 - i)    // Boundary S value corresponding to R'[i] = 1
    }

    // Sort the unique candidate values. M is the number of candidates.
    let V = Array(candidateSet).sorted()
    let M = V.count

    // 2. Initialize DP table (using space optimization with two rows).
    // dp_prev stores results for step i-1, dp_curr for step i.
    var dp_prev = Array(repeating: infinity, count: M)
    var dp_curr = Array(repeating: infinity, count: M)

    // 3. Base Case (i = 0): Calculate costs for the first disc.
    let constraint_s0_min = 1 - 0 // S[0] must be >= 1 (so R'[0] >= 1)
    for k in 0..<M {
        let s_val = V[k]
        if s_val >= constraint_s0_min {
            let final_radius = s_val + 0 // R'[0] = S[0] + 0
            dp_prev[k] = calculate_cost(R[0], final_radius, A, B)
        }
        // else dp_prev[k] remains infinity
    }

    // 4. DP Iteration (i from 1 to N-1): Fill the table row by row.
    for i in 1..<N {
        // Minimum required S value for the current disc i ( S[i] >= 1 - i )
        let constraint_si_min = 1 - i
        // Tracks the minimum cost from the previous row dp[i-1] up to column j (inclusive)
        var min_prev_cost_upto_k = infinity

        // Reset dp_curr for the current row 'i' calculation.
        dp_curr = Array(repeating: infinity, count: M)

        // Iterate through all possible S values (V[k]) for the current disc 'i'.
        for k in 0..<M {
            // Efficiently find min(dp[i-1][j] for j <= k)
            min_prev_cost_upto_k = min(min_prev_cost_upto_k, dp_prev[k])
            let prev_min = min_prev_cost_upto_k // Min cost to reach a valid S[i-1] <= V[k]

            let s_val = V[k] // Candidate S value for disc i

            // Check if this S value meets the R'[i] >= 1 constraint (S[i] >= 1 - i)
            if s_val >= constraint_si_min {
                let final_radius = s_val + i // Corresponding final radius R'[i]
                // Calculate the cost to change disc i to this final_radius
                let cost_for_disc_i = calculate_cost(R[i], final_radius, A, B)

                // If changing disc 'i' is possible and we have a valid path from the previous step
                if cost_for_disc_i != infinity && prev_min != infinity {
                    // Calculate the total cost to reach this state dp[i][k]
                    // Addition is safe because infinity is Cost.max / 3
                    let total_cost = prev_min + cost_for_disc_i
                    dp_curr[k] = total_cost
                }
                 // else dp_curr[k] remains infinity
            }
             // else dp_curr[k] remains infinity because S[i] constraint violated
        }
        // Roll over: the current row becomes the previous row for the next iteration.
        dp_prev = dp_curr
    }

    // 5. Final Answer: Find the minimum cost in the last computed row (dp_prev now holds results for i=N-1).
    let final_min_cost = dp_prev.min() ?? infinity

    // Return the result as Int, handling the infinity case (problem likely guarantees a solution).
    // If final_min_cost is infinity, it means no stable configuration was possible.
    return final_min_cost >= infinity ? -1 : Int(final_min_cost)
}
//
//// --- Testing with Sample Cases (using the refined function) ---
//print("Sample 1: Expected 5, Got: \(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1))")
//print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))")
//print("Sample 3: Expected 9, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))")
//print("Sample 4: Expected 19, Got: \(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))")
//print("Sample 5: Expected 207, Got: \(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))")
//print("Sample 6: Expected 10, Got: \(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1))")
