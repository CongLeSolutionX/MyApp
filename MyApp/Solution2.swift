//
//  Solution2.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//
import Foundation

func getPlusSignCount(_ N: Int, _ L: [Int], _ D: String) -> Int {
    // 1. Track all stroke endpoints and collect unique coordinates for compression
    var points = [(x: Int, y: Int)]()
    var xCoords = [Int]()
    var yCoords = [Int]()
    
    var currentX = 0
    var currentY = 0
    
    points.append((currentX, currentY))
    xCoords.append(currentX)
    yCoords.append(currentY)
    
    for i in 0..<N {
        let length = L[i]
        let dir = D[D.index(D.startIndex, offsetBy: i)]
        
        switch dir {
        case "U": currentY += length
        case "D": currentY -= length
        case "L": currentX -= length
        case "R": currentX += length
        default: break
        }
        
        points.append((currentX, currentY))
        xCoords.append(currentX)
        yCoords.append(currentY)
    }
    
    // 2. Coordinate compression
    let uniqueX = Array(Set(xCoords)).sorted()
    let uniqueY = Array(Set(yCoords)).sorted()
    
    func compressX(_ x: Int) -> Int {
        return binarySearch(array: uniqueX, target: x)
    }
    
    func compressY(_ y: Int) -> Int {
        return binarySearch(array: uniqueY, target: y)
    }
    
    // 3. Extract horizontal and vertical segments using compressed coordinates
    var horizontalSegments = [Int: [(start: Int, end: Int)]]()  // key: compressed Y, intervals on X
    var verticalSegments = [Int: [(start: Int, end: Int)]]()    // key: compressed X, intervals on Y
    
    for i in 0..<N {
        let x1 = compressX(points[i].x)
        let y1 = compressY(points[i].y)
        let x2 = compressX(points[i+1].x)
        let y2 = compressY(points[i+1].y)
        
        if y1 == y2 {
            // horizontal segment
            let startX = min(x1, x2)
            let endX = max(x1, x2)
            horizontalSegments[y1, default: []].append((start: startX, end: endX))
        } else if x1 == x2 {
            // vertical segment
            let startY = min(y1, y2)
            let endY = max(y1, y2)
            verticalSegments[x1, default: []].append((start: startY, end: endY))
        }
    }
    
    // 4. Merge intervals for all horizontal and vertical line groups
    func mergeIntervals(_ intervals: [(start: Int, end: Int)]) -> [(start: Int, end: Int)] {
        guard !intervals.isEmpty else { return [] }
        let sorted = intervals.sorted { $0.start < $1.start }
        var merged = [(start: Int, end: Int)]()
        merged.append(sorted[0])
        
        for interval in sorted.dropFirst() {
            var last = merged.removeLast()
            if interval.start <= last.end + 1 {
                // overlapping or contiguous, merge
                last.end = max(last.end, interval.end)
                merged.append(last)
            } else {
                merged.append(last)
                merged.append(interval)
            }
        }
        return merged
    }
    
    for key in horizontalSegments.keys {
        horizontalSegments[key] = mergeIntervals(horizontalSegments[key]!)
    }
    
    for key in verticalSegments.keys {
        verticalSegments[key] = mergeIntervals(verticalSegments[key]!)
    }
    
    // 5. Helper function: binary search to check if a point falls inside any interval
    // intervals must be sorted and non-overlapping (merged)
    func intervalContains(_ intervals: [(start: Int, end: Int)], _ point: Int) -> Bool {
        // Binary search to find interval where point could lie
        var left = 0
        var right = intervals.count - 1
        
        while left <= right {
            let mid = (left + right) / 2
            let interval = intervals[mid]
            
            if point < interval.start {
                right = mid - 1
            } else if point > interval.end {
                left = mid + 1
            } else {
                // point in [start, end]
                return true
            }
        }
        return false
    }
    
    // Checks presence of points strictly above and below a point in intervals
    func hasUpAndDown(_ intervals: [(start: Int, end: Int)], _ point: Int) -> Bool {
        // Find the interval containing point
        // Then check if interval has space strictly above and strictly below point
        // Since intervals are merged, only one interval can contain the point
        guard let index = intervals.firstIndex(where: { $0.start <= point && point <= $0.end }) else {
            return false
        }
        let interval = intervals[index]
        
        let hasUp = point < interval.end         // something above
        let hasDown = point > interval.start     // something below
        
        return hasUp && hasDown
    }
    
    // Checks presence of points strictly left and right of a point in intervals
    func hasLeftAndRight(_ intervals: [(start: Int, end: Int)], _ point: Int) -> Bool {
        // Similar logic as hasUpAndDown
        guard let index = intervals.firstIndex(where: { $0.start <= point && point <= $0.end }) else {
            return false
        }
        let interval = intervals[index]
        
        let hasLeft = point > interval.start
        let hasRight = point < interval.end
        
        return hasLeft && hasRight
    }
    
    // 6. Check candidate points: only stroke endpoints
    var plusCount = 0
    
    for p in points {
        let cx = compressX(p.x)
        let cy = compressY(p.y)
        
        // Get vertical intervals at x == cx and horizontal intervals at y == cy
        guard let vIntervals = verticalSegments[cx], intervalContains(vIntervals, cy) else { continue }
        guard let hIntervals = horizontalSegments[cy], intervalContains(hIntervals, cx) else { continue }
        
        // Verify that there's paint going up and down vertically and left and right horizontally
        if hasUpAndDown(vIntervals, cy) && hasLeftAndRight(hIntervals, cx) {
            plusCount += 1
        }
    }
    
    return plusCount
}

// Standard binary search (returns index of target)
func binarySearch(array: [Int], target: Int) -> Int {
    var low = 0
    var high = array.count - 1
    
    while low <= high {
        let mid = (low + high) / 2
        if array[mid] == target {
            return mid
        } else if array[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    // If not found, return insertion point (should not happen as all targets are in compressed arrays)
    return low
}
