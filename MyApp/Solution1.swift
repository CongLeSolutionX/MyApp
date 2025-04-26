//
//  Solution1.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

import Foundation // Not essential for core logic, but good practice

/// Calculates the minimal representation (a, b, c) for a score s
/// such that s = 1*a + 2*b + 3*c and a+b+c (problems) is minimized.
/// - Parameter s: The target score (must be >= 0).
/// - Returns: A tuple containing the counts (a, b, c) and the minimum number of problems p.
func getMinRepresentation(_ s: Int) -> (a: Int, b: Int, c: Int, p: Int) {
    // Greedily use as many 3s as possible
    let c = s / 3
    let rem1 = s % 3 // Remainder after using 3s (0, 1, or 2)

    // Greedily use as many 2s as possible from the remainder
    let b = rem1 / 2
    let rem2 = rem1 % 2 // Remainder after using 2s (0 or 1)

    // The rest must be covered by 1s
    let a = rem2

    // The minimum number of problems for score s
    let p = a + b + c
    return (a, b, c, p)
}

/// Finds the minimum possible number of problems in the contest.
/// - Parameters:
///   - N: The number of competitors (unused in the final algorithm, but part of input).
///   - S: An array of scores for each competitor (S_i > 0).
/// - Returns: The minimum possible number of problems.
public func getMinProblemCount(_ N: Int, _ S: [Int]) -> Int {
    // Constraints state N >= 1 and S_i >= 1, so empty check is defensive.
    if S.isEmpty {
        return 0
    }

    // p0: The max of the minimum problems needed *individually* for each score.
    var p0 = 0
    // Pa, Pb, Pc: Max count of 1s, 2s, 3s needed across all *minimal* representations.
    var Pa = 0
    var Pb = 0
    var Pc = 0

    for score in S {
         // Calculate the minimal representation (a,b,c) and min problems (p) for the current score
        let rep = getMinRepresentation(score)

        // Update p0: The Overall minimum P must be at least the max individual minimum P.
        p0 = max(p0, rep.p)

        // Update Pa, Pb, Pc: Track the max resource needed for each point value
        // based *only* on these minimal representations f(si).
        Pa = max(Pa, rep.a)
        Pb = max(Pb, rep.b)
        Pc = max(Pc, rep.c)
    }

    // P_test: The total problems required by the specific configuration (Pa, Pb, Pc).
    // This configuration is guaranteed to work for all scores Si because it covers
    // their minimal representation f(Si). Thus, P_ans <= P_test.
    let P_test = Pa + Pb + Pc

    // We have p0 <= P_ans <= P_test. The hypothesis/observation is P_ans = max(p0, P_test).
    return max(p0, P_test)
}

//// --- Testing with Sample Cases ---
//
//// Sample 1
//let N1 = 5
//let S1 = [1, 2, 3, 4, 5]
//print("Sample 1: \(getMinProblemCount(N1, S1))") // Expected: 3
//
//// Sample 2
//let N2 = 4
//let S2 = [4, 3, 3, 4]
//print("Sample 2: \(getMinProblemCount(N2, S2))") // Expected: 2
//
//// Sample 3
//let N3 = 4
//let S3 = [2, 4, 6, 8]
//print("Sample 3: \(getMinProblemCount(N3, S3))") // Expected: 4
//
//// Sample 4
//let N4 = 1
//let S4 = [8]
//print("Sample 4: \(getMinProblemCount(N4, S4))") // Expected: 3
