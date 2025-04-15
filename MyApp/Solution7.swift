//
//  Solution7.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import UIKit

// MARK: - Brute force solution

class BossFight_BruteForceSolution: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        // Print out results
        let expected_Return_Value_1 = getMaxDamageDealt_BruteForce(3, [2, 1, 4], [3, 1, 2], 4)
        let expected_Return_Value_2 = getMaxDamageDealt_BruteForce(4, [1, 1, 2, 100], [1, 2, 1, 3], 8)
        let expected_Return_Value_3 = getMaxDamageDealt_BruteForce(4, [1, 1, 2, 3], [1, 2, 1, 100], 8)
        print("\(expected_Return_Value_1)")
        print("\(expected_Return_Value_2)")
        print("\(expected_Return_Value_3)")
    }
    
    // Function to calculate damage for a specific (i, j) pair
    func calculateDamage(i: Int, j: Int, H: [Int], D: [Int], B: Int) -> Double {
        let H_i = Double(H[i])
        let H_j = Double(H[j])
        let D_i = Double(D[i])
        let D_j = Double(D[j])
        let B_double = Double(B)
        
        if B_double == 0 { return Double.infinity } // Avoid division by zero, though constraints say B >= 1
        
        // Using the simplified formula:
        let self_damage_i = D_i * H_i / B_double
        let self_damage_j = D_j * H_j / B_double
        let mult_j = D_j / B_double
        
        let totalDamage = self_damage_i + mult_j * H_i + self_damage_j
        return totalDamage
        
        /* // Original formula derivation check:
         let time_i = H_i / B_double
         let time_j = H_j / B_double
         let damage_phase1 = (D_i + D_j) * time_i
         let damage_phase2 = D_j * time_j
         return damage_phase1 + damage_phase2
         */
    }
    
    // Brute-force main function (Conceptual)
    func getMaxDamageDealt_BruteForce(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
        var maxDamage: Double = 0.0
        
        for i in 0..<N {
            for j in 0..<N {
                if i == j { continue } // Warriors must be distinct
                
                let currentDamage = calculateDamage(i: i, j: j, H: H, D: D, B: B)
                maxDamage = max(maxDamage, currentDamage)
            }
        }
        return Float(maxDamage)
    }
}

