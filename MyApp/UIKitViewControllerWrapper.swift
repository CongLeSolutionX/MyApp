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
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "PLACEHOLDER_TEXT"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the initial image for the imageView within viewDidLoad
        imageView.image = image
        
        view.addSubview(imageView)
        
        // Set up constraints for imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),    // Center horizontally
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),     // Center vertically
            imageView.widthAnchor.constraint(equalToConstant: 200),             // Set width
            imageView.heightAnchor.constraint(equalToConstant: 200)             // Set height
        ])
        
        
        // Example of calling the closure function
        simpleClosureExample()
    }
    
    
    // MARK: - Threads: The Low-Level Building Blocks (Use with Caution)
    
    func threadExample() {
        Thread {
            // Code to be executed in a separate thread
            print("Code running in a separate thread")
        }.start()
    }
    
    // MARK: - Synchronization Primitives: Ensuring Thread Safety
    
    // MARK: - Closures/Callbacks: The Foundation for Asynchronous Operations
    // TODO: Download image from URL link - Need to create mock server
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
    //TODO: Create a mock server with mock data for testing purposes
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
    
    func loadImage(from imageName: String, completion: @escaping (UIImage?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to load the image directly from the Assets Catalog
            if let image = UIImage(named: imageName) {
                completion(image, nil)
                return
            }
            
            // If not found in Assets, try loading from the bundle (less common)
            if let imagePath = Bundle.main.path(forResource: imageName, ofType: "png") { // Assuming it's a PNG
                let imageURL = URL(fileURLWithPath: imagePath)
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    if let image = UIImage(data: imageData) {
                        completion(image, nil)
                    } else {
                        completion(nil, NSError(domain: "ImageLoadingErrorDomain", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not create image from data"]))
                    }
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "ImageLoadingErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image file not found in bundle: \(imageName)"]))
            }
        }
    }
    
    // MARK: - Grand Central Dispatch (GCD): Structured Concurrency
    
    // MARK: - Queues (aka DispatchQueues): The Core Concept
    
    // MARK: - Serial Queues: The Orderly Line
    
    let databaseSerialQueue = DispatchQueue(label: "com.example.databaseSerialQueue")
    
    func serialQueueExample() {
        databaseSerialQueue.async {
            // Task 1: Access and modify shared resource
            self.updateDatabase()
        }
        
        databaseSerialQueue.async {
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
    
    // MARK: - Built-in Queues: System-Provided Options
    
    // MARK: - Main Queue: UI and Event Handling
    
    func updateUIExample() {
        DispatchQueue.main.async {
            // Update UI elements
            self.label.text = "New Title"
            self.imageView.image = UIImage(named: "newImage")
        }
    }
    
    // MARK: - Global Queues: System-Provided Concurrent Queues
    
    func globalQueueExample() {
        DispatchQueue.global(qos: .background).async {
            // Perform background task
            // ... (Perform time-consuming operation)
            DispatchQueue.main.async {
                // ... (Update UI)
            }
        }
    }
    
    // MARK: - Custom Queues: Tailored for Your Needs
    
    
    // MARK: - Fine-Tuning Concurrency with GCD: Advanced Mechanisms
    
    // MARK: - Dispatch Work Items (DispatchWorkItem): Encapsulating Tasks
    
    func dispatchWorkItemExample() {
        let workItem = DispatchWorkItem(qos: .default) {
            // Perform some work
            print("Dispatch Work Item executing")
        }
        concurrentQueue.async(execute: workItem)
        // workItem.cancel() // You can cancel if needed
    }
    
    // MARK: - QoS (Quality of Service): Prioritizing for Performance
    
    func qosExample() {
        let backgroundQueue = DispatchQueue(label: "com.example.backgroundQueue", qos: .background)
        backgroundQueue.async {
            print("Background task executing")
        }
    }
    
    // MARK: - Barriers: Synchronization within Concurrent Queues

    func barrierExample() {
        concurrentQueue.async {
            self.writeDataToDisk() // Task 1: Write data to a file
        }
        
        concurrentQueue.async(flags: .barrier) {
            // Barrier: Ensure all writing is complete before proceeding
            print("Barrier reached - writing complete")
        }
        
        concurrentQueue.async {
            self.readDataFromDisk() // Task 2: Read data (after barrier)
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
    
    // MARK: - Dispatch Sources: Reacting to System Events
    
    func dispatchSourceExample() {
        let timerSource = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timerSource.schedule(deadline: .now() + 5, repeating: .seconds(1))
        timerSource.setEventHandler {
            // Code to be executed when the timer fires
            print("Timer fired!")
        }
        timerSource.resume()
    }
    
    // MARK: - Dispatch Semaphores: Resource Access Control
    
    let semaphore = DispatchSemaphore(value: 2) // Allow 2 concurrent accesses

    func accessSharedResource() {
        semaphore.wait() // Acquire the semaphore (decrements the counter)

        defer {
            semaphore.signal() // Release the semaphore (increments the counter)
        }

        // Access and use the shared resource here
        print("Accessing shared resource")
    }

    func dispatchSemaphoreExample() {
        concurrentQueue.async {
            self.accessSharedResource()
        }
        concurrentQueue.async {
            self.accessSharedResource()
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
}
