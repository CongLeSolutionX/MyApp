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
    typealias UIViewControllerType = ObjC_MetalViewController_UIKitWrapperViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> ObjC_MetalViewController_UIKitWrapperViewController {
        // Instantiate and return the UIKit view controller
        return ObjC_MetalViewController_UIKitWrapperViewController()
    }
    
    func updateUIViewController(_ uiViewController: ObjC_MetalViewController_UIKitWrapperViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example iOS UIKit view controller
class MyUIKitViewController: MySwiftViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
    }
}
class ObjC_MetalViewController_UIKitWrapperViewController: MySwiftViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .brown
        
        // Load ObjC view controller
        let objcViewController = MetalViewController()
        addChild(objcViewController)
        view.addSubview(objcViewController.view)
        objcViewController.didMove(toParent: self)
    }
}
#endif
