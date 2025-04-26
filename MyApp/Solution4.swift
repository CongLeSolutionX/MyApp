////
////  Solution4.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Calculates minimum required P1 (a) for score s using <= P problems total. O(1)
//private func calculate_req_a(s: Int, P: Int) -> Int {
//    // Minimum count of 1-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    let k_min = (s + 2) / 3 // Min problems needed for score s
//    if k_min > P {
//        return Int.max // Impossible if min problems needed > budget P
//    }
//    // The minimum 'a' required occurs when using the fewest total problems (k_min).
//    return max(0, 2 * k_min - s)
//}
//
//// Calculates minimum required P2 (b) for score s using <= P problems total. O(1)
//private func calculate_req_b(s: Int, P: Int) -> Int {
//    // Minimum count of 2-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    let k_min = (s + 2) / 3
//    if k_min > P {
//        return Int.max
//    }
//    let k_max = s // Max problems needed is s (all 1s)
//    // Effective max problems we can use is limited by P
//    let k_effective_max = min(P, k_max)
//
//    // If the allowed range [k_min, k_effective_max] is invalid (shouldn't happen if k_min <= P)
//    if k_min > k_effective_max {
//        return Int.max
//    }
//
//    // We need min( (s-k) % 2 ) for k in [k_min, k_effective_max]
//    // If range has >1 element, min is 0. If range has 1 element k_min, min is (s-k_min)%2.
//    let is_range_singleton = (k_min == k_effective_max)
//    let sk_parity_differs = ((s - k_min) % 2) != 0 // True if s-k_min is odd
//
//    // Min b is 1 only if range is size 1 AND s, k_min have different parity
//    return (is_range_singleton && sk_parity_differs) ? 1 : 0
//}
//
//// Calculates minimum required P3 (c) for score s using <= P problems total. O(1)
//private func calculate_req_c(s: Int, P: Int) -> Int {
//    // Minimum count of 3-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    let k_min = (s + 2) / 3
//    if k_min > P {
//        return Int.max
//    }
//    let k_max = s
//    let k_effective_max = min(P, k_max) // Max problems usable
//
//    if k_min > k_effective_max {
//         return Int.max
//    }
//
//    // The minimum 'c' required occurs when using the maximum allowed problems (k_effective_max).
//    return max(0, s - 2 * k_effective_max)
//}
//
//// check(P): Determines if a total budget of 'P' problems is sufficient
//// to explain all scores in 'uniquePositiveScores'. O(U), U = # unique positive scores.
//private func check(_ P: Int, _ uniquePositiveScores: [Int]) -> Bool {
//    if P < 0 { return false } // Budget must be non-negative
//
//    var P1_req = 0 // Max required 1-pointers across all scores for budget P
//    var P2_req = 0 // Max required 2-pointers
//    var P3_req = 0 // Max required 3-pointers
//
//    for s in uniquePositiveScores {
//        // Calculate minimum requirements for this score 's' given budget 'P'
//        let ra = calculate_req_a(s: s, P: P)
//        if ra == Int.max { return false } // Score s impossible with P problems
//
//        let rb = calculate_req_b(s: s, P: P)
//        if rb == Int.max { return false } // Should not happen if ra != Int.max
//
//        let rc = calculate_req_c(s: s, P: P)
//        if rc == Int.max { return false } // Should not happen if ra != Int.max
//
//        // Update the overall maximum count needed for each problem type
//        P1_req = max(P1_req, ra)
//        P2_req = max(P2_req, rb)
//        P3_req = max(P3_req, rc)
//
//        // Early Exit Optimization: Check if the current sum of max requirements exceeds P
//        // Use addingReportingOverflow for safe addition, guarding against Int overflow.
//        let p1p2Check = P1_req.addingReportingOverflow(P2_req)
//        if p1p2Check.overflow { return false } // Sum exceeds Int.max, therefore > P
//
//        let p1p2p3Check = p1p2Check.partialValue.addingReportingOverflow(P3_req)
//        if p1p2p3Check.overflow { return false } // Sum exceeds Int.max, therefore > P
//
//        // If the total required problems exceed the budget P, P is insufficient.
//        if p1p2p3Check.partialValue > P {
//            return false
//        }
//    }
//
//    // If loop finishes, P is large enough to satisfy the requirements for all scores.
//    // The final check below is redundant due to the early exit, but confirms the logic.
//    let final_p1p2 = P1_req.addingReportingOverflow(P2_req)
//    if final_p1p2.overflow { return false }
//    let final_p1p2p3 = final_p1p2.partialValue.addingReportingOverflow(P3_req)
//    if final_p1p2p3.overflow { return false }
//
//    return final_p1p2p3.partialValue <= P
//}
//
//// Main function to find the minimum problem count.
//public func getMinProblemCount(_ N: Int, _ S: [Int]) -> Int {
//    // Filter out 0s and get unique positive scores. Set is efficient.
//    let uniquePositiveScores = Array(Set(S.filter { $0 > 0 }))
//
//    // If no positive scores exist, 0 problems are needed.
//    if uniquePositiveScores.isEmpty { return 0 }
//
//    // Find max score for binary search upper bound. Force unwrap safe as list isn't empty.
//    let maxScore = uniquePositiveScores.max()!
//
//    // Binary search for the minimum P.
//    var low = 0          // Lower bound for P test
//    var high = maxScore  // Upper bound (safe, achievable with maxScore 1s)
//    var ans = high       // Initialize answer to the safe upper bound
//
//    while low <= high {
//        // Calculate midpoint safely to avoid overflow
//        let mid = low + (high - low) / 2
//
//        // Check if 'mid' problems are sufficient.
//        if check(mid, uniquePositiveScores) {
//            // If yes, 'mid' is a potential answer. Store it and
//            // try searching for a smaller P in the lower half.
//            ans = mid
//            high = mid - 1
//        } else {
//            // If no, 'mid' is too small. Need more problems. Search upper half.
//            low = mid + 1
//        }
//    }
//
//    // 'ans' holds the smallest value of 'mid' for which check() returned true.
//    return ans
//}
