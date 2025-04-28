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
        
        //runProxyPatternDemo()
        runProxyPattern_ComprehensiveDemo()
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
    
    func runProxyPattern_ComprehensiveDemo() {
        
        print("\n--- Example 1: Using Virtual Proxy (Lazy Loading) ---")
        
        // Client interacts via the protocol, unaware of lazy loading details
        let lazyDownloader: FileDownloader = VirtualFileDownloaderProxy()
        let dummyURL1 = URL(string: "https://example.com/file1.txt")!
        
        print("Client: lazyDownloader created. Requesting download...")
        // Only now will the RealFileDownloader potentially be created inside the proxy
        lazyDownloader.downloadFile(url: dummyURL1) { result in
            switch result {
            case .success(let data):
                print("Client (Virtual): Download succeeded! Data size: \(data.count)")
            case .failure(let error):
                print("Client (Virtual): Download failed! Error: \(error.localizedDescription)")
            }
        }
        // Keep the script running for async operations
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate waiting for download
        
        
        print("\n--- Example 2: Using Protection Proxy ---")
        let baseDownloader = RealFileDownloader() // Or could be the VirtualProxy
        let guestURL = URL(string: "https://example.com/public/guest_file.zip")!
        let premiumURL = URL(string: "https://example.com/premium_content/movie.mp4")!
        let adminURL = URL(string: "https://example.com/admin_files/config.json")!
        
        // Scenario A: Guest User
        print("\nClient: Simulating GUEST user...")
        var guestDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: baseDownloader, userRole: .guest)
        
        print("Client (Guest): Attempting to download guest file...")
        guestDownloader.downloadFile(url: guestURL) { result in print("Client (Guest - Guest File): Result: \(result)") }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
        
        print("\nClient (Guest): Attempting to download premium file...")
        guestDownloader.downloadFile(url: premiumURL) { result in print("Client (Guest - Premium File): Result: \(result)") }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
        
        print("\nClient (Guest): Attempting to download admin file...")
        guestDownloader.downloadFile(url: adminURL) { result in print("Client (Guest - Admin File): Result: \(result)") }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
        
        // Scenario B: Premium User
        print("\nClient: Simulating PREMIUM user...")
        var premiumDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: baseDownloader, userRole: .premiumUser)
        
        print("Client (Premium): Attempting to download premium file...")
        premiumDownloader.downloadFile(url: premiumURL) { result in print("Client (Premium - Premium File): Result: \(result)") }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate download
        
        print("\nClient (Premium): Attempting to download admin file...")
        premiumDownloader.downloadFile(url: adminURL) { result in print("Client (Premium - Admin File): Result: \(result)") }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Wait briefly
        
        print("\n--- Example 3: Using Caching Proxy ---")
        let dummyURL2 = URL(string: "https://example.com/file2.jpg")!
        var cachingDownloader: FileDownloader = CachingFileDownloaderProxy(wrapping: baseDownloader) // Wrap the real downloader
        
        print("\nClient (Caching): First download attempt for file2.jpg...")
        cachingDownloader.downloadFile(url: dummyURL2) { result in
            print("Client (Caching - 1st attempt): Result: \(result)")
        }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3)) // Simulate download & caching
        
        print("\nClient (Caching): Second download attempt for file2.jpg...")
        cachingDownloader.downloadFile(url: dummyURL2) { result in
            print("Client (Caching - 2nd attempt): Result: \(result)") // Should hit cache
        }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Should be fast
        
        
        print("\n--- Example 4: Chaining Proxies ---")
        // Real -> Virtual -> Caching -> Protection
        // Order matters! Protection check should likely happen first.
        // Let's do: Protection -> Caching -> Virtual -> Real (if needed)
        
        let baseVirtualDownloader = VirtualFileDownloaderProxy() // Start with lazy loading
        let cachingLayer = CachingFileDownloaderProxy(wrapping: baseVirtualDownloader)
        let finalDownloader: FileDownloader = ProtectionFileDownloaderProxy(wrapping: cachingLayer, userRole: .administrator) // Admin user
        
        let complexURL = URL(string: "https://example.com/admin_files/complex_report.pdf")!
        
        print("\nClient (Chained): First download attempt (Admin User)...")
        finalDownloader.downloadFile(url: complexURL) { result in
            print("Client (Chained - 1st attempt): Result: \(result)")
            // Expected flow: Protection (OK) -> Caching (Miss) -> Virtual (Creates Real) -> Real (Downloads) -> Virtual (Returns) -> Caching (Caches) -> Protection (Returns)
        }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 4)) // Allow time for full flow
        
        print("\nClient (Chained): Second download attempt (Admin User)...")
        finalDownloader.downloadFile(url: complexURL) { result in
            print("Client (Chained - 2nd attempt): Result: \(result)")
            // Expected flow: Protection (OK) -> Caching (Hit) -> Protection (Returns)
        }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1)) // Should be fast due to cache
        
        print("\n--- End of Demonstrations ---")
        
    }
}
