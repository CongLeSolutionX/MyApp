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
        
        runDesignPatternDemo()
    }
    
    func runDesignPatternDemo() {
        
        // Usage:
        // Access the single instance from anywhere
        let settings = SettingsManager.shared
        settings.username = "iOSDev"
        settings.setVolumeLevel(0.8)
        SettingsManager.shared.saveSettings() // Or call save explicitly later

        let currentVolume = SettingsManager.shared.getVolumeLevel()
        print("Current volume retrieved: \(currentVolume)")

        // Attempting to create a new instance fails:
        // let anotherSettings = SettingsManager() // Error: 'SettingsManager' initializer is inaccessible due to 'private' protection level

    }
}
