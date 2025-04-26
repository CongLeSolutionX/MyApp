////
////  Solution2.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Calculates minimum required a for score s using <= P problems total. O(s)
//func calculate_req_a(s: Int, P: Int) -> Int {
//    // req_a(s, P): min a s.t. s=a+2b+3c, k=a+b+c <= P.
//    var min_a_found = Int.max
//    var possible = false
//    // Iterate c from s/3 down to 0. rem = s-3c.
//    // The rep with max b for this c is (a=rem%2, b=rem/2, c).
//    for c in stride(from: s / 3, through: 0, by: -1) {
//        let rem = s - 3 * c
//        if rem < 0 { continue } // Should not happen
//
//        let a = rem % 2
//        let b = rem / 2
//        let k = a + b + c
//
//        if k <= P {
//            min_a_found = min(min_a_found, a)
//            possible = true
//            // Optimization: if we find a=0, we can't do better.
//             if min_a_found == 0 { break }
//        }
//    }
//    return possible ? min_a_found : Int.max
//}
//
//// Calculates minimum required b for score s using <= P problems total. O(s)
//func calculate_req_b(s: Int, P: Int) -> Int {
//    // req_b(s, P): min b s.t. s=a+2b+3c, k=a+b+c <= P.
//    var min_b_found = Int.max
//    var possible = false
//    // Iterate c from s/3 down to 0. rem = s-3c.
//    // Smallest b for rem=a+2b is 0, using a=rem.
//    // Check if k = a+b+c = rem+0+c <= P.
//    for c in stride(from: s / 3, through: 0, by: -1) {
//         let rem = s - 3 * c
//         if rem < 0 { continue }
//
//         let k = rem + 0 + c // Using b=0, a=rem
//         if k <= P {
//              min_b_found = min(min_b_found, 0)
//              possible = true
//              // Optimization: if we find b=0, we can't do better.
//              break
//         }
//         // If b=0 didn't work, try minimal b > 0.
//         // The next smallest b is 1 (if rem is odd). a=rem-2
//         if rem >= 2 { // Need rem=a+2b, min b for a given c
//             // Find the smallest b = k' >= 0 such that a = rem - 2k' >= 0 and a+b+c <= P
//             // => (rem - 2k') + k' + c <= P => rem - k' + c <= P => k' >= rem + c - P
//             let required_b = rem + c - P
//             if required_b <= rem / 2 { // Check if a feasible k' exists (k' <= max b = rem/2)
//                 let actual_b = max(0, required_b) // Need b>=0
//                  // Double check a = rem - 2*actual_b >= 0
//                 if rem >= 2 * actual_b {
//                     min_b_found = min(min_b_found, actual_b)
//                     possible = true
//                 }
//             }
//         }
//    }
//     // Fallback just in case the logic above missed something (it shouldn't)
//     // Revert to O(s^2) check for b if needed, but let's trust O(s) for now.
//
//    return possible ? min_b_found : Int.max
//}
//
//// Calculates minimum required c for score s using <= P problems total. O(s)
//func calculate_req_c(s: Int, P: Int) -> Int {
//    // req_c(s, P): min c s.t. s=a+2b+3c, k=a+b+c <= P.
//    var min_c_found = Int.max
//    var possible = false
//    // Iterate b from s/2 down to 0. rem = s-2b.
//    // Smallest c for rem=a+3c is 0, using a=rem.
//    // Check if k = a+b+c = rem+b+0 <= P.
//    for b in stride(from: s / 2, through: 0, by: -1) {
//        let rem = s - 2 * b
//        if rem < 0 { continue }
//
//        let k = rem + b + 0 // Using c=0, a=rem
//        if k <= P {
//            min_c_found = min(min_c_found, 0)
//            possible = true
//             // Optimization: if we find c=0, we can't do better.
//            break
//        }
//         // If c=0 didn't work, try minimal c > 0.
//         // Find the smallest c = k' >= 0 such that a = rem - 3k' >= 0 and a+b+c <= P
//         // => (rem - 3k') + b + k' <= P => rem + b - 2k' <= P => 2k' >= rem + b - P
//         let required_2k = rem + b - P
//         if required_2k <= rem { // Max possible 2k is roughly 2/3 rem, so check vs rem
//              let k_potential = (required_2k + 1) / 2 // Equivalent to ceil(required_2k / 2.0)
//              let actual_c = max(0, k_potential)
//              // Ensure a = rem - 3*actual_c >= 0
//              if rem >= 3 * actual_c {
//                   min_c_found = min(min_c_found, actual_c)
//                   possible = true
//              }
//         }
//    }
//    return possible ? min_c_found : Int.max
//}
//
//// Optimized check(P) function using O(s) helpers
//// Complexity: O(N * max(S))
//func checkOptimized(_ P: Int, _ scores: [Int]) -> Bool {
//    // P must be non-negative
//    if P < 0 { return false }
//
//    var P1_req = 0
//    var P2_req = 0
//    var P3_req = 0
//
//    for s in scores {
//        // Basic check: Need at least ceil(s/3.0) problems for score s
//        let minProblemsForS = (s + 2) / 3
//        if minProblemsForS > P { return false }
//
//        // Calculate required counts using O(s) methods
//        let ra = calculate_req_a(s: s, P: P)
//        if ra == Int.max { return false } // Score s cannot be formed with P problems
//
//        let rb = calculate_req_b(s: s, P: P)
//        if rb == Int.max { return false }
//
//        let rc = calculate_req_c(s: s, P: P)
//        if rc == Int.max { return false }
//
//        P1_req = max(P1_req, ra)
//        P2_req = max(P2_req, rb)
//        P3_req = max(P3_req, rc)
//
//        // Early exit optimization (check for potential overflow first)
//        let p1p2Check = P1_req.addingReportingOverflow(P2_req)
//        if p1p2Check.overflow { return false }
//        let p1p2p3Check = p1p2Check.partialValue.addingReportingOverflow(P3_req)
//        if p1p2p3Check.overflow { return false }
//
//        if p1p2p3Check.partialValue > P {
//            return false
//        }
//    }
//
//    // Final check after processing all scores
//    let p1p2 = P1_req.addingReportingOverflow(P2_req)
//    if p1p2.overflow { return false }
//    let p1p2p3 = p1p2.partialValue.addingReportingOverflow(P3_req)
//    if p1p2p3.overflow { return false }
//
//    return p1p2p3.partialValue <= P
//}
//
//// Main function using Binary Search with OPTIMIZED check
//public func getMinProblemCount(_ N: Int, _ S: [Int]) -> Int {
//    if S.isEmpty { return 0 }
//
//    // Using Set to get unique scores might slightly speed up the check function if many duplicates
//    let uniqueScores = Array(Set(S))
//    guard let maxScore = uniqueScores.max() else { return 0} // Handle empty case (already done)
//    if maxScore == 0 { return 0 }
//
//    var low = 0
//    var high = maxScore // Safe upper bound
//    var ans = high
//
//    while low <= high {
//        let mid = low + (high - low) / 2
//        if checkOptimized(mid, uniqueScores) { // Use unique scores
//            ans = mid
//            high = mid - 1
//        } else {
//            low = mid + 1
//        }
//    }
//
//    return ans
//}
