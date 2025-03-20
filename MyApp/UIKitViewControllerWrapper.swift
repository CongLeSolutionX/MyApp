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
    
    func expectedDistance(startingBeltIndex: Int, direction: String, allBelts: [ConveyorBelt]) -> Float {
        let totalWidth: Float = 1_000_000.0
        let startingBelt = allBelts[startingBeltIndex]
        let beltWidth = startingBelt.endX - startingBelt.startX
        
        // Starting X position based on direction
        let startX: Float = (direction == "left") ? startingBelt.startX : startingBelt.endX
        
        //Recursive helper function to be called
        func recursiveExpectedDistance(x: Float, currentHeight: Float, allBelts: [ConveyorBelt]) -> Float{
            // Base Case: Hit the ground
            if currentHeight <= 0 {
                return 0
            }
            
            // Find the *immediate* next belt below the current position
            var nextBeltIndex: Int? = nil
            for j in 0..<allBelts.count {
                if allBelts[j].height < currentHeight {
                    nextBeltIndex = j
                    break
                }
            }
            
            //If there is no next belt, return 0
            guard let nextBeltIdx = nextBeltIndex else {
                return 0
            }
            
            let nextBelt = allBelts[nextBeltIdx]
            
            // If not on any belt, fall down to the *immediate* next belt
            if x < nextBelt.startX || x > nextBelt.endX {
                return recursiveExpectedDistance(x: x, currentHeight: nextBelt.height, allBelts: allBelts)
            } else {
                // On the next belt.  Consider both directions (50/50 chance)
                let distToLeft = x - nextBelt.startX
                let distToRight = nextBelt.endX - x
                
                let totalDist = 0.5 * (distToLeft + recursiveExpectedDistance(x: nextBelt.startX, currentHeight: nextBelt.height, allBelts: allBelts))
                + 0.5 * (distToRight + recursiveExpectedDistance(x: nextBelt.endX, currentHeight: nextBelt.height, allBelts: allBelts))
                return totalDist
            }
        }
        
        // Calculate the weighted average of expected distances
        var totalExpectedDistance: Float = 0.0
        
        // Packages starting ON the chosen belt
        if direction == "left"{
            totalExpectedDistance += (beltWidth / totalWidth) * (beltWidth / 2.0)
        }else{
            totalExpectedDistance += (beltWidth / totalWidth) * (beltWidth / 2.0)
        }
        
        // Packages starting to the LEFT of the chosen belt
        totalExpectedDistance += (startX / totalWidth) * recursiveExpectedDistance(x: startX, currentHeight: startingBelt.height, allBelts: allBelts)
        
        // Packages starting to the RIGHT of the chosen belt
        totalExpectedDistance += ((totalWidth - startX) / totalWidth) * recursiveExpectedDistance(x: startX, currentHeight: startingBelt.height, allBelts: allBelts)
        
        return totalExpectedDistance
    }
    
    func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int], _ A: [Int], _ B: [Int]) -> Float {
        var belts: [ConveyorBelt] = []
        for i in 0..<N {
            belts.append(ConveyorBelt(startX: Float(A[i]), endX: Float(B[i]), height: Float(H[i])))
        }
        belts.sort { $0.height > $1.height }
        
        var minDistance = Float.infinity
        
        // Iterate through all possible STARTING belts and directions
        for i in 0..<N {
            for direction in ["left", "right"] {
                let distance = expectedDistance(startingBeltIndex: i, direction: direction, allBelts: belts)
                minDistance = min(minDistance, distance)
            }
        }
        
        return minDistance
    }
    
    func checkTheAlgorithmWithTestCases() {
        // Simplified Test Cases
        let N1 = 2
        let H1 = [10, 20]
        let A1 = [100000, 400000]
        let B1 = [600000, 800000]
        let result1 = getMinExpectedHorizontalTravelDistance(N1, H1, A1, B1)
        print(String(format: "%.8f", result1))
        
        let N2 = 5
        let H2 = [2, 8, 5, 9, 4]
        let A2 = [5000, 2000, 7000, 9000, 0]
        let B2 = [7000, 8000, 11000, 11000, 4000]
        let result2 = getMinExpectedHorizontalTravelDistance(N2, H2, A2, B2)
        print(String(format: "%.8f", result2))
        
        let N3 = 4
        let H3 = [7, 5, 9, 3]
        let A3 = [2, 4, 0, 6]
        let B3 = [3, 6, 4, 8]
        let result3 = getMinExpectedHorizontalTravelDistance(N3, H3, A3, B3)
        print(String(format: "%.8f", result3))
    } 
}
