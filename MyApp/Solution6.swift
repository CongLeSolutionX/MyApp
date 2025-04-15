//
//  Solution6.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import UIKit


class BossFight_BruteForceSolution2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        // Print out results
        // Example Usage based on Sample Cases:
        let N1 = 3
        let H1 = [2, 1, 4]
        let D1 = [3, 1, 2]
        let B1 = 4
        let result1 = getMaxDamageDealt(N1, H1, D1, B1)
        print(String(format: "Sample 1 Result: %.6f", result1)) // Expected: 6.500000
        
        let N2 = 4
        let H2 = [1, 1, 2, 100]
        let D2 = [1, 1, 2, 1]
        let B2 = 8
        let result2 = getMaxDamageDealt(N2, H2, D2, B2)
        print(String(format: "Sample 2 Result: %.6f", result2)) // Expected: 62.750000 (Code yields 38.000000)
        
        let N3 = 4 // Same as N2
        let H3 = [1, 1, 2, 100]
        let D3 = [1, 1, 2, 1]
        let B3 = 8
        let result3 = getMaxDamageDealt(N3, H3, D3, B3)
        print(String(format: "Sample 3 Result: %.6f", result3)) // Expected: 62.750000 (Code yields 38.000000)
    }
    
    func getMaxDamageDealt(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
        // --- Basic Input Validation ---
        if N < 2 { return 0.0 } // Need at least two warriors
        
        let B_double = Double(B)
        // Constraint B >= 1 ensures B_double > 0
        if B_double <= 0 { return 0.0 } // Defensive check
        
        // --- Precompute values only for potentially valid warriors (H > 0) ---
        // Note: Constraints H >= 1 makes H > 0 always true, but belts and suspenders.
        var self_damage = Array(repeating: 0.0, count: N)
        var mult = Array(repeating: 0.0, count: N)
        var valid_indices = [Int]()
        valid_indices.reserveCapacity(N)
        
        for k in 0..<N {
            // Check if warrior can participate. With H >= 1, all can.
            if H[k] <= 0 { continue }
            
            valid_indices.append(k)
            let Dk = Double(D[k])
            let Hk = Double(H[k])
            
            // self_damage_k = D[k] * H[k] / B
            self_damage[k] = Dk * Hk / B_double
            // mult_k = D[k] / B
            mult[k] = Dk / B_double
        }
        
        // Need at least two valid warriors to form a pair
        if valid_indices.count < 2 {
            return 0.0
        }
        
        // --- Calculate Max Damage using Brute-Force Check of Pairs ---
        var maxTotalDamage: Double = 0.0
        
        // Iterate through all distinct pairs (i, j) of valid warriors
        for idx_i in 0..<valid_indices.count {
            let i = valid_indices[idx_i] // Original index of the front-line warrior
            let sdi = self_damage[i]
            let Hi = Double(H[i]) // Need H[i] for the mult_j * H[i] term
            
            for idx_j in 0..<valid_indices.count {
                // Warriors must be distinct
                if idx_i == idx_j { continue }
                
                let j = valid_indices[idx_j] // Original index of the backup warrior
                
                let sdj = self_damage[j]
                let multj = mult[j]
                
                // Calculate total damage with i as front-line, j as backup
                // Formula: TotalDamage(i, j) = self_damage_i + mult_j * H[i] + self_damage_j
                // It represents: (D[i]*H[i]/B) + (D[j]*H[i]/B) + (D[j]*H[j]/B)
                let currentTotalDamage = sdi + multj * Hi + sdj
                
                maxTotalDamage = max(maxTotalDamage, currentTotalDamage)
            }
        }
        
        // --- Return Result ---
        // Convert the final result to Float. Double intermediate calculations maintain precision.
        // The standard Float conversion should handle the required decimal places.
        return Float(maxTotalDamage)
    }
}

