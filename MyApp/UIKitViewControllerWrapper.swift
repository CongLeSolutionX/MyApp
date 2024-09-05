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
    
    // Escaping Closure storage
    var completionHandlers: [() -> Void] = [] // Array to hold escaping closures
    
    // UI Label to display results
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        
        // Add the label to the view
        view.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Example usage
        var resultText = ""
        
        // Non-Escaping Closure
        // This closure is executed immediately within the function.
        // It cannot be stored for later use.
        performNonEscapingClosure {
            resultText += "This is inside the non-escaping closure.\n"
            print("This is inside the non-escaping closure.") // Expected output
        }
        
        // Escaping Closure
        // This closure is stored in an array and can be executed later,
        // even after the function that takes the closure as a parameter has returned.
        performEscapingClosure {
            resultText += "This is inside the escaping closure.\n"
            print("This is inside the escaping closure.") // Expected output
        }
        
        // Later on, we execute the escaping closures stored in the array.
        // This demonstrates that escaping closures can be called after the function ends.
        completionHandlers.forEach { $0() }
        
        // Auto Closure
        // This function takes an expression that evaluates to a boolean value.
        // The expression is automatically wrapped in a closure.
        performAutoClosure(closure: (2 > 1))
        
        // The above autoclosure is equivalent to this non-escaping closure:
        // Here, we manually create a closure that evaluates an expression.
        performNonEscapingClosure {
            let result = 2 > 1
            resultText += "Auto Closure evaluated to \(result)\n"
            print("Auto Closure evaluated to \(result)") // Expected output
        }
        
        // Update the label text
        resultLabel.text = resultText
    }
    
    // Non-Escaping Closure
    // This function takes a closure as its parameter and executes it immediately.
    // The closure cannot be stored or executed after the function returns.
    //
    // Example:
    // Imagine you're at a restaurant. You order food, and the chef starts cooking right away.
    // You can't change your order once the chef starts cooking. This is like a non-escaping closure.
    func performNonEscapingClosure(closure: () -> Void) {
        print("Non-Escaping Closure start")
        closure()  // Execute the closure immediately
        print("Non-Escaping Closure end")
    }
    
    // Escaping Closure
    // This function takes an escaping closure as its parameter.
    // The closure is stored rather than being executed immediately and can be executed after the function returns.
    //
    // Example:
    // Imagine you place an order for a custom-built computer. The company stores your order details (closure)
    // and starts building the computer. They might call you later (execute the closure) to confirm details.
    func performEscapingClosure(closure: @escaping () -> Void) {
        print("Escaping Closure start")
        completionHandlers.append(closure)  // Store the closure for later use
    }
    
    // Auto Closure
    // This function takes an autoclosure as its parameter.
    // The autoclosure is a closure that is automatically created to wrap the given expression.
    //
    // Example:
    // Imagine you tell someone, "I'll check if it's raining later." You haven't checked yet,
    // but you will check when you need to know. This is like an autoclosure.
    func performAutoClosure(closure: @autoclosure () -> Bool) {
        print("Auto Closure start")
        if closure() { // The closure is executed here when called.
            print("Auto Closure evaluated to true")
        } else {
            print("Auto Closure evaluated to false")
        }
    }
}
