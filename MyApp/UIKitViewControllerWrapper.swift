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
        
        runSolution()
    }
    
    func runSolution() {
        // --- Testing with Sample Cases ---

        // Sample 1
        let N1 = 5
        let S1 = [1, 2, 3, 4, 5]
        print("Sample 1: \(getMinProblemCount(N1, S1))") // Expected: 3

        // Sample 2
        let N2 = 4
        let S2 = [4, 3, 3, 4]
        print("Sample 2: \(getMinProblemCount(N2, S2))") // Expected: 2

        // Sample 3
        let N3 = 4
        let S3 = [2, 4, 6, 8]
        print("Sample 3: \(getMinProblemCount(N3, S3))") // Expected: 4

        // Sample 4
        let N4 = 1
        let S4 = [8]
        print("Sample 4: \(getMinProblemCount(N4, S4))") // Expected: 3

    }
}
