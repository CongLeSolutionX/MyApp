//
//  LifecycleViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import UIKit

class LifecycleViewController: UIViewController {
    
    // Custom View for Demonstration
    private let customView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Initialization (viewDidLoad, viewWillAppear, etc.)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("LifecycleViewController: Initialization Start")
        print("- nibName: \(nibNameOrNil ?? "nil")")
        //print("- bundle: \(nibBundleOrNil ?? "nil")")
        
        print("LifecycleViewController: Initialization End")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("LifecycleViewController: Initialization from Storyboard/Nib (required init)")
        
    }
    
    override func loadView() {
        super.loadView()
        print("LifecycleViewController: loadView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LifecycleViewController: viewDidLoad")
        view.backgroundColor = .systemGray
        setupCustomView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LifecycleViewController: viewWillAppear(animated: \(animated))")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("LifecycleViewController: viewWillLayoutSubviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("LifecycleViewController: viewDidLayoutSubviews")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LifecycleViewController: viewDidAppear(animated: \(animated))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LifecycleViewController: viewWillDisappear(animated: \(animated))")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LifecycleViewController: viewDidDisappear(animated: \(animated))")
    }
    
    
    deinit {
        print("LifecycleViewController: Deallocation")
    }
    
    // Trait Collection and Size Change Handling
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("LifecycleViewController: viewWillTransition(to: \(size), with: coordinator)")
        
        coordinator.animate(alongsideTransition: { context in
            print("LifecycleViewController: Transition Coordinator Animation Start")
            self.updateViewConstraintsForSize(size)
            self.view.layoutIfNeeded()
            print("LifecycleViewController: Transition Coordinator Animation End")
            
        }) { context in
            print ("LifecycleViewController: Transition  Completion")
        }
    }
    
    // Helper method to update constraints based on size
    private func updateViewConstraintsForSize(_ size: CGSize) {
        print("LifecycleViewController: updateViewConstraintsForSize -  \(size)")
        // Example: Adjust customView size based on width
        let isWide = size.width > size.height
        let customViewSize: CGFloat = isWide ? 100 : 200
        
        NSLayoutConstraint.activate([
            customView.widthAnchor.constraint(equalToConstant: customViewSize),
            customView.heightAnchor.constraint(equalToConstant: customViewSize),
            customView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // View Setup
    
    private func setupCustomView() {
        print("LifecycleViewController: setupCustomView")
        
        view.addSubview(customView)
        updateViewConstraintsForSize(view.bounds.size) // Initial setup
    }
}
