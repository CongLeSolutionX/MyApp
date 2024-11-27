//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit


// MARK: - Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
    }
}

// MARK: - Wrap the UIKit View Controller into a wrapper preparing for preview

// UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// MARK: - Previews
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
