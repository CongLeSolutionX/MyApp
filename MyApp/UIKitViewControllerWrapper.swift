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
    typealias UIViewControllerType = PresentingSimpleViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> PresentingSimpleViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return PresentingSimpleViewController()
    }
    
    func updateUIViewController(_ uiViewController: PresentingSimpleViewController, context: Context) {
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
