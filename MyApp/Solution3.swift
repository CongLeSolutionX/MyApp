//
//  Solution3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {
    var totalSeconds = 0
    var discs = R

    // iterate from top to bottom starting from second disc (disc index 1)
    for i in 1..<N {
        if discs[i - 1] >= discs[i] {
            let requiredAdjustment = discs[i - 1] - discs[i] + 1
            
            if discs[i] - requiredAdjustment > 0 {  // safe deflation
                discs[i] -= requiredAdjustment
                totalSeconds += requiredAdjustment * B
            } else {                               // forced inflation
                discs[i - 1] += requiredAdjustment
                totalSeconds += requiredAdjustment * A
                
                // IMPORTANT: Back-propagate upward if necessary
                var j = i - 1
                while j > 0 && discs[j - 1] >= discs[j] {
                    let adj = discs[j - 1] - discs[j] + 1
                    discs[j - 1] += adj
                    totalSeconds += adj * A
                    j -= 1
                }
            }
        }
    }
    return totalSeconds
}
//
//// Checking provided test cases:
//print(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1)) // expect 5
//print(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))// expect 5
//print(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))// expect 9
//print(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))  // expect 19
//print(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))// expect 207
//print(getMinimumSecondsRequired(6, [6,5,2,4,4,7],1,1))    // expect 10
