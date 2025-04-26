//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        runSolution()
    }
    
    func runSolution() {
        
        // --- Testing with Sample Cases ---
        print("Sample 1: Expected 5, Got: \(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1))")
        print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))") // Corrected R' is [98, 99, 100] -> Cost (100-98)*3 + (100-99)*3 + 0 = 6+3=9. Hmm, example says 5? Let's re-read. Example 2 explanation: Deflate [100] to 99 (cost 3), Inflate [100] to 101 (cost 2). R'=[?,99,101]. Maybe R'=[98,99,101]? Cost (100-98)*3 + (100-99)*3 + (101-100)*2 = 6+3+2 = 11. Example 2 explanation says: *deflating disc 1 from 100" to 99" (taking 3 seconds) and inflating disc 3 from 100" to 101" (taking 2 seconds)*. This means R'=[100, 99, 101]. This IS NOT STABLE! 100 is not < 99. There might be an error in the example explanation or my understanding for Case 2. Let's trust the DP logic. DP gives 9 for R'=[98,99,100]. Let's check R'=[99,100,101]. Cost (100-99)*3 + 0 + (101-100)*2 = 3+2=5. OK, R'=[99,100,101] is stable and costs 5. The DP should find this. Let's trace DP for case 2. V=[98,99,100].
        // Trace Case 2: N=3, R=[100,100,100], A=2, B=3. V=[98,99,100] (M=3)
        // i=0: R[0]=100. S[0]>=1.
        //   k=0, V=98: R'=98. Cost=(100-98)*3=6. dp[0][0]=6
        //   k=1, V=99: R'=99. Cost=(100-99)*3=3. dp[0][1]=3
        //   k=2, V=100: R'=100. Cost=0. dp[0][2]=0
        // i=1: R[1]=100. S[1]>=0. V=[98,99,100] all >=0.
        //   min_prev = [6, 3, 0]
        //   k=0, V=98: R'=98+1=99. Cost=(100-99)*3=3. prev_min=min_prev[0]=6. dp[1][0]=3+6=9
        //   k=1, V=99: R'=99+1=100. Cost=0. prev_min=min_prev[1]=3. dp[1][1]=0+3=3
        //   k=2, V=100: R'=100+1=101. Cost=(101-100)*2=2. prev_min=min_prev[2]=0. dp[1][2]=2+0=2
        // i=2: R[2]=100. S[2]>=-1. V=[98,99,100] all >=-1.
        //   min_prev = [9, 3, 2]
        //   k=0, V=98: R'=98+2=100. Cost=0. prev_min=min_prev[0]=9. dp[2][0]=0+9=9
        //   k=1, V=99: R'=99+2=101. Cost=(101-100)*2=2. prev_min=min_prev[1]=3. dp[2][1]=2+3=5
        //   k=2, V=100: R'=100+2=102. Cost=(102-100)*2=4. prev_min=min_prev[2]=2. dp[2][2]=4+2=6
        // Final min(dp[2]) = min(9, 5, 6) = 5. OK, the DP logic works and matches Sample 2's expected value.

        print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))")
        print("Sample 3: Expected 9, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))")
        print("Sample 4: Expected 19, Got: \(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))")
        print("Sample 5: Expected 207, Got: \(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))")
        print("Sample 6: Expected 10, Got: \(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1))")

    }
}
