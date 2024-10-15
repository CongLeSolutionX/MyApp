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
        let userSelectedCompressionType: CompressionType = .png // Example: from user settings
        
        // Using the factory:
        if let strategy = CompressionStrategyFactory.createStrategy(for: userSelectedCompressionType) {
            let imageProcessor = ImageProcessor(compressionStrategy: strategy)
            if let image = UIImage(named: "Round_logo") { // Replace with actual image loading
                let result = imageProcessor.processImage(image: image)
                switch result {
                case .success(let data):
                    print("Compressed image data: \(data)")
                case .failure(let error):
                    print("Image compression failed: \(error.localizedDescription)")
                }
            }
        }

    }
}

// MARK: - Strategy Protocol
protocol ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error>
}

// MARK: - Concrete Strategies
class JPEGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .failure(NSError(domain: "JPEGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "JPEG compression failed"]))
        }
        return .success(data)
    }
}

class PNGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.pngData() else {
            return .failure(NSError(domain: "PNGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "PNG compression failed"]))
        }
        return .success(data)
    }
}

// MARK: - Context Class
class ImageProcessor {
    var compressionStrategy: ImageCompressionStrategy

    init(compressionStrategy: ImageCompressionStrategy) {
        self.compressionStrategy = compressionStrategy
    }

    func processImage(image: UIImage) -> Result<Data, Error> {
        return compressionStrategy.compress(image: image)
    }

    func setCompressionStrategy(strategy: ImageCompressionStrategy) {
        self.compressionStrategy = strategy
    }
}

// MARK: - Compression Type Enum (for Strategy Selection)
enum CompressionType: CaseIterable, RawRepresentable {
    case jpeg, png

    typealias RawValue = String
    var rawValue: String {
        switch self {
        case .jpeg: return "jpeg"
        case .png: return "png"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "jpeg": self = .jpeg
        case "png": self = .png
        default: return nil
        }
    }
}

// MARK: - Strategy Factory (Advanced Usage)
struct CompressionStrategyFactory {
    static func createStrategy(for type: CompressionType) -> ImageCompressionStrategy? {
        switch type {
        case .jpeg: return JPEGCompression()
        case .png: return PNGCompression()
        }
    }
}
