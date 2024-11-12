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
        
     
        testOutActionSleeveFunction()
    }

    func buttonTapped() {
        print("...and this is the print statement from the buttonTapped function!")
    }
    
    func testOutActionSleeveFunction() {
        myButton.addAction(for: .touchUpInside) { sender, event in
            if let touch = event?.allTouches?.first {
                print("Button pressed at location: \(touch.location(in: sender))")
            }
        }
    }
}



// MARK: - ActionSleeve

// Define the unique key using UInt8 to ensure uniqueness and avoid exposing internal representation
private struct AssociatedKeys {
    static var sleeves: UInt8 = 0
}

// Note: This class only works on a compiled app, but not worked on the canvas Preview => The ObjC nature is validated!
class ActionSleeve {
    private let action: (UIControl, UIEvent?) -> Void
    
    init(action: @escaping (UIControl, UIEvent?) -> Void) {
        self.action = action
    }
    
    @objc func invoke(sender: UIControl, event: UIEvent?) {
        action(sender, event)
    }
}

extension UIControl {
    func addAction(for event: UIControl.Event, action: @escaping (UIControl, UIEvent?) -> Void) {
        let sleeve = ActionSleeve(action: action)
        addTarget(sleeve, action: #selector(ActionSleeve.invoke(sender:event:)), for: event)
        
        var sleeves = objc_getAssociatedObject(self, &AssociatedKeys.sleeves) as? [ActionSleeve] ?? []
        sleeves.append(sleeve)
        objc_setAssociatedObject(self, &AssociatedKeys.sleeves, sleeves, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func removeAllActions() {
        guard let sleeves = objc_getAssociatedObject(self, &AssociatedKeys.sleeves) as? [ActionSleeve] else { return }
        sleeves.forEach { sleeve in
            removeTarget(sleeve, action: #selector(ActionSleeve.invoke(sender:event:)), for: .allEvents)
        }
        objc_setAssociatedObject(self, &AssociatedKeys.sleeves, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
