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

// Example of a UIKit view controller demonstrating the use of inout parameters to swap two values
class MyUIKitViewController: UIViewController {
    /// The first title for the button.
    var firstTitle: String = "First Title"
    
    /// The second title for the button.
    var secondTitle: String = "Second Title"
    
    /// A lazily initialized UIButton that displays a title and responds to user taps.
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle(firstTitle, for: .normal) // Set the initial title of the button
        button.backgroundColor = .systemBlue // Set the background color of the button
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside) // Add a target-action for button taps
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button) // Add the button to the view hierarchy
        
        // Configure Auto Layout constraints for the button
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Handles the button tap event by swapping the button's title.
    @objc func buttonTapped() {
        swapButtonTitle(button, &firstTitle, &secondTitle) // Swap the titles using inout parameters
    }
    
    /**
     Swaps the titles of the button using two inout parameters.
     
     - Parameters:
       - button: The UIButton whose title will be updated.
       - title1: The first title, which will be swapped with the second title.
       - title2: The second title, which will be swapped with the first title.
     
     This method uses `inout` parameters to allow the swapping of two titles, effectively modifying the original values.
     */
    func swapButtonTitle<T>(_ button: UIButton, _ title1: inout T, _ title2: inout T) {
        let temporaryTitle = title1 // Store the first title in a temporary variable
        title1 = title2 // Assign the second title to the first title
        title2 = temporaryTitle // Assign the temporary title to the second title
        button.setTitle("\(title1)", for: .normal) // Update the button's title to reflect the change
    }
}


