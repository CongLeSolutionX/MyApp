////
////  Solution3.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Calculates minimum required P1 (a) for score s using <= P problems total. O(1)
//func calculate_req_a(s: Int, P: Int) -> Int {
//    // Minimum count of 1-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    // k_min is the absolute minimum number of problems (any type) to achieve score s
//    let k_min = (s + 2) / 3
//    // If even the minimum problems needed (k_min) exceeds the budget P, score s is impossible.
//    if k_min > P {
//        return Int.max // Use Int.max to signal impossibility
//    }
//    // The minimum 'a' occurs when using the fewest total problems (k_min).
//    // This minimum 'a' is max(0, 2 * k_min - s).
//    // Overflow check: 2 * k_min fits in standard 64-bit Int as k_min <= s <= 10^9.
//    return max(0, 2 * k_min - s)
//}
//
//// Calculates minimum required P2 (b) for score s using <= P problems total. O(1)
//func calculate_req_b(s: Int, P: Int) -> Int {
//    // Minimum count of 2-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    let k_min = (s + 2) / 3
//    if k_min > P {
//        return Int.max // Impossible if min problems needed > budget
//    }
//    // k_max is the max problems needed for score s (using all 1s).
//    let k_max = s
//    // k_effective_max is the actual maximum number of problems we can use, limited by P.
//    let k_effective_max = min(P, k_max)
//
//    // Sanity check: the valid range for k must exist. If k_min > k_effective_max,
//    // it implies P < k_min, which should have been caught already.
//     if k_min > k_effective_max {
//         return Int.max // Should not be reached if k_min <= P
//     }
//
//    // We want the minimum value of (s-k) % 2 over k in [k_min, k_effective_max].
//    // If the range [k_min, k_effective_max] contains more than one integer,
//    // it contains both even and odd k (relative to s's parity), making min value 0.
//    // Only if the range contains exactly one integer (k_min == k_effective_max),
//    // the result depends solely on the parity of (s - k_min).
//    let is_range_singleton = (k_min == k_effective_max)
//    // Check if (s - k_min) is odd. s - k_min is non-negative here.
//    let is_sk_odd_at_min = ((s - k_min) % 2) != 0
//
//    // If range has size 1 AND (s-k_min) is odd, we must use at least one 2-pointer (b=1).
//    // Otherwise, a combination with b=0 is possible within the allowed k range.
//    return (is_range_singleton && is_sk_odd_at_min) ? 1 : 0
//}
//
//// Calculates minimum required P3 (c) for score s using <= P problems total. O(1)
//func calculate_req_c(s: Int, P: Int) -> Int {
//    // Minimum count of 3-point problems needed for score 's' given budget 'P'.
//    if s == 0 { return 0 }
//    let k_min = (s + 2) / 3
//    if k_min > P {
//        return Int.max // Impossible
//    }
//    let k_max = s
//    let k_effective_max = min(P, k_max) // Max problems usable
//
//     if k_min > k_effective_max {
//          return Int.max // Safety check
//     }
//
//    // The minimum 'c' occurs when using the maximum allowed number of problems (k_effective_max).
//    // This minimum 'c' is max(0, s - 2 * k_effective_max).
//    // Overflow checks: 2 * k_effective_max fits in Int. The subtraction result also fits.
//    return max(0, s - 2 * k_effective_max)
//}
//
//// check(P): Determines if a total budget of 'P' problems is sufficient
//// to explain all scores in 'uniqueScores'. O(U), U = # unique scores.
//func check(_ P: Int, _ uniqueScores: [Int]) -> Bool {
//    if P < 0 { return false } // Budget must be non-negative
//
//    var P1_req = 0 // Max required 1-pointers across all scores for budget P
//    var P2_req = 0 // Max required 2-pointers
//    var P3_req = 0 // Max required 3-pointers
//
//    for s in uniqueScores {
//        if s == 0 { continue } // Score 0 requires 0 problems
//
//        // Calculate minimum requirements for this specific score 's'
//        let ra = calculate_req_a(s: s, P: P)
//        // If any score is impossible to achieve with P problems, P is not sufficient.
//        if ra == Int.max { return false }
//
//        let rb = calculate_req_b(s: s, P: P)
//        if rb == Int.max { return false } // Should be caught by ra check, but added for safety
//
//        let rc = calculate_req_c(s: s, P: P)
//        if rc == Int.max { return false } // Should be caught by ra check
//
//        // Update the overall maximum requirements needed for the contest
//        P1_req = max(P1_req, ra)
//        P2_req = max(P2_req, rb)
//        P3_req = max(P3_req, rc)
//
//        // Early Exit Optimization: Check if the sum of maximum requirements already exceeds P.
//        // Use addingReportingOverflow for safe addition.
//        let p1p2Check = P1_req.addingReportingOverflow(P2_req)
//        if p1p2Check.overflow { return false } // Sum is too large
//
//        let p1p2p3Check = p1p2Check.partialValue.addingReportingOverflow(P3_req)
//        if p1p2p3Check.overflow { return false } // Sum is too large
//
//        // If the total required problems exceed the budget P, P is insufficient.
//        if p1p2p3Check.partialValue > P {
//            return false
//        }
//    }
//
//    // If the loop completes without returning false, it means a contest with
//    // P1_req ones, P2_req twos, and P3_req threes (total <= P) can satisfy all scores.
//    // The final check below is redundant due to the early exit but confirms the condition.
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
//    // Get unique positive scores. Set is efficient for this.
//    let uniquePositiveScores = Array(Set(S.filter { $0 > 0 }))
//
//    // If no positive scores, 0 problems are needed.
//    if uniquePositiveScores.isEmpty { return 0 }
//
//    // Find the maximum score, required for binary search upper bound.
//    // Force unwrap is safe because uniquePositiveScores is not empty.
//    let maxScore = uniquePositiveScores.max()!
//
//    // Binary search for the minimum P.
//    var low = 0          // Lower bound for P
//    var high = maxScore  // Upper bound for P (safe, achievable with all 1s)
//    var ans = high       // Initialize answer to the safe upper bound
//
//    while low <= high {
//        let mid = low + (high - low) / 2 // Prevent potential overflow
//
//        // Check if 'mid' problems are sufficient.
//        if check(mid, uniquePositiveScores) {
//            // If yes, 'mid' is a possible answer. Try searching for a smaller P.
//            ans = mid
//            high = mid - 1
//        } else {
//            // If no, 'mid' is too small. Need more problems.
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
