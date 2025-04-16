////
////  Solution2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//
//struct ConveyorBelt {
//    let startX: Float
//    let endX: Float
//    let height: Float
//}
//
//func expectedDistance(startingBeltIndex: Int, direction: String, allBelts: [ConveyorBelt]) -> Float {
//    let totalWidth: Float = 1_000_000.0
//    let startingBelt = allBelts[startingBeltIndex]
//    let beltWidth = startingBelt.endX - startingBelt.startX
//
//    // Starting X position based on direction
//    let startX: Float = (direction == "left") ? startingBelt.startX : startingBelt.endX
//
//    //Recursive helper function to be called
//    func recursiveExpectedDistance(x: Float, currentHeight: Float, allBelts: [ConveyorBelt], onInitialBelt: Bool) -> Float{
//        // Base Case: Hit the ground
//        if currentHeight <= 0 {
//            return 0
//        }
//
//        // Find the *immediate* next belt below the current position
//        var nextBeltIndex: Int? = nil
//        for j in 0..<allBelts.count {
//            if allBelts[j].height < currentHeight {
//                nextBeltIndex = j
//                break
//            }
//        }
//
//        //If there is no next belt, return 0
//        guard let nextBeltIdx = nextBeltIndex else {
//            return 0
//        }
//
//        let nextBelt = allBelts[nextBeltIdx]
//
//        // If not on any belt, fall down to the *immediate* next belt
//        if x < nextBelt.startX || x > nextBelt.endX {
//            return recursiveExpectedDistance(x: x, currentHeight: nextBelt.height, allBelts: allBelts, onInitialBelt: false)
//        } else {
//            // On the next belt.
//            if onInitialBelt {
//                // If we're on the initial belt, we *must* go in the chosen direction.
//                if direction == "left" {
//                    return x - nextBelt.startX + recursiveExpectedDistance(x: nextBelt.startX, currentHeight: nextBelt.height, allBelts: allBelts, onInitialBelt: false)
//                } else { // direction == "right"
//                    return nextBelt.endX - x + recursiveExpectedDistance(x: nextBelt.endX, currentHeight: nextBelt.height, allBelts: allBelts, onInitialBelt: false)
//                }
//            } else {
//                // On a subsequent belt, consider both directions (50/50 chance)
//                let distToLeft = x - nextBelt.startX
//                let distToRight = nextBelt.endX - x
//
//                let totalDist = 0.5 * (distToLeft + recursiveExpectedDistance(x: nextBelt.startX, currentHeight: nextBelt.height, allBelts: allBelts, onInitialBelt: false))
//                + 0.5 * (distToRight + recursiveExpectedDistance(x: nextBelt.endX, currentHeight: nextBelt.height, allBelts: allBelts, onInitialBelt: false))
//                return totalDist
//            }
//        }
//    }
//
//    // Calculate the weighted average of expected distances
//    var totalExpectedDistance: Float = 0.0
//
//    // Packages starting ON the chosen belt.  We handle this *inside* recursiveExpectedDistance now.
//    totalExpectedDistance += (beltWidth / totalWidth) * recursiveExpectedDistance(x: startX, currentHeight: startingBelt.height, allBelts: allBelts, onInitialBelt: true)
//
//    // Packages starting to the LEFT of the chosen belt
//    if startingBelt.startX > 0 { // Only if there's space to the left
//        totalExpectedDistance += (startX / totalWidth) * recursiveExpectedDistance(x: startX, currentHeight: startingBelt.height, allBelts: allBelts, onInitialBelt: false)
//    }
//
//    // Packages starting to the RIGHT of the chosen belt
//     if startingBelt.endX < totalWidth { //Only if there's space to the right
//        totalExpectedDistance += ((totalWidth - startX) / totalWidth) * recursiveExpectedDistance(x: startX, currentHeight: startingBelt.height, allBelts: allBelts, onInitialBelt: false)
//    }
//
//    return totalExpectedDistance
//}
//
//func getMinExpectedHorizontalTravelDistance(_ N: Int, _ H: [Int], _ A: [Int], _ B: [Int]) -> Float {
//    var belts: [ConveyorBelt] = []
//    for i in 0..<N {
//        belts.append(ConveyorBelt(startX: Float(A[i]), endX: Float(B[i]), height: Float(H[i])))
//    }
//    belts.sort { $0.height > $1.height }
//
//    var minDistance = Float.infinity
//
//    // Iterate through all possible STARTING belts and directions
//    for i in 0..<N {
//        for direction in ["left", "right"] {
//            let distance = expectedDistance(startingBeltIndex: i, direction: direction, allBelts: belts)
//            minDistance = min(minDistance, distance)
//        }
//    }
//
//    return minDistance
//}
//
//func checkTheAlgorithmWithTestCases() {
//    // Simplified Test Cases
//    let N1 = 2
//    let H1 = [10, 20]
//    let A1 = [100000, 400000]
//    let B1 = [600000, 800000]
//    let result1 = getMinExpectedHorizontalTravelDistance(N1, H1, A1, B1)
//    print(String(format: "%.8f", result1)) // Expected: 155000
//
//    let N2 = 5
//    let H2 = [2, 8, 5, 9, 4]
//    let A2 = [5000, 2000, 7000, 9000, 0]
//    let B2 = [7000, 8000, 11000, 11000, 4000]
//    let result2 = getMinExpectedHorizontalTravelDistance(N2, H2, A2, B2)
//    print(String(format: "%.8f", result2)) // Expected: 36.5
//
//    let N3 = 4
//    let H3 = [7, 5, 9, 3]
//    let A3 = [2, 4, 0, 6]
//    let B3 = [3, 6, 4, 8]
//    let result3 = getMinExpectedHorizontalTravelDistance(N3, H3, A3, B3)
//    print(String(format: "%.8f", result3)) // Expected: 0.5625
//    
//}
