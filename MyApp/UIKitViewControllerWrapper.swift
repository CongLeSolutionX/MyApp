//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import WebKit

// UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Instantiate and return the UIKit view controller
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
        
        DemoDelegateExample()
    }
    
    func DemoDelegateExample() {
        
        // Usage example (with optional WKWebView and button state update):
        let webViewInstance = WKWebView()
        let delegateExample = DelegateExample(webView: webViewInstance)
        delegateExample.loadButtonEnabledStateChanged = { isEnabled in
            // Update button enabled state on UI, e.g., myButton.isEnabled = isEnabled
        }
        delegateExample.startDataTaskWithDelegate()
    }
    
    func DemoCompletionHandlerExample() {
        // Usage example (if you have a WKWebView instance):
        let webViewInstance = WKWebView()
        let example = CompletionHandlerExample(webView: webViewInstance)
        example.startDataTaskWithCompletionHandler()
        
    }
}
