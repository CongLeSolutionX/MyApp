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
    
    // Toggle callback
    var toggleViewCallback: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        
        // Initialize PageViewController and set its delegate to the Coordinator
        let pageVC = PageViewController()
        pageVC.navigationDelegate = context.coordinator
        
        // Assign the navigation controller to the coordinator
        context.coordinator.navigationController = navigationController
        
        // Set the root view controller
        navigationController.viewControllers = [pageVC]
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Handle updates if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(toggleViewCallback: toggleViewCallback)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, PageViewControllerNavigationDelegate, SafariPageViewControllerNavigationDelegate {
        var toggleViewCallback: () -> Void
        weak var navigationController: UINavigationController?
        
        init(toggleViewCallback: @escaping () -> Void) {
            self.toggleViewCallback = toggleViewCallback
        }
        
        // MARK: - PageViewControllerNavigationDelegate Methods
        
        func pageViewControllerDidRequestNavigationToSafari(_ pageViewController: PageViewController) {
            let safariPageVC = SafariPageViewController()
            safariPageVC.navigationDelegate = self
            navigationController?.pushViewController(safariPageVC, animated: true)
        }
        
        // MARK: - SafariPageViewControllerNavigationDelegate Methods
        
        func safariPageViewControllerDidRequestToggle(_ safariPageViewController: SafariPageViewController) {
            toggleViewCallback()
        }
    }
}

// MARK: - Previews
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper(toggleViewCallback: {})
    }
}

