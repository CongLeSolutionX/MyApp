//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
#if canImport(UIKit)
import SwiftUI
import UIKit

// UIViewControllerRepresentable implementation
struct iOS_UIKit_ViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = ObjectiveC_UIKitWrapperViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> ObjectiveC_UIKitWrapperViewController {
        // Instantiate and return the UIKit view controller
        return ObjectiveC_UIKitWrapperViewController()
    }
    
    func updateUIViewController(_ uiViewController: ObjectiveC_UIKitWrapperViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example iOS UIKit view controller
class MyUIKitViewController: MyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
    }
}

class ObjectiveC_UIKitWrapperViewController: MyViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load ObjC view controller
        let objcViewController = ObjCViewController()
        addChild(objcViewController)
        view.addSubview(objcViewController.view)
        objcViewController.didMove(toParent: self)
    }
}
#endif
