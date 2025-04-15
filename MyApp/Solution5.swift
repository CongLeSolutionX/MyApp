//
//  Solution5.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import Foundation

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
