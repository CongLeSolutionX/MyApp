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
        
        
        
        self.checkTheAlgorithmWithTestCases()
        
        
    }
    struct ConveyorBelt {
        let startX: Float
        let endX: Float
        let height: Float
    }

    func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int], _ A: [Int], _ B: [Int]) -> Float {
        // 1. Data Representation and Sorting
        var belts: [ConveyorBelt] = []
        for i in 0..<N {
            belts.append(ConveyorBelt(startX: Float(A[i]), endX: Float(B[i]), height: Float(H[i])))
        }
        belts.sort { $0.height > $1.height } // Sort by height, descending
        print("Sorted Belts: \(belts)")

        let totalWidth: Float = 1_000_000.0
        var minExpectedDistance = Float.infinity

        // 2. Iterate through Belts and Directions
        for i in 0..<N {
            for direction in ["left", "right"] {
                print("\n--- Choosing Belt \(i) (\(belts[i])), Direction: \(direction) ---")
                var memo: [Int: Float] = [:] // Memoization: x-coordinate -> expected distance

                func expectedDistance(x: Float, currentHeight: Float) -> Float {
                    print("  expectedDistance(x: \(x), height: \(currentHeight))")
                    // Base Case: Hit the ground
                    if currentHeight <= 0 {
                        print("    Base Case: Ground reached. Returning 0")
                        return 0
                    }

                    // Check Memoization
                    let intX = Int(x)
                    if let cachedDistance = memo[intX] {
                        print("    Memo Hit: Returning cached value \(cachedDistance) for x: \(intX)")
                        return cachedDistance
                    }

                    print("    Memo Miss for x: \(intX). Calculating...")
                    var totalDist: Float = 0.0

                    // Find the *immediate* next belt below the current position
                    var nextBeltIndex: Int? = nil
                    for j in 0..<N {
                        if belts[j].height < currentHeight {
                            nextBeltIndex = j
                            break
                        }
                    }
                    //If there is no next belt, return 0
                    guard let nextBeltIdx = nextBeltIndex else {
                        print("  No belt below. Returning 0")
                        memo[intX] = 0
                        return 0
                    }

                    let nextBelt = belts[nextBeltIdx]
                    print("    Next Belt Below: \(nextBelt)")

                    // If not on any belt, fall down to the *immediate* next belt
                    if x < nextBelt.startX || x > nextBelt.endX {
                        print("    Not on next belt. Recursively calling expectedDistance with x: \(x), height: \(nextBelt.height)")
                        totalDist = expectedDistance(x: x, currentHeight: nextBelt.height)
                    } else {
                        // On the next belt.  Consider both directions (50/50 chance)
                        print("    On next belt. Calculating distances...")
                        let distToLeft = x - nextBelt.startX
                        let distToRight = nextBelt.endX - x
                        print("      distToLeft: \(distToLeft), distToRight: \(distToRight)")
                        totalDist += 0.5 * (distToLeft + expectedDistance(x: nextBelt.startX, currentHeight: nextBelt.height))
                        totalDist += 0.5 * (distToRight + expectedDistance(x: nextBelt.endX, currentHeight: nextBelt.height))
                        print("      Intermediate totalDist (on next belt): \(totalDist)")
                    }

                    print("    Storing in memo: x: \(intX), distance: \(totalDist)")
                    memo[intX] = totalDist
                    print("    Current Memo: \(memo)")
                    return totalDist
                }

                var currentExpectedDistance: Float = 0.0
                let currentBelt = belts[i]
                let beltLength = currentBelt.endX - currentBelt.startX

                // Calculate expected distance for the chosen belt and direction
                var onBeltDistance: Float = 0.0
                if direction == "left" {
                    // Expected distance ON the chosen belt (going left)
                    onBeltDistance = (beltLength / 2.0) * (beltLength / totalWidth)
                    print("  On-Belt Distance (Left): \(onBeltDistance)")
                    currentExpectedDistance += onBeltDistance
                } else { // direction == "right"
                    // Expected distance ON the chosen belt (going right)
                    onBeltDistance = (beltLength / 2.0) * (beltLength / totalWidth)
                    print("  On-Belt Distance (Right): \(onBeltDistance)")
                    currentExpectedDistance += onBeltDistance
                }

                // Expected distance for packages falling to the LEFT of the belt
                let leftDistance = (currentBelt.startX / totalWidth) * expectedDistance(x: currentBelt.startX, currentHeight: currentBelt.height)
                print("  Left-of-Belt Distance: \(leftDistance) (startX: \(currentBelt.startX) / totalWidth: \(totalWidth) * expectedDistance)")
                currentExpectedDistance += leftDistance

                // Expected distance for packages falling to the RIGHT of the belt
                let rightDistance = ((totalWidth - currentBelt.endX) / totalWidth) * expectedDistance(x: currentBelt.endX, currentHeight: currentBelt.height)
                print("  Right-of-Belt Distance: \(rightDistance) ((totalWidth: \(totalWidth) - endX: \(currentBelt.endX)) / totalWidth: \(totalWidth) * expectedDistance)")
                currentExpectedDistance += rightDistance

                print("  Total currentExpectedDistance: \(currentExpectedDistance)")
                minExpectedDistance = min(minExpectedDistance, currentExpectedDistance)
                print("  Current minExpectedDistance: \(minExpectedDistance)")
            }
        }

        return minExpectedDistance
    }

    func checkTheAlgorithmWithTestCases() {
        // Sample Test Cases (from the prompt)
        let N1 = 2
        let H1 = [10, 20]
        let A1 = [100000, 400000]
        let B1 = [600000, 800000]
        let result1 = getMinExpectedHorizontalTravelDistance(N1, H1, A1, B1)
        print(String(format: "%.8f", result1)) // Expected: 155000.00000000

//        let N2 = 5
//        let H2 = [2, 8, 5, 9, 4]
//        let A2 = [5000, 2000, 7000, 9000, 0]
//        let B2 = [7000, 8000, 11000, 11000, 4000]
//        let result2 = getMinExpectedHorizontalTravelDistance(N2, H2, A2, B2)
//        print(String(format: "%.8f", result2)) // Expected: 36.50000000
//
//        let N3 = 4
//        let H3 = [7, 5, 9, 3]
//        let A3 = [2, 4, 0, 6]
//        let B3 = [3, 6, 4, 8]
//        let result3 = getMinExpectedHorizontalTravelDistance(N3, H3, A3, B3)
//        print(String(format: "%.8f", result3))// Expected: 0.5625
        
    }
    
}
