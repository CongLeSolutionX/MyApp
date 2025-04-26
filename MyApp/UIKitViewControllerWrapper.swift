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
        // --- Testing with provided examples ---
        let N1 = 9
        let L1 = [6, 3, 4, 5, 1, 6, 3, 3, 4]
        let D1 = "ULDRULURD"
        let result1 = getPlusSignCount(N1, L1, D1)
        print("Sample 1 Result: \(result1) (Expected: 4)") // Should be 4
        
        let N2 = 8
        let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
        let D2 = "RDLUULDR"
        let result2 = getPlusSignCount(N2, L2, D2)
        print("Sample 2 Result: \(result2) (Expected: 1)") // Should be 1
        
        let N3 = 8
        let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
        let D3 = "UDUDLRLR"
        let result3 = getPlusSignCount(N3, L3, D3)
        print("Sample 3 Result: \(result3) (Expected: 1)") // Should be 1
        
        // --- Testing with custom potentially problematic cases ---
        let N4 = 4
        let L4 = [5, 2, 5, 2] // Rectangle R_5, D_2, L_5, U_2
        let D4 = "RDLU"
        // Expect 0 based on the logic that no internal vertices are formed
        let result4 = getPlusSignCount(N4, L4, D4)
        print("Sample 4 (Rectangle) Result: \(result4) (Expected based on logic: 0)")
        
        let N5 = 4
        let L5 = [3, 3, 3, 3] // Square R_3, U_3, L_3, D_3
        let D5 = "RULD"
        // Expect 0 based on the logic
        let result5 = getPlusSignCount(N5, L5, D5)
        print("Sample 5 (Square) Result: \(result5) (Expected based on logic: 0)")
        
        // Test Case: Intersection creating an internal vertex
        let N6 = 4
        let L6 = [5, 2, 3, 4] // From prev test, R 5, D 2, L 3, U 4 -> Path (0,0)->(5,0)->(5,-2)->(2,-2)->(2,2)
        let D6 = "RDLU"
        // Expect 1, center at real (2,0) -> compressed (1,1)
        let result6 = getPlusSignCount(N6, L6, D6)
        print("Sample 6 (Intersection) Result: \(result6) (Expected: 1)") // Should be 1
        
        // Test Case: No plus sign
        let N7 = 2
        let L7 = [5, 5]
        let D7 = "RU"
        let result7 = getPlusSignCount(N7, L7, D7)
        print("Sample 7 (No Plus) Result: \(result7) (Expected: 0)") // Should be 0
        
    }
}
