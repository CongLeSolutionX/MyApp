//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 4/25/25.
//
import SwiftUI
import UIKit


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
        runSolution()
    }
    
    func runSolution() {
        
        // --- Sample Tests (Using Optimized Approach) ---
        print("--- Running Sample Test Cases (Optimized Endpoint Check) ---")
        let N1 = 9; let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]; let D1 = "ULDRULURD"; let result1 = getPlusSignCount(N1, L1, D1); print("Sample 1 Result: \(result1) (\(result1 == 4 ? "Correct" : "Incorrect"), Expected: 4)")
        let N2 = 8; let L2 = [1, 1, 1, 1, 1, 1, 1, 1]; let D2 = "RDLUULDR"; let result2 = getPlusSignCount(N2, L2, D2); print("Sample 2 Result: \(result2) (\(result2 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
        let N3 = 8; let L3 = [1, 2, 2, 1, 1, 2, 2, 1]; let D3 = "UDUDLRLR"; let result3 = getPlusSignCount(N3, L3, D3); print("Sample 3 Result: \(result3) (\(result3 == 1 ? "Correct" : "Incorrect"), Expected: 1)")
        
        print("\n--- Running Boundary/Edge Test Cases (Optimized Endpoint Check) ---")
        let N4 = 4; let L4 = [5, 2, 5, 2]; let D4 = "RDLU"; let result4 = getPlusSignCount(N4, L4, D4); print("Sample 4 (Rectangle) Result: \(result4) (\(result4 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
        let N5 = 5; let L5 = [2, 2, 2, 2, 4]; let D5 = "RULD R"; let result5 = getPlusSignCount(N5, L5, D5); // Note: Typo in D5 assumed RDULR
        print("Sample 5 (Overlap) Result: Skipped due to unclear D5") // Original problem likely used 'RDULR' -> gives 1 plus at (0,0). Path: (0,0)->(2,0)->(2,-2)->(0,-2)->(0,0)->(4,0)
        let N6 = 4; let L6 = [5, 2, 3, 4]; let D6 = "RDLU"; let result6 = getPlusSignCount(N6, L6, D6); print("Sample 6 (Intersection) Result: \(result6) (\(result6 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center (2,0). Path: (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
        let N7 = 2; let L7 = [5, 5]; let D7 = "RU"; let result7 = getPlusSignCount(N7, L7, D7); print("Sample 7 (No Plus) Result: \(result7) (\(result7 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
        let N8 = 4; let L8 = [1,1,1,1]; let D8 = "RDLU"; let result8 = getPlusSignCount(N8, L8, D8); print("Sample 8 (Small Square) Result: \(result8) (\(result8 == 1 ? "Correct" : "Incorrect"), Expected: 1)") // Center at (0,0) original (1,1) compressed
        let N9 = 7; let L9 = [1,1,1,1,1,1,1]; let D9 = "RDRDRDR"; let result9 = getPlusSignCount(N9, L9, D9); print("Sample 9 (Staircase) Result: \(result9) (\(result9 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
        let N10 = 8; let L10 = [1,1,1,1,1,1,1,1]; let D10 = "RURURURU"; let result10 = getPlusSignCount(N10, L10, D10); print("Sample 10 (Diagonal) Result: \(result10) (\(result10 == 0 ? "Correct" : "Incorrect"), Expected: 0)")
        let N11 = 4; let L11 = [1, 2, 1, 2]; let D11 = "RLUD"; let result11 = getPlusSignCount(N11, L11, D11); print("Sample 11 (Explicit Cross) Result: \(result11) (\(result11 == 0 ? "Correct" : "Incorrect"), Expected: 0)") // Center (-1,0) original is not internal after compression. Path vertices:(0,0),(1,0),(-1,0),(-1,1),(-1,-1)
        
        // Test case likely causing TLE before optimization (Large N, possibly large compressed grid)
        // let largeN = 2_000_000
        // var largeL = [Int](repeating: 1, count: largeN)
        // var largeD = ""
        // for i in 0..<largeN { largeD += ["R", "U", "L", "D"][i % 4] } // Creates a large spiral outward
        // print("\n--- Running Large Test Case (Optimized Endpoint Check) ---")
        // let start = CFAbsoluteTimeGetCurrent()
        // let resultLarge = getPlusSignCount(largeN, largeL, largeD)
        // let time = CFAbsoluteTimeGetCurrent() - start
        // print("Large N Result: \(resultLarge) (Time: \(String(format: "%.3f", time))s)") // Expect 1 plus at origin.
        
        print("\n--- Testing Complete ---")
        
    }
}
