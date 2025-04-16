//
//  Solution5.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {
    var discs = R
    var totalSeconds = 0
    
    for i in 1..<N {
        if discs[i] >= discs[i - 1] {
            // must strictly decrease downward, calculate deflate required clearly
            let target = discs[i - 1] - 1
            if target >= 1 {
                // safe deflation downward
                let deflate = discs[i] - target
                totalSeconds += deflate * B
                discs[i] = target
            } else {
                // forced inflation upward, carefully chain back if needed
                let inflate = discs[i] - discs[i - 1] + 1
                totalSeconds += inflate * A
                discs[i - 1] += inflate
                
                // IMPORTANT: Chain backward if needed:
                var j = i - 1
                while j > 0 && discs[j] >= discs[j - 1] {
                    let extraInflate = discs[j] - discs[j - 1] + 1
                    discs[j - 1] += extraInflate
                    totalSeconds += extraInflate * A
                    j -= 1
                }
            }
        }
    }
    return totalSeconds
}
//
//// Verify explicitly provided examples (official test cases):
//print(getMinimumSecondsRequired(5, [2,5,3,6,5], 1, 1))   // Expected Output: 5
//print(getMinimumSecondsRequired(3, [100,100,100], 2, 3)) // Expected Output: 5
//print(getMinimumSecondsRequired(3, [100,100,100], 7, 3)) // Expected Output: 9
//print(getMinimumSecondsRequired(4, [6,5,4,3], 10, 1))    // Expected Output: 19
//print(getMinimumSecondsRequired(4,[100,100,1,1],2, 1))   // Expected Output: 207
//print(getMinimumSecondsRequired(6,[6,5,2,4,4,7],1,1))    // Expected Output: 10
