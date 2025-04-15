//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

import Foundation // Needed for potentially large number calculations if not using Double directly

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = BossFight_BruteForceSolution
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> BossFight_BruteForceSolution {
        // Step 1c: Instantiate and return the UIKit view controller
        return BossFight_BruteForceSolution()
    }
    
    func updateUIViewController(_ uiViewController: BossFight_BruteForceSolution, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
        
//        let bossFightSolution = BossFightSolution()
//        
//        let expected_Return_Value_1 = bossFightSolution.getMaxDamageDealt_OptimizedStructure(3, [2, 1, 4], [3, 1, 2], 4)
//        let expected_Return_Value_2 = bossFightSolution.getMaxDamageDealt_OptimizedStructure(4, [1, 1, 2, 100], [1, 2, 1, 3], 8)
//        let expected_Return_Value_3 = bossFightSolution.getMaxDamageDealt_OptimizedStructure(4, [1, 1, 2, 3], [1, 2, 1, 100], 8)
//        
//        print("Expected Return Value = \(expected_Return_Value_1)")
//        print("Expected Return Value = \(expected_Return_Value_2)")
//        print("Expected Return Value = \(expected_Return_Value_3)")
        
    }
}



class BossFightSolution {
    // ---- Data Structures for Optimized Solution ----
    
    // Represents the line y = m*x + c for a warrior's contribution as backup
    // x = H[i] (front-liner's health)
    struct Line {
        let m: Double // mult_j = D[j] / B
        let c: Double // self_damage_j = D[j] * H[j] / B
        let originalIndex: Int // Original warrior index 'j'
        
        func eval(at x: Double) -> Double {
            return m * x + c
        }
        
        // A negligible line to represent empty nodes/results or invalid warriors
        static let negligible = Line(m: 0.0, c: -Double.infinity, originalIndex: -1)
    }
    
    // Node for the Li Chao Tree segment tree (stores *indices* into the lines array)
    // This simplified version only stores the single best line index.
    // A full solution needs modification for Top-2.
    struct LiChaoTreeNode {
        var lineIndex: Int = -1 // Index into the 'lines' array
    }
    
    // Li Chao Tree Implementation (Top-1 ONLY - for structure reference)
    // A full Top-2 implementation is significantly more complex.
    class LiChaoTree_Top1 {
        private var tree: [LiChaoTreeNode]
        private let lines: [Line] // Reference to all lines
        private let minCoordIndex: Int // Range of compressed indices [0...maxCoordIndex]
        private let maxCoordIndex: Int
        private let sortedUniqueH: [Int] // Map compressed index back to original H value
        
        // Needs a size calculation based on the range (maxCoordIndex - minCoordIndex + 1)
        private let treeSize: Int
        
        init(lines: [Line], sortedUniqueH: [Int]) {
            self.lines = lines
            self.sortedUniqueH = sortedUniqueH
            self.minCoordIndex = 0
            self.maxCoordIndex = sortedUniqueH.count - 1
            
            // Calculate appropriate tree size (power of 2 >= range size)
            let rangeSize = maxCoordIndex - minCoordIndex + 1
            let treeHeight = (rangeSize > 0) ? (rangeSize - 1).bitWidth : 0
            self.treeSize = 1 << (treeHeight + 1) // * 2 for segment tree array convention (1-based indexing)
            self.tree = Array(repeating: LiChaoTreeNode(), count: treeSize)
            
            // Build the tree by inserting all lines
            for i in 0..<lines.count {
                if lines[i].originalIndex != -1 { // Only insert valid lines
                    insert(lineIndex: i)
                }
            }
        }
        
        private func getLine(_ index: Int) -> Line {
            return (index == -1 || index >= lines.count) ? Line.negligible : lines[index]
        }
        
