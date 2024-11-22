//
//  NativeUIKitViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//

import UIKit

class NativeUIKitViewController: UIViewController {

    var customView: CustomView?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("NativeUIKitViewController viewDidLoad() called")
        view.backgroundColor = .white

        // Initialize CustomView programmatically
        let frame = CGRect(x: 50, y: 100, width: 200, height: 200)
        customView = CustomView(frame: frame)
        if let customView = customView {
            view.addSubview(customView)
        }

        // Trigger layout and display updates after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.customView?.triggerLayout()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.customView?.triggerDisplay()
        }

        // Remove the view after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.customView?.removeView()
            self.customView = nil
        }
        
        demoRunObjectCViewController()
    }
    
    // Notes: Since ObjC code will compile at compiling time, not at runtime,
    // we need to compile the project on a simulator or a physical device to see Obj-C code run.
    // Presenting LifecycleViewController from another view controller
    func demoRunObjectCViewController() {
        let objCViewController = LifecycleViewController(nibName: nil, bundle: nil)
        objCViewController.present(self, animated: true) {
            NSLog("LifecycleViewController presented")
        }
    }
}
