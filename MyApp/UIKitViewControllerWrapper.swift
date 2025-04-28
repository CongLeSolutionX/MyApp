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
        
        runMVP_ComprehensiveDemo()
    }
    
    func runMVP_ComprehensiveDemo() {
        
        print("\n--- Running Simulation ---")

        // 1. Create an instance of our simulated View Controller
        let viewController = UserViewControllerSimulator()

        // 2. Simulate the `viewDidLoad` lifecycle event. This triggers presenter creation and the initial data load.
        viewController.simulateViewDidLoad()

        // Note: The fetchUser is async, so the following simulation might run before the first fetch completes.
        // We need to keep the playground/script running to see the async results.

        // 3. Simulate the user tapping the refresh button after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            viewController.simulateRefreshButtonTap()
        }

        // Keep the execution context alive long enough for async operations to complete
        // In a Playground, this happens automatically. For command-line, you might need RunLoop handling.
        print("\n--- Simulation Triggered (Waiting for Async Results) ---")
        // In a real app, the RunLoop keeps the app alive. For simple scripts/playgrounds:
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil { // Basic check if not running in Test context
            // Keep alive for a few seconds to see async results in basic scripts
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
            print("\n--- Simulation End ---")
        }

    }
}
