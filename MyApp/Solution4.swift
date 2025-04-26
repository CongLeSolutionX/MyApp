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
////
////// ------------ Testing with Samples ---------------
////// Sample 1: N = 5, S = [1, 2, 3, 4, 5] -> Expected: 3
////print("Sample 1: \(getMinProblemCount(5, [1, 2, 3, 4, 5]))")
////
////// Sample 2: N = 4, S = [4, 3, 3, 4] -> Expected: 2
////print("Sample 2: \(getMinProblemCount(4, [4, 3, 3, 4]))")
////
////// Sample 3: N = 4, S = [2, 4, 6, 8] -> Expected: 3
////print("Sample 3: \(getMinProblemCount(4, [2, 4, 6, 8]))")
////
////// Sample 4: N = 1, S = [8] -> Expected: 3
////print("Sample 4: \(getMinProblemCount(1, [8]))")
////
////// Additional Test Cases
////// All zeros
////print("Test All Zeros: \(getMinProblemCount(3, [0, 0, 0]))") // Expected: 0
////// Empty
////print("Test Empty: \(getMinProblemCount(0, []))") // Expected: 0
////// Single large score
////print("Test Large Single: \(getMinProblemCount(1, [15]))") // k_min = 5. req_a(15,5)=0, req_b(15,5)=0, req_c(15,5)=max(0, 15-2*5)=5. Sum=5. check(5)=T. check(4)=F. Expected: 5
////// Needs b=1 case: s=5, P=k_min=2. k_eff_max=2. range=[2,2]. s-k_min=3 (odd). req_b=1.
////// req_a(5,2)=max(0, 2*2-5)=0. req_c(5,2)=max(0, 5-2*min(2,5))=max(0,5-4)=1. P1=0,P2=1,P3=1. Sum=2<=P. check(2)=T.
////print("Test b=1 case: \(getMinProblemCount(1, [5]))") // Expected: 2
////// Needs a=1 case: s=1, P=k_min=1. k_eff_max=1. range=[1,1]. s-k_min=0 (even). req_b=0.
////// req_a(1,1)=max(0, 2*1-1)=1. req_c(1,1)=max(0, 1-2*min(1,1))=max(0,1-2)=0. P1=1,P2=0,P3=0. Sum=1<=P. check(1)=T. check(0)=F.
////print("Test a=1 case: \(getMinProblemCount(1, [1]))") // Expected: 1
