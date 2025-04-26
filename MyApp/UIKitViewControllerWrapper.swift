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
        
        // --- Testing with Provided Examples ---
        print("--- Running Sample Test Cases (Enhanced Compression) ---")
        let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
        print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1)), Expected: 4")
        let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
        print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2)), Expected: 1")
        let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
        print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3)), Expected: 1")
        
        print("\n--- Testing Custom Cases ---")
        // Case 4: Simple Intersection forming a plus
        let N4 = 4, L4 = [2, 2, 2, 2], D4 = "RDLU" // Expected: 1 at (1, -1)
        print("Sample 4 (Intersection) Result: \(getPlusSignCount(N4, L4, D4)), Expected: 1")
        // Case 5: Rectangle - No plus signs
        let N5 = 4, L5 = [5, 2, 5, 2], D5 = "RDLU" // Expected: 0
        print("Sample 5 (Rectangle) Result: \(getPlusSignCount(N5, L5, D5)), Expected: 0")
        
        // Case 9: Minimal plus centered at (0,0) - Using the sequence from thinking phase
        let N9 = 6, L9 = [1, 1, 2, 2, 2, 1], D9 = "RULDRU" // Center (0,0) should be valid.
        print("Sample 9 (Minimal Plus) Result: \(getPlusSignCount(N9, L9, D9)), Expected: 1")
        
        // Case 11: Tricky Center
        let N11 = 7, L11 = [2, 1, 1, 2, 1, 1, 1], D11 = "RULDLUR" // Center (1,0)
        print("Sample 11 (Tricky Center) Result: \(getPlusSignCount(N11, L11, D11)), Expected: 1")
        
        // Case 12: Empty input edge case
        print("Sample 12 (N=0) Result: \(getPlusSignCount(0, [], "")), Expected: 0")
        // Case 13: Less than 4 strokes
        print("Sample 13 (N=3) Result: \(getPlusSignCount(3, [1,1,1], "RDR")), Expected: 0")
        
        // Case 14: Coincident segments (retracing) - should still form plus
        let N14 = 8, L14 = [1, 1, 1, 1, 1, 1, 1, 1], D14 = "RULDDRUL" // Center (0,0)? R(1,0)U(1,1)L(0,1)D(0,0) D(0,-1)R(1,-1)U(1,0)L(0,0)
        print("Sample 14 (Retracing) Result: \(getPlusSignCount(N14, L14, D14)), Expected: 1")
        
        print("\n--- Testing Complete ---")
        
    }
}
