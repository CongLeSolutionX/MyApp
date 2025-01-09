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
        demoComprehensiveSwiftInitializer()
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
