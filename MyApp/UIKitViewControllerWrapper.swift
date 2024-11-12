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
        let button = UIButton(type: .system)
        button.setTitle("Click Me", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        
        // Customize font
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        // Add an image
        let image = UIImage(systemName: "hand.point.right.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .white

        button.setBackgroundImage(UIImage(named: "Round_logo.png"), for: .highlighted)
        
        // Customize font
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(myButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            myButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            myButton.widthAnchor.constraint(equalToConstant: 150),
            myButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        myButton.addAction {
            self.buttonTapped()
        }
    }

    func buttonTapped() {
        print("Button was tapped!")
    }
}

extension UIControl {
    func addAction(action: @escaping () -> Void) {
        let sleeve = ActionSleeve(action: action)
        addTarget(sleeve, action: #selector(ActionSleeve.invoke), for: .touchUpInside)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

class ActionSleeve {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func invoke() {
        action()
    }
}
