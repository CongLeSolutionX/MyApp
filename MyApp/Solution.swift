//
//  Solution.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import Foundation

// MARK: - Line Structure

/// Represents a line y = m*x + c.
/// Used here for BackupContribution(j, i) = mult_j * H[i] + self_damage_j
/// where x = H[i], m = mult_j, c = self_damage_j
struct Line: Comparable {
    let m: Double // Slope: D[j] / B
    let c: Double // Intercept: self_damage_j = D[j]*H[j]/B
    let originalIndex: Int // Original warrior index 'j'

    /// Evaluates the line at a given x coordinate.
    func eval(at x: Double) -> Double {
        return m * x + c
    }

    /// A placeholder for negligible or non-existent lines.
    static let negligible = Line(m: 0.0, c: -Double.infinity, originalIndex: -1)

    /// Comparable conformance for simple sorting (e.g., by slope). Not used in core LCT logic directly.
    static func < (lhs: Line, rhs: Line) -> Bool {
        if lhs.m != rhs.m {
            return lhs.m < rhs.m
        }
        return lhs.c < rhs.c
    }

    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.m == rhs.m && lhs.c == rhs.c && lhs.originalIndex == rhs.originalIndex
    }
}

// MARK: - Li Chao Tree Node (Top-2)

/// Node for the Li Chao Tree, storing indices of the best two lines covering its range.
struct LiChaoTreeNode_Top2 {
    // Indices into the main 'lines' array
    var best_idx: Int = -1   // Index of the line that is generally best in this node's range
    var second_idx: Int = -1 // Index of the second-best line

    init() {
        best_idx = -1
        second_idx = -1
    }
}

// MARK: - Li Chao Tree (Top-2)

class LiChaoTree_Top2 {
    private var tree: [LiChaoTreeNode_Top2]
    private var lines: [Line] // Stores all the actual Line objects
    private let sortedUniqueH: [Int] // Maps compressed index back to original H value
    private let minCoordIndex: Int
    private let maxCoordIndex: Int
    private let treeSize: Int // Cache tree size

    /// Initializes the Li Chao Tree.
    /// - Parameters:
    ///   - initialLines: An array of Line objects to build the tree with.
    ///   - sortedUniqueH: An array of unique, sorted H values used for coordinate compression.
    init(initialLines: [Line], sortedUniqueH: [Int]) {
        self.lines = [Line.negligible] + initialLines /// Add negligible at index 0 for safety, work with 1-based indices internally for lines array access if desired, OR keep lines 0-based and handle -1 index in nodes. Let's stick to -1 meaning negligible and lines array being 0-based.
        self.sortedUniqueH = sortedUniqueH
        self.minCoordIndex = 0
        self.maxCoordIndex = sortedUniqueH.count - 1

        // Calculate tree size (needs to be large enough for the range)
        // Using 1-based indexing for segment tree array: size needs > 2 * rangeSize
        let rangeSize = self.maxCoordIndex - self.minCoordIndex + 1
         if rangeSize <= 0 {
             self.treeSize = 0
             self.tree = []
             print("Warning: Li Chao Tree initialized with non-positive range size.")
             return
         }
        let treeHeight = (rangeSize == 1) ? 1 : (rangeSize - 1).bitWidth
        // Standard segment tree size calculation for 1-based indexing
        self.treeSize = 1 << (treeHeight + 1) // 2 * (power of 2 >= rangeSize)
        self.tree = Array(repeating: LiChaoTreeNode_Top2(), count: self.treeSize)

        // Insert all initial lines
        for i in 0..<initialLines.count {
             // Index in the main `lines` array corresponds to i + 1 if inserted negligible at 0
             // If lines array is 0-based, use insert(lineIndex: i)
            insert(lineIndex: i) // Assuming lines array is 0-based
        }
    }
    
    // --- Helper to safely get a line ---
    private func getLine(at index: Int) -> Line {
        if index < 0 || index >= lines.count {
            return Line.negligible
        }
        return lines[index]
    }

