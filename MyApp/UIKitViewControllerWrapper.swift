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
        
        self.demoStrategyPattern()
    }
    
    func demoStrategyPattern() {
        // MARK: - Usage Example
        let userSelectedCompressionType: CompressionType = .jpeg // Example: from user settings
        
        // Using the factory to create the selected compression strategy:
        if let strategy = CompressionStrategyFactory.createStrategy(for: userSelectedCompressionType) {
            let imageProcessor = ImageProcessor(compressionStrategy: strategy)
            if let image = UIImage(named: "Round_logo") { // Replace with your image loading
                
                // Before compression:
                if let originalImageData = image.pngData() { // Get original image data (adjust type if needed)
                    print("Original image data size: \(originalImageData.count) bytes")
                }
                
                
                let result = imageProcessor.processImage(image: image)
                switch result {
                case .success(let compressedData):
                    print("Compressed image data size: \(compressedData.count) bytes")
                case .failure(let error):
                    print("Image compression failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
