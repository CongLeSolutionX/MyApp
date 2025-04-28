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
        
        //runSimpleFactoryDemo()
        //runFactoryMethodPatternDemo()
        runAbstractFactoryPatternPatternDemo()
    }
    
    func runSimpleFactoryDemo() {
        
        // Client Code
        let success = AlertFactory.createAlert(type: .success)
        success.show(title: "Operation Complete", message: "Data saved successfully.")

        let error = AlertFactory.createAlert(type: .error)
        error.show(title: "Operation Failed", message: "Network connection lost.")

    }
    
    func runFactoryMethodPatternDemo() {
        // Client Code
        let consoleCreator: LoggerFactory = ConsoleLoggerFactory()
        consoleCreator.logProcess(action: "User Login") // Uses ConsoleLogger

        let fileCreator: LoggerFactory = FileLoggerFactory(logFilePath: "debug.log")
        fileCreator.logProcess(action: "Data Sync") // Uses FileLogger
        
    }
    
    func runAbstractFactoryPatternPatternDemo() {
        
        // Usage
        print("--- Using Light Theme ---")
        let lightFactory = LightThemeFactory()
        let lightSettings = SettingsScreen(factory: lightFactory)
        lightSettings.displayUI()

        print("\n--- Using Dark Theme ---")
        let darkFactory = DarkThemeFactory()
        let darkSettings = SettingsScreen(factory: darkFactory)
        darkSettings.displayUI()

    }
}
