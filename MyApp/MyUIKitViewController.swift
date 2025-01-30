//
//  MyUIKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/30/25.
//

import UIKit

// Example UIKit view controller with built-in lifecycle functions
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
