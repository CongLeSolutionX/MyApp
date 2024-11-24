//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import MapKit

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
    let interactiveMapPin = InteractiveMapPinView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        // Customize the pin's properties
        interactiveMapPin.title = "My Location"
        interactiveMapPin.subtitle = "Interesting place"
        interactiveMapPin.location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Example coordinates
        interactiveMapPin.detailAction = { [weak self] in
            // Handle the detail action (e.g., show a detail view)
            print("Detail button tapped!")
            print(self?.interactiveMapPin.location ?? "No location")
            // Optionally, create and present a detail view controller here:
            //let detailVC = DetailViewController()
            //self?.navigationController?.pushViewController(detailVC, animated: true)

        }

        // Add the pin to the view controller's view
        view.addSubview(interactiveMapPin)

        // Set constraints to position the pin (crucial!)
        interactiveMapPin.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            interactiveMapPin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            interactiveMapPin.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            interactiveMapPin.widthAnchor.constraint(equalToConstant: 200), // Adjust width as needed
            interactiveMapPin.heightAnchor.constraint(equalToConstant: 100) // Adjust height as needed
        ])
    }
}
