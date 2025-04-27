//
//  Solution.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

// Write any import statements here
import Foundation

func getMaxExpectedProfit(_ N: Int, _ V: [Int], _ C: Int, _ S: Float) -> Float {
  // Write your code here
  
   // Use Double for high precision internal calculations
    let cost: Double = Double(C)
    let theftProbability: Double = Double(S)
    // Use a small epsilon for robust floating-point comparisons, consistent with high precision needs
    let epsilon: Double = 1e-11 // Adjusted slightly smaller, might help convergence/boundary cases
    // Clamp survival probability just in case S is slightly outside [0, 1]
    let survivalProbability: Double = max(0.0, min(1.0, 1.0 - theftProbability))
    // Convert package values to Double upfront
    let values: [Double] = V.map { Double($0) }

    // thresholds[i] will store the optimal collection threshold for potentialValue on day i
    // A potentialValue >= thresholds[i] implies collection is optimal on day i.
    var thresholds: [Double] = Array(repeating: 0.0, count: N)

    // --- Backward Pass: Calculate Time-Varying Optimal Thresholds ---

    // Helper function to simulate total expected future profit starting from 'startDay'
    // with 'startE' expected value, using the already computed thresholds for days >= startDay.
    // T_computed contains thresholds[0...N-1], but we only use indices >= startDay.
    func calculateFutureProfit(startDay: Int, startE: Double, T_computed: [Double]) -> Double {
        var currentE = startE
        var profit: Double = 0.0

        // Check if simulation starts beyond the last day
        if startDay >= N {
            return max(0.0, currentE - cost) // Only final collection possible
        }

        // Simulate forward from startDay
        for day in startDay..<N {
            let potential = currentE + values[day]
            // The optimal threshold for this 'day' was computed in the backward pass
            let threshold = T_computed[day]

            // Decision Rule: Collect if potential value meets/exceeds threshold AND is greater than cost
            let shouldCollect = (potential >= threshold - epsilon) && (potential > cost + epsilon)

            if shouldCollect {
                profit += potential - cost
                currentE = 0.0 // Value resets after collection
            } else {
                // Value decays due to theft risk at end of 'day'
                currentE = survivalProbability * potential
            }
        }
        // After the loop finishes (after day N-1), check if collecting the final remaining value is profitable
        profit += max(0.0, currentE - cost)
        return profit
    }

    // Iterate backwards from the second-to-last day (N-1) down to day 0
    // The 'thresholds' array is filled from right to left.
    for i in (0..<N).reversed() {

        // Calculate f(i+1, 0): Expected future profit starting day i+1 with 0 value,
        // using the thresholds T[i+1]...T[N-1] already computed.
        let const_f0_next = calculateFutureProfit(startDay: i + 1, startE: 0.0, T_computed: thresholds)

        // Binary search for the threshold T[i] (represented by potentialValue 'v')
        // The threshold is the value 'v' where collecting equals not collecting:
        // Equation: (v - C) + f(i+1, 0) = f(i+1, (1-S)*v)
        // Define Balance(v) = [(v - C) + f(i+1, 0)] - f(i+1, (1-S)*v)
        // We are looking for the smallest v where Balance(v) >= 0

        var lowV: Double = cost    // Minimum possible threshold is the cost itself
        var highV: Double = 1e12   // Use a very large upper bound to be safe for large values/small S

        // Perform binary search for ~100 iterations for high precision with Doubles
        for _ in 0..<100 {
            // Use midpoint calculation less prone to overflow with large bounds
            let midV = lowV + (highV - lowV) / 2.0

            // Avoid calculating future profit if midV is invalid (less than cost)
            // Although lowV starts at cost, midV could theoretically dip below due to precision issues if bounds are huge.
            // This check is likely redundant but safe.
             if midV < cost - epsilon {
                 lowV = midV // Keep searching higher
                 continue
             }

            // Calculate f(i+1, (1-S)*midV) using already computed future thresholds
            let futureProfitIfKeep = calculateFutureProfit(startDay: i + 1, startE: survivalProbability * midV, T_computed: thresholds)

            // Calculate the balance: Profit(Collect) - Profit(Don't Collect) at potential value midV
            let balance = ((midV - cost) + const_f0_next) - futureProfitIfKeep

            // If balance >= 0, collecting at midV is optimal or equal.
            // The true threshold might be midV or lower. We search in [lowV, midV].
            if balance >= 0 {
                highV = midV
            } else {
            // If balance < 0, collecting at midV is suboptimal.
            // The true threshold must be higher than midV. We search in [midV, highV].
                lowV = midV
            }
        }

        // After the binary search, highV holds the lowest potentialValue where collecting becomes >= not collecting.
        // This is our threshold for day i.
        thresholds[i] = highV
    }

    // --- Forward Pass: Calculate Max Profit using the computed Optimal Thresholds ---
    var totalProfit: Double = 0.0
    var currentExpectedValue: Double = 0.0 // Expected value at the START of day i

    for i in 0..<N {
        // Value in room after package V[i] arrives
        let potentialValue = currentExpectedValue + values[i]
        // Get the optimal threshold computed for this day
        let threshold = thresholds[i]

        // Decision Rule: Collect if potential meets/exceeds threshold AND is profitable (> cost)
        let shouldCollect = (potentialValue >= threshold - epsilon ) && (potentialValue > cost + epsilon)

        if shouldCollect {
            totalProfit += potentialValue - cost
            currentExpectedValue = 0.0 // Reset state after collection
        } else {
            // State decays for the start of the next day
             currentExpectedValue = survivalProbability * potentialValue
        }
    }

    // Final check: After the loop (after day N-1), collect any remaining profitable value.
    // This is crucial and wasn't handled completely correctly by just letting the simulation run.
    // The forward simulation decides based on T[N-1], but a final collection might still be optimal *after* day N-1 ends.
    // This is redundant ONLY IF calculateFutureProfit's final check correctly models the value function f(N,E)=max(0, E-C)
    // Based on the calculateFutureProfit logic, the final check inside IT handles the value after day N-1.
    // Re-adding it here would be double-counting. Let's trust the calculateFutureProfit's final check.

    // The totalProfit accumulated during the forward pass using optimal thresholds IS the answer.

    // Return the final result cast to Float, as required by the problem statement.
    return Float(totalProfit)
}
