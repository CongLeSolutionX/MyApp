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
        print("Sample 1 Result: \(result1) (Expected: 4)")
        
        let N2 = 8
        let L2 = [1, 1, 1, 1, 1, 1, 1, 1]
        let D2 = "RDLUULDR"
        let result2 = getPlusSignCount(N2, L2, D2)
        print("Sample 2 Result: \(result2) (Expected: 1)")
        
        let N3 = 8
        let L3 = [1, 2, 2, 1, 1, 2, 2, 1]
        let D3 = "UDUDLRLR"
        let result3 = getPlusSignCount(N3, L3, D3)
        print("Sample 3 Result: \(result3) (Expected: 1)")
        
        let N4_path = 4
        let L4_path = [5, 2, 3, 4] // R 5, D 2, L 3, U 4
        let D4_path = "RDLU"
        let result4 = getPlusSignCount(N4_path, L4_path, D4_path)
        print("Sample 4 (Intersection) Result: \(result4) (Expected: 1)")
    }
}
