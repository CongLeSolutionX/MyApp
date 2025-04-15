////
////  Solution2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import Foundation
//
//// MARK: - Line Structure
//
///// Represents a line y = m*x + c.
///// Used here for BackupContribution(j, i) = mult_j * H[i] + self_damage_j
///// where x = H[i], m = mult_j, c = self_damage_j
//struct Line: Comparable {
//    let m: Double // Slope: D[j] / B
//    let c: Double // Intercept: self_damage_j = D[j]*H[j]/B
//    let originalIndex: Int // Original warrior index 'j'
//    
//    /// Evaluates the line at a given x coordinate.
//    func eval(at x: Double) -> Double {
//        return m * x + c
//    }
//    
//    /// A placeholder for negligible or non-existent lines.
//    static let negligible = Line(m: 0.0, c: -Double.infinity, originalIndex: -1)
//    
//    /// Comparable conformance for simple sorting (e.g., by slope). Not used in core LCT logic directly.
//    static func < (lhs: Line, rhs: Line) -> Bool {
//        if lhs.m != rhs.m {
//            return lhs.m < rhs.m
//        }
//        return lhs.c < rhs.c
//    }
//    
//    static func == (lhs: Line, rhs: Line) -> Bool {
//        return lhs.m == rhs.m && lhs.c == rhs.c && lhs.originalIndex == rhs.originalIndex
//    }
//}
//
//// MARK: - Li Chao Tree Node (Top-2)
//
///// Node for the Li Chao Tree, storing indices of the best two lines covering its range.
//struct LiChaoTreeNode_Top2 {
//    // Indices into the main 'lines' array
//    var best_idx: Int = -1   // Index of the line that is generally best in this node's range
//    var second_idx: Int = -1 // Index of the second-best line
//    
//    init() {
//        best_idx = -1
//        second_idx = -1
//    }
//}
//
//// MARK: - Li Chao Tree (Top-2)
//
//class LiChaoTree_Top2 {
//    private var tree: [LiChaoTreeNode_Top2]
//    private var lines: [Line] // Stores all the actual Line objects (0-based index)
//    private let sortedUniqueH: [Int] // Maps compressed index back to original H value
//    private let minCoordIndex: Int
//    private let maxCoordIndex: Int
//    private let treeSize: Int // Cache tree size
//    
//    /// Initializes the Li Chao Tree.
//    /// - Parameters:
//    ///   - initialLines: An array of Line objects to build the tree with.
//    ///   - sortedUniqueH: An array of unique, sorted H values used for coordinate compression.
//    init(initialLines: [Line], sortedUniqueH: [Int]) {
//        // Store lines 0-based. Node indices refer to this array. -1 means negligible.
//        self.lines = initialLines
//        self.sortedUniqueH = sortedUniqueH
//        self.minCoordIndex = 0
//        self.maxCoordIndex = sortedUniqueH.count - 1
//        
//        // Calculate tree size
//        let rangeSize = self.maxCoordIndex - self.minCoordIndex + 1
//        if rangeSize <= 0 {
//            self.treeSize = 0
//            self.tree = []
//            print("Warning: Li Chao Tree initialized with non-positive range size.")
//            return
//        }
//        // Determine height excluding root (level 0), then calculate total nodes needed
//        // Height for rangeSize=1 is 0. For rangeSize=2 is 1. Height = floor(log2(rangeSize - 1))? No.
//        // Height = ceil(log2(rangeSize)). Power of 2 >= rangeSize.
//        let height = (rangeSize == 1) ? 0 : (rangeSize - 1).bitWidth // Correct height calculation (0-based)
//        // Size = 2^(height+1) - 1 nodes for 0-based indexing, or 2^(height+1) for array size
//        // Let's use 1-based indexing for the tree array for simplicity of child calculation
//        self.treeSize = 1 << (height + 1) // Size if using 1-based indexing internally
//        self.tree = Array(repeating: LiChaoTreeNode_Top2(), count: self.treeSize)
//        
//        // Insert all initial lines (use their 0-based index from the original array)
//        for i in 0..<self.lines.count {
//            insert(lineIndex: i) // Pass the index in the `lines` array
//        }
//    }
//    
//    // --- Helper to safely get a line ---
//    private func getLine(at index: Int) -> Line {
//        // Use 0-based index for lines array
//        if index < 0 || index >= lines.count {
//            return Line.negligible
//        }
//        return lines[index]
//    }
//    
//    // --- Public Insert Function ---
//    func insert(lineIndex: Int) {
//        // Use 0-based index for lines array
//        if lineIndex < 0 || lineIndex >= lines.count { return } // Safety check
//        _insert(incomingLineIndex: lineIndex, nodeIdx: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
//    }
//    
//    // --- Recursive Insert Helper ---
//    // nodeIdx is 1-based for the tree array
//    // rangeL, rangeR are 0-based indices into sortedUniqueH
//    // incomingLineIndex is 0-based index into the lines array
//    private func _insert(incomingLineIndex: Int, nodeIdx: Int, rangeL: Int, rangeR: Int) {
//        guard rangeL <= rangeR, nodeIdx > 0, nodeIdx < treeSize else { return } // Basic validation
//        
//        let midIndex = rangeL + (rangeR - rangeL) / 2 // 0-based mid index for coordinate range
//        guard midIndex >= 0 && midIndex < sortedUniqueH.count else { return } // Mid coordinate index validation
//        let midH = Double(sortedUniqueH[midIndex]) // Evaluation X-coordinate
//        
//        let currentBestIdx = tree[nodeIdx].best_idx
//        let currentSecondIdx = tree[nodeIdx].second_idx
//        
//        // --- Logic to determine Top 2 at Midpoint ---
//        // Get the three relevant lines (handling negligible cases)
//        let lineIncoming = getLine(at: incomingLineIndex)
//        let lineNodeBest = getLine(at: currentBestIdx)
//        let lineNodeSecond = getLine(at: currentSecondIdx)
//        
//        // Evaluate all potentially valid lines at the midpoint
//        var candidates: [(value: Double, index: Int)] = []
//        if incomingLineIndex != -1 { candidates.append((value: lineIncoming.eval(at: midH), index: incomingLineIndex)) }
//        if currentBestIdx != -1 { candidates.append((value: lineNodeBest.eval(at: midH), index: currentBestIdx)) }
//        if currentSecondIdx != -1 { candidates.append((value: lineNodeSecond.eval(at: midH), index: currentSecondIdx)) }
//        
//        // Remove duplicates by index (if incoming line is already best/second)
//        var uniqueCandidatesMap: [Int: Double] = [:]
//        for cand in candidates {
//            uniqueCandidatesMap[cand.index, default: -Double.infinity] = max(uniqueCandidatesMap[cand.index]!, cand.value)
//        }
//        
//        // Sort the unique candidates by value descending
//        let sortedUniqueCandidates = uniqueCandidatesMap.map { (index: $0.key, value: $0.value) }
//            .sorted { $0.value > $1.value }
//        
//        // Update the node's best and second best indices (-1 if fewer than 1 or 2 candidates)
//        let newBestIdx = sortedUniqueCandidates.indices.contains(0) ? sortedUniqueCandidates[0].index : -1
//        let newSecondIdx = sortedUniqueCandidates.indices.contains(1) ? sortedUniqueCandidates[1].index : -1
//        
//        tree[nodeIdx].best_idx = newBestIdx
//        tree[nodeIdx].second_idx = newSecondIdx
//        
//        // --- Propagation Logic ---
//        // Determine which line didn't make the top 2 at midH among the original set (incoming, old best, old second)
//        var loserIndex = -1
//        let originalIndices = [incomingLineIndex, currentBestIdx, currentSecondIdx].filter { $0 != -1 }
//        let uniqueOriginalIndices = Set(originalIndices)
//        
//        if uniqueOriginalIndices.count >= 1 && !uniqueOriginalIndices.contains(newBestIdx) {
//            // This case should not happen if newBestIdx came from uniqueCandidatesMap derived from originals
//        }
//        if uniqueOriginalIndices.count >= 2 && !uniqueOriginalIndices.contains(newSecondIdx) {
//            //This case should not happen either
//        }
//        
//        // Find an original index that is NOT the new best OR new second
//        for idx in uniqueOriginalIndices {
//            if idx != newBestIdx && idx != newSecondIdx {
//                loserIndex = idx
//                break
//            }
//        }
//        
//        // If no line lost (e.g., fewer than 3 valid distinct lines involved) or it's a leaf node, return
//        if loserIndex == -1 || rangeL == rangeR {
//            return
//        }
//        
//        // Propagate the losing line to the appropriate child node
//        let lineLoser = getLine(at: loserIndex)
//        let lineWinner1 = getLine(at: newBestIdx) // Compare loser against the absolute best at this node
//        
//        // Simplified propagation (like Top-1 LCT), considering only the intersection with the best line.
//        // More complex logic might consider intersection with the second best line too.
//        if lineLoser.m > lineWinner1.m { // Loser has steeper slope -> potential win on the right side
//            _insert(incomingLineIndex: loserIndex, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
//        } else if lineLoser.m < lineWinner1.m { // Loser has shallower slope -> potential win on the left side
//            _insert(incomingLineIndex: loserIndex, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
//        }
//        // else: Slopes are equal. The loser must have lower 'c' (or was incoming and is equal),
//        // so it won't dominate the winner. No propagation needed in this simplified model.
//    }
//    
//    // --- Public Query Function (Corrected) ---
//    // Takes compressed index directly for path navigation.
//    func queryTop2Corrected(targetCompressedIndex: Int) -> [(value: Double, index: Int)] {
//        guard targetCompressedIndex >= minCoordIndex && targetCompressedIndex <= maxCoordIndex else {
//            print("Warning: Query index \(targetCompressedIndex) out of range [\(minCoordIndex), \(maxCoordIndex)]")
//            return [] // Invalid compressed index
//        }
//        // Ensure the compressed index is valid for the sortedUniqueH array
//        guard targetCompressedIndex >= 0 && targetCompressedIndex < sortedUniqueH.count else {
//            print("Internal Error: targetCompressedIndex \(targetCompressedIndex) invalid for sortedUniqueH lookip.")
//            return []
//        }
//        
//        let queryH = Double(sortedUniqueH[targetCompressedIndex]) // The actual H value for line evaluation
//        return _queryCorrected(targetH: queryH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 1, rangeL: minCoordIndex, rangeR: maxCoordIndex)
//    }
//    
//    // --- Recursive Query Helper (Corrected) ---
//    // targetH: Value to evaluate lines at.
//    // targetCompressedIndex: Index used for path decisions.
//    // nodeIdx: 1-based tree node index.
//    // rangeL, rangeR: 0-based compressed coordinate range for this node.
//    private func _queryCorrected(targetH: Double, targetCompressedIndex: Int, nodeIdx: Int, rangeL: Int, rangeR: Int) -> [(value: Double, index: Int)] {
//        guard rangeL <= rangeR, nodeIdx > 0, nodeIdx < treeSize else {
//            return [] // Invalid range or node index
//        }
//        
//        // Get the top 2 lines directly stored at the current node
//        let nodeBestIdx = tree[nodeIdx].best_idx
//        let nodeSecondIdx = tree[nodeIdx].second_idx
//        let lineNodeBest = getLine(at: nodeBestIdx)
//        let lineNodeSecond = getLine(at: nodeSecondIdx)
//        
//        // Evaluate these node lines at the target H value
//        var candidates: [(value: Double, index: Int)] = []
//        if nodeBestIdx != -1 { candidates.append((value: lineNodeBest.eval(at: targetH), index: nodeBestIdx)) }
//        if nodeSecondIdx != -1 { candidates.append((value: lineNodeSecond.eval(at: targetH), index: nodeSecondIdx)) }
//        
//        // If not a leaf node, recursively query the appropriate child
//        if rangeL != rangeR {
//            let midIndex = rangeL + (rangeR - rangeL) / 2 // Midpoint of the compressed index range
//            var childResults: [(value: Double, index: Int)] = []
//            
//            // Decide which child path to take based on the targetCompressedIndex
//            if targetCompressedIndex <= midIndex {
//                // Target is in the left child's range
//                childResults = _queryCorrected(targetH: targetH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 2 * nodeIdx, rangeL: rangeL, rangeR: midIndex)
//            } else {
//                // Target is in the right child's range
//                childResults = _queryCorrected(targetH: targetH, targetCompressedIndex: targetCompressedIndex, nodeIdx: 2 * nodeIdx + 1, rangeL: midIndex + 1, rangeR: rangeR)
//            }
//            
//            // Add the results from the child query to the candidates
//            candidates.append(contentsOf: childResults)
//        }
//        
//        // Consolidate results: Find the top 2 unique lines from candidates (node + child results)
//        var uniqueResultsMap: [Int: Double] = [:]
//        for cand in candidates {
//            // Store the best value found for each unique line index
//            uniqueResultsMap[cand.index, default: -Double.infinity] = max(uniqueResultsMap[cand.index]!, cand.value)
//        }
//        
//        // Convert map back to array, sort by value descending, take top 2
//        let finalTop2 = uniqueResultsMap.map { (index: $0.key, value: $0.value) }
//            .sorted { $0.value > $1.value } // Sort descending by value
//            .prefix(2) // Get the best two
//        
//        return Array(finalTop2)
//    }
//    
//} // End of LiChaoTree_Top2 class
//
//// MARK: - Main Solver Function
//
//func getMaxDamageDealt(_ N: Int, _ H: [Int], _ D: [Int], _ B: Int) -> Float {
//    if N < 2 { return 0.0 }
//    let B_double = Double(B)
//    if B_double <= 0 { return 0.0 }
//    
//    // --- Preprocessing & Coordinate Compression ---
//    var linesForLCT = [Line]() // Lines representing backup contribution
//    var uniqueHSet = Set<Int>()
//    var self_damage = [Double](repeating: 0.0, count: N) // Store self_damage for final sum
//    var isValidWarrior = [Bool](repeating: false, count: N)
//    var warriorIndices = [Int]() // Store original indices of valid warriors
//    warriorIndices.reserveCapacity(N)
//    
//    for k in 0..<N {
//        if H[k] <= 0 { continue } // Skip invalid warriors
//        
//        isValidWarrior[k] = true
//        warriorIndices.append(k) // Add valid warrior index
//        
//        let Dk = Double(D[k])
//        let Hk = Double(H[k])
//        let sd = Dk * Hk / B_double
//        let mult = Dk / B_double
//        self_damage[k] = sd // Store self_damage of warrior k
//        
//        // Line for LCT represents k's contribution *if k is backup*
//        // Use index k (0-based)
//        linesForLCT.append(Line(m: mult, c: sd, originalIndex: k))
//        uniqueHSet.insert(H[k]) // Collect unique H values for compression
//    }
//    
//    // Need at least two valid warriors
//    if warriorIndices.count < 2 { return 0.0 }
//    
//    // --- Coordinate Compression ---
//    let sortedUniqueH = Array(uniqueHSet).sorted()
//    var hToCompressedIndex = [Int: Int]()
//    for (index, hVal) in sortedUniqueH.enumerated() {
//        hToCompressedIndex[hVal] = index // Map H value to 0-based compressed index
//    }
//    
//    // --- Initialize and Build Li Chao Tree ---
//    // Ensure we have data to build the tree
//    guard !linesForLCT.isEmpty, !sortedUniqueH.isEmpty else {
//        print("Error: Cannot build LCT with empty lines or coordinates.")
//        return 0.0
//    }
//    // Pass the 0-based lines array
//    let lct = LiChaoTree_Top2(initialLines: linesForLCT, sortedUniqueH: sortedUniqueH)
//    
//    // --- Querying ---
//    var maxTotalDamage: Double = 0.0
//    
//    // Iterate only through valid warriors to consider them as front-liner 'i'
//    for i in warriorIndices {
//        // Get H[i] and its compressed index
//        let currentH = H[i]
//        guard let compressedIndex = hToCompressedIndex[currentH] else {
//            print("Error: H value \(currentH) for warrior \(i) not found in compression map.")
//            continue // Should not happen if preprocessing is correct
//        }
//        
//        // Query the LCT to get the best TWO backup candidates (j) and their contribution values
//        // at the point x = H[i] (using the compressed index for the query)
//        let top2Results = lct.queryTop2Corrected(targetCompressedIndex: compressedIndex)
//        
//        var best_backup_contribution : Double = 0.0
//        
//        // Determine the best backup contribution from a warrior j where j != i
//        if !top2Results.isEmpty {
//            let top1 = top2Results[0]
//            if top1.index != i {
//                // The best line is not warrior 'i' acting as backup
//                best_backup_contribution = top1.value
//            } else {
//                // The best line *is* warrior 'i'. Use the second best, if it exists and is valid.
//                if top2Results.count > 1 {
//                    let top2 = top2Results[1]
//                    // Ensure second best is not also negligible (shouldn't happen if filtered)
//                    if top2.index != -1 {
//                        best_backup_contribution = top2.value
//                    }
//                }
//                // else: Only one result (i) or second result was negligible. Backup is 0.
//            }
//        }
//        // Ensure non-negative damage contribution
//        best_backup_contribution = max(best_backup_contribution, 0.0)
//        
//        // Final calculation: TotalDamage = self_damage_i + best_backup_contribution_from_j_neq_i
//        // self_damage[i] was precalculated
//        let currentTotalDamage = self_damage[i] + best_backup_contribution
//        maxTotalDamage = max(maxTotalDamage, currentTotalDamage)
//    }
//    
//    // Return result as Float
//    return Float(maxTotalDamage)
//}
