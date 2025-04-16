//
//  Solution4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

func getMinimumSecondsRequired(_ N: Int, _ R: [Int], _ A: Int, _ B: Int) -> Int {
    var totalSeconds = 0
    var discs = R

    for i in stride(from: N - 2, through: 0, by: -1) {
        // If current disc not strictly smaller than one below
        if discs[i] >= discs[i + 1] {
            // Option 1: Inflate disc below (i+1) to discs[i]+1
            let costInflateBelow = (discs[i] - discs[i + 1] + 1) * A

            // Option 2: Deflate current disc (i) to discs[i+1]-1, ensure positive radius
            let requiredDeflate = discs[i] - (discs[i + 1] - 1)
            
            // Option (2) deflation only possible if resulting disc[i] > 0
            let costDeflateCurrent = (requiredDeflate <= discs[i] - 1 && discs[i + 1] > 1) ? requiredDeflate * B : Int.max
            
            if costInflateBelow <= costDeflateCurrent {
                discs[i + 1] += (discs[i] - discs[i + 1] + 1)
                totalSeconds += costInflateBelow
            } else {
                discs[i] -= requiredDeflate
                totalSeconds += costDeflateCurrent
            }
        }
    }

    return totalSeconds
}

//// Official Test Case Check again:
//print(getMinimumSecondsRequired(5, [2,5,3,6,5], 1, 1))  // Expected: 5
//print(getMinimumSecondsRequired(3, [100,100,100], 2, 3))// Expected: 5
//print(getMinimumSecondsRequired(3, [100,100,100], 7, 3))// Expected: 9
//print(getMinimumSecondsRequired(4, [6,5,4,3], 10, 1))   // Expected: 19
//print(getMinimumSecondsRequired(4, [100,100,1,1], 2,1)) // Expected: 207
//print(getMinimumSecondsRequired(6,[6,5,2,4,4,7],1,1))   // Expected: 10
