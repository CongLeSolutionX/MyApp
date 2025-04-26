//
//  Solution5.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

import Foundation

// Calculates minimum required P1 (a) for score s using <= P problems total. O(1)
private func calculate_req_a(s: Int, P: Int) -> Int {
    if s == 0 { return 0 }
    let k_min = (s + 2) / 3 // Min problems needed for score s
    if k_min > P {
        return Int.max // Impossible if min problems needed > budget P
    }
    return max(0, 2 * k_min - s)
}

// Calculates minimum required P2 (b) for score s using <= P problems total. O(1)
private func calculate_req_b(s: Int, P: Int) -> Int {
    if s == 0 { return 0 }
    let k_min = (s + 2) / 3
    if k_min > P {
        return Int.max
    }
    let k_max = s
    let k_effective_max = min(P, k_max)

    if k_min > k_effective_max {
        // This case means P < k_min, which is already checked.
        // If somehow reached, indicates an issue, return impossible.
        return Int.max
    }

    // We need min( (s-k) % 2 ) for k in [k_min, k_effective_max]
    // Minimum is 0 if range has >1 element, else depends on parity at k_min.
    let is_range_singleton = (k_min == k_effective_max)
    let sk_parity_differs = ((s - k_min) % 2) != 0 // True if s-k_min is odd

    return (is_range_singleton && sk_parity_differs) ? 1 : 0
}

// Calculates minimum required P3 (c) for score s using <= P problems total. O(1)
private func calculate_req_c(s: Int, P: Int) -> Int {
    if s == 0 { return 0 }
    let k_min = (s + 2) / 3
    if k_min > P {
        return Int.max
    }
    let k_max = s
    let k_effective_max = min(P, k_max) // Max problems usable

    if k_min > k_effective_max {
         return Int.max
    }

    // Min 'c' occurs when using max allowed problems (k_effective_max).
    return max(0, s - 2 * k_effective_max)
}

// check(P): Determines if a budget of 'P' problems is sufficient
// based on the derived necessary condition. O(U), U = # unique positive scores.
private func check(_ P: Int, _ uniquePositiveScores: [Int]) -> Bool {
    if P < 0 { return false }

    var P1_req = 0 // Max required 1-pointers across all scores
    var P2_req = 0 // Max required 2-pointers
    var P3_req = 0 // Max required 3-pointers

    for s in uniquePositiveScores {
        let ra = calculate_req_a(s: s, P: P)
        if ra == Int.max { return false } // Score s impossible with P problems

        let rb = calculate_req_b(s: s, P: P)
        if rb == Int.max { return false } // Should not happen if ra != Int.max

        let rc = calculate_req_c(s: s, P: P)
        if rc == Int.max { return false } // Should not happen if ra != Int.max

        P1_req = max(P1_req, ra)
        P2_req = max(P2_req, rb)
        P3_req = max(P3_req, rc)

        // Removed the early exit based on triple sum for clarity,
        // as the final check covers it. The pairwise checks derived
        // earlier were also shown to be potentially insufficient or misleading.
        // Sticking to the logic that the sum of max requirements must fit P.
    }

    // Final check: Does the sum of maximum required counts fit within budget P?
    // Use overflow checking for safety.
    let p1p2 = P1_req.addingReportingOverflow(P2_req)
    if p1p2.overflow { return false } // Cannot fit if sum overflows Int

    let p1p2p3 = p1p2.partialValue.addingReportingOverflow(P3_req)
    if p1p2p3.overflow { return false } // Cannot fit if sum overflows Int

    return p1p2p3.partialValue <= P
}

// Main function to find the minimum problem count.
public func getMinProblemCount(_ N: Int, _ S: [Int]) -> Int {
    let uniquePositiveScores = Array(Set(S.filter { $0 > 0 }))
    if uniquePositiveScores.isEmpty { return 0 }
    let maxScore = uniquePositiveScores.max()!

    var low = 0
    var high = maxScore
    var ans = high

    // Calculate max_k_min to potentially tighten the lower bound of search?
    // Optional optimization: Adjust 'low' initial value.
    // var max_k_min_overall = 0
    // for s in uniquePositiveScores {
    //     max_k_min_overall = max(max_k_min_overall, (s + 2) / 3)
    // }
    // low = max_k_min_overall // Start search from the absolute minimum required problems.

    while low <= high {
        let mid = low + (high - low) / 2
        if check(mid, uniquePositiveScores) {
            ans = mid
            high = mid - 1 // Try smaller P
        } else {
            low = mid + 1 // Need larger P
        }
    }
    return ans
}
