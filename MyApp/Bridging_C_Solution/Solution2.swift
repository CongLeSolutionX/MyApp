////
////  Solution2.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// MARK: - Platform Specific Imports for Pthread
//#if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//    import Darwin
//    typealias ThreadHandle = pthread_t? // Use optional pthread_t for POSIX
//    typealias ThreadAttributes = pthread_attr_t
//#elseif os(Windows)
//    import CRT
//    import WinSDK // Required for thread APIs on Windows
//    // Note: Windows thread handling is different. This pthread wrapper might need adjustments
//    // For Windows, you might use _beginthreadex directly for more control.
//    // This simplified version assumes a basic POSIX-like interface is available via CRT
//    // or that compilation environment provides necessary mappings.
//    typealias ThreadHandle = uintptr_t // Placeholder, Windows uses HANDLE or uintptr_t from _beginthreadex
//    typealias ThreadAttributes = Void // Windows doesn't use pthread_attr_t directly
//#else
//    #error("Unsupported operating system for Pthread operations")
//#endif
//
//// MARK: - Stack Size Increase Utility
//
///// Runs the given block of code on a separate thread with an increased stack size.
///// Necessary for potentially deep recursion in algorithms like Tarjan's SCC or DP.
/////
///// - Parameter block: The closure containing the code to execute.
//func runWithIncreasedStack(block: @escaping () -> Void) {
//    #if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//        var attributes = ThreadAttributes()
//        pthread_attr_init(&attributes)
//        defer { pthread_attr_destroy(&attributes) } // Ensure cleanup
//
//        // Set stack size (e.g., 8MB)
//        let stackSize = 8 * 1024 * 1024
//        pthread_attr_setstacksize(&attributes, stackSize)
//
//        var thread: ThreadHandle = nil
//        let creation = pthread_create(&thread, &attributes, { argPointer in
////            guard let argPointer = argPointer else {
//               print("Error: Received nil argPointer in thread creation")
////               return nil
////            }
//            // Retrieve, Cast, and Call the block
//            (Unmanaged<AnyObject>.fromOpaque(argPointer).takeUnretainedValue() as! () -> Void)()
//            return nil // pthread routine expects a return value
//        }, Unmanaged.passUnretained(block as AnyObject).toOpaque())
//
//        if creation != 0 {
//            // --- FIX IS HERE ---
//            // Convert the C string from strerror to a Swift String safely
//            let errorPtr = strerror(creation) // Returns UnsafeMutablePointer<CChar>? or similar
//            let errorMessage = errorPtr.map { String(cString: $0) } ?? "Unknown error code \(creation)" // Use map for optional handling
//            print("Error creating pthread with increased stack size: \(errorMessage). Falling back to current thread.")
//            // --- END FIX ---
//    
//            Unmanaged.passUnretained(block as AnyObject).release() // Release context if thread creation failed
//            block() // Fallback to running on the current thread
//            return
//        }
//
//        if let thread = thread {
//            pthread_join(thread, nil)
//        } else {
//             print("Error: Thread handle was nil after creation attempt.")
//             block() // Fallback if thread handle is somehow nil
//        }
//
//    #elseif os(Windows)
//        // Windows thread creation is different. This is a simplified placeholder.
//        // Using _beginthreadex would be more appropriate for stack size control.
//        print("Warning: Pthread stack size increase not fully implemented for Windows in this example. Running on current thread.")
//        block()
//    #else
//        // Fallback for other potential platforms (though unlikely with #error above)
//         print("Warning: Pthread stack size increase not implemented for this platform. Running on current thread.")
//        block()
//    #endif
//}
//
//// MARK: - Core Algorithm Implementation
//
///// Solves the Slippery Trip problem.
///// Finds the maximum number of unique coins collectible following the grid rules,
///// considering arbitrary row shifts before starting.
/////
///// - Parameters:
/////   - R: Number of rows.
/////   - C: Number of columns.
/////   - G: The grid represented as an array of strings.
///// - Returns: The maximum number of unique coins.
//private func solveSlipperyTrip(_ R: Int, _ C: Int, _ G: [String]) -> Int {
//
//    let N = R * C // Number of primary state nodes (r, c_virt)
//    let num_state_nodes = N
//    // Junction nodes represent entering a row (1-based index). J_1 enters row 0, J_R enters row R-1.
//    // There are R such entry points conceptually, but we only need junctions for rows 1 to R (indices 0 to R-1)
//    // as you cannot 'enter' row 0 via a junction, you start there.
//    let num_junction_nodes = R
//    let total_nodes = num_state_nodes + num_junction_nodes
//
//    // --- Node Index Mapping ---
//    // State (r, c_virt) [0-based] maps to index: r * C + c_virt (Range: 0 to N-1)
//    // Junction Jr (representing entering row r [0-based]) maps to index: N + r (Range: N to N+R-1)
//    // Example: Moving down from row 0 enters row 1 (0-based index 1). Use Junction Node N + 1.
//    // Moving down from row R-2 enters row R-1 (0-based index R-1). Use Junction Node N + (R-1).
//
//    var adj = Array(repeating: [Int](), count: total_nodes)
//    var weights = Array(repeating: 0, count: total_nodes)
//    let grid = G.map { Array($0) } // Easier char access
//
//    // --- 1. Build the State Graph ---
//    for r in 0..<R {
//        for c_virt in 0..<C {
//            let u_idx = r * C + c_virt
//            let char = grid[r][c_virt]
//
//            // Assign weight if it's a coin
//            if char == "*" {
//                weights[u_idx] = 1
//            }
//
//            // --- Right Transitions ---
//            if char == ">" || char == "." || char == "*" {
//                let v_right_idx = r * C + (c_virt + 1) % C // Wrap around column
//                adj[u_idx].append(v_right_idx)
//            }
//
//            // --- Down Transitions (via Junction Nodes) ---
//            // Can only move down if not in the last row (R-1)
//            if (char == "v" || char == "." || char == "*") && r < R - 1 {
//                 // Moving down from row 'r' means entering row 'r+1' (0-based index)
//                let target_row_index = r + 1
//                // The junction node for entering row 'r+1' is at index N + target_row_index
//                let junction_node_idx = N + target_row_index
//                adj[u_idx].append(junction_node_idx)
//            }
//            // Note: If char is 'v' and r == R-1, the trip ends, no edge added.
//        }
//    }
//
//    // --- Edges from Junction nodes to Actual State nodes ---
//    // A junction node Jr (N+r) connects to all states (r, c') in the row it represents entering.
//    for r_entered in 0..<R { // Junction N+0 represents entering row 0 (start), N+R-1 enters row R-1.
//        let junction_node_idx = N + r_entered
//        let target_row_idx = r_entered // The row index this junction leads into
//
//        // Add edges from the junction node to all possible virtual column states in that row
//        for c_target in 0..<C {
//            let v_state_node_idx = target_row_idx * C + c_target
//            adj[junction_node_idx].append(v_state_node_idx)
//        }
//    }
//
//    // --- 2. Tarjan's SCC Algorithm ---
//    var ids = Array(repeating: -1, count: total_nodes)         // Discovery time / id
//    var low = Array(repeating: -1, count: total_nodes)         // Lowest id reachable
//    var onStack = Array(repeating: false, count: total_nodes)  // Is node currently on the recursion stack?
//    var stack = [Int]()                                     // Recursion stack
//    var timer = 0                                           // Discovery time counter
//    var sccCount = 0                                        // Number of SCCs found
//    var sccMap = Array(repeating: -1, count: total_nodes)      // Maps node index -> its SCC ID
//    var sccCoins = [Int]()                                  // Stores total coins for each SCC ID
//
//    func dfs_scc(_ at: Int) {
//        stack.append(at)
//        onStack[at] = true
//        ids[at] = timer
//        low[at] = timer
//        timer += 1
//
//        for to in adj[at] {
//            if ids[to] == -1 { // Not visited yet
//                dfs_scc(to)
//                low[at] = min(low[at], low[to]) // Update low-link value from subtree
//            } else if onStack[to] { // Visited and on stack -> back edge or cross edge within SCC
//                low[at] = min(low[at], ids[to]) // Update low-link with ancestor's id
//            }
//            // If visited but not on stack, it's a cross-edge to an already processed SCC - ignore.
//        }
//
//        // If low[at] == ids[at], 'at' is the root of an SCC
//        if ids[at] == low[at] {
//            var currentSccCoins = 0
//            while let node = stack.popLast() {
//                onStack[node] = false
//                // low[node] = ids[at] // Not strictly needed, useful for debugging
//                sccMap[node] = sccCount // Assign SCC ID to the node
//                currentSccCoins += weights[node] // Accumulate coins for this SCC
//                if node == at { break } // Found the root, stop popping for this SCC
//            }
//            sccCoins.append(currentSccCoins) // Store total coins for the new SCC
//            sccCount += 1
//        }
//    }
//
//    // Run Tarjan's from all unvisited nodes
//    for i in 0..<total_nodes {
//        if ids[i] == -1 {
//            dfs_scc(i)
//        }
//    }
//
//     // Handle case where no SCCs are formed (e.g., R=0 or C=0 grid), though constraints likely prevent this.
//    if sccCount == 0 && total_nodes > 0 {
//        // Check if any start node itself has a coin.
//         for c_virt_start in 0..<C {
//             let start_node_idx = 0 * C + c_virt_start
//             if weights[start_node_idx] > 0 { return 1 }
//         }
//        return 0
//    }
//     if sccCount == 0 { return 0} // Truly empty graph
//
//    // --- 3. Build Condensation Graph (DAG of SCCs) ---
//    var adj_scc_sets = Array(repeating: Set<Int>(), count: sccCount)
//    for u in 0..<total_nodes {
//        let scc_u = sccMap[u]
//         if scc_u == -1 { continue } // Should not happen if graph is connected/processed
//
//        for v in adj[u] {
//            let scc_v = sccMap[v]
//             if scc_v == -1 { continue } // Should not happen
//
//            if scc_u != scc_v {
//                adj_scc_sets[scc_u].insert(scc_v) // Add edge from SCC u to SCC v
//            }
//        }
//    }
//    // Convert sets to arrays for easier iteration in DP
//    let adj_scc_list = adj_scc_sets.map { Array($0) }
//
//    // --- 4. DP on the Condensation Graph (DAG) ---
//    // dp[scc_id] = max coins obtainable starting from within scc_id
//    var dp = Array(repeating: -1, count: sccCount)
//
//    func solve_dp(_ scc_id: Int) -> Int {
//        // Check memoization table
//        if dp[scc_id] != -1 {
//            return dp[scc_id]
//        }
//
//        // Calculate max coins from successor SCCs
//        var max_coins_from_successors = 0
//        for next_scc in adj_scc_list[scc_id] {
//             max_coins_from_successors = max(max_coins_from_successors, solve_dp(next_scc))
//        }
//
//        // Total coins = coins within this SCC + max coins from paths starting in successors
//        dp[scc_id] = sccCoins[scc_id] + max_coins_from_successors
//        return dp[scc_id]
//    }
//
//    // --- 5. Calculate Final Result ---
//    // The trip can start effectively corresponding to any state (0, c_virt)
//    // by choosing the initial shift s0. Find the max DP result starting from the SCC
//    // containing each of these initial states.
//    var max_total_coins = 0
//    for c_virt_start in 0..<C {
//         let start_node_idx = 0 * C + c_virt_start // State node corresponding to row 0, virtual col c_virt_start
//         // Ensure the start node was actually processed and belongs to an SCC
//         if start_node_idx < total_nodes && sccMap[start_node_idx] != -1 {
//             let start_scc_id = sccMap[start_node_idx]
//             max_total_coins = max(max_total_coins, solve_dp(start_scc_id))
//         } else if start_node_idx < total_nodes && weights[start_node_idx] > 0 {
//              // Handle edge case: start node is isolated but has a coin
//              max_total_coins = max(max_total_coins, weights[start_node_idx])
//         }
//    }
//
//    // Special check: if the max calculated is 0, but one of the direct start nodes
//    // (0, c_virt) has a coin and might be isolated or only lead to 0-coin paths.
//    // This is mostly covered by the DP, but double-check for single-coin starts.
//    if max_total_coins == 0 {
//         for c_virt_start in 0..<C {
//              let start_node_idx = 0 * C + c_virt_start
//              if start_node_idx < total_nodes && weights[start_node_idx] > 0 {
//                  // If an isolated start node has a coin, the max should be at least 1.
//                  // The DP should handle this if it's part of an SCC, but this covers isolation.
//                  max_total_coins = max(max_total_coins, 1)
//              }
//         }
//    }
//
//    return max_total_coins
//}
//
///// Public wrapper function that calls the main logic with increased stack size.
//public func getMaxCollectableCoins(_ R: Int, _ C: Int, _ G: [String]) -> Int {
//    // Basic input validation
//    if R <= 0 || C <= 0 || G.isEmpty || G.count != R || G.contains(where: { $0.count != C }) {
//        print("Warning: Invalid input dimensions or grid format.")
//        return 0
//    }
//
//    var result = 0
//    runWithIncreasedStack {
//        result = solveSlipperyTrip(R, C, G)
//    }
//    return result
//}
//
//// MARK: - Test Cases
//
//struct TestCase {
//    let id: String
//    let R: Int
//    let C: Int
//    let grid: [String]
//    let expectedResult: Int
//    let rationale: String
//}
//
//let testCases: [TestCase] = [
//    // --- 1. Basic Paths & Simple Choices ---
//    TestCase(id: "1.1", R: 1, C: 5, grid: ["*.**."], expectedResult: 3, rationale: "Simple horizontal path, no down moves."),
//    TestCase(id: "1.2", R: 3, C: 1, grid: ["*", "*", "v"], expectedResult: 2, rationale: "Simple vertical path, ends at 'v'."),
//    TestCase(id: "1.3", R: 2, C: 2, grid: [".*", "**"], expectedResult: 3, rationale: "Choice needed. Max path via shift s0=1 -> (0,1)[*] -> J1 -> (1,0)[*] -> (1,1)[*]."),
//    TestCase(id: "1.4", R: 3, C: 3, grid: ["*..", ".**", "..."], expectedResult: 3, rationale: "Simple diagonal-like path req. choices."),
//
//    // --- 2. Shifting Required ---
//    TestCase(id: "2.1", R: 1, C: 3, grid: [".*."], expectedResult: 1, rationale: "Must shift row 0 (s0=1 or 2) to start at '*'."),
//    TestCase(id: "2.2", R: 2, C: 2, grid: ["v>", ".**"], expectedResult: 2, rationale: "Needs s0=1 to start '>'. Needs s1=1 to land on '*' after forced down."),
//    TestCase(id: "2.3", R: 2, C: 3, grid: ["..v", "***"], expectedResult: 3, rationale: "Path collects all 3 '*' in row 1 after forced down."),
//    TestCase(id: "2.4", R: 2, C: 2, grid: [">v", ".v"], expectedResult: 0, rationale: "All paths lead to 'v' in row 1, ending the trip."),
//
//    // --- 3. Forced Moves & End Conditions ---
//    TestCase(id: "3.1", R: 1, C: 4, grid: [">>>*"], expectedResult: 1, rationale: "Forced horizontal wrapping to collect coin."),
//    TestCase(id: "3.2", R: 3, C: 2, grid: ["v.", "v.", "**"], expectedResult: 2, rationale: "Forced down moves, land on '*' in last row."),
//    TestCase(id: "3.3", R: 2, C: 2, grid: [".*", "vv"], expectedResult: 1, rationale: "Can collect '*' at (0,1), but moving down ends trip."),
//    TestCase(id: "3.4", R: 1, C: 1, grid: ["v"], expectedResult: 0, rationale: "Start 'v' in last row immediately ends."),
//
//    // --- 4. Cycles ---
//    TestCase(id: "4.1", R: 1, C: 4, grid: [">*>."], expectedResult: 1, rationale: "Simple horizontal cycle, collects coin once."),
//    TestCase(id: "4.2", R: 2, C: 3, grid: ["v..", "**>"], expectedResult: 2, rationale: "Down move leads to cycle in row 1, collects 2 coins before repeating cycle."),
//    TestCase(id: "4.3", R: 2, C: 3, grid: ["...", ">>>"], expectedResult: 0, rationale: "Enters infinite cycle with no coins."),
//    TestCase(id: "4.4_Sample2", R: 3, C: 3, grid: [">>*", "*>*", ">>*"], expectedResult: 4, rationale: "Sample 2: Path collects coins then enters cycle in row 2."),
//
//    // --- 5. Boundary Conditions / Small Grids ---
//    TestCase(id: "5.1", R: 1, C: 1, grid: ["*"], expectedResult: 1, rationale: "Single cell coin."),
//    TestCase(id: "5.2", R: 1, C: 1, grid: ["."], expectedResult: 0, rationale: "Single cell empty."),
//    TestCase(id: "5.3", R: 1, C: 1, grid: [">"], expectedResult: 0, rationale: "Single cell cycle."),
//    // TestCase(id: "5.4", R: 1, C: 1, grid: ["v"], expectedResult: 0, rationale: "Duplicate of 3.4"), // Redundant
//
//    // --- 6. Tricky Cases / Ambiguities (Sample 3) ---
//    TestCase(id: "6.1_Sample3", R: 2, C: 2, grid: ["..", "**"], expectedResult: 0,
//             rationale: "Sample 3: Expected 0. Algorithm logically finds path collecting 2 coins (e.g., (0,0)->J1->(1,0)->(1,1)). Test asserts 0 to match sample, highlighting potential ambiguity."),
//    TestCase(id: "6.2", R: 2, C: 2, grid: ["..", ".*"], expectedResult: 1, rationale: "Similar to 6.1, but only one coin below. Should collect 1."),
//
//    // --- 7. Larger / Complex Cases ---
//    TestCase(id: "7.1_Sample4", R: 4, C: 6, grid: [">**v>*", "*v*>*", ".*.>.*", "..*..*v"], expectedResult: 6, rationale: "Sample 4: Complex path with multiple features."),
//    TestCase(id: "7.2", R: 5, C: 5, grid: [">.v*.", "*v..>", ".*v*.", "..*>>", "v.**."], expectedResult: 6, rationale: "Complex grid mixing choices, forced moves, cycles. (Expected value from running the code)."),
//    TestCase(id: "7.3", R: 3, C: 4, grid: ["*...",".v..","***>"], expectedResult: 4, rationale: "Path forced down, then potential cycle in last row."),
//    TestCase(id: "7.4_NoCoins", R: 3, C: 3, grid: ["...", ".v.", ">>>"], expectedResult: 0, rationale: "Grid with reachable cycle but no coins anywhere."),
//    TestCase(id: "7.5_IsolatedStartCoin", R: 2, C: 2, grid: ["*v", ".."], expectedResult: 1, rationale: "Start coin available (shift s0=0), but forced down leads nowhere."),
//]
//
//// MARK: - Test Execution
////
////print("--- Running Slippery Trip Test Cases ---")
////
////var passedCount = 0
////var failedCount = 0
////
////for test in testCases {
////    print("\nRunning Test: \(test.id)")
////    print("Rationale: \(test.rationale)")
////    print("Grid:")
////    test.grid.forEach { print($0) }
////
////    let startTime = DispatchTime.now()
////    let actualResult = getMaxCollectableCoins(test.R, test.C, test.grid)
////    let endTime = DispatchTime.now()
////    let timeElapsed = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000.0
////
////    if actualResult == test.expectedResult {
////        print("✅ PASSED (Expected: \(test.expectedResult), Got: \(actualResult)) - Time: \(String(format: "%.4f", timeElapsed))s")
////        passedCount += 1
////    } else {
////        // Specific handling for Sample 3 known discrepancy
////        if test.id == "6.1_Sample3" && actualResult == 2 {
////             print("⚠️ WARNING (Sample 3 Discrepancy): Expected 0 (official sample), Algorithm got 2 (logically correct based on rules). Test considers this FAILED against sample.")
////        } else {
////             print("❌ FAILED (Expected: \(test.expectedResult), Got: \(actualResult)) - Time: \(String(format: "%.4f", timeElapsed))s")
////        }
////        failedCount += 1
////    }
////}
////
////print("\n--- Test Summary ---")
////print("Passed: \(passedCount)")
////print("Failed: \(failedCount)")
////print("Total:  \(testCases.count)")
////print("--------------------")
////
////// You can run this file directly using the Swift interpreter:
////// swift path/to/your/file.swift
