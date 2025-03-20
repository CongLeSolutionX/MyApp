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
        
        // Test Cases
        let N1 = 9
        let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
        let D1 = ["U", "L", "D", "R", "U", "L", "U", "R", "D"]
        print(countPlusSigns(N: N1, L: L1, D: D1)) // Output: 4

        let N2 = 8
        let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
        let D2 = ["R", "D", "L", "U", "U", "L", "D", "R"]
        print(countPlusSigns(N: N2, L: L2, D: D2)) // Output: 1

        let N3 = 8
        let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
        let D3 = ["U", "D", "U", "D", "L", "R", "L", "R"]
        print(countPlusSigns(N: N3, L: L3, D: D3)) // Output: 1

        let N4 = 2
        let L4 = [1000000000, 999999999]
        let D4 = ["U", "L"]
        print(countPlusSigns(N: N4, L: L4, D: D4))  // 0

        let N5 = 4
        let L5 = [1,1,1,1]
        let D5 = ["R", "U", "L", "D"]
        print(countPlusSigns(N: N5, L: L5, D: D5)) // 1

        let N6 = 4
        let L6 = [2, 1, 1, 3]
        let D6 = ["U", "L", "R", "D"]
        print(countPlusSigns(N: N6, L: L6, D: D6))//0
    }
    
    func countPlusSigns(N: Int, L: [Int], D: [String]) -> Int {
        // 1. Represent Lines (using tuples: (x1, y1, x2, y2))
        var horizontalLines = Set<[Int]>()
        var verticalLines = Set<[Int]>()

        // 2. Keep track of all used x and y coordinates to check for intersections
        var allX = Set<Int>()
        var allY = Set<Int>()
        
        // 3. Draw Lines
        var currentX = 0
        var currentY = 0
        allX.insert(0)
        allY.insert(0)

        for i in 0..<N {
            let length = L[i]
            let direction = D[i]
            var nextX = currentX
            var nextY = currentY

            switch direction {
            case "U":
                nextY += length
                verticalLines.insert([currentX, min(currentY, nextY), currentX, max(currentY, nextY)])
            case "D":
                nextY -= length
                verticalLines.insert([currentX, min(currentY, nextY), currentX, max(currentY, nextY)])
            case "L":
                nextX -= length
                horizontalLines.insert([min(currentX, nextX), currentY, max(currentX, nextX), currentY])
            case "R":
                nextX += length
                horizontalLines.insert([min(currentX, nextX), currentY, max(currentX, nextX), currentY])
            default:
                break
            }
            allX.insert(nextX)
            allY.insert(nextY)
            currentX = nextX
            currentY = nextY
        }

        // 4. Check for Plus Signs
        var plusCount = 0

          for x in allX {
            for y in allY {
                // Check for lines in all four directions
                var hasUp = false
                var hasDown = false
                var hasLeft = false
                var hasRight = false
                
                //Efficient direction checking.
                for line in verticalLines {
                    if line[0] == x && line[1] <= y && line[3] >= y && line[1] != line[3] { // Vertical line containing (x,y)
                       if(y < line[3]){
                           hasUp = true
                       }
                        if(y > line[1]){
                            hasDown = true
                        }
                    }
                }
                for line in horizontalLines {
                    if line[1] == y && line[0] <= x && line[2] >= x && line[0] != line[2]{ // Horizontal Line containing (x, y)
                        if(x < line[2]){
                            hasRight = true
                        }
                        if(x > line[0]){
                            hasLeft = true
                        }
                    }
                }

                if hasUp && hasDown && hasLeft && hasRight {
                    plusCount += 1
                }
            }
        }

        return plusCount
    }
}
