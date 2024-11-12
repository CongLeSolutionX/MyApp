//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {

    // Initialize the button
    private let myButton: UIButton = {
        let button = UIButton(type: .system) // You can choose different button types
        button.setTitle("Click Me", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Add button to the view
        view.addSubview(myButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            myButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            myButton.widthAnchor.constraint(equalToConstant: 150),
            myButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add target for button action
        myButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // Action method
    @objc private func buttonTapped() {
        print("Button was tapped!")
        // You can perform any action here, such as navigating to another screen
    }
}
