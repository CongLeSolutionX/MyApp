//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
        
        self.runTheSolution()
    }
    
    
    func countPlusSigns(N: Int, L: [Int], D: String) -> Int {
        // Represent Lines (using tuples: (x1, y1, x2, y2))
        var horizontalLines = Set<[Int]>()
        var verticalLines = Set<[Int]>()
        var horizontalPoints = Set<[Int]>() // Points on horizontal lines, stored as [x, y]
        var verticalPoints = Set<[Int]>()   // Points on vertical lines, stored as [x, y]
        
        // Draw Lines
        var currentX = 0
        var currentY = 0
        
        for i in 0..<N {
            let length = L[i]
            let direction = D[i]
            var nextX = currentX
            var nextY = currentY
            
            switch direction {
            case "U":
                nextY += length
                verticalLines.insert([currentX, min(currentY, nextY), currentX, max(currentY, nextY)])
                for y in min(currentY, nextY)...max(currentY, nextY) {
                    verticalPoints.insert([currentX, y])
                }
            case "D":
                nextY -= length
                verticalLines.insert([currentX, min(currentY, nextY), currentX, max(currentY, nextY)])
                for y in min(currentY, nextY)...max(currentY, nextY) {
                    verticalPoints.insert([currentX, y])
                }
            case "L":
                nextX -= length
                horizontalLines.insert([min(currentX, nextX), currentY, max(currentX, nextX), currentY])
                for x in min(currentX, nextX)...max(currentX, nextX) {
                    horizontalPoints.insert([x, currentY])
                }
            case "R":
                nextX += length
                horizontalLines.insert([min(currentX, nextX), currentY, max(currentX, nextX), currentY])
                for x in min(currentX, nextX)...max(currentX, nextX) {
                    horizontalPoints.insert([x, currentY])
                }
            default:
                break
            }
            currentX = nextX
            currentY = nextY
        }
        
        // Find potential intersections (points on BOTH types of lines)
        let potentialIntersections = horizontalPoints.intersection(verticalPoints)
        
        var plusCount = 0
        for point in potentialIntersections {
            let x = point[0]
            let y = point[1]
            
            var hasUp = false
            var hasDown = false
            var hasLeft = false
            var hasRight = false
            
            // Optimized direction checks
            for line in verticalLines {
                if line[0] == x && line[1] < y && line[3] >= y + 1 {
                    hasUp = true
                }
                if line[0] == x && line[1] <= y - 1 && line[3] > y {
                    hasDown = true
                }
            }
            
            for line in horizontalLines {
                if line[1] == y && line[0] < x && line[2] >= x + 1 {
                    hasRight = true
                }
                if line[1] == y && line[0] <= x - 1 && line[2] > x {
                    hasLeft = true
                }
            }
            
            if hasUp && hasDown && hasLeft && hasRight {
                plusCount += 1
            }
        }
        
        return plusCount
    }
    
    func runTheSolution() {
        
        
        
        // Test Cases (Adapted from Python)
        let testCases: [[String: Any]] = [
            // Basic Cases (from the problem description)
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
            ["N": 5, "L": [1, 1, 1, 1, 1], "D": "RULDU", "expected": 1], // Forms a '+' and moves up
            ["N": 8, "L": [2, 2, 2, 2, 2, 2, 2, 2], "D": "RULDURDL", "expected": 2],
            ["N": 9, "L": [1,1,1,1,1,1,1,1,1], "D": "RULDURDLU", "expected":2],
            
            
            // Overlapping Lines (shouldn't affect plus sign count)
            ["N": 5, "L": [1, 1, 1, 1, 2], "D": "RULD", "expected": 1],  // Overlap on last move
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RULDDU", "expected": 1],  // Overlapping vertical
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RURLDL", "expected": 1], // Overlapping horizontal.
            
            // Large L Values
            ["N": 4, "L": [1000000, 1000000, 1000000, 1000000], "D": "RULD", "expected": 1],
            ["N": 2, "L": [1000000000, 1000000000], "D": "RU", "expected": 0],
            
            // Zig-Zag Patterns (testing intersection logic)
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "RURURU", "expected": 0],
            ["N": 6, "L": [1, 1, 1, 1, 1, 1], "D": "DRDRDR", "expected": 0],
            ["N": 7, "L": [1, 2, 1, 2, 1, 2, 1], "D": "RURURUR", "expected": 0],
            
            // Edge Cases
            ["N": 2, "L": [1, 1], "D": "RU", "expected": 0],  // Minimum N
            ["N": 2, "L": [1, 1], "D": "RD", "expected": 0], // Two segments
            ["N": 3, "L": [1,1,1], "D": "RUL", "expected": 0],
            
            // Dense Grid (many intersections)
            ["N": 8, "L": [1, 1, 1, 1, 1, 1, 1, 1], "D": "RULDURDL", "expected": 2],
            ["N": 12, "L": [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], "D": "RULDURDLUULD", "expected": 3],
            
            // Long lines with few intersections
            ["N": 4, "L": [1000, 1, 1000, 1], "D": "RULD", "expected": 1],
            ["N": 4, "L": [1, 1000, 1, 1000], "D": "RULD", "expected": 1],
            
            //Alternating short and long lines
            [ "N": 8, "L": [1, 1000, 1, 1000, 1, 1000, 1, 1000], "D": "RULDURDL", "expected": 2],
            [ "N": 8, "L": [1000, 1, 1000, 1, 1000, 1, 1000, 1], "D": "RULDURDL", "expected": 2],
            
            // Very large lines, only two, forming no intersections
            ["N": 2, "L": [999999999, 999999999], "D": "RU", "expected": 0],
            ["N": 2, "L": [999999999, 999999999], "D": "RL", "expected": 0],
            
            // A larger 'plus'
            ["N": 4, "L": [5,5,5,5], "D": "RULD", "expected": 1],
            
            // Same start/end points but different lengths
            ["N": 5, "L": [1, 2, 1, 2, 2], "D": "RULDR", "expected": 1],
            ["N": 5, "L": [2, 4, 3, 1, 1], "D":"URDLU", "expected": 0],
        ]
        
        for (index, testCase) in testCases.enumerated() {
            let N = testCase["N"] as! Int
            let L = testCase["L"] as! [Int]
            let D = testCase["D"] as! [String]
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
