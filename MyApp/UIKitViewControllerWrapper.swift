//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import MapKit

// UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}


// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    private var interactiveMapPinView: InteractiveMapPinView? // Optional to allow deallocation
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        
        interactiveMapPinView = InteractiveMapPinView() // lazy initialization
        
        if let interactiveMapPinView = interactiveMapPinView {
            // Customize the pin's properties
            interactiveMapPinView.title = "My Location"
            interactiveMapPinView.subtitle = "Interesting place at location: \(String(describing: interactiveMapPinView.location))"
            interactiveMapPinView.location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            interactiveMapPinView.detailAction = { [weak self] in
                guard let self else { return }
                // Handle the detail action (e.g., show a detail view)
                print("Detail button tapped!")
                print(self.interactiveMapPinView?.location ?? "No location")
                // Optionally, create and present a detail view controller here:
                let detailVC = DetailMapViewController(location: self.interactiveMapPinView?.location)
                self.present(detailVC, animated: true, completion: nil)
            }
            
            // Add the pin to the view controller's view
            view.addSubview(interactiveMapPinView)
            
            // Set constraints to position the pin (crucial!)
            interactiveMapPinView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                interactiveMapPinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                interactiveMapPinView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                interactiveMapPinView.widthAnchor.constraint(equalToConstant: 200), // Adjust width as needed
                interactiveMapPinView.heightAnchor.constraint(equalToConstant: 100) // Adjust height as needed
            ])
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove the view from its superview to assist in deallocation
        interactiveMapPinView?.removeFromSuperview()
        
        // Release the reference
        interactiveMapPinView = nil
    }
    
    deinit {
        print("MyUIKitViewController deinitialized successfully!") // Debugging statement
    }
}
