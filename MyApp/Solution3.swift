//
//  Solution3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import Foundation

func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // Extract points and compress coordinates
    var points = [(x: Int, y: Int)]()
    var xCoords = [Int]()
    var yCoords = [Int]()
    var currentX = 0
    var currentY = 0
    
    points.append((x: currentX, y: currentY))
    xCoords.append(currentX)
    yCoords.append(currentY)
    
    let DArray = Array(D)  // For efficient indexing
    
    for i in 0..<N {
        let length = L[i]
        switch DArray[i] {
        case "U":
            currentY += length
        case "D":
            currentY -= length
        case "L":
            currentX -= length
        case "R":
            currentX += length
        default:
            break
        }
        points.append((x: currentX, y: currentY))
        xCoords.append(currentX)
        yCoords.append(currentY)
    }
    
    // Coordinate compression
    let uniqueX = Array(Set(xCoords)).sorted()
    let uniqueY = Array(Set(yCoords)).sorted()
    
    func compressX(_ x: Int) -> Int {
        var low = 0, high = uniqueX.count - 1
        while low <= high {
            let mid = (low + high) / 2
            if uniqueX[mid] == x { return mid }
            else if uniqueX[mid] < x { low = mid + 1 }
            else { high = mid - 1 }
        }
        return low
    }
    
    func compressY(_ y: Int) -> Int {
        var low = 0, high = uniqueY.count - 1
        while low <= high {
            let mid = (low + high) / 2
            if uniqueY[mid] == y { return mid }
            else if uniqueY[mid] < y { low = mid + 1 }
            else { high = mid - 1 }
        }
        return low
    }
    
    let width = uniqueX.count
    let height = uniqueY.count
    
    // Arrays for horizontal and vertical strokes coverage:
    // For each Y, mark presence intervals of paint in X.
    // For each X, mark presence intervals of paint in Y.
    
    // horizontalLines[y][x] = 1 if paint is on (x,y)
    // verticalLines[x][y] = 1 if paint is on (x,y)
    
    // We will not build full 2D arrays due to size, instead we store segment markings on 1D arrays with prefix sums.
    
    var horizontalPaint = Array(repeating: Array(repeating: 0, count: width), count: height)
    var verticalPaint = Array(repeating: Array(repeating: 0, count: height), count: width)
    
    // Mark paint presence for all strokes
    for i in 0..<N {
        let x1 = compressX(points[i].x)
        let y1 = compressY(points[i].y)
        let x2 = compressX(points[i+1].x)
        let y2 = compressY(points[i+1].y)
        
        if y1 == y2 {
            // horizontal stroke -- mark from minX to maxX in horizontalPaint[y1]
            let startX = min(x1, x2)
            let endX = max(x1, x2)
            for x in startX...endX {
                horizontalPaint[y1][x] = 1
            }
        } else if x1 == x2 {
            // vertical stroke -- mark from minY to maxY in verticalPaint[x1]
            let startY = min(y1, y2)
            let endY = max(y1, y2)
            for y in startY...endY {
                verticalPaint[x1][y] = 1
            }
        }
    }
    
    // Precompute prefix sums on horizontalPaint per row
    for y in 0..<height {
        for x in 1..<width {
            horizontalPaint[y][x] += horizontalPaint[y][x - 1]
        }
    }
    
    // Precompute prefix sums on verticalPaint per column
    for x in 0..<width {
        for y in 1..<height {
            verticalPaint[x][y] += verticalPaint[x][y - 1]
        }
    }
    
    // Helper function: range sum in prefix sums [l, r] inclusive
    func rangeSum(_ arr: [Int], _ l: Int, _ r: Int) -> Int {
        if l > r { return 0 }
        return arr[r] - (l > 0 ? arr[l - 1] : 0)
    }
    
    var plusCount = 0
    
    // Now check all possible candidate points at intersections of uniqueX and uniqueY:
    // candidate points: all (x_idx, y_idx)
    
    for x in 0..<width {
        for y in 0..<height {
            // Check paint extending up and down on vertical line at x:
            // paint above: verticalPaint[x][height-1] - verticalPaint[x][y] > 0 ?
            // paint below: verticalPaint[x][y-1] - verticalPaint[x][0-1]? but can't have -1 so check y>0
            
            let verticalCol = verticalPaint[x]
            let paintAbove = (y < height - 1) ? (verticalCol[height - 1] - verticalCol[y]) : 0
            let paintBelow = (y > 0) ? verticalCol[y - 1] : 0
            
            if paintAbove == 0 || paintBelow == 0 {
                continue
            }
            
            // Check paint extending left and right on horizontal line at y:
            // paint right: horizontalPaint[y][width-1] - horizontalPaint[y][x]
            // paint left: horizontalPaint[y][x-1]
            
            let horizontalRow = horizontalPaint[y]
            let paintRight = (x < width - 1) ? (horizontalRow[width - 1] - horizontalRow[x]) : 0
            let paintLeft = (x > 0) ? horizontalRow[x - 1] : 0
            
            if paintRight == 0 || paintLeft == 0 {
                continue
            }
            
            // This position is a plus sign
            plusCount += 1
        }
    }
    
    return plusCount
}
