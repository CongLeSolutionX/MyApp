//
//  ProxyDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import Foundation
import UIKit

// --- 1. Define the Subject Protocol ---
protocol ImageService {
    func displayImage(on imageView: UIImageView)
    func getImageData() -> Data? // Example method
}

// --- 2. Implement the RealSubject ---
class RealImageService: ImageService {
    private let imageURL: URL
    private var imageData: Data? // Assume this could be large

    init(url: URL) {
        self.imageURL = url
        print("RealImageService: Initialized (but image not loaded yet)")
        // In a real scenario, you might start loading immediately
        // or truly wait for access. For simplicity, we load on demand.
    }

    private func loadImage() {
        guard imageData == nil else { return } // Load only once
        print("RealImageService: Loading image data from \(imageURL)...")
        // Simulate network/disk load
        // In reality, use URLSession, etc. This should be async.
        self.imageData = try? Data(contentsOf: imageURL) // Synchronous for example simplicity
        print("RealImageService: Image data loaded (\(imageData?.count ?? 0) bytes)")
    }

    func displayImage(on imageView: UIImageView) {
        loadImage() // Ensure data is loaded
        if let data = self.imageData, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                 imageView.image = image
            }
            print("RealImageService: Displaying image.")
        } else {
            print("RealImageService: Failed to load or display image.")
            // Maybe set a placeholder image
             DispatchQueue.main.async {
                 imageView.image = UIImage(systemName: "photo") // Placeholder
             }
        }
    }

    func getImageData() -> Data? {
        loadImage() // Ensure data is loaded before returning
        return self.imageData
    }
}

// --- 3. Implement the Proxy (Virtual Proxy Example) ---
class LazyImageServiceProxy: ImageService {
    private let imageURL: URL
    private var realService: RealImageService? // Reference to the RealSubject, initially nil

    init(url: URL) {
        self.imageURL = url
        print("LazyImageServiceProxy: Initialized for URL \(imageURL). Real service not created yet.")
    }

    // Lazy instantiation of the RealSubject
    private func getRealService() -> RealImageService {
        if realService == nil {
            print("LazyImageServiceProxy: Creating RealImageService instance now (lazy loading)...")
            realService = RealImageService(url: imageURL)
        }
        // Add logging or other proxy logic here if needed
        return realService!
    }

    // Forward requests to the RealSubject (after ensuring it exists)
    func displayImage(on imageView: UIImageView) {
        print("LazyImageServiceProxy: Intercepted displayImage request.")
        // Maybe show a placeholder immediately
        DispatchQueue.main.async {
            imageView.image = UIImage(systemName: "hourglass") // Loading indicator
        }
        // Forward to real service (which triggers its loading if needed)
        getRealService().displayImage(on: imageView)
    }

    func getImageData() -> Data? {
        print("LazyImageServiceProxy: Intercepted getImageData request.")
        // Forward to real service (which triggers its loading if needed)
        return getRealService().getImageData()
    }
}
//
//// --- 4. Client Usage ---
//let imageURL = URL(string: "https://via.placeholder.com/300")! // Example URL
//let imageView = UIImageView()
//
//// Client interacts with the Subject protocol, using the Proxy
//let imageLoader: ImageService = LazyImageServiceProxy(url: imageURL)
//print("Client: Created proxy.")
//
//// RealImageService instance and image loading only happens now:
//print("Client: Requesting displayImage...")
//imageLoader.displayImage(on: imageView) // Proxy creates RealService, RealService loads data
//
//print("\nClient: Requesting imageData...")
//let data = imageLoader.getImageData() // Proxy forwards, RealService returns loaded data.
//print("Client: Received data (\(data?.count ?? 0) bytes)")
