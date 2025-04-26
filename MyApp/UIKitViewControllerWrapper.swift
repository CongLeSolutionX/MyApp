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
        
        runSolution()
    }
    
    func runSolution() {
      
        // --- Testing with Sample Cases (using the refined function) ---
        print("Sample 1: Expected 5, Got: \(getMinimumSecondsRequired(5, [2, 5, 3, 6, 5], 1, 1))")
        print("Sample 2: Expected 5, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 2, 3))")
        print("Sample 3: Expected 9, Got: \(getMinimumSecondsRequired(3, [100, 100, 100], 7, 3))")
        print("Sample 4: Expected 19, Got: \(getMinimumSecondsRequired(4, [6, 5, 4, 3], 10, 1))")
        print("Sample 5: Expected 207, Got: \(getMinimumSecondsRequired(4, [100, 100, 1, 1], 2, 1))")
        print("Sample 6: Expected 10, Got: \(getMinimumSecondsRequired(6, [6, 5, 2, 4, 4, 7], 1, 1))")

    }
}
