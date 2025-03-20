//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
import SwiftUI
import UIKit

// MARK: - Custom Structures

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct LineSegment: Hashable {
    let start: Point  // For horizontal segments, start.x <= end.x; for vertical segments, start.y <= end.y.
    let end: Point
}

// MARK: - SwiftUI Wrapper for the UIKit View Controller

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update if needed.
    }
}

// MARK: - Example UIKit View Controller

class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Run the solution once the view has loaded.
        runTheSolution()
    }
    
    /// Counts the number of valid plus signs formed by the drawn lines.
    /// - Parameters:
    ///   - N: The number of segments.
    ///   - L: The array of segment lengths.
    ///   - D: A string that holds the direction for each segment (each character is one of "U", "D", "L", or "R").
    /// - Returns: The number of plus signs.
    func countPlusSigns(N: Int, L: [Int], D: String) -> Int {
        // Use custom structs for lines and points.
        var horizontalLines = Set<LineSegment>()
        var verticalLines = Set<LineSegment>()
        var horizontalPoints = Set<Point>()
        var verticalPoints = Set<Point>()
        
        var currentX = 0, currentY = 0
        
        // Draw each segment.
        for i in 0..<N {
            let length = L[i]
            // Use the appropriate index in the string.
            let directionChar = D[D.index(D.startIndex, offsetBy: i)]
            var nextX = currentX
            var nextY = currentY
            
            switch directionChar {
            case "U":
                nextY += length
                let ymin = min(currentY, nextY)
                let ymax = max(currentY, nextY)
                let segment = LineSegment(start: Point(x: currentX, y: ymin),
                                          end: Point(x: currentX, y: ymax))
                verticalLines.insert(segment)
                for y in ymin...ymax {
                    verticalPoints.insert(Point(x: currentX, y: y))
                }
            case "D":
                nextY -= length
                let ymin = min(currentY, nextY)
                let ymax = max(currentY, nextY)
                let segment = LineSegment(start: Point(x: currentX, y: ymin),
                                          end: Point(x: currentX, y: ymax))
                verticalLines.insert(segment)
                for y in ymin...ymax {
                    verticalPoints.insert(Point(x: currentX, y: y))
                }
            case "L":
                nextX -= length
                let xmin = min(currentX, nextX)
                let xmax = max(currentX, nextX)
                let segment = LineSegment(start: Point(x: xmin, y: currentY),
                                          end: Point(x: xmax, y: currentY))
                horizontalLines.insert(segment)
                for x in xmin...xmax {
                    horizontalPoints.insert(Point(x: x, y: currentY))
                }
            case "R":
                nextX += length
                let xmin = min(currentX, nextX)
                let xmax = max(currentX, nextX)
                let segment = LineSegment(start: Point(x: xmin, y: currentY),
                                          end: Point(x: xmax, y: currentY))
                horizontalLines.insert(segment)
                for x in xmin...xmax {
                    horizontalPoints.insert(Point(x: x, y: currentY))
                }
            default:
                break
            }
            
            currentX = nextX
            currentY = nextY
        }
        
        // Identify points that lie on both horizontal and vertical drawn segments.
        let potentialIntersections = horizontalPoints.intersection(verticalPoints)
        var plusCount = 0
        
        // For every intersection point, check for arms in all four directions.
        for point in potentialIntersections {
            let x = point.x, y = point.y
            var hasUp = false, hasDown = false, hasLeft = false, hasRight = false
            
            // Check vertical lines for upward and downward extensions.
            for segment in verticalLines {
                if segment.start.x == x {
                    if segment.start.y <= y && segment.end.y >= y + 1 { hasUp = true }
                    if segment.start.y <= y - 1 && segment.end.y >= y { hasDown = true }
                }
                if hasUp && hasDown { break }
            }
            
            // Check horizontal lines for leftward and rightward extensions.
            for segment in horizontalLines {
                if segment.start.y == y {
                    if segment.start.x <= x && segment.end.x >= x + 1 { hasRight = true }
                    if segment.start.x <= x - 1 && segment.end.x >= x { hasLeft = true }
                }
                if hasLeft && hasRight { break }
            }
            
            if hasUp && hasDown && hasLeft && hasRight {
                plusCount += 1
            }
        }
        
        return plusCount
    }
    
    /// Runs a suite of tests to validate the plus sign count.
    func runTheSolution() {
        let testCases: [[String: Any]] = [
            // Basic Cases
            ["N": 9, "L": [6, 3, 4, 5, 1, 6, 3, 3, 4], "D": "ULDRULURD", "expected": 4],
            ["N": 8, "L": [1, 1, 1, 1, 1, 1, 1, 1], "D": "RDLUULDR", "expected": 1],
            ["N": 8, "L": [1, 2, 2, 1, 1, 2, 2, 1], "D": "UDUDLRLR", "expected": 1],
            
            // No Plus Signs
            ["N": 2, "L": [1000000000, 999999999], "D": "UL", "expected": 0],
            ["N": 4, "L": [2, 1, 1, 3], "D": "ULRD", "expected": 0],
            ["N": 3, "L": [1, 2, 3], "D": "UUU", "expected": 0],
            ["N": 3, "L": [1, 2, 3], "D": "RRR", "expected": 0],
            ["N": 2, "L": [5, 5], "D": "RU", "expected": 0],
            
            // Single Plus Sign
            ["N": 4, "L": [1, 1, 1, 1], "D": "RULD", "expected": 1],
            ["N": 4, "L": [2, 2, 2, 2], "D": "RULD", "expected": 1],
            ["N": 4, "L": [10,10,10,10], "D": "RDLU", "expected": 1],
            
            // Multiple Plus Signs
            ["N": 5, "L": [1, 1, 1, 1, 1], "D": "RULDU", "expected": 1],
            ["N": 8, "L": [2, 2, 2, 2, 2, 2, 2, 2], "D": "RULDURDL", "expected": 2],
            ["N": 9, "L": [1,1,1,1,1,1,1,1,1], "D": "RULDURDLU", "expected": 2],
            
            // Overlapping Lines
            ["N": 5, "L": [1, 1, 1, 1, 2], "D": "RULD", "expected": 1],
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RULDDU", "expected": 1],
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RURLDL", "expected": 1],
            
            // Large L Values
            ["N": 4, "L": [1000000, 1000000, 1000000, 1000000], "D": "RULD", "expected": 1],
            ["N": 2, "L": [1000000000, 1000000000], "D": "RU", "expected": 0],
            
            // Zig-Zag Patterns
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RURURU", "expected": 0],
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "DRDRDR", "expected": 0],
            ["N": 7, "L": [1, 2, 1, 2, 1, 2, 1], "D": "RURURUR", "expected": 0],
            
            // Edge Cases
            ["N": 2, "L": [1, 1], "D": "RU", "expected": 0],
            ["N": 2, "L": [1, 1], "D": "RD", "expected": 0],
            ["N": 3, "L": [1,1,1], "D": "RUL", "expected": 0],
            
            // Dense Grid
            ["N": 8, "L": [1, 1, 1, 1, 1, 1, 1, 1], "D": "RULDURDL", "expected": 2],
            ["N": 12, "L": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], "D": "RULDURDLUULD", "expected": 3],
            
            // Long lines with few intersections
            ["N": 4, "L": [1000, 1, 1000, 1], "D": "RULD", "expected": 1],
            ["N": 4, "L": [1, 1000, 1, 1000], "D": "RULD", "expected": 1],
            
            // Alternating short and long lines
            [ "N": 8, "L": [1, 1000, 1, 1000, 1, 1000, 1, 1000], "D": "RULDURDL", "expected": 2],
            [ "N": 8, "L": [1000, 1, 1000, 1, 1000, 1, 1000, 1], "D": "RULDURDL", "expected": 2],
            
            // Very large lines, only two segments
            ["N": 2, "L": [999999999, 999999999], "D": "RU", "expected": 0],
            ["N": 2, "L": [999999999, 999999999], "D": "RL", "expected": 0],
            
            // A larger 'plus'
            ["N": 4, "L": [5,5,5,5], "D": "RULD", "expected": 1],
            
            // Same start/end points but different lengths
            ["N": 5, "L": [1, 2, 1, 2, 2], "D": "RULDR", "expected": 1],
            ["N": 5, "L": [2, 4, 3, 1, 1], "D": "URDLU", "expected": 0],
        ]
        
        for (index, testCase) in testCases.enumerated() {
            let N = testCase["N"] as! Int
            let L = testCase["L"] as! [Int]
            let D = testCase["D"] as! String
            let expected = testCase["expected"] as! Int
            let result = countPlusSigns(N: N, L: L, D: D)
            if result == expected {
                print("Test Case \(index + 1): PASSED (Expected: \(expected), Got: \(result))")
            } else {
                print("Test Case \(index + 1): FAILED (Expected: \(expected), Got: \(result))")
            }
        }
    }
}
