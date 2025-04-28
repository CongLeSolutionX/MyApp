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
        // Additional setup
        
        runProxyPatternDemo()
    }
    
    func runProxyPatternDemo() {
        
        // --- 4. Client Usage ---
        let imageURL = URL(string: "https://via.placeholder.com/300")! // Example URL
        let imageView = UIImageView()

        // Client interacts with the Subject protocol, using the Proxy
        let imageLoader: ImageService = LazyImageServiceProxy(url: imageURL)
        print("Client: Created proxy.")

        // RealImageService instance and image loading only happens now:
        print("Client: Requesting displayImage...")
        imageLoader.displayImage(on: imageView) // Proxy creates RealService, RealService loads data

        print("\nClient: Requesting imageData...")
        let data = imageLoader.getImageData() // Proxy forwards, RealService returns loaded data.
        print("Client: Received data (\(data?.count ?? 0) bytes)")

    }
}