        // --- Insert Function (Top-1) ---
        func insert(lineIndex: Int) {
            if lineIndex < 0 || lineIndex >= lines.count { return } // Safety check
            _insert(newLineIndex: lineIndex, treeNodeIndex: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
        }
        
        private func _insert(newLineIndex: Int, treeNodeIndex: Int, rangeL: Int, rangeR: Int) {
            // Base case: invalid range or node index out of bounds
            if rangeL > rangeR || treeNodeIndex <= 0 || treeNodeIndex >= tree.count { return }
            
            let midIndex = rangeL + (rangeR - rangeL) / 2
            // Evaluate lines at the H value corresponding to the mid *index*
            // Need to handle potential out-of-bounds if range indices are wrong.
            guard midIndex >= 0 && midIndex < sortedUniqueH.count else { return }
            let midH = Double(sortedUniqueH[midIndex])
            
            var currentBestIndex = tree[treeNodeIndex].lineIndex
            var incomingLineIndex = newLineIndex // Use 'var' to allow swapping
            
            let currentLine = getLine(currentBestIndex)
            let incomingLine = getLine(incomingLineIndex)
            
            // If incoming line is better at midpoint, swap it with current node's line
            if incomingLine.eval(at: midH) > currentLine.eval(at: midH) {
                swap(&currentBestIndex, &incomingLineIndex) // Swap the *indices*
                tree[treeNodeIndex].lineIndex = currentBestIndex // Update node with the new best index
            }
            
            // If the range is just a single point, we're done for this path
            if rangeL == rangeR { return }
            
            // Try to insert the line that was worse at the midpoint into the appropriate child.
            // Note: 'incomingLineIndex' now holds the index of the line that was *worse* at midH after the potential swap.
            let remainingLineIndex = incomingLineIndex
            let remainingLine = getLine(remainingLineIndex)
            let bestLineAtNode = getLine(currentBestIndex) // The line that won at midH (or was already there)
            
            // If the remaining line is negligible, no need to propagate.
            if remainingLine.originalIndex == -1 { return }
            
            // Propagate based on slopes:
            // Only propagate if the remaining line could potentially beat the current node's line
            // somewhere within the relevant child's range.
            // Note: Floating point comparisons need care, consider using a small epsilon if necessary,
            //       but direct comparison often works okay here.
            if remainingLine.m > bestLineAtNode.m {
                // Higher slope -> potential win on right side
                _insert(newLineIndex: remainingLineIndex, treeNodeIndex: 2 * treeNodeIndex + 1, rangeL: midIndex + 1, rangeR: rangeR)
            } else if remainingLine.m < bestLineAtNode.m {
                // Lower slope -> potential win on left side
                _insert(newLineIndex: remainingLineIndex, treeNodeIndex: 2 * treeNodeIndex, rangeL: rangeL, rangeR: midIndex)
            }
            // Implicit else: If slopes are equal, the line with strictly better `c` should have won the swap.
            // The remaining line (with lower or equal `c`) will not dominate, so no need to propagate.
        }
        
        // --- Query Function (Top-1) ---
        func query(compressedIndex: Int) -> (value: Double, index: Int) {
            let x = Double(sortedUniqueH[compressedIndex]) // Original H value for evaluation
            return _query(targetX: x, treeNodeIndex: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
        }
        
        private func _query(targetX: Double, treeNodeIndex: Int, rangeL: Int, rangeR: Int) -> (value: Double, index: Int) {
            if rangeL > rangeR || treeNodeIndex >= tree.count{
                return (value: -Double.infinity, index: -1) // Base case: invalid range or node
            }
            
            // Best value found so far (start with current node's line)
            let nodeLineIndex = tree[treeNodeIndex].lineIndex
            let nodeLine = getLine(nodeLineIndex)
            var bestVal = nodeLine.eval(at: targetX)
            var bestIdx = nodeLine.originalIndex
            
            // If not a leaf, check the relevant child
            if rangeL != rangeR {
                let midIndex = rangeL + (rangeR - rangeL) / 2
                var childResult: (value: Double, index: Int)
                
                if sortedUniqueH.firstIndex(of: Int(targetX)) ?? -1 <= midIndex { // Check which range targetX falls into based on its compressed index
                    childResult = _query(targetX: targetX, treeNodeIndex: 2 * treeNodeIndex, rangeL: rangeL, rangeR: midIndex)
                } else {
                    childResult = _query(targetX: targetX, treeNodeIndex: 2 * treeNodeIndex + 1, rangeL: midIndex + 1, rangeR: rangeR)
                }
                
                if childResult.value > bestVal {
                    bestVal = childResult.value
                    bestIdx = childResult.index
                }
            }
            
            return (bestVal, bestIdx)
        }
    }
    
    // --- Main Function (using placeholder Top-1 LCT logic) ---
    // NOTE: This will NOT produce the correct answer because it lacks Top-2 logic.
    // It demonstrates the *structure* needed for the optimized approach.
    func getMaxDamageDealt_OptimizedStructure(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
        if N < 2 { return 0.0 }
        let B_double = Double(B)
        if B_double <= 0 { return 0.0 }
        
        var calculatedLines = [Line]()
        var uniqueHSet = Set<Int>()
        var self_damage = [Double](repeating: 0.0, count: N)
        var originalIndexToLine = [Int: Line]() // Map original warrior index to its Line object
        
        for k in 0..<N {
            if H[k] <= 0 {
                // Store a negligible line placeholder if needed, or just skip
                originalIndexToLine[k] = Line.negligible
                continue
            }
            let Dk = Double(D[k])
            let Hk = Double(H[k])
            let sd = Dk * Hk / B_double
            let mult = Dk / B_double
            self_damage[k] = sd
            let line = Line(m: mult, c: sd, originalIndex: k)
            calculatedLines.append(line)
            originalIndexToLine[k] = line
            uniqueHSet.insert(H[k])
        }
        
        if calculatedLines.count < 2 { return 0.0 } // Not enough valid warriors
        
        // --- Coordinate Compression ---
        let sortedUniqueH = Array(uniqueHSet).sorted()
        var hToCompressedIndex = [Int: Int]()
        for (index, hVal) in sortedUniqueH.enumerated() {
            hToCompressedIndex[hVal] = index
        }
        
        // Filter lines array to only valid lines before passing to LCT
        let validLines = calculatedLines.filter { $0.originalIndex != -1 }
        
        // --- Initialize and Build Li Chao Tree (using Top-1 placeholder) ---
        let lct = LiChaoTree_Top1(lines: validLines, sortedUniqueH: sortedUniqueH)
        
        // --- Query for Each Warrior ---
        var maxTotalDamage: Double = 0.0
        
        for i in 0..<N { // Iterate through original warrior indices
            if H[i] <= 0 { continue } // Skip warriors who can't fight
            
            guard let compressedIndex = hToCompressedIndex[H[i]] else { continue } // Should always exist if H[i] > 0
            
            // --- Query LCT for BEST backup contribution ---
            // THIS IS WHERE TOP-2 LOGIC IS CRITICAL AND CURRENTLY MISSING
            let top1Result = lct.query(compressedIndex: compressedIndex) // Gets single best backup (j)
            
            var best_backup_contribution : Double = 0.0
            
            // Placeholder logic - INCORRECT as it doesn't find the second best
            if top1Result.index != -1 {
                if top1Result.index != i {
                    best_backup_contribution = top1Result.value
                } else {
                    // **** Need to query LCT again somehow for the second best ****
                    // **** This requires a Top-2 LCT implementation. ****
                    // As a placeholder, let's assume 0 if best is self.
                    best_backup_contribution = 0.0 // Incorrect assumption
                }
            }
            
            best_backup_contribution = max(best_backup_contribution, 0.0)
            
            let currentTotalDamage = self_damage[i] + best_backup_contribution
            maxTotalDamage = max(maxTotalDamage, currentTotalDamage)
        }
        
        return Float(maxTotalDamage)
    }
    
    // Choose which function to submit based on requirements:
    // - getMaxDamageDealt: Use the brute-force version for logic check.
    // - getMaxDamageDealt_OptimizedStructure: Use this structure, BUT replace
    //   LiChaoTree_Top1 with a fully working LiChaoTree_Top2 implementation.
    // Since Top-2 LCT is complex, submitting the brute-force might pass
    // initial sample cases but will TLE on larger ones.
}



// MARK: - Brute force solution

// Example UIKit view controller
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




// MARK: - Preview
// Use in SwiftUI view
struct ContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}