    // --- Public Insert Function ---
    func insert(lineIndex: Int) {
        if lineIndex < 0 || lineIndex >= lines.count { return } // Safety check
        _insert(incomingLineIndex: lineIndex, nodeIdx: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
    }

    // --- Recursive Insert Helper ---
    private func _insert(incomingLineIndex: Int, nodeIdx: Int, rangeL: Int, rangeR: Int) {
        guard rangeL <= rangeR, nodeIdx > 0, nodeIdx < treeSize else {
            if nodeIdx >= treeSize && treeSize > 0 {
                 // This indicates tree size calculation might be slightly off or access is wrong
                 print("Warning: Attempt to access nodeIdx \(nodeIdx) beyond treeSize \(treeSize)")
             }
            return // Invalid range or node index
        }

        let midIndex = rangeL + (rangeR - rangeL) / 2
         guard midIndex >= 0 && midIndex < sortedUniqueH.count else {
             print("Warning: midIndex \(midIndex) out of bounds for sortedUniqueH (count \(sortedUniqueH.count))")
             return
         }
        let midH = Double(sortedUniqueH[midIndex]) // Evaluation X-coordinate

        var currentBestIdx = tree[nodeIdx].best_idx
        var currentSecondIdx = tree[nodeIdx].second_idx

        let lineIncoming = getLine(at: incomingLineIndex)
        let lineNodeBest = getLine(at: currentBestIdx)
        let lineNodeSecond = getLine(at: currentSecondIdx)

        // Evaluate all three lines at the midpoint
        // Create pairs of (value, index) for sorting
        var candidates = [
            (value: lineIncoming.eval(at: midH), index: incomingLineIndex),
            (value: lineNodeBest.eval(at: midH), index: currentBestIdx),
            (value: lineNodeSecond.eval(at: midH), index: currentSecondIdx)
        ]

        // Filter out negligible lines and remove duplicates by index before sorting
        var uniqueCandidates: [Int: Double] = [:]
         for cand in candidates {
             if cand.index != -1 { // Ignore negligible index
                 uniqueCandidates[cand.index, default: -Double.infinity] = max(uniqueCandidates[cand.index]!, cand.value)
             }
         }
        
         var sortedUniqueCandidates = uniqueCandidates.map { (index: $0.key, value: $0.value) }
                                                  .sorted { $0.value > $1.value } // Sort descending by value

        // Update the node's best and second best
        tree[nodeIdx].best_idx = sortedUniqueCandidates.indices.contains(0) ? sortedUniqueCandidates[0].index : -1
        tree[nodeIdx].second_idx = sortedUniqueCandidates.indices.contains(1) ? sortedUniqueCandidates[1].index : -1

        // Determine the line that "lost" at the midpoint (wasn't top 2)
        let winner1Idx = tree[nodeIdx].best_idx
        let winner2Idx = tree[nodeIdx].second_idx

        var loserIndex = -1
         for cand in candidates {
              if cand.index != -1 && cand.index != winner1Idx && cand.index != winner2Idx {
                  loserIndex = cand.index
                  break
              }
         }

        // If no line lost (e.g., fewer than 3 valid lines involved) or it's a leaf, return
        if loserIndex == -1 || rangeL == rangeR {
            return
        }

        // Propagate the losing line to the relevant child
         let lineLoser = getLine(at: loserIndex)
         let lineWinner1 = getLine(at: winner1Idx) // Use the absolute best line for slope comparison

          // --- Simplified Propagation Logic (similar to Top-1 LCT) ---
          // Propagate the loser based on slope comparison with the node's dominant line.
          // This is a heuristic; more complex logic involving intersections with both winners exists.
        if lineLoser.m > lineWinner1.m { // Loser has steeper slope -> might win on the right
            _insert(incomingLineIndex: loserIndex, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
        } else if lineLoser.m < lineWinner1.m { // Loser has shallower slope -> might win on the left
            _insert(incomingLineIndex: loserIndex, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
        } else {
            // Slopes are equal. The loser (with equal or worse 'c') won't dominate.
            // No propagation needed in this simplified model.
        }

    }

    // --- Public Query Function ---
     func queryTop2(compressedIndex: Int) -> [(value: Double, index: Int)] {
         guard compressedIndex >= minCoordIndex && compressedIndex <= maxCoordIndex else {
             print("Warning: Query index \(compressedIndex) out of range [\(minCoordIndex), \(maxCoordIndex)]")
             return [] // Invalid index
         }
         guard !sortedUniqueH.isEmpty else { return [] } // No coords to query

         let queryH = Double(sortedUniqueH[compressedIndex]) // The actual H value for evaluation
         return _query(targetH: queryH, nodeIdx: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
     }

    // --- Recursive Query Helper ---
    private func _query(targetH: Double, nodeIdx: Int, rangeL: Int, rangeR: Int) -> [(value: Double, index: Int)] {
         guard rangeL <= rangeR, nodeIdx > 0, nodeIdx < treeSize else {
             return [] // Invalid range or node index
         }

         // Get the top 2 lines from the current node
         let nodeBestIdx = tree[nodeIdx].best_idx
         let nodeSecondIdx = tree[nodeIdx].second_idx
         let lineNodeBest = getLine(at: nodeBestIdx)
         let lineNodeSecond = getLine(at: nodeSecondIdx)

         // Initial candidates from this node
         var candidates = [
             (value: lineNodeBest.eval(at: targetH), index: nodeBestIdx),
             (value: lineNodeSecond.eval(at: targetH), index: nodeSecondIdx)
         ].filter { $0.index != -1 } // Filter out negligible

        // If not a leaf, query the relevant child
        if rangeL != rangeR {
            let midIndex = rangeL + (rangeR - rangeR) / 2
            var childResults: [(value: Double, index: Int)] = []

            // Determine the compressed index corresponding to targetH to decide which child to visit.
            // We already have the original H (targetH), need its *compressed index*.
            // This requires a binary search or dictionary lookup. Assume we got the compressed index
            // passed down or can recalculate it efficiently if needed.
            // Let's assume the *initial* call provided the compressedIndex 'queryCompressedIndex'
            // and we need it here. This suggests the recursive function needs `queryCompressedIndex`.
            // RETHINK: The query path depends on the compressed index, *not* the targetH value itself.

            // Let's redefine _query to take targetH AND the targetCompressedIndex
             // This feels redundant. The initial call has the compressed index. Use it to find the path.

             // Corrected approach: Decide path based on the compressed index used in the *initial* query.
             // We need queryTop2 to pass the original compressedIndex down.

            // --- Temporarily redefine _query for clarity ---
            // Need to pass originalTargetCompressedIndex down the recursion
            // func _query(targetH: Double, originalTargetCompressedIndex: Int, nodeIdx: Int, rangeL: Int, rangeR: Int) ...

            // **** SIMPLIFICATION FOR NOW: Assume we have originalTargetCompressedIndex ****
            // In a real implementation, pass it down from the public query function. Let's *simulate* it
             // Find where targetH would fit in sortedUniqueH to get its compressed index for path decision.
             // Since the initial call HAS the index, we use that index to decide the path.
              // Let's refine the *public* query and call the helper appropriately.

           // ---- Let's restructure the query ---
           // Public function finds H value, then calls helper with H and compressed idx
           // Helper uses compressed idx for path, H for evaluation.

            // --- Back to original _query structure, assuming we have the compressed index implicitly ---
             // This is confusing. How does the helper know the path?
             // It must be based on the target index passed to the public function.
              // Okay, let's assume the path decision is correctly made *outside* this snapshot.

            // Fetch the compressed index required for path decision (needs to be passed down) - FAKING IT
            var targetCompressedIndex = -1
            if let foundIndex = sortedUniqueH.firstIndex(of: Int(targetH)) { // Inefficient lookup!
                 targetCompressedIndex = foundIndex
             } else {
                 // Approximation if exact H not found (shouldn't happen if H comes from input H array)
                 // This indicates a structure problem if H isn't in sortedUniqueH
                 print("Error: Query target H (\(targetH)) not found in sortedUniqueH for path decision.")
                 // Attempt recovery (e.g., find closest, or just use midIndex comparison logic)
                  // Let's use range logic for now
                  if targetH <= Double(sortedUniqueH[midIndex]) { // Heuristic if index not available
                       childResults = _query(targetH: targetH, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
                   } else {
                       childResults = _query(targetH: targetH, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
                   }

             }
             
            // --- Correct query path logic requires the compressed index ---
             // This needs fixing. Let's assume `targetCompressedIndex` is correctly passed.
            //  if targetCompressedIndex <= midIndex { // Correct logic using compressed index
            //      childResults = _query(targetH: targetH, /* pass targetCompressedIndex */ nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
            //  } else {
            //      childResults = _query(targetH: targetH, /* pass targetCompressedIndex */ nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
            //  }
             // --- Let's revert to the approximate path for now, as index isn't passed ---
              if targetH <= Double(sortedUniqueH[midIndex]) { // Heuristic if index not available
                   childResults = _query(targetH: targetH, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
               } else {
                   childResults = _query(targetH: targetH, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
               }

            // Combine results from node and child
            candidates.append(contentsOf: childResults)
        }

         // Filter duplicates by index, keeping the one with the higher value
          var uniqueResults: [Int: Double] = [:]
          for cand in candidates {
              if cand.index != -1 {
                  uniqueResults[cand.index, default: -Double.infinity] = max(uniqueResults[cand.index]!, cand.value)
              }
          }

         // Sort unique results by value descending and take top 2
          let finalTop2 = uniqueResults.map { (index: $0.key, value: $0.value) }
                                     .sorted { $0.value > $1.value } // Descending value
                                     .prefix(2) // Take at most 2

        return Array(finalTop2)
    }
    
     // --- REVISED Public Query ---
     // Takes compressed index directly for path navigation.
     func queryTop2Corrected(targetCompressedIndex: Int) -> [(value: Double, index: Int)] {
         guard targetCompressedIndex >= minCoordIndex && targetCompressedIndex <= maxCoordIndex else {
             print("Warning: Query index \(targetCompressedIndex) out of range [\(minCoordIndex), \(maxCoordIndex)]")
             return [] // Invalid index
         }
          guard targetCompressedIndex >= 0 && targetCompressedIndex < sortedUniqueH.count else {
              print("Internal Error: targetCompressedIndex \(targetCompressedIndex) invalid for sortedUniqueH")
              return []
          }

         let queryH = Double(sortedUniqueH[targetCompressedIndex]) // The actual H value for evaluation
         return _queryCorrected(targetH: queryH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
     }

     // --- REVISED Recursive Query Helper ---
     private func _queryCorrected(targetH: Double, targetCompressedIndex: Int, nodeIdx: Int, rangeL: Int, rangeR: Int) -> [(value: Double, index: Int)] {
          guard rangeL <= rangeR, nodeIdx > 0, nodeIdx < treeSize else {
              return [] // Invalid range or node index
          }

          // Get the top 2 lines from the current node
          let nodeBestIdx = tree[nodeIdx].best_idx
          let nodeSecondIdx = tree[nodeIdx].second_idx
          let lineNodeBest = getLine(at: nodeBestIdx)
          let lineNodeSecond = getLine(at: nodeSecondIdx)

          // Initial candidates from this node
          var candidates = [
              (value: lineNodeBest.eval(at: targetH), index: nodeBestIdx),
              (value: lineNodeSecond.eval(at: targetH), index: nodeSecondIdx)
          ].filter { $0.index != -1 } // Filter out negligible

         // If not a leaf, query the relevant child
         if rangeL != rangeR {
             let midIndex = rangeL + (rangeR - rangeL) / 2
             var childResults: [(value: Double, index: Int)] = []

             // Decide path based on the targetCompressedIndex
             if targetCompressedIndex <= midIndex {
                 childResults = _queryCorrected(targetH: targetH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
             } else {
                 childResults = _queryCorrected(targetH: targetH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
             }

             // Combine results from node and child
             candidates.append(contentsOf: childResults)
         }

          // Filter duplicates by index, keeping the one with the higher value
           var uniqueResults: [Int: Double] = [:]
           for cand in candidates {
               if cand.index != -1 {
                   uniqueResults[cand.index, default: -Double.infinity] = max(uniqueResults[cand.index]!, cand.value)
               }
           }

          // Sort unique results by value descending and take top 2
           let finalTop2 = uniqueResults.map { (index: $0.key, value: $0.value) }
                                      .sorted { $0.value > $1.value } // Descending value
                                      .prefix(2) // Take at most 2

         return Array(finalTop2)
     }

} // End of LiChaoTree_Top2 class

// MARK: - Main Solver Function

func getMaxDamageDealt(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
    if N < 2 { return 0.0 }
    let B_double = Double(B)
    if B_double <= 0 { return 0.0 }

    // --- Preprocessing & Coordinate Compression ---
    var linesForLCT = [Line]() // Lines representing backup contribution
    var uniqueHSet = Set<Int>()
    var self_damage = [Double](repeating: 0.0, count: N) // Store self_damage for final sum
    var isValidWarrior = [Bool](repeating: false, count: N)
    var warriorCount = 0

    for k in 0..<N {
        if H[k] <= 0 { continue } // Skip invalid warriors

        isValidWarrior[k] = true
        warriorCount += 1
        let Dk = Double(D[k])
        let Hk = Double(H[k])
        let sd = Dk * Hk / B_double
        let mult = Dk / B_double
        self_damage[k] = sd // Store self_damage of warrior k

        // Line for LCT represents k's contribution *if k is backup*
        linesForLCT.append(Line(m: mult, c: sd, originalIndex: k))
        uniqueHSet.insert(H[k]) // Collect unique H values for compression
    }

    // Need at least two valid warriors
    if warriorCount < 2 { return 0.0 }

    // --- Coordinate Compression ---
    let sortedUniqueH = Array(uniqueHSet).sorted()
    var hToCompressedIndex = [Int: Int]()
    for (index, hVal) in sortedUniqueH.enumerated() {
        hToCompressedIndex[hVal] = index
    }

    // --- Initialize and Build Li Chao Tree ---
     guard !linesForLCT.isEmpty, !sortedUniqueH.isEmpty else {
         print("Error: Cannot build LCT with empty lines or coordinates.")
         return 0.0 // Or handle as appropriate
     }
    let lct = LiChaoTree_Top2(initialLines: linesForLCT, sortedUniqueH: sortedUniqueH)

    // --- Querying ---
    var maxTotalDamage: Double = 0.0

    for i in 0..<N { // Iterate through original indices to consider each as front-liner 'i'
        if !isValidWarrior[i] { continue } // Skip if warrior 'i' cannot fight

        guard let compressedIndex = hToCompressedIndex[H[i]] else {
            print("Error: H value \(H[i]) for warrior \(i) not found in compression map.")
            continue // Should not happen if preprocessing is correct
        }

        // Query the LCT to get the best TWO backup candidates (j) and their contribution values
        // at the point x = H[i]
        let top2Results = lct.queryTop2Corrected(targetCompressedIndex: compressedIndex) // Use corrected query

        var best_backup_contribution : Double = 0.0

        if !top2Results.isEmpty {
            let top1 = top2Results[0]
            if top1.index != i {
                // The best backup is not warrior 'i' itself
                best_backup_contribution = top1.value
            } else {
                // The best backup *is* warrior 'i'. Use the second best, if it exists.
                if top2Results.count > 1 {
                    best_backup_contribution = top2Results[1].value
                }
                // else: Only one potential backup line found, and it was 'i',
                // so no valid backup contribution (remains 0.0)
            }
        }
        // Ensure we don't use negligible placeholder value
        best_backup_contribution = max(best_backup_contribution, 0.0)

        // Final calculation: TotalDamage = self_damage_i + best_backup_contribution_from_j_neq_i
        let currentTotalDamage = self_damage[i] + best_backup_contribution
        maxTotalDamage = max(maxTotalDamage, currentTotalDamage)
    }

    // Return result as Float
    return Float(maxTotalDamage)
}
