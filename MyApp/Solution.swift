//
//  Solution.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//
import Foundation

func getMaxVisitableWebpages(_ N: Int, _ M: Int, _ A: [Int], _ B: [Int]) -> Int {
    var graph = Array(repeating: [Int](), count: N + 1)
    for i in 0..<M {
        graph[A[i]].append(B[i])
    }

    var time = 0
    var low = Array(repeating: 0, count: N + 1)
    var disc = Array(repeating: 0, count: N + 1) // discovery time
    var stack = [Int]()
    var stackMember = Array(repeating: false, count: N + 1)
    var sccId = Array(repeating: 0, count: N + 1)
    var sccCount = 0

    func tarjan(_ u: Int) {
        time += 1
        disc[u] = time
        low[u] = time
        stack.append(u)
        stackMember[u] = true

        for v in graph[u] {
            if disc[v] == 0 {
                tarjan(v)
                low[u] = min(low[u], low[v])
            } else if stackMember[v] {
                low[u] = min(low[u], disc[v])
            }
        }

        if low[u] == disc[u] {
            sccCount += 1
            while true {
                let w = stack.popLast()!
                stackMember[w] = false
                sccId[w] = sccCount
                if w == u { break }
            }
        }
    }

    for i in 1...N {
        if disc[i] == 0 { tarjan(i) }
    }

    // Now sccId has SCC group for each node (1-based)
    // sccCount = total number of SCCs

    // Calculate size of each SCC
    var sizeSCC = Array(repeating: 0, count: sccCount + 1)
    for i in 1...N {
        sizeSCC[sccId[i]] += 1
    }

    // Build SCC graph by edges between scc groups
    var sccGraph = Array(repeating: Set<Int>(), count: sccCount + 1)
    for i in 0..<M {
        let u = sccId[A[i]]
        let v = sccId[B[i]]
        if u != v {
            sccGraph[u].insert(v)
        }
    }

    // Longest path DP on DAG
    var dp = Array(repeating: -1, count: sccCount + 1)

    func dfs(_ u: Int) -> Int {
        if dp[u] != -1 { return dp[u] }
        var maxLen = 0
        for v in sccGraph[u] {
            maxLen = max(maxLen, dfs(v))
        }
        dp[u] = sizeSCC[u] + maxLen
        return dp[u]
    }

    var result = 0
    for i in 1...sccCount {
        result = max(result, dfs(i))
    }

    return result
}
