//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = PageViewController
    
    // Add the toggleViewCallback property
    var toggleViewCallback: () -> Void /// to hold the callback function that the app will use to toggle the view.
    
    func makeUIViewController(context: Context) -> PageViewController {
        ///  pass the `toggleViewCallback` to the `SafariPageViewController` initializer
//        return SafariPageViewController(toggleViewCallback: toggleViewCallback)
        return PageViewController()
    }
    
    func updateUIViewController(_ uiViewController: PageViewController, context: Context) {
        // Update the view controller if needed (e.g., based on SwiftUI state changes)
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

// MARK: - Previews
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper(toggleViewCallback: {})
    }
}

