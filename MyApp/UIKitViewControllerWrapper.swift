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

// Example UIKit view controller using inout parameter UIButton
class MyUIKitViewController: UIViewController {
    
    var submitButton = UIButton() // Initialize submitButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Configure the submitButton for different states
        // The & symbol indicates that submitButton is being passed by reference,
        // allowing the function to modify its properties directly and persistently.
        configureButton(button: &submitButton, title: "Submit", color: .red, for: .normal)
        configureButton(button: &submitButton, title: "Submitting...", color: .orange, for: .highlighted)
        
        // Add the button to the view
        view.addSubview(submitButton)
        
        // Set button constraints
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 200),  // Set width
            submitButton.heightAnchor.constraint(equalToConstant: 50)   // Set height
        ])
    }
    
    /**
     Configures a UIButton's appearance and behavior for a specified state.
     
     - Parameters:
       - button: An `inout` parameter representing the UIButton instance to be configured.
                 By using `inout`, the function can directly modify the properties of the UIButton instance.
                 This means that changes made to the button within this function (such as setting the title,
                 title color, and background image) are applied directly to the original UIButton instance
                 passed as an argument.
       - title: A `String` that sets the text to be displayed on the button for the specified state.
       - color: A `UIColor` that sets the background color of the button for the specified state.
       - state: A `UIControl.State` value indicating the state for which the title and color should be configured.
     */
    func configureButton(button: inout UIButton, title: String, color: UIColor, for state: UIControl.State) {
        // Set the button's title for the specified state
        button.setTitle(title, for: state)
        
        // Set the button's title color to white for the specified state
        button.setTitleColor(.white, for: state)
        
        // Set the button's background color for the specified state by using a background image
        button.setBackgroundImage(imageWithColor(color), for: state)
        
        // Optional: Set a corner radius to make the button corners rounded
        button.layer.cornerRadius = 10
        button.clipsToBounds = true  // Ensure the corner radius is applied
    }
    
    // Helper method to create a UIImage from a UIColor
    private func imageWithColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
