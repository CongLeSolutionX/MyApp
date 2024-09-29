//
//  UIKitViewWrapper.swift
//  MyApp
//
//  Created by Cong Le on 9/28/24.
//

import UIKit
import SwiftUI

struct UIKitViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        DispatchQueue.main.async { // Important: Dispatch to avoid UIKit on main thread warning
            startDeadlockSimulation(on: view)
        }
        return view
    }

    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed in this example
    }
    
    private func startDeadlockSimulation(on view: UIView) {
        let queue1 = DispatchQueue(label: "com.example.queue1")
        let queue2 = DispatchQueue(label: "com.example.queue2")
        let semaphore = DispatchSemaphore(value: 1)
        
        queue1.async {
            print("Queue 1: Starting work")
            semaphore.wait()
            
            print("Queue 1: Doing some work...")
            usleep(1_000_000)
            
            // Avoid the deadlock by using async on queue2
            queue2.async { // Now asynchronous!
                print("Queue 1: Accessing Queue 2")
                semaphore.signal()
                print("Queue 1: Work finished")
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    view.backgroundColor = .green // Turn the view green
                }
            }
        }
        
        queue2.async {
            print("Queue 2: Starting work")
            semaphore.wait()
            
            // Also use async for queue1 access
            queue1.async { // Now asynchronous!
                print("Queue 2: Accessing Queue 1")
                semaphore.signal()
                print("Queue 2: Work finished")
            }
        }
    }
    
}
