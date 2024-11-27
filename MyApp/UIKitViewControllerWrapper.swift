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
    typealias UIViewControllerType = LifecycleViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> LifecycleViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return LifecycleViewController()
    }
    
    func updateUIViewController(_ uiViewController: LifecycleViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct DemoUIKitContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct DemoUIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
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
