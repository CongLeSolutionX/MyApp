//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit
import CoreData

//// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = DeadlockExampleViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> DeadlockExampleViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return DeadlockExampleViewController()
    }
    
    func updateUIViewController(_ uiViewController: DeadlockExampleViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class DeadlockExampleViewController: UIViewController {
    var persistentContainer: NSPersistentContainer? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
       
       var lockA = NSObject()
       var lockB = NSObject()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        
        // Load persistent store
        persistentContainer?.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        // Simulating UI action that triggers deadlock scenario
        simulateUserAction()
    }

    func simulateUserAction() {
        // Task 1: Database update on a background queue
        let backgroundQueue = DispatchQueue(label: "backgroundQueue")
        backgroundQueue.async {
            print("Background: Waiting to lock A")
            objc_sync_enter(self.lockA)
            print("Background: Locked A")

            // Simulate work with a delay
            Thread.sleep(forTimeInterval: 1)

            print("Background: Waiting to lock B")
            objc_sync_enter(self.lockB)
            print("Background: Locked B")

            // Here, normally a database update would occur
            self.updateDatabase()

            objc_sync_exit(self.lockB)
            objc_sync_exit(self.lockA)

            print("Background: Released locks A and B")
        }

        // Task 2: UI update on main queue
        DispatchQueue.main.async {
            print("Main: Waiting to lock B")
            objc_sync_enter(self.lockB)
            print("Main: Locked B")

            // Simulate UI update after a delay
            Thread.sleep(forTimeInterval: 1)

            print("Main: Waiting to lock A")
            objc_sync_enter(self.lockA)
            print("Main: Locked A")

            // Normally, update UI with the results
            self.updateUI()

            objc_sync_exit(self.lockA)
            objc_sync_exit(self.lockB)

            print("Main: Released locks B and A")
        }
    }

    func updateDatabase() {
        // Dummy function to mimic a database update
        print("Updating database...")
    }

    func updateUI() {
        // Dummy function to mimic UI updates
        print("Updating UI...")
    }
}
