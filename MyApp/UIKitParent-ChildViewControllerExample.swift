//
//  UIKitParent-ChildViewControllerExample.swift
//  MyApp
//
//  Created by Cong Le on 11/27/24.
//

import UIKit

// --- Child View Controller 1 ---
class ChildViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink  // Distinct color for easy identification
        setupLabel("Child 1")   // Utility method to add a label
    }

    private func setupLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// --- Child View Controller 2 ---
class ChildViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen  // Distinct color for easy identification
        setupLabel("Child 2") // Reusing the utility method for adding a label
    }

    private func setupLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// --- Parent View Controller ---
class ParentViewController: UIViewController {

    /// It's ok to use force unwrap here and make the example simple
    private var containerView: UIView! // To hold the child views
    private var child1: ChildViewController1!
    private var child2: ChildViewController2!
    private var currentChild: UIViewController? // To keep track of the active child

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

         // Set up segmented control to switch views
        let items = ["Show Child 1", "Show Child 2"]

          // Set up segmented control.
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)

        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Setup container
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor ,constant: -20)
        ])
       
        // Initialize child VCs
        child1 = ChildViewController1()
        child2 = ChildViewController2()

        // Show the initial child view
         showChildViewController(child1)

    }

    // Method for changing the view
    @objc private func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showChildViewController(child1)
        } else {
            showChildViewController(child2)
        }
    }

    // Function to switch view controllers
    private func showChildViewController(_ child: UIViewController) {
           //  If we are already showing the view then do not add it on top
           if child == currentChild {
               return
           }

           // Remove any existing child VC's view
           currentChild?.willMove(toParent: nil)
           currentChild?.view.removeFromSuperview()
           currentChild?.removeFromParent()

           // Add the new child VC.
           addChild(child)
           child.view.frame = containerView.bounds
           containerView.addSubview(child.view)
           child.didMove(toParent: self)
           currentChild = child
       }
}
//
//// --- SceneDelegate for setup ---
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = ParentViewController() // Set the root as the Parent
//        window?.makeKeyAndVisible()
//    }
//
//    // Rest of the SceneDelegate methods are standard...
//    func sceneDidDisconnect(_ scene: UIScene) {}
//    func sceneDidBecomeActive(_ scene: UIScene) {}
//    func sceneWillResignActive(_ scene: UIScene) {}
//    func sceneWillEnterForeground(_ scene: UIScene) {}
//    func sceneDidEnterBackground(_ scene: UIScene) {}
//}
//
