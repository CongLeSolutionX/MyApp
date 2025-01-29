//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController

    func makeUIViewController(context: Context) -> MyUIKitViewController {
        print("[UIKitViewControllerWrapper] makeUIViewController") // Lifecycle log
        return MyUIKitViewController()
    }

    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        print("[UIKitViewControllerWrapper] updateUIViewController") // Lifecycle log
        // Update the view controller if needed
    }
}

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
