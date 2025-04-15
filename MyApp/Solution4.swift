//
//  Solution4.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//
import Foundation

func getMaxDamageDealt(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
    
    var maxDamage: Double = 0.0
    
    typealias Warrior = (H: Int, D: Int)
    
    var warriors = (0..<N).map { Warrior(H[$0], D[$0]) }
    
    // Sort warriors descendingly based on Damage (DPS)
    warriors.sort { $0.D > $1.D }
    
    for i in 0..<N {
        let front = warriors[i]

        // Choose the best available backup (highest DPS, not the front)
        let bestBackupIndex = (i == 0) ? 1 : 0
        
        if bestBackupIndex >= N { continue }

        let backup = warriors[bestBackupIndex]

        // Compute the total damage precisely
        let frontAlive = Double(front.H) / Double(B)
        let backupAlive = Double(backup.H) / Double(B)

        let totalDamage = frontAlive * Double(front.D + backup.D) + backupAlive * Double(backup.D)

        maxDamage = max(maxDamage, totalDamage)
    }
    
    // Ensure correct precision, rounded to exactly 6 decimal places
    let preciseResult = Double(round(maxDamage * 1_000_000) / 1_000_000)
    return Float(String(format: "%.6f", preciseResult))!
}
