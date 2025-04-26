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
        
        
        // --- Testing with Examples (Same as previous tests) ---
        print("--- Running Sample Test Cases ---")
        let N1 = 9, L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4], D1 = "ULDRULURD" // Expected: 4
        print("Sample 1 Result: \(getPlusSignCount(N1, L1, D1))")
        let N2 = 8, L2 = [1, 1, 1, 1, 1, 1, 1, 1], D2 = "RDLUULDR" // Expected: 1
        print("Sample 2 Result: \(getPlusSignCount(N2, L2, D2))")
        let N3 = 8, L3 = [1, 2, 2, 1, 1, 2, 2, 1], D3 = "UDUDLRLR" // Expected: 1
        print("Sample 3 Result: \(getPlusSignCount(N3, L3, D3))")
        
        print("\n--- Running Boundary/Edge Test Cases ---")
        let N4 = 4, L4 = [5, 2, 5, 2], D4 = "RDLU" // Rectangle, Expected: 0
        print("Sample 4 (Rectangle) Result: \(getPlusSignCount(N4, L4, D4))")
        let N5 = 4, L5 = [3, 3, 3, 3], D5 = "RULD" // Square, Expected: 0
        print("Sample 5 (Square) Result: \(getPlusSignCount(N5, L5, D5))")
        
        print("\n--- Running Intersection Test Cases ---")
        let N6 = 4, L6 = [5, 2, 3, 4], D6 = "RDLU" // Intersection, Expected: 1
        print("Sample 6 (Intersection) Result: \(getPlusSignCount(N6, L6, D6))")
        let N7 = 2, L7 = [5, 5], D7 = "RU" // No plus possible, Expected: 0
        print("Sample 7 (No Plus) Result: \(getPlusSignCount(N7, L7, D7))")
        
        print("\n--- Testing Complete ---")
        
    }
}
