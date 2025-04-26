////
////  Solution1.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//
//import Foundation
//
//// Using a larger stack size for deep recursion potentially needed in Tarjan's/DP
//#if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//import Darwin
//#elseif os(Windows)
//import CRT
//#endif
//
//func runWithIncreasedStack(block: () -> Void) {
//    var attributes = pthread_attr_t()
//    pthread_attr_init(&attributes)
//    var stackSize = 8 * 1024 * 1024 // 8 MB stack
//    pthread_attr_setstacksize(&attributes, stackSize)
//    
//    var thread: pthread_t? = nil
//    
//    let creation = pthread_create(&thread, &attributes, { argPointer in
//        // 1. Get the Unmanaged reference from the opaque pointer
//        let unmanagedBlock = Unmanaged<AnyObject>.fromOpaque(argPointer)
//        // 2. Get the Swift object (the closure) back
//        let blockObject = unmanagedBlock.takeUnretainedValue()
//        
//        // 3. Cast the object to the correct closure type and call it
//        if let actualBlock = blockObject as? () -> Void {
//            actualBlock() // Execute the block
//        } else {
//            print("Error casting block object back to () -> Void in pthread")
//            // Consider how to handle this error, though it shouldn't happen
//            // if the setup is correct.
//        }
//        
//        return nil // pthread routine expects a return value
//    },Unmanaged.passUnretained(block as AnyObject).toOpaque())
//    
//    pthread_attr_destroy(&attributes)
//    
//    if creation != 0 {
//        print("Error creating thread")
//        block() // Fallback to running on the current thread
//        return
//    }
//    
//    pthread_join(thread!, nil)
//}
//
//func getMaxCollectableCoins(_ R: Int, _ C: Int, _ G: [String]) -> Int {
//    
//    var result = 0
//    
//    runWithIncreasedStack { // Run the core logic on a thread with a larger stack
//        result = solveSlipperyTrip(R, C, G)
//    }
//    return result
//}
//
//private func solveSlipperyTrip(_ R: Int, _ C: Int, _ G: [String]) -> Int {
//    
//    let N = R * C
//    let num_state_nodes = N
//    let num_junction_nodes = R // J_1 to J_R (junctions for entering rows 1 to R)
//    let total_nodes = num_state_nodes + num_junction_nodes
//    
//    // Map state (r, c_virt) -> r * C + c_virt
//    // Map junction Jr (entering row r, 1-based) -> N + r - 1
//    
//    var adj = Array(repeating: [Int](), count: total_nodes)
//    var weights = Array(repeating: 0, count: total_nodes)
//    let grid = G.map { Array($0) } // Easier access
//    
//    // --- 1. Build the Graph ---
//    for r in 0..<R {
//        for c_virt in 0..<C {
//            let u_idx = r * C + c_virt
//            let char = grid[r][c_virt]
//            
//            if char == "*" {
//                weights[u_idx] = 1
//            }
//            
//            // Right transitions
//            if char == ">" || char == "." || char == "*" {
//                let v_right_idx = r * C + (c_virt + 1) % C
//                adj[u_idx].append(v_right_idx)
//            }
//            
//            // Down transitions (via junctions)
//            if (char == "v" || char == "." || char == "*") && r < R - 1 {
//                // Going down means entering row r+1 (1-based)
//                // Junction node for entering row r+1 is J_{r+1}
//                let junction_node_idx = N + (r + 1) - 1 // Map J_{r+1}
//                adj[u_idx].append(junction_node_idx)
//            }
//        }
//    }
//    
//    // Edges from Junction nodes to actual state nodes in the entered row
//    for r_entered in 1...R { // Junctions J_1 to J_R
//        let junction_node_idx = N + r_entered - 1
//        let target_row_idx = r_entered - 1 // 0-based row index corresponding to J_r
//        
//        // Cannot enter row R via junction, as transitions stop before that
//        if target_row_idx < R {
//            for c_target in 0..<C {
//                let v_idx = target_row_idx * C + c_target
//                adj[junction_node_idx].append(v_idx)
//            }
//        }
//    }
//    
//    // --- 2. Tarjan's SCC Algorithm ---
//    var ids = Array(repeating: -1, count: total_nodes)
//    var low = Array(repeating: -1, count: total_nodes)
//    var onStack = Array(repeating: false, count: total_nodes)
//    var stack = [Int]()
//    var timer = 0
//    var sccCount = 0
//    var sccMap = Array(repeating: -1, count: total_nodes) // node index -> scc id
//    var sccCoins = [Int]() // scc id -> total coins
//    
//    func dfs_scc(_ at: Int) {
//        stack.append(at)
//        onStack[at] = true
//        ids[at] = timer
//        low[at] = timer
//        timer += 1
//        
//        for to in adj[at] {
//            if ids[to] == -1 {
//                dfs_scc(to)
//                low[at] = min(low[at], low[to])
//            } else if onStack[to] {
//                low[at] = min(low[at], ids[to])
//            }
//        }
//        
//        if ids[at] == low[at] {
//            var currentSccCoins = 0
//            while let node = stack.popLast() {
//                onStack[node] = false
//                low[node] = ids[at] // Mark as part of this SCC
//                sccMap[node] = sccCount
//                currentSccCoins += weights[node]
//                if node == at { break }
//            }
//            sccCoins.append(currentSccCoins)
//            sccCount += 1
//        }
//    }
//    
//    for i in 0..<total_nodes {
//        if ids[i] == -1 {
//            dfs_scc(i)
//        }
//    }
//    
//    // --- 3. Build Condensation Graph ---
//    var adj_scc = Array(repeating: Set<Int>(), count: sccCount)
//    for u in 0..<total_nodes {
//        for v in adj[u] {
//            let scc_u = sccMap[u]
//            let scc_v = sccMap[v]
//            if scc_u != scc_v {
//                adj_scc[scc_u].insert(scc_v)
//            }
//        }
//    }
//    
//    // Convert Set to Array for easier iteration in DP
//    var adj_scc_list = adj_scc.map { Array($0) }
//    
//    // --- 4. DP on DAG ---
//    var dp = Array(repeating: -1, count: sccCount) // Memoization table
//    
//    func solve_dp(_ scc_id: Int) -> Int {
//        if dp[scc_id] != -1 {
//            return dp[scc_id]
//        }
//        
//        var max_coins_from_successors = 0
//        for next_scc in adj_scc_list[scc_id] {
//            max_coins_from_successors = max(max_coins_from_successors, solve_dp(next_scc))
//        }
//        
//        dp[scc_id] = sccCoins[scc_id] + max_coins_from_successors
//        return dp[scc_id]
//    }
//    
//    // --- 5. Calculate Final Result ---
//    var max_total_coins = 0
//    for c_virt_start in 0..<C {
//        let start_node_idx = 0 * C + c_virt_start // State (0, c_virt_start)
//        if sccMap[start_node_idx] != -1 { // Ensure node exists in an SCC
//            let start_scc_id = sccMap[start_node_idx]
//            max_total_coins = max(max_total_coins, solve_dp(start_scc_id))
//        }
//    }
//    
//    // Handle cases like Sample 3 where start node might not lead anywhere or collect coins
//    if max_total_coins == 0 {
//        for c_virt_start in 0..<C {
//            let start_node_idx = 0 * C + c_virt_start
//            if weights[start_node_idx] > 0 { // Check if the start node itself has a coin
//                
//                // Re-calculate DP specifically for this start SCC if needed to capture just the start coin
//                let start_scc_id = sccMap[start_node_idx]
//                if dp[start_scc_id] == -1 { // If DP wasn't run/cached for this SCC via other paths
//                    max_total_coins = max(max_total_coins, solve_dp(start_scc_id))
//                } else {
//                    // If DP was already run, max_total_coins should already reflect the possibility
//                }
//                // Ensure at least the starting coin is counted if it's the only one reachable
//                if max_total_coins == 0 {
//                    max_total_coins = 1
//                }
//            }
//            
//        }
//    }
//    
//    return max_total_coins
//}
