//
//  Solution6.swift
//  MyApp
//
//  Created by Cong Le on 4/26/25.
//

func getMaxCollectableCoins(_ R: Int, _ C: Int, _ G: [[String]]) -> Int {
    // Directions: 0 = down, 1 = right
    let DIRS = [(1, 0), (0, 1)] // Down, Right
    let DOWN = 0, RIGHT = 1

    // Compress the grid into [row][col] = cell
    let grid = G.map { $0 }

    // For DP we only need two rows: current and next
    // dp[row][col][dir]
    var curr = Array(repeating: Array(repeating: 0, count: 2), count: C)
    var next = Array(repeating: Array(repeating: 0, count: 2), count: C)

    // Start from bottom row, fill base case
    // If you arrive below last row, it's end, so next = zeros

    for row in (0..<R).reversed() {
        // For each possible entry col and direction
        for col in 0..<C {
            for dir in 0...1 { // 0 = from top/down, 1 = from left/right
                var best = 0
                // Try all right shifts
                for shift in 0..<C {
                    // Build visited for THIS path (local to this single run)
                    var seen = Set<[Int]>()
                    var coins = 0
                    // Start simulating from entry (row, col), with this shift
                    var pos = (row, (col + shift) % C)
                    var d = dir
                    var vCoins = Array(repeating: false, count: C) // Coin collected in this row?

                    while true {
                        // Defensive, prevent infinite loop
                        let (r, c) = pos
                        if seen.contains([r, c, d]) { break }
                        seen.insert([r, c, d])
                        let cell = grid[r][c]
                        // If it contains coin, collect if not yet
                        if cell == "*" && !vCoins[c] {
                            coins += 1
                            vCoins[c] = true
                        }
                        // If contains arrow, change direction
                        if cell == ">" {
                            d = RIGHT
                        } else if cell == "v" {
                            d = DOWN
                        }
                        // Move to next cell
                        var (dr, dc) = DIRS[d]
                        var nr = r + dr
                        var nc = (c + dc) % C
                        if d == RIGHT && dc == 1 { // wrap right
                            // nothing special, already used modulo
                        }
                        // If moving down out of grid, end
                        if nr >= R {
                            break
                        }
                        // If moving right, stay in same row, go to nc
                        pos = (nr, nc)
                        // If moving down, finish this row, add DP from next row
                        if d == DOWN && dr == 1 {
                            coins += next[nc][DOWN]
                            break
                        }
                        // If moving right and return to col already visited, might loop forever but can't collect coins twice in a row
                        // handled by seen set
                    }
                    if coins > best { best = coins }
                }
                curr[col][dir] = best
            }
        }
        // swap: current row's DP becomes next for above row
        (curr, next) = (next, curr)
    }
    // Start at row 0, col 0, dir down
    return next[0][DOWN]
}
