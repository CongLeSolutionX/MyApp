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
    typealias UIViewControllerType = FacePoseSegmentationViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> FacePoseSegmentationViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return FacePoseSegmentationViewController()
    }
    
    func updateUIViewController(_ uiViewController: FacePoseSegmentationViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
    }
}
