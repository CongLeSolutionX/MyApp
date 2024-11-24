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
    typealias UIViewControllerType = MetalRendererViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MetalRendererViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MetalRendererViewController()
    }
    
    func updateUIViewController(_ uiViewController: MetalRendererViewController, context: Context) {
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
