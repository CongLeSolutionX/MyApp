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
    typealias UIViewControllerType = ConcurrencyViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> ConcurrencyViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return ConcurrencyViewController()
    }
    
    func updateUIViewController(_ uiViewController: ConcurrencyViewController, context: Context) {
        // Update the view controller if needed
    }
}

// MARK: - Classic Concurrency in Swift

class ConcurrencyViewController: UIViewController {
    
    var image = UIImage(systemName: "house")
     lazy var imageView: UIImageView = {
         let imageView = UIImageView() // Initialize without setting the image initially
         imageView.image = image
         imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
     }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the initial image for the imageView within viewDidLoad
        imageView.image = image
        
        view.addSubview(imageView)
        
        // Set up constraints for imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center horizontally
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor), // Center vertically
            imageView.widthAnchor.constraint(equalToConstant: 200),        // Set width
            imageView.heightAnchor.constraint(equalToConstant: 200)       // Set height
        ])
        
        
        // Example of calling the closure function
        simpleClosureExample()
    }
    
    // MARK: - Closures/Callbacks: The Building Blocks
    
//    func simpleClosureExample() {
//        downloadImage(from: "https://www.example.com/image.jpg") { image, error in
//            if let image = image {
//                // Update UI with the downloaded image on the main queue
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                }
//            } else if let error = error {
//                print("Error downloading image: \(error)")
//            }
//        }
//    }
//    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        // ... (Implementation to download image from URL)
    }
    
    
    func simpleClosureExample() {
        loadImage(from: "Orange_Cloud_round_logo") { image, error in // Pass the image name
            DispatchQueue.main.async { // Always update UI on the main queue
                if let image = image {
                    self.imageView.image = image
                } else if let error = error {
                    print("Error loading image: \(error)")
                    // Handle the error appropriately (e.g., display an error message to the user)
                    self.imageView.image = UIImage(named: "placeholderImage") // Show a placeholder
                }
            }
        }
    }
    
    func loadImage(from imageName: String, completion: @escaping (UIImage?, Error?) -> Void) { // Takes image name
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = UIImage(named: imageName) { // Load from Assets Catalog
                completion(image, nil)
            } else {
                completion(nil, NSError(domain: "ImageLoadingErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image not found in Assets Catalog"]))
            }
        }
    }
    
    // MARK: - Grand Central Dispatch (GCD): Taming the Threads
    
    // MARK: - Queues (aka DispatchQueues): The Core Concept
    
    // MARK: - Serial Queues: The Orderly Line
    
    let serialQueue = DispatchQueue(label: "com.example.serialQueue")
    
    func serialQueueExample() {
        serialQueue.async {
            // Task 1: Access and modify shared resource
            self.updateDatabase()
        }
        
        serialQueue.async {
            // Task 2: Access and modify the same shared resource (guaranteed to run after Task 1)
            self.readFromDatabase()
        }
    }
    
    func updateDatabase() {
        // ... (Implementation to update a database)
        print("Database updated")
    }
    
    func readFromDatabase() {
        // ... (Implementation to read from a database)
        print("Data read from database")
    }
    
    // MARK: - Concurrent Queues: The Multitasking Team
    
    let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)
    
    func concurrentQueueExample() {
        concurrentQueue.async {
            // Task 1: Download image 1
            self.downloadImage(from: "https://www.example.com/image1.jpg") { image, error in
                // ...
            }
        }
        
        concurrentQueue.async {
            // Task 2: Download image 2
            self.downloadImage(from: "https://www.example.com/image2.jpg") { image, error in
                // ...
            }
        }
    }
    
    // MARK: - Fine-Tuning Concurrency with GCD: Beyond the Basics
    
    // MARK: - Barriers: Creating Synchronization Points within Concurrent Queues
    
    func barrierExample() {
        concurrentQueue.async {
            // Task 1: Write data to a file
            self.writeDataToDisk()
        }
        
        concurrentQueue.async(flags: .barrier) {
            // Barrier: Ensure all writing is complete before reading
            print("Barrier reached - writing complete")
        }
        
        concurrentQueue.async {
            // Task 2: Read data from the file (guaranteed to run after the barrier)
            self.readDataFromDisk()
        }
    }
    
    func writeDataToDisk() {
        // ... (Implementation to write data to disk)
        print("Data written to disk")
    }
    
    func readDataFromDisk() {
        // ... (Implementation to read data from disk)
        print("Data read from disk")
    }
    
    // MARK: - DispatchGroup: Coordinating Across Queues
    
    let dispatchGroup = DispatchGroup()
    
    func dispatchGroupExample() {
        dispatchGroup.enter()
        concurrentQueue.async {
            // Task 1: Download image 1
            self.downloadImage(from: "https://www.example.com/image1.jpg") { image, error in
                // ...
                self.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        concurrentQueue.async {
            // Task 2: Download image 2
            self.downloadImage(from: "https://www.example.com/image2.jpg") { image, error in
                // ...
                self.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            // All downloads are complete - update UI on the main queue
            print("All image downloads complete")
            // ... (Update UI with downloaded images)
        }
    }
    
    // MARK: - Operation Queues: Object-Oriented Concurrency
    
    let operationQueue = OperationQueue()
    
    func operationQueueExample() {
        let operation1 = BlockOperation {
            // Task 1: Perform some work
            print("Operation 1 completed")
        }
        
        let operation2 = BlockOperation {
            // Task 2: Perform some work that depends on Operation 1
            print("Operation 2 completed")
        }
        
        // Add a dependency: Operation 2 depends on Operation 1
        operation2.addDependency(operation1)
        
        operationQueue.addOperations([operation1, operation2], waitUntilFinished: false)
    }
    
    // MARK: - Threads: The Low-Level Powerhouse
    
    func threadExample() {
        Thread {
            // Code to be executed in a separate thread
            print("Code running in a separate thread")
        }.start()
    }
}
