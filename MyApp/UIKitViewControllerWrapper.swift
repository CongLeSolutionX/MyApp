//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
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
        
        let photoService = PhotoService()
        let photoRepository = PhotoRepository(photoService: photoService)
        let viewModel = PhotoViewModel(photoRepository: photoRepository)
        let photoViewController = PhotoViewController(viewModel: viewModel)
        
        addChild(photoViewController)
        photoViewController.view.frame = view.bounds
        view.addSubview(photoViewController.view)
        photoViewController.didMove(toParent: self)
    }
}
