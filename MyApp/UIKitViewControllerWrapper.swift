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
        
        // Demonstrate Non-Escaping Closures
        demonstrateNonEscapingClosure()
        
        // Demonstrate Escaping Closures
        demonstrateEscapingClosure()
        
        // Demonstrate Autoclosures
        demonstrateAutoclosure()
        
        // Demonstrate Combined Autoclosure and Escaping
        demonstrateCombinedAutoclosureAndEscaping()
    }
    
    // MARK: - Non-Escaping Closures
    
    func demonstrateNonEscapingClosure() {
        print("Non-Escaping Closure Example:")
        
        // As Parameters
        performOperation {
            print("This is a non-escaping closure (as parameter)")
        }
        
        // As Statements
        let closure: () -> Void = {
            print("Executing non-escaping closure (as statement)")
        }
        closure()
    }
    
    func performOperation(closure: () -> Void) {
        closure() // Executed within the function
    }
    
    // MARK: - Escaping Closures
    
    func demonstrateEscapingClosure() {
        print("\nEscaping Closure Example:")
        
        // As Parameters
        performAsyncOperation {
            print("This is an escaping closure (as parameter)")
        }
        
        // As Return Types
        let returnedClosure = makeEscapingClosure()
        //TODO: REVIEW: The closure acts as Return type should be executed here
        returnedClosure() // Executed later
        
        // As Statements
        storeClosure {
            print("Stored escaping closure (as statement)")
        }
        
        for closure in escapingClosures {
            //TODO: REVIEW: The stored closure act as statements are executed here
            closure() // Executed later
        }
    }
    
    func performAsyncOperation(closure: @escaping () -> Void) {
        // Escaping closure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            closure() // Executed after the function returns
        }
    }
    
    func makeEscapingClosure() -> (() -> Void) {
        return {
            print("This is a returned escaping closure")
        }
    }
    
    var escapingClosures: [() -> Void] = [] // An array `escapingClosures` is defined to store closures.
    
    func storeClosure(closure: @escaping () -> Void) {
        escapingClosures.append(closure) // The closure is stored in an array for later execution
    }
    
    // MARK: - Autoclosures
    
    func demonstrateAutoclosure() {
        print("\nAutoclosure Example:")
        
        // As Parameters (without @autoclosure)
        logMessageWithoutAutoclosure(message: { "This is a log message (without autoclosure)" })
        
        // As Parameters (with @autoclosure)
        logMessage(message: "This is a log message (autoclosure)")
        
        // As Statements (without @autoclosure)
        let condition: () -> Bool = { return 3 > 2 }
        evaluateConditionWithoutAutoclosure(condition: condition)
        
        // As Statements (with @autoclosure)
        evaluateCondition(3 > 2) // Expression automatically wrapped in a closure
        
        // As Return Types (without @autoclosure)
        let messageClosureWithoutAutoclosure = delayedLogMessageWithoutAutoclosure()
        print("Log (without autoclosure - return type): \(messageClosureWithoutAutoclosure())")
        
        // As Return Types (with @autoclosure)
        let messageClosureWithAutoclosure = delayedLogMessage(message: "This is a delayed log message (autoclosure)")
        print("Log (with autoclosure - return type): \(messageClosureWithAutoclosure())")
    }
    
    func logMessageWithoutAutoclosure(message: () -> String) {
        print("Log (without autoclosure - as parameters): \(message())")
    }
    
    func logMessage(message: @autoclosure () -> String) {
        print("Log (with autoclosure - as parameters): \(message())")
    }
    
    func evaluateConditionWithoutAutoclosure(condition: () -> Bool) {
        if condition() {
            print("Condition is true (without autoclosure - as statements)")
        }
    }
    
    func evaluateCondition(_ condition: @autoclosure () -> Bool) {
        if condition() {
            print("Condition is true (autoclosure - as statements)")
        }
    }
    
    // As Return Types (without @autoclosure)
    func delayedLogMessageWithoutAutoclosure() -> () -> String {
        return { "This is a delayed log message (without autoclosure)" }
    }
    
    // As Return Types (with @autoclosure)
    func delayedLogMessage(message: @autoclosure @escaping () -> String) -> () -> String {
        return message // Return the autoclosure directly
    }
    
    // MARK: - Combined Autoclosure and Escaping
    
    func demonstrateCombinedAutoclosureAndEscaping() {
        print("\nCombined Autoclosure and Escaping Example:")
        
        storeCombinedClosure(print("This is a stored autoclosure and escaping"))
        
        for closure in combinedClosures {
            closure()
        }
    }
    
    var combinedClosures: [() -> Void] = []
    
    func storeCombinedClosure(_ closure: @autoclosure @escaping () -> Void) {
        combinedClosures.append(closure)
    }
}
