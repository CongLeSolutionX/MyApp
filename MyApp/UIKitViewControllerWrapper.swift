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
        
        // Simulate dynamic selection by iterating through all compression types
        for compressionType in CompressionType.allCases {
            performImageCompression(using: compressionType)
        }
    }
    
    // Function to simulate usage of Image Compression Strategy
    func performImageCompression(using compressionType: CompressionType) {
        // Using the factory to create the selected compression strategy:
        guard let strategy = CompressionStrategyFactory.createStrategy(for: compressionType) else {
            print("Unsupported compression type selected.")
            return
        }
        let imageProcessor = ImageProcessor(compressionStrategy: strategy)
        
        // Replace "Round_logo" with the actual image name in your asset catalog
        // or use another method to load the UIImage
        guard let image = UIImage(named: "Round_logo") else {
            print("Failed to load the image.")
            return
        }
        
        // Retrieve original image data based on the selected compression type
        let originalImageData: Data?
        switch compressionType {
        case .jpeg:
            // Assuming the original image is best represented as JPEG for comparison
            originalImageData = image.jpegData(compressionQuality: 1.0)
        case .png:
            // Assuming the original image is best represented as PNG for comparison
            originalImageData = image.pngData()
        }
        
        if let originalData = originalImageData {
            print("Compression Type: \(compressionType.rawValue.uppercased())")
            print("Original image data size: \(originalData.count) bytes")
        } else {
            print("Failed to retrieve original image data.")
        }
        
        // Perform compression using the selected strategy
        let result = imageProcessor.processImage(image: image)
        switch result {
        case .success(let compressedData):
            print("Compressed image data size: \(compressedData.count) bytes\n")
        case .failure(let error):
            print("Image compression failed: \(error.localizedDescription)\n")
        }
    }
}
