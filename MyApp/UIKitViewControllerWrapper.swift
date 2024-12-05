//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> UINavigationController {
        // Instantiate and return the PhotoViewController
        let photoService = PhotoService()
        let photoRepository = PhotoRepository(photoService: photoService)
        let viewModel = PhotoViewModel(photoRepository: photoRepository)
        let photoViewController = PhotoViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: photoViewController)

        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
    }
}
