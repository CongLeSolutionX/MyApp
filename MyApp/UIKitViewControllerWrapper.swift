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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
//        demoComprehensiveSwiftInitializer()
        
        demoCalculation()
    }
    
    func demoComprehensiveSwiftInitializer() {
        // Usage
        let product = Product(name: "Widget", price: 19.99, description: "A fancy widget")
        let simpleProduct = Product(name: "Simple Widget") // Convenience
        let noPriceProduct = Product(name: "No Price Widget", price: -10.0) // Failable, returns nil
        let specialProduct = Product(name: "", price: 29.99, description: "Special") // Implicitly unwrapped failable, returns nil
        let productFromRawData = Product(rawData: ["name": "Raw Widget", "price": 15.99]) // Two-Phase Initialization
        let discountedProduct = DiscountedProduct(name: "Cheap Widget", price: 9.99, description: "A cheaper widget") // Required Initializer
        
        print(product ?? "No product")
        print(simpleProduct)
        print(noPriceProduct ?? "No price")
        print(specialProduct ?? "No special price")
        print(productFromRawData)
        print(discountedProduct)

    }
    
    func demoCalculation() {
        
        let myCalculation = Calculation(initialValue: 5)
        // Output:
        // Phase 1: Initial value set for 'value' to 5
        // Phase 2: Calculated 'result' based on 'value', result is 10

    }
}

class Product {
    var name: String
    var price: Double
    var description: String?

    // Designated Initializer
    init(name: String, price: Double, description: String?) {
        self.name = name
        self.price = price
        self.description = description
    }

    // Convenience Initializer
    convenience init(name: String) {
        self.init(name: name, price: 0.0, description: nil)
    }

    // Failable Initializer
    init?(name: String, price: Double) {
        guard price >= 0 else { return nil }
        self.name = name
        self.price = price
        self.description = nil
    }

    // Implicitly Unwrapped Failable Initializer
    init!(name: String, price: Double, description: String) {
        guard !name.isEmpty else { return nil }
        self.name = name
        self.price = price
        self.description = description
    }

    // Two-Phase Initialization
    init(rawData: [String: Any]) {
        self.name = rawData["name"] as? String ?? "Unknown"
        self.price = rawData["price"] as? Double ?? 0.0
        if let description = rawData["description"] as? String, !description.isEmpty {
            self.description = description
        }
    }

    // Deinitialization
    deinit {
        print("Deinitializing product named: \(name)")
    }
}

// Required Initializer in a subclass
class DiscountedProduct: Product {
    let discountPercentage: Double

    required init(discountPercentage: Double) {
        self.discountPercentage = discountPercentage
        super.init(name: "Discounted", price: 0.0, description: "A product with a discount")
    }

    override init(name: String, price: Double, description: String?) {
        self.discountPercentage = 10 // Default discount
        super.init(name: name, price: price, description: description)
    }
}

// MARK: - Calculation Example
class Calculation {
    var value: Int
    var result: Int

    init(initialValue: Int) {
        // Phase 1: Initialization of All Stored Properties

        // Initialize 'value' - a stored property of this class.
        self.value = initialValue
        print("Phase 1: Initial value set for 'value' to \(value)")

        // Initialize 'result' - another stored property of this class.
        // We need to give it an initial value before we can use 'self'
        // to call methods that might rely on it.
        self.result = 0 // Provide a default initial value
        print("Phase 1: Initial (placeholder) value set for 'result' to \(result)")

        // At this point, if 'Calculation' had a superclass,
        // the superclass's designated initializer would be called
        // implicitly by Swift before Phase 2 begins for this class.

        // Phase 2: Customization and Further Setup

        // Now that all stored properties of this class ('value' and 'result')
        // and its superclass (if any) have been initialized with a value,
        // we can perform further customization and calculations.

        // Perform a calculation based on the initialized 'value'.
        // It's now safe to call 'calculateResult' because 'result' has
        // been initialized (even with a placeholder).
        let calculatedResult = calculateResult()
        self.result = calculatedResult // Assign the calculated value
        print("Phase 2: Calculated 'result' based on 'value', result updated to \(result)")

        // You can perform other setup tasks here, knowing that
        // all stored properties have their initial values.
    }

    func calculateResult() -> Int {
        return value * 2
    }
}

