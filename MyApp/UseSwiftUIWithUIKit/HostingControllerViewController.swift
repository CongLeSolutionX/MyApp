//
//  HostingControllerViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/10/24.
//

import SwiftUI


class HostingControllerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let content = Text("Hello, World!")
        
        let hostingController = UIHostingController(rootView: content)
        
        view.addSubview(hostingController.view)
    }
}
