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
    typealias UIViewControllerType = PageViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> PageViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return PageViewController()
    }
    
    func updateUIViewController(_ uiViewController: PageViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        print("[MyUIKitViewController] viewDidLoad") // Lifecycle log
        // Additional setup
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[MyUIKitViewController] viewWillAppear") // Lifecycle log
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("[MyUIKitViewController] viewDidAppear") // Lifecycle log
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("[MyUIKitViewController] viewWillDisappear") // Lifecycle log
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[MyUIKitViewController] viewDidDisappear") // Lifecycle log
    }
}
